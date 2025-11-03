import 'package:everfight/game/game_state.dart';
import 'package:everfight/logic/game_class.dart';
import 'package:everfight/models/boss.dart';
import 'package:everfight/util/size_utils.dart';
import 'package:everfight/widgets/monster_widget.dart';
import 'package:flame/components.dart';

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
    final team = game.playerTeam.team;
    if (team.isEmpty) return;

    var monsterWidth = SizeUtils.scalePercentage(game.size.x, 10);
    var monsterHeight = SizeUtils.scalePercentage(game.size.y, 25);
    if (debugMode) {
      print('Monster widget size: $monsterWidth x $monsterHeight');
    }
    var halfMonsterWidth = monsterWidth / 2;

    final slotOffsets = [
      Vector2(-280 - halfMonsterWidth, -70),
      Vector2(-140 - halfMonsterWidth, -20),
      Vector2(0    - halfMonsterWidth,   0),
      Vector2(140  - halfMonsterWidth, -20),
      Vector2(280  - halfMonsterWidth, -70),
    ];

    final fillOrder = [2, 1, 3, 0, 4];

    final double centerX = game.size.x / 2;
    final double baseY = game.size.y - 20 - monsterHeight;

    for (int i = 0; i < team.length && i < 5; i++) {
      final slotIndex = fillOrder[i];
      final offset = slotOffsets[slotIndex];

      add(MonsterWidget(
        monster: team[i],
        position: Vector2(centerX + offset.x, baseY + offset.y),
        width: monsterWidth,
        height: monsterHeight,
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
    boss.takeDamage(monster.baseAttack);

    if (boss.health <= 0) {
      _onVictory();
    }
  }

  void _bossAttack() {
    final targets = game.playerTeam.team.where((m) => m.health > 0).toList();
    if (targets.isEmpty) {
      _onDefeat();
      return;
    }

    targets.shuffle();
    final victim = targets.first;

    victim.takeDamage(boss.attack);

    if (victim.health <= 0) {
      if (game.playerTeam.team.every((m) => m.health <= 0)) {
        _onDefeat();
      }
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
    removeWhere((c) => c is BossWidget);
    _renderBoss();
  }
}