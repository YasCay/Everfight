import 'package:everfight/game/game_state.dart';
import 'package:everfight/logic/game_class.dart';
import 'package:everfight/models/boss.dart';
import 'package:everfight/widgets/monster_widget.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' hide Element;

class GameScene extends Component with HasGameReference<RogueliteGame> {
  late SpriteComponent background;
  late Boss boss;
  double timer = 0;

  @override
  Future<void> onLoad() async {
    for (final boss in game.bosses) {
      boss.resetHealth();
    }

    boss = game.bosses[game.currentBossIndex];
    boss.addListener(refreshBossUI);
    await _loadBackground();

    game.playerTeam.addListener(refreshTeamUI);

    if (game.playerTeam.team.isEmpty) {
      game.state = GameState.selecting;
      game.showMonsterSelection();
    }

    add(TextComponent(
      text: 'Boss: ${boss.name}',
      textRenderer: TextPaint(style: const TextStyle(fontSize: 20, color: Colors.white)),
      position: Vector2(20, 10),
    ));

    _renderTeam();
    _renderBoss();
  }

  Future<void> _loadBackground() async {
    background = SpriteComponent()
      ..sprite = await Sprite.load(boss.backgroundPath)
      ..size = game.size
      ..position = Vector2.zero();

    add(background);
  }

  @override
  void onRemove() {
    game.playerTeam.removeListener(refreshTeamUI);
    boss.removeListener(refreshBossUI);
    super.onRemove();
  }

  void _renderTeam() {
    double offsetY = 60;
    for (final m in game.playerTeam.team) {
      add(MonsterWidget(monster: m, position: Vector2(20, offsetY)));
      offsetY += 100;
    }

    // add(MonsterWidget(monster: boss, position: Vector2(game.size.x - 120, game.size.y / 2 - 40)));
  }

  void _renderBoss() {
    add(BossWidget(boss: boss, position: Vector2(game.size.x - 120, game.size.y / 2 - 40)));
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (game.state == GameState.inMenues) {
      return;
    }

    timer += dt;
    if (timer > 1.0) {
      // _renderTeam();
      // _renderBoss();
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
    final totalDamage = game.playerTeam.team.map((m) => m.baseAttack).fold(0, (a, b) => a + b);
    boss.takeDamage(totalDamage);
    if (boss.health <= 0) {
      _onVictory();
      return;
    }

    // Boss retaliates randomly
    final target = game.playerTeam.team.where((m) => m.health > 0).toList();
    if (target.isNotEmpty) {
      final victim = (target..shuffle()).first;
      victim.takeDamage(boss.attack);
      if (victim.health <= 0) {
        game.playerTeam.remove(victim);
      }
    }

    if (game.playerTeam.team.isEmpty) {
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
      boss.removeListener(refreshBossUI);
      boss = game.bosses[game.currentBossIndex];
      _loadBackground();
      boss.addListener(refreshBossUI);
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

  void refreshTeamUI() {
    removeWhere((c) => c is MonsterWidget);
    _renderTeam();
  }

  void refreshBossUI() {
    removeWhere((c) => c is MonsterWidget && c.monster == boss);
    _renderBoss();
  }
}