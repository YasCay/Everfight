import 'package:everfight/game/game_state.dart';
import 'package:everfight/main.dart';
import 'package:everfight/models/monster.dart';
import 'package:everfight/widgets/monster_widget.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' hide Element;

class GameScene extends Component with HasGameReference<RogueliteGame> {
  late Monster boss;
  late List<Monster> team = game.playerTeam;
  double timer = 0;

  @override
  Future<void> onLoad() async {
    if (game.playerTeam.isEmpty) {
      game.state = GameState.selecting;
      game.showMonsterSelection();
    }

    for (final boss in game.bosses) {
      boss.resetHealth();
    }

    boss = game.bosses[game.currentBossIndex];

    add(TextComponent(
      text: 'Boss: ${boss.name}',
      textRenderer: TextPaint(style: const TextStyle(fontSize: 20, color: Colors.white)),
      position: Vector2(20, 10),
    ));

    _renderTeam();
  }

  void _renderTeam() {
    double offsetY = 60;
    for (final m in team) {
      add(MonsterWidget(monster: m, position: Vector2(20, offsetY)));
      offsetY += 100;
    }

    add(MonsterWidget(monster: boss, position: Vector2(game.size.x - 120, game.size.y / 2 - 40)));
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (game.state == GameState.inMenues) {
      return;
    }

    timer += dt;
    if (timer > 1.0) {
      _renderTeam();
      timer = 0;
      if (game.state != GameState.selecting) {
        _doCombatRound();
      }
    }
  }

  void _doCombatRound() {
    if (game.state != GameState.inCombat) {
      game.state = GameState.inCombat;
    }

    // Player attacks boss
    final totalDamage = team.map((m) => m.baseAttack).fold(0, (a, b) => a + b);
    boss.health -= totalDamage;
    if (boss.health <= 0) {
      _onVictory();
      return;
    }

    // Boss retaliates randomly
    final target = team.where((m) => m.health > 0).toList();
    if (target.isNotEmpty) {
      final victim = (target..shuffle()).first;
      victim.health -= boss.baseAttack;
      if (victim.health <= 0) {
        team.remove(victim);
      }
    }

    if (team.isEmpty) {
      _onDefeat();
    }
  }

  void _onVictory() {
    game.state = GameState.victory;
    game.currentBossIndex++;

    game.healTeam();

    if (game.currentBossIndex >= game.bosses.length) {
      game.router.pushReplacementNamed('menu');
      game.state = GameState.inMenues;
    } else {
      // Show reward overlay and set next boss
      boss = game.bosses[game.currentBossIndex];
      game.state = GameState.selecting;
      game.showMonsterSelection();
    }
  }

  void _onDefeat() {
    game.state = GameState.defeat;
    game.currentBossIndex = 0;
    game.playerTeam.clear();
    game.router.pushReplacementNamed('menu');
    game.state = GameState.inMenues;
  }
}