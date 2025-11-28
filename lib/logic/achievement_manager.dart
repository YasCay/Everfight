import 'dart:convert';
import 'package:everfight/models/achievement.dart';
import 'package:everfight/models/achievement_condition.dart';
import 'package:everfight/models/enums.dart';
import 'package:everfight/models/statistics.dart';
import 'package:everfight/models/unlockable_action.dart';
import 'package:everfight/util/local_storage.dart';
import 'package:flutter/services.dart';

class AchievementManager {
  late List<Achievement> achievements;
  final Set<String> unlockedIds = {};

  // Singleton
  static final AchievementManager _instance = AchievementManager._internal();
  factory AchievementManager() => _instance;
  AchievementManager._internal();

  Future<void> init() async {
    // Load unlocked IDs
    unlockedIds.addAll(await LocalStorage.loadUnlockedAchievements());

    // Load achievements JSON
    final raw = await rootBundle.loadString('assets/data/achievements.json');
    final jsonList = json.decode(raw) as List;

    achievements = jsonList.map((e) => Achievement.fromJson(e)).toList();

    // Mark as unlocked (saved from prefs)
    for (var a in achievements) {
      if (unlockedIds.contains(a.id)) {
        a.unlocked = true;
      }
    }
  }

  void evaluate(Statistics stats) {
    for (final a in achievements) {
      if (a.unlocked) continue;

      if (_checkCondition(a.condition, stats)) {
        _unlock(a, stats);
      }
    }
  }

  bool _checkCondition(AchievementCondition cond, Statistics stats) {
    final value = _getStatValue(cond.stat, stats);
    if (value == null) return false;

    switch (cond.operator) {
      case '>=': return value >= cond.value;
      case '>':  return value > cond.value;
      case '==': return value == cond.value;
      case '<=': return value <= cond.value;
      case '<':  return value < cond.value;
      default: return false;
    }
  }

  dynamic _getStatValue(String path, Statistics s) {
    switch (path) {
      case 'runsWon': return s.runsWon;
      case 'runsStarted': return s.runsStarted;
      case 'highestLevelReached': return s.highestLevelReached;
      case 'totalDamageDealt': return s.totalDamageDealt;
      case 'totalDamageTaken': return s.totalDamageTaken;
      case 'bossesDefeated': return s.bossesDefeated;
    }

    if (path.startsWith('bossesDefeatedByElement.')) {
      final elementName = path.split('.')[1];
      final element = Element.values.firstWhere(
        (e) => e.toString().split('.').last == elementName,
        orElse: () => Element.fire,
      );
      return s.bossesDefeatedByElement[element] ?? 0;
    }

    if (path.startsWith('monsterPicked.')) {
      final key = path.split('.')[1];
      return s.monsterPicked[key] ?? 0;
    }

    if (path.startsWith('winsWithMonster.')) {
      final key = path.split('.')[1];
      return s.winsWithMonster[key] ?? 0;
    }

    if (path.startsWith('monsterDeaths.')) {
      final key = path.split('.')[1];
      return s.monsterDeaths[key] ?? 0;
    }

    return null;
  }

  void _unlock(Achievement a, Statistics stats) {
    a.unlocked = true;
    unlockedIds.add(a.id);
    LocalStorage.saveUnlockedAchievements(unlockedIds);

    if (a.unlock != null) {
      _applyUnlock(a.unlock!, stats);
    }

    // TODO: fire UI event (popup, sound)
  }

  void _applyUnlock(UnlockableAction action, Statistics stats) {
    switch (action.type) {
      case 'reward':
        _applyReward(action.rewardType, action.data);
        break;
    }
  }

  void _applyReward(String rewardType, dynamic data) {
    switch (rewardType) {
      case 'tier_unlock':
        print("Unlocked tier: $data");
        break;
    }
  }
}
