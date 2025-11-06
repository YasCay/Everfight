import 'dart:math';

import 'package:everfight/models/enums.dart';
import 'package:everfight/models/monster.dart';
import 'package:everfight/util/monster_layout.dart';
import 'package:everfight/util/settings.dart';
import 'package:everfight/util/size_utils.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart' hide Element;

class TeamManager extends ChangeNotifier {
  final Random _random = Random();
  final List<Monster> _team = [];

  List<Monster> get team => List.unmodifiable(_team);

  bool add(Monster m) {
    if (_team.length >= MAX_TEAM_SIZE) return false;
    _team.add(m);
    notifyListeners();
    return true;
  }

  bool replace(int index, Monster newMonster) {
    if (DEBUG_MODE) {
      print("Replacing monster at index $index with ${newMonster.name}");
    }
    if (index < 0 || index >= _team.length) return false;
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
    final allCandidates = [
      Monster(name: 'Basaltor', baseHealth: 90, baseAttack: 10, element: Element.earth, imagePath: 'fakemons/earth/Basaltor_front.png'),
      Monster(name: 'Tidepanzer', baseHealth: 80, baseAttack: 18, element: Element.water, imagePath: 'fakemons/water/Tidepanzer_front.png'),
      Monster(name: 'Ashblade', baseHealth: 70, baseAttack: 20, element: Element.fire, imagePath: 'fakemons/fire/Ashblade_front.png'),
      Monster(name: 'Stormgryph', baseHealth: 70, baseAttack: 20, element: Element.air, imagePath: 'fakemons/air/Stormgryph_front.png'),
    ];

    allCandidates.shuffle(_random);

    // Pick first `count` monsters and scale their stats by player level
    final selected = allCandidates.take(count).map((m) {
      var baseHealth = (m.baseHealth * (1 + 0.1 * (level - 1))).toInt();
      var baseAttack = (m.baseAttack * (1 + 0.1 * (level - 1))).toInt();
      final scaled = Monster(name: m.name, imagePath: m.imagePath, baseHealth: baseHealth, baseAttack: baseAttack, element: m.element);
      return scaled;
    }).toList();

    return selected;
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
}
