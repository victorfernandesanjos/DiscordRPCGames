import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';
import '../models/game_profile.dart';

/// Service to manage Discord Rich Presence using Named Pipes (Windows)
class DiscordRPCService {
  int? _pipeHandle;
  String? _clientId;
  bool _isInitialized = false;
  bool _isConnected = false;
  GameProfile? _currentGame;
  DateTime? _startTime;
  bool _isReconnecting = false;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 3;
  static const Duration _reconnectDelay = Duration(seconds: 2);

  bool get isInitialized => _isInitialized;
  bool get isConnected => _isConnected;
  GameProfile? get currentGame => _currentGame;

  /// Initialize Discord RPC with client ID
  Future<bool> initialize(String clientId) async {
    if (_isInitialized) {
      await shutdown();
    }

    try {
      _clientId = clientId;

      // Try to connect to Discord IPC pipe (try pipes 0-9)
      for (int i = 0; i < 10; i++) {
        try {
          final pipeName = '\\\\.\\pipe\\discord-ipc-$i';
          final pipeNamePtr = pipeName.toNativeUtf16();

          // Try to open the named pipe
          final handle = CreateFile(
            pipeNamePtr,
            GENERIC_READ | GENERIC_WRITE,
            0,
            nullptr,
            OPEN_EXISTING,
            0,
            NULL,
          );

          calloc.free(pipeNamePtr);

          if (handle != INVALID_HANDLE_VALUE) {
            _pipeHandle = handle;

            // Send handshake
            await _sendHandshake();
            
            // Small delay to let handshake process
            await Future.delayed(const Duration(milliseconds: 100));

            _isInitialized = true;
            _isConnected = true;
            
            // Only reset reconnect attempts if we're not in a reconnect loop
            if (!_isReconnecting) {
              _reconnectAttempts = 0;
            }

            print('Connected to Discord via pipe $i');
            return true;
          }
        } catch (e) {
          // Try next pipe
          continue;
        }
      }

      throw Exception(
        'Could not connect to Discord. Make sure Discord is running.',
      );
    } catch (e) {
      print('Failed to initialize Discord RPC: $e');
      _isInitialized = false;
      _isConnected = false;
      return false;
    }
  }

  /// Send handshake to Discord
  Future<void> _sendHandshake() async {
    final handshake = {'v': 1, 'client_id': _clientId};
    await _send(0, handshake);
  }

  /// Send data to Discord pipe
  Future<void> _send(int opcode, Map<String, dynamic> data) async {
    if (_pipeHandle == null) return;

    try {
      final payload = utf8.encode(json.encode(data));
      final length = payload.length;

      // Create buffer: opcode (4 bytes) + length (4 bytes) + payload
      final buffer = Uint8List(8 + length);
      final byteData = ByteData.sublistView(buffer);

      // Write opcode and length as little-endian
      byteData.setUint32(0, opcode, Endian.little);
      byteData.setUint32(4, length, Endian.little);

      // Write payload
      buffer.setRange(8, 8 + length, payload);

      // Write to pipe using Win32 API
      final bufferPtr = calloc<Uint8>(buffer.length);
      for (var i = 0; i < buffer.length; i++) {
        bufferPtr[i] = buffer[i];
      }

      final bytesWritten = calloc<DWORD>();

      final success = WriteFile(
        _pipeHandle!,
        bufferPtr,
        buffer.length,
        bytesWritten,
        nullptr,
      );

      calloc.free(bufferPtr);
      calloc.free(bytesWritten);

      if (success == FALSE) {
        throw Exception('Failed to write to pipe');
      }
    } catch (e) {
      print('Error sending to Discord: $e');
      _isConnected = false;
      
      // Attempt to reconnect
      if (!_isReconnecting && _reconnectAttempts < _maxReconnectAttempts) {
        _attemptReconnect();
      }
    }
  }
  
  /// Attempt to reconnect to Discord
  Future<void> _attemptReconnect() async {
    if (_isReconnecting || _clientId == null || _reconnectAttempts >= _maxReconnectAttempts) return;
    
    _isReconnecting = true;
    _reconnectAttempts++;
    
    print('Attempting to reconnect to Discord (attempt $_reconnectAttempts/$_maxReconnectAttempts)...');
    
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_reconnectDelay, () async {
      try {
        // Close old handle if it exists
        if (_pipeHandle != null) {
          try {
            CloseHandle(_pipeHandle!);
          } catch (e) {
            // Ignore close errors
          }
          _pipeHandle = null;
        }
        
        _isInitialized = false;
        _isConnected = false;
        
        // Try to reconnect
        final success = await initialize(_clientId!);
        
        if (success) {
          print('Successfully reconnected to Discord!');
          
          // Wait a bit before restoring presence
          await Future.delayed(const Duration(milliseconds: 500));
          
          // Restore previous presence if there was one
          if (_currentGame != null && _isConnected) {
            await updatePresence(_currentGame!);
          }
        } else {
          print('Reconnection failed - attempt $_reconnectAttempts/$_maxReconnectAttempts');
          if (_reconnectAttempts >= _maxReconnectAttempts) {
            print('Max reconnection attempts reached. Please restart monitoring.');
          }
        }
      } catch (e) {
        print('Reconnection error: $e');
      } finally {
        _isReconnecting = false;
      }
    });
  }

  /// Update presence with game information
  Future<void> updatePresence(GameProfile game) async {
    if (!_isInitialized || _pipeHandle == null) {
      print('Discord RPC not initialized');
      
      // Try to reconnect if we have a client ID
      if (_clientId != null && !_isReconnecting) {
        _attemptReconnect();
      }
      return;
    }

    try {
      _currentGame = game;
      _startTime ??= DateTime.now();

      final presence = <String, dynamic>{
        'details': game.details ?? 'Playing ${game.displayName}',
      };

      if (game.state != null) {
        presence['state'] = game.state;
      }

      // Add assets (images)
      final assets = <String, dynamic>{};
      if (game.largeImageKey != null || game.iconUrl != null) {
        assets['large_image'] = game.largeImageKey ?? game.iconUrl;
        assets['large_text'] = game.largeImageText ?? game.displayName;
      }
      if (game.smallImageKey != null) {
        assets['small_image'] = game.smallImageKey;
        assets['small_text'] = game.smallImageText;
      }
      if (assets.isNotEmpty) {
        presence['assets'] = assets;
      }

      // Add timestamp
      presence['timestamps'] = {
        'start': _startTime!.millisecondsSinceEpoch ~/ 1000,
      };

      final command = {
        'cmd': 'SET_ACTIVITY',
        'args': {'pid': pid, 'activity': presence},
        'nonce': DateTime.now().millisecondsSinceEpoch.toString(),
      };

      await _send(1, command);
    } catch (e) {
      print('Failed to update Discord presence: $e');
      _isConnected = false;
    }
  }

  /// Clear the current presence
  Future<void> clearPresence() async {
    if (!_isInitialized || _pipeHandle == null) {
      return;
    }

    try {
      final command = {
        'cmd': 'SET_ACTIVITY',
        'args': {'pid': pid},
        'nonce': DateTime.now().millisecondsSinceEpoch.toString(),
      };

      await _send(1, command);
      _currentGame = null;
      _startTime = null;
    } catch (e) {
      print('Failed to clear Discord presence: $e');
    }
  }

  /// Shutdown Discord RPC
  Future<void> shutdown() async {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _reconnectAttempts = 0;
    _isReconnecting = false;
    
    if (_pipeHandle != null) {
      try {
        await clearPresence();
        CloseHandle(_pipeHandle!);
      } catch (e) {
        print('Error during shutdown: $e');
      }
      _pipeHandle = null;
    }
    _isInitialized = false;
    _isConnected = false;
    _currentGame = null;
    _startTime = null;
  }

  /// Dispose resources
  void dispose() {
    shutdown();
  }
}
