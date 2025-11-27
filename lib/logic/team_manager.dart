import 'package:everfight/logic/monster_generator.dart';
import 'package:everfight/logic/monster_repository.dart';
import 'package:everfight/logic/statistics_manager.dart';
import 'package:everfight/models/game_state.dart';
import 'package:everfight/models/monster.dart';
import 'package:everfight/util/monster_layout.dart';
import 'package:everfight/util/settings.dart';
import 'package:everfight/util/size_utils.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart' hide Element;

class TeamManager extends ChangeNotifier {
  final List<Monster> _team = [];

  List<Monster> get team => List.unmodifiable(_team);

  bool add(Monster m) {
    if (_team.length >= MAX_TEAM_SIZE) return false;
    StatisticsManager().recordMonsterPicked(m.name);
    _team.add(m);
    notifyListeners();
    return true;
  }

  bool replace(int index, Monster newMonster) {
    if (DEBUG_MODE) {
      print("Replacing monster at index $index with ${newMonster.name}");
    }
    if (index < 0 || index >= _team.length) return false;
    StatisticsManager().recordMonsterPicked(newMonster.name);
    _team[index] = newMonster;
    notifyListeners();
    return true;
  }

  void remove(Monster m) {
    _team.remove(m);
    notifyListeners();
  }

  void clear() {
    _team.clear();
    notifyListeners();
  }

  List<MonsterLayout> getMonsterLayouts(Vector2 gameSize) {
    if (_team.isEmpty) return [];

    var monsterWidth = SizeUtils.scalePercentage(gameSize.x, 10);
    var monsterHeight = SizeUtils.scalePercentage(gameSize.y, 25);
    var halfMonsterWidth = monsterWidth / 2;
    var padding = SizeUtils.scalePercentage(gameSize.x, 5);

    if (DEBUG_MODE) {
      print('Monster widget size: $monsterWidth x $monsterHeight');
    }

    final slotOffsets = [
      Vector2(-(2 * monsterWidth + padding) - halfMonsterWidth, -70),
      Vector2(-(monsterWidth + padding) - halfMonsterWidth, -20),
      Vector2(0 - halfMonsterWidth, 0),
      Vector2((monsterWidth + padding) - halfMonsterWidth, -20),
      Vector2((2 * monsterWidth + padding) - halfMonsterWidth, -70),
    ];

    final fillOrder = [2, 1, 3, 0, 4];
    final double centerX = gameSize.x / 2;
    final double baseY = gameSize.y - 20 - monsterHeight;

    List<MonsterLayout> layouts = [];

    for (int i = 0; i < _team.length && i < 5; i++) {
      final slotIndex = fillOrder[i];
      final offset = slotOffsets[slotIndex];
      layouts.add(MonsterLayout(
        monster: _team[i],
        position: Vector2(centerX + offset.x, baseY + offset.y),
        width: monsterWidth,
        height: monsterHeight,
      ));
    }

    return layouts;
  }

  List<Monster> getRecruitmentCandidates({int level = 1, int count = 3}) {
    var templates = MonsterRepository().templateMap;

    var monsterGenerator = MonsterGenerator(templates: templates);

    return monsterGenerator.generateMonsters(level, count);
  }

  bool get isFull => _team.length >= MAX_TEAM_SIZE;

  bool addOrExchange(Monster candidate, {int? exchangeIndex}) {
    if (!isFull) {
      return add(candidate);
    } else if (exchangeIndex != null && exchangeIndex >= 0 && exchangeIndex < _team.length) {
      replace(exchangeIndex, candidate);
      return true;
    }
    
    return false; // Team full and no valid exchange index provided
  }

  // Notify listeners to rerender team UI (buggy on skip action)
  void rerenderTeam() {
    notifyListeners();
  }

  void loadState(GameState state) {
    _team.clear();
    for (var m in state.team) {
      _team.add(Monster(
        name: m.name,
        baseHealth: m.baseHealth,
        baseAttack: m.baseAttack,
        element: m.element,
        imagePath: m.imagePath,
      ));
    }
    notifyListeners();
  }
}
