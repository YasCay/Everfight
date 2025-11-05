import 'package:everfight/game/game_phase.dart';
import 'package:everfight/logic/game_class.dart';
import 'package:everfight/models/boss.dart';
import 'package:everfight/util/size_utils.dart';
import 'package:everfight/widgets/boss_widget.dart';
import 'package:everfight/widgets/monster_widget.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';

class GameScene extends Component with HasGameReference<RogueliteGame> {
  late SpriteComponent background;
  late Boss boss;
  double timer = 0;

  List<dynamic> turnQueue = [];
  int currentTurnIndex = 0;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    if (debugMode) {
      print("GameScene loaded with size:");
      print(game.size);
    }
    
    game.teamManager.addListener(refreshTeamUI);

    if (game.teamManager.team.isEmpty) {
      game.phaseController.startNewRun();
    }

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

  @override
  void onRemove() {
    game.teamManager.removeListener(refreshTeamUI);
    super.onRemove();
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
  void update(double dt) {
    super.update(dt);

    final phase = game.phaseController.phase;

    if (phase == GamePhase.inMenues) return;
    if (phase == GamePhase.selecting) return;

    if (phase == GamePhase.idle) {
      _startTurnOrder();
    }

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

    monsterWidget.attack(bossWidget, () {
      if (boss.health <= 0) {
        _onVictory();
      }
    });
  }

  void _bossAttack() {
    final targets = game.teamManager.team.where((m) => m.health > 0).toList();
    if (targets.isEmpty) {
      _onDefeat();
      return;
    }

    targets.shuffle();
    final victim = targets.first;

    final victimWidget = children.whereType<MonsterWidget>().firstWhere((mw) => mw.monster == victim);
    final bossWidget = children.whereType<BossWidget>().firstWhere((bw) => bw.boss == boss);

    bossWidget.attack(victimWidget, () {
      if (victim.health <= 0) {
        // Check for defeat
        final aliveMonsters = game.teamManager.team.where((m) => m.health > 0).toList();
        if (aliveMonsters.isEmpty) {
          _onDefeat();
        }
      }
    });
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
  }
}