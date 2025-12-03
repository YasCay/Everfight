import 'dart:convert';
import 'package:everfight/logic/game_class.dart';
import 'package:everfight/logic/unlock_manager.dart';
import 'package:everfight/models/achievement.dart';
import 'package:everfight/models/achievement_condition.dart';
import 'package:everfight/models/enums.dart';
import 'package:everfight/models/statistics.dart';
import 'package:everfight/models/unlockable_action.dart';
import 'package:everfight/util/local_storage.dart';
import 'package:everfight/util/settings.dart';
import 'package:flutter/services.dart';

class AchievementManager {
  late List<Achievement> achievements;
  final Set<String> unlockedIds = {};
  late RogueliteGame game;

  // Singleton
  static final AchievementManager _instance = AchievementManager._internal();
  factory AchievementManager() => _instance;
  AchievementManager._internal();

  Future<void> init(RogueliteGame game) async {
    this.game = game;

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
      case '>=':
        return value >= cond.value;
      case '>':
        return value > cond.value;
      case '==':
        return value == cond.value;
      case '<=':
        return value <= cond.value;
      case '<':
        return value < cond.value;
      default:
        return false;
    }
  }

  dynamic _getStatValue(String path, Statistics s) {
    if (path.startsWith('bossesDefeatedByElementRun.')) {
      final elementName = path.split('.')[1];
      final element = Element.values.firstWhere(
        (e) => e.toString().split('.').last == elementName,
      );
      return s.bossesDefeatedByElementRun[element] ?? 0;
    }

    if (path.startsWith('custom.hasTwoTier2.')) {
      final elementName = path.split('.')[2];
      final element = Element.values.firstWhere(
        (e) => e.toString().split('.').last == elementName,
      );

      final count = game.teamManager.team.where(
        (m) => m.tier == 2 && m.element == element,
      ).length;

      int level = game.currentLevel - 1;

      return (count >= 2 && level >= 28) ? 1 : 0;
    }

    if (path.startsWith('custom.hasTier3.')) {
      final elementName = path.split('.')[2];
      final element = Element.values.firstWhere(
        (e) => e.toString().split('.').last == elementName,
      );

      final bosses = s.bossesDefeatedByElement[element] ?? 0;
      final hasTier3 = game.teamManager.team.any((m) => m.tier == 3 && m.element == element);

      return (bosses >= 12 && hasTier3) ? 1 : 0;
    }


    switch (path) {
      case 'runsWon':
        return s.runsWon;
      case 'runsStarted':
        return s.runsStarted;
      case 'highestLevelReached':
        return s.highestLevelReached;
      case 'totalDamageDealt':
        return s.totalDamageDealt;
      case 'totalDamageTaken':
        return s.totalDamageTaken;
      case 'bossesDefeated':
        return s.bossesDefeated;
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
        if (DEBUG_MODE) {
          print("Unlocked tier: $data");
        }
        _unlockTier(data);
        break;
    }
  }

  void _unlockTier(String path) {
    Element element = Element.values.firstWhere(
      (e) => e.toString().split('.').last == path.split('_')[0],
    );
    int tier = int.parse(path.split('_')[1]);

    UnlockManager().unlockNextTier(element, unlockTier: tier);
  }
}
