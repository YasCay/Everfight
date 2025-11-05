import 'package:everfight/game/game_state.dart';
import 'package:everfight/logic/game_class.dart';
import 'package:everfight/models/boss.dart';
import 'package:everfight/util/size_utils.dart';
import 'package:everfight/widgets/monster_widget.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

class GameScene extends Component with HasGameReference<RogueliteGame> {
  late SpriteComponent background;
  late Boss boss;
  double timer = 0;

  List<dynamic> turnQueue = [];
  int currentTurnIndex = 0;

  @override
  Future<void> onLoad() async {
    if (debugMode) {
      print(game.size);
    }
    print("GameScene loaded");
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
    final layouts = game.playerTeam.getMonsterLayouts(game.size);

    for (final layout in layouts) {
      add(MonsterWidget(
        monster: layout.monster,
        position: layout.position,
        width: layout.width,
        height: layout.height,
      ));
    }
  }

  void _renderBoss() {
    var bossWidth = SizeUtils.scalePercentage(game.size.x, 20);
    var bossHeight = SizeUtils.scalePercentage(game.size.y, 35);
    final pos = Vector2(
      game.size.x / 2 - bossWidth / 2,
      20,
    );
    add(BossWidget(boss: boss, position: pos, width: bossWidth, height: bossHeight));
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (game.state == GameState.inMenues) return;
    if (game.state == GameState.selecting) return;

    // Start turn cycle if not already
    if (game.state != GameState.inCombat) {
      _startTurnOrder();
    }

    timer += dt;
    if (timer > 0.5) {
      timer = 0;
      _runNextTurn();
    }
  }

  void _startTurnOrder() {
    game.state = GameState.inCombat;

    final aliveTeam = game.playerTeam.team.where((m) => m.health > 0).toList()..shuffle();

    turnQueue = [...aliveTeam, boss];
    currentTurnIndex = 0;
  }

  void _runNextTurn() {
    if (turnQueue.isEmpty) {
      _startTurnOrder();
      return;
    }

    final entity = turnQueue[currentTurnIndex];

    // Skip dead monsters
    if (entity != boss && entity.health <= 0) {
      currentTurnIndex++;
      if (currentTurnIndex >= turnQueue.length) {
        _startTurnOrder();
      }
      return;
    }

    if (entity == boss) {
      _bossAttack();
    } else {
      _playerAttack(entity);
    }

    currentTurnIndex++;

    if (currentTurnIndex >= turnQueue.length) {
      _startTurnOrder();
    }
  }

  void _playerAttack(monster) {
    final monsterWidget = children.whereType<MonsterWidget>().firstWhere((mw) => mw.monster == monster);
    final bossWidget = children.whereType<BossWidget>().firstWhere((bw) => bw.boss == boss);

    var monsterPos = monsterWidget.position.clone();
    var bossPos = bossWidget.position.clone();

    var monsterCenter = monsterPos + Vector2(monsterWidget.width / 2, monsterWidget.height / 2);
    var bossCenter = bossPos + Vector2(bossWidget.width / 2, bossWidget.height / 2);

    final attackEffect = MoveByEffect(
      Vector2(bossCenter.x - monsterCenter.x, bossCenter.y - monsterCenter.y) * 0.5,
      EffectController(duration: 0.15, reverseDuration: 0.15),
      onComplete: () {
        boss.takeDamage(monster.baseAttack);

        if (boss.health <= 0) {
          _onVictory();
        }
      },
    );

    final hitEffect = ColorEffect(
      Colors.red.withValues(alpha: 0.5),
      EffectController(duration: 0.1, reverseDuration: 0.1),
    );

    monsterWidget.add(attackEffect);
    bossWidget.spriteComponent.add(hitEffect);
  }

  void _bossAttack() {
    final targets = game.playerTeam.team.where((m) => m.health > 0).toList();
    if (targets.isEmpty) {
      _onDefeat();
      return;
    }

    targets.shuffle();
    final victim = targets.first;

    final victimWidget = children.whereType<MonsterWidget>().firstWhere((mw) => mw.monster == victim);
    final bossWidget = children.whereType<BossWidget>().firstWhere((bw) => bw.boss == boss);

    var victimPos = victimWidget.position.clone();
    var bossPos = bossWidget.position.clone();
    var victimCenter = victimPos + Vector2(victimWidget.width / 2, victimWidget.height / 2);
    var bossCenter = bossPos + Vector2(bossWidget.width / 2, bossWidget.height / 2);

    final attackEffect = MoveByEffect(
      Vector2(victimCenter.x - bossCenter.x, victimCenter.y - bossCenter.y) * 0.5,
      EffectController(duration: 0.15, reverseDuration: 0.15),
      onComplete: () {
        victim.takeDamage(boss.attack);

        if (victim.health <= 0) {
          if (game.playerTeam.team.every((m) => m.health <= 0)) {
            _onDefeat();
          }
        }
      },
    );

    final hitEffect = ColorEffect(
      Colors.red.withValues(alpha: 0.5),
      EffectController(duration: 0.1, reverseDuration: 0.1),
    );

    victimWidget.spriteComponent.add(hitEffect);
    bossWidget.add(attackEffect);
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
      _renderBoss();
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
    removeWhere((c) => c is BossWidget);
    _renderBoss();
  }
}