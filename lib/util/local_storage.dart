import 'dart:convert';
import 'package:everfight/models/enums.dart';
import 'package:everfight/models/game_state.dart';
import 'package:everfight/models/statistics.dart';
import 'package:everfight/models/tier_unlocks.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const _gameStateKey = 'game_state';
  static const _tierKey = 'unlocked_tiers';
  static const _statisticsKey = "game_statistics_v1";
  static const _achievementsKey = "unlocked_achievements";

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

  /// Save unlocked tiers
  static Future<void> saveUnlockedTiers(TierUnlocks tiers) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(tiers.toJson());
    await prefs.setString(_tierKey, jsonString);
  }

  /// Load unlocked tiers
  static Future<TierUnlocks> loadUnlockedTiers() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_tierKey); 
    if (jsonString != null) {
      try {
        final jsonData = jsonDecode(jsonString);
        return TierUnlocks.fromJson(jsonData);
      } catch (e) {
        print('Error loading unlocked tiers: $e');
      }
    }
    return TierUnlocks(unlockedTiers: {
      for (var element in Element.values) element: 1, // Default all tiers to 1
    }); // default all tier 1
  }

  /// Save statistics
  static Future<void> saveStatistics(Statistics stats) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(stats.toJson());
    await prefs.setString(_statisticsKey, jsonString);
  }

  /// Load statistics
  static Future<Statistics?> loadStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_statisticsKey);
    if (jsonString != null) {
      try {
        final jsonData = jsonDecode(jsonString);
        return Statistics.fromJson(jsonData);
      } catch (e) {
        print('Error loading statistics: $e');
      }
    }
    return null; // no statistics saved yet
  }

  /// Load unlocked achievements
  static Future<Set<String>> loadUnlockedAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_achievementsKey);
    if (ids != null) {
      return ids.toSet();
    }
    return {};
  }

  /// Save unlocked achievements
  static Future<void> saveUnlockedAchievements(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_achievementsKey, ids.toList());
  }

  /// Clear saved state
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_gameStateKey);
    await prefs.remove(_tierKey);
    await prefs.remove(_statisticsKey);
    await prefs.remove(_achievementsKey);
  }
}
