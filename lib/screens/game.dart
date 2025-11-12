import 'package:everfight/game/game_phase.dart';
import 'package:everfight/logic/game_class.dart';
import 'package:everfight/models/boss.dart';
import 'package:everfight/models/monster.dart';
import 'package:everfight/util/size_utils.dart';
import 'package:everfight/widgets/boss_widget.dart';
import 'package:everfight/widgets/monster_widget.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';

class GameScene extends Component with HasGameReference<RogueliteGame> {
  late SpriteComponent background;
  late Boss boss;
  double timer = 0;
  bool isAnimating = false;

  List<dynamic> turnQueue = [];
  int currentTurnIndex = 0;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    if (debugMode) {
      print("GameScene loaded with size:");
      print(game.size);
    }
  }

  @override
  Future<void> onMount() async {
    super.onMount();

    game.teamManager.addListener(refreshTeamUI);
    _initRun();
  }

  @override
  void onRemove() {
    game.teamManager.removeListener(refreshTeamUI);
    super.onRemove();
  }

  Future<void> _initRun() async {
    if (game.currentLevel != 1 || game.teamManager.team.isNotEmpty) {
      boss = game.bossManager.currentBoss ?? game.bossManager.generateNextBoss(game.currentLevel);
      await _loadBackground();
      _renderTeam();
      _renderBoss();
      
      game.phaseController.onTeamSelected();
      return;
    }

    game.phaseController.startNewRun();

    boss = game.bossManager.generateNextBoss(game.currentLevel);
    await _loadBackground();

    _renderBoss();
  }

  Future<void> _loadBackground() async {
    var image = Flame.images.fromCache(boss.backgroundPath);
    background = SpriteComponent()
      ..sprite = Sprite(image)
      ..size = game.size
      ..position = Vector2.zero();

    add(background);
  }

  void _renderTeam() {
    final layouts = game.teamManager.getMonsterLayouts(game.size);

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
  Future<void> update(double dt) async {
    super.update(dt);

    final phase = game.phaseController.phase;

    if (phase == GamePhase.selecting) return;

    if (phase == GamePhase.idle) {
      _startTurnOrder();
    }

    if (isAnimating) return;

    timer += dt;
    if (timer > 0.5) {
      timer = 0;
      _runNextTurn();
    }
  }

  void _startTurnOrder() {
    game.phaseController.startCombat();
    final aliveTeam = game.teamManager.team.where((m) => m.health > 0).toList()..shuffle();

    turnQueue = [...aliveTeam, boss];
    currentTurnIndex = 0;
  }

  void _runNextTurn() {
    if (turnQueue.isEmpty) {
      _startTurnOrder();
      return;
    }

    final entity = turnQueue[currentTurnIndex];

    if (entity is Monster && entity.health <= 0) {
      _advanceTurn();
      return;
    }

    if (entity == boss) {
      _bossAttack();
    } else if (entity is Monster) {
      _playerAttack(entity);
    } else {
      _advanceTurn();
    }
  }

  void _advanceTurn() {
    currentTurnIndex++;
    if (currentTurnIndex >= turnQueue.length) {
      _startTurnOrder();
    }
  }

  void _playerAttack(Monster monster) {
    final monsterWidget = _findMonsterWidget(monster);
    final bossWidget = _findBossWidget();
    if (monsterWidget == null || bossWidget == null) {
      if (debugMode) {
        print('Skipping player attack – missing widgets (monster: ${monsterWidget != null}, boss: ${bossWidget != null})');
      }
      _advanceTurn();
      return;
    }

    isAnimating = true;

    monsterWidget.attack(
      target: bossWidget,
      applyDamage: () {
        bossWidget.takeDamage(monster.baseAttack);
      },
      onAttackFinished: () {
        isAnimating = false;
        if (boss.health <= 0) {
          _onVictory();
        } else {
          _advanceTurn();
        }
      },
    );
  }

  void _bossAttack() {
    final targets = game.teamManager.team.where((m) => m.health > 0).toList();
    if (targets.isEmpty) {
      _onDefeat();
      return;
    }

    isAnimating = true;
    targets.shuffle();
    final victim = targets.first;

    final victimWidget = _findMonsterWidget(victim);
    final bossWidget = _findBossWidget();

    if (victimWidget == null || bossWidget == null) {
      isAnimating = false;
      if (debugMode) {
        print('Skipping boss attack – missing widgets (monster: ${victimWidget != null}, boss: ${bossWidget != null})');
      }
      _advanceTurn();
      return;
    }

    bossWidget.attack(
      target: victimWidget,
      applyDamage: () {
        victimWidget.takeDamage(boss.attack);
      },
      onAttackFinished: () {
        isAnimating = false;
        if (victim.health <= 0) {
          final aliveMonsters = game.teamManager.team.where((m) => m.health > 0).toList();
          if (aliveMonsters.isEmpty) {
            _onDefeat();
            return;
          }
        }
        _advanceTurn();
      },
    );
  }

  MonsterWidget? _findMonsterWidget(Monster monster) {
    for (final widget in children.whereType<MonsterWidget>()) {
      if (widget.monster == monster) {
        return widget;
      }
    }
    return null;
  }

  BossWidget? _findBossWidget() {
    final iterator = children.whereType<BossWidget>().iterator;
    if (iterator.moveNext()) {
      return iterator.current;
    }
    return null;
  }

  void _onVictory() {
    game.phaseController.victory(() {
      boss = game.bossManager.generateNextBoss(game.currentLevel + 1);
      _loadBackground();
      var bossWidget = children.whereType<BossWidget>().first;
      remove(bossWidget);

      // add new boss widget
      _renderBoss();
    });
  }

  void _onDefeat() {
    game.phaseController.defeat();
  }

  void refreshTeamUI() {
    removeWhere((c) => c is MonsterWidget);
    _renderTeam();
    // reset turn order (workaround --> currently sometimes buggy behavior on replace/skip)
    turnQueue.clear();
    currentTurnIndex = 0;
  }
}
