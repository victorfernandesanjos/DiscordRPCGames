import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_profile.dart';

/// Service to persist game profiles
class StorageService {
  static const String _gamesKey = 'saved_games';
  static const String _clientIdKey = 'discord_client_id';
  static const String _autoStartKey = 'auto_start_monitoring';

  SharedPreferences? _prefs;

  /// Initialize the storage service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Save all game profiles
  Future<bool> saveGames(List<GameProfile> games) async {
    if (_prefs == null) await initialize();

    try {
      final jsonList = games.map((game) => json.encode(game.toJson())).toList();
      return await _prefs!.setStringList(_gamesKey, jsonList);
    } catch (e) {
      print('Error saving games: $e');
      return false;
    }
  }

  /// Load all game profiles
  Future<List<GameProfile>> loadGames() async {
    if (_prefs == null) await initialize();

    try {
      final jsonList = _prefs!.getStringList(_gamesKey) ?? [];
      return jsonList
          .map((jsonStr) => GameProfile.fromJson(json.decode(jsonStr)))
          .toList();
    } catch (e) {
      print('Error loading games: $e');
      return [];
    }
  }

  /// Save Discord client ID
  Future<bool> saveClientId(String clientId) async {
    if (_prefs == null) await initialize();
    return await _prefs!.setString(_clientIdKey, clientId);
  }

  /// Load Discord client ID
  Future<String?> loadClientId() async {
    if (_prefs == null) await initialize();
    return _prefs!.getString(_clientIdKey);
  }

  /// Save auto-start monitoring preference
  Future<bool> saveAutoStart(bool autoStart) async {
    if (_prefs == null) await initialize();
    return await _prefs!.setBool(_autoStartKey, autoStart);
  }

  /// Load auto-start monitoring preference
  Future<bool> loadAutoStart() async {
    if (_prefs == null) await initialize();
    return _prefs!.getBool(_autoStartKey) ?? false;
  }

  /// Clear all data
  Future<bool> clearAll() async {
    if (_prefs == null) await initialize();
    return await _prefs!.clear();
  }
}
