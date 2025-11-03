import 'package:everfight/models/monster.dart';
import 'package:everfight/util/monster_layout.dart';
import 'package:everfight/util/settings.dart';
import 'package:everfight/util/size_utils.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class TeamManager extends ChangeNotifier {
  final List<Monster> _team = [];

  List<Monster> get team => List.unmodifiable(_team);

  void add(Monster m) {
    _team.add(m);

    m.addListener(notifyListeners);
    notifyListeners();
  }

  void remove(Monster m) {
    m.removeListener(notifyListeners);
    _team.remove(m);
    notifyListeners();
  }

  void clear() {
    for (var m in _team) {
      m.removeListener(notifyListeners);
    }
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
}
