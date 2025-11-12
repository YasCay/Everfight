import 'dart:convert';
import 'package:everfight/models/game_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const _gameStateKey = 'game_state';

  /// Save the current state to local storage
  static Future<void> saveState(GameState state) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(state.toJson());
    await prefs.setString(_gameStateKey, jsonString);
  }

  /// Load the state from local storage, or return a default state
  static Future<GameState> loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_gameStateKey);

    if (jsonString != null) {
      try {
        final jsonData = jsonDecode(jsonString);
        return GameState.fromJson(jsonData);
      } catch (e) {
        print('Error loading game state: $e');
      }
    }

    return GameState(); // default empty state
  }

  /// Clear saved state
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_gameStateKey);
  }
}
