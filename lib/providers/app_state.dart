import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/game_profile.dart';
import '../services/discord_rpc_service.dart';
import '../services/process_monitor.dart';
import '../services/storage_service.dart';

/// Main application state manager
class AppState extends ChangeNotifier {
  // Default Discord Application ID (fallback if user doesn't provide their own)
  static const String _defaultClientId = '1434273144645881876';
  
  final StorageService _storage = StorageService();
  final DiscordRPCService _discordRPC = DiscordRPCService();
  final ProcessMonitor _processMonitor = ProcessMonitor();
  final Uuid _uuid = const Uuid();

  List<GameProfile> _games = [];
  String? _clientId;
  bool _isMonitoring = false;
  bool _autoStart = false;
  GameProfile? _currentGame;
  Set<String> _runningProcesses = {};

  // Getters
  List<GameProfile> get games => List.unmodifiable(_games);
  String? get clientId => _clientId;
  String get effectiveClientId => (_clientId == null || _clientId!.isEmpty) ? _defaultClientId : _clientId!;
  bool get isMonitoring => _isMonitoring;
  bool get autoStart => _autoStart;
  GameProfile? get currentGame => _currentGame;
  bool get isDiscordConnected => _discordRPC.isConnected;
  Set<String> get runningProcesses => Set.unmodifiable(_runningProcesses);

  /// Initialize the app state
  Future<void> initialize() async {
    await _storage.initialize();
    _games = await _storage.loadGames();
    final loadedClientId = await _storage.loadClientId();
    
    // Treat empty string as null (use default)
    _clientId = (loadedClientId == null || loadedClientId.isEmpty) ? null : loadedClientId;
    
    _autoStart = await _storage.loadAutoStart();

    // Auto-start monitoring if enabled (uses default client ID if none set)
    if (_autoStart) {
      await startMonitoring();
    }

    notifyListeners();
  }

  /// Set Discord client ID (empty string will use default)
  Future<void> setClientId(String clientId) async {
    _clientId = clientId.isEmpty ? null : clientId;
    await _storage.saveClientId(clientId);

    // Reinitialize Discord if monitoring
    if (_isMonitoring) {
      await stopMonitoring();
      await startMonitoring();
    }

    notifyListeners();
  }

  /// Add a new game profile
  Future<void> addGame(GameProfile game) async {
    _games.add(game);
    await _storage.saveGames(_games);
    notifyListeners();
  }

  /// Update an existing game profile
  Future<void> updateGame(String id, GameProfile updatedGame) async {
    final index = _games.indexWhere((g) => g.id == id);
    if (index != -1) {
      _games[index] = updatedGame;
      await _storage.saveGames(_games);
      notifyListeners();
    }
  }

  /// Delete a game profile
  Future<void> deleteGame(String id) async {
    _games.removeWhere((g) => g.id == id);
    await _storage.saveGames(_games);
    notifyListeners();
  }

  /// Create a new game profile
  GameProfile createGameProfile({
    required String processName,
    required String displayName,
    String? iconUrl,
    String? details,
    String? state,
  }) {
    return GameProfile(
      id: _uuid.v4(),
      processName: processName,
      displayName: displayName,
      iconUrl: iconUrl,
      details: details,
      state: state,
      enabled: true,
    );
  }

  /// Toggle auto-start
  Future<void> toggleAutoStart() async {
    _autoStart = !_autoStart;
    await _storage.saveAutoStart(_autoStart);
    notifyListeners();
  }

  /// Start monitoring processes
  Future<void> startMonitoring() async {
    // Use user's client ID if set, otherwise use default
    final clientIdToUse = effectiveClientId;

    // Initialize Discord RPC
    final success = await _discordRPC.initialize(clientIdToUse);
    if (!success) {
      throw Exception('Failed to connect to Discord');
    }

    // Start process monitoring
    _processMonitor.startMonitoring(_onProcessesUpdated);
    _isMonitoring = true;
    notifyListeners();
  }

  /// Stop monitoring processes
  Future<void> stopMonitoring() async {
    _processMonitor.stopMonitoring();
    await _discordRPC.shutdown();
    _isMonitoring = false;
    _currentGame = null;
    notifyListeners();
  }

  /// Handle process updates
  void _onProcessesUpdated(Set<String> processes) {
    _runningProcesses = processes;

    // Find matching game
    GameProfile? matchedGame;
    for (final game in _games) {
      if (game.enabled && processes.contains(game.processName.toLowerCase())) {
        matchedGame = game;
        break;
      }
    }

    // Update Discord presence if game changed
    if (matchedGame != _currentGame) {
      _currentGame = matchedGame;

      if (matchedGame != null) {
        _discordRPC.updatePresence(matchedGame);
      } else {
        _discordRPC.clearPresence();
      }

      notifyListeners();
    }
  }

  @override
  void dispose() {
    _processMonitor.dispose();
    _discordRPC.dispose();
    super.dispose();
  }
}
