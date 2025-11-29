import 'package:everfight/game/game_phase.dart';
import 'package:everfight/logic/game_class.dart';
import 'package:everfight/models/boss.dart';
import 'package:everfight/models/monster.dart';
import 'package:everfight/util/size_utils.dart';
import 'package:everfight/widgets/boss_widget.dart';
import 'package:everfight/widgets/monster_widget.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:everfight/util/settings.dart';

class GameScene extends Component with HasGameReference<RogueliteGame> {
  late SpriteComponent background;
  late Boss boss;
  double timer = 0;
  bool isAnimating = false;

  late TextComponent levelText;
  double levelFontSize = 18.0;

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
    // Ensure the run is initialized so we know the current level and background.
    await _initRun();

    // Create and show the level indicator top-left after the scene has been initialized
    // so it is drawn above the background.
    _createLevelText();
  }

  @override
  void onRemove() {
    game.teamManager.removeListener(refreshTeamUI);
    super.onRemove();
  }

  Future<void> _initRun() async {
    game.phaseController.startNewRun();

    boss = game.bossManager.generateNextBoss(game.currentLevel);
    await _loadBackground();

    _renderBoss();
  }

  void _createLevelText() {
  final fontSize = levelFontSize; // reasonable default; scaled sizes can be used if desired
    levelText = TextComponent(
      text: 'Level ${game.currentLevel}',
      textRenderer: _textPaintForLevel(game.currentLevel, fontSize),
      anchor: Anchor.topRight,
    )
      ..position = Vector2(game.size.x - 8, 8)
      ..priority = 100; // ensure it's on top

    add(levelText);
  }

  void _updateLevelText() {
    try {
  levelText.text = 'Level ${game.currentLevel}';
  // refresh renderer to reflect new level glow/color
  levelText.textRenderer = _textPaintForLevel(game.currentLevel, levelFontSize);
    } catch (e) {
      // If levelText isn't ready or an error occurs, ignore silently.
      if (debugMode) {
        print('Could not update level text: $e');
      }
    }
  }

  TextPaint _textPaintForLevel(int level, double fontSize) {
    // Use MAX_BOSS_COUNT to compute progression (0.0 - 1.0). If MAX_BOSS_COUNT is 0 fall back to 1.
    final maxLevel = (MAX_BOSS_COUNT <= 0) ? 1 : MAX_BOSS_COUNT;
    final progress = (level / maxLevel).clamp(0.0, 1.0);

    // Keep the text itself white; the glow will carry the color/gradient.
    final baseColor = Colors.white;

    // Gradient endpoints for the glow (cool -> warm).
    final startColor = HSVColor.fromAHSV(1.0, 200, 0.9, 0.9).toColor(); // blue-cyan
    final endColor = HSVColor.fromAHSV(1.0, 40, 0.95, 1.0).toColor(); // yellow-orange

    // Determine the main glow color by progress along the gradient.
    final mainGlow = Color.lerp(startColor, endColor, progress) ?? startColor;

    // Glow intensity & spread increase with progress.
    final glowIntensity = (1.0 + progress * 3.0).clamp(1.0, 4.0);

    // Create layered shadows to mimic a soft, colored glow. Layers closer to text are brighter
    // and smaller; outer layers are larger and more diffuse.
    final layers = 6;
    final shadows = <Shadow>[];
    for (var i = 0; i < layers; i++) {
      final t = i / (layers - 1);
      final blur = (2.0 + t * 18.0) * glowIntensity;

      // opacity depends on both progress and layer position; inner layers slightly stronger
      final layerBase = 0.3 * (1 - t) + 0.06;
      final opacity = (layerBase * (0.6 + progress * 0.8)).clamp(0.02, 0.95);

      // Mix a bit of the start/end based on layer to create a radial-like gradient
      final layerColor = Color.lerp(mainGlow, startColor, (1 - t) * 0.25)!.withOpacity(opacity);

      shadows.add(Shadow(color: layerColor, blurRadius: blur, offset: Offset(0, 0)));
    }

    final textStyle = TextStyle(
      color: baseColor,
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      shadows: shadows,
    );

    return TextPaint(style: textStyle);
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
    if (timer > 0.2) {
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
      boss = game.bossManager.generateNextBoss(game.currentLevel);
      _loadBackground();
      var bossWidget = children.whereType<BossWidget>().first;
      remove(bossWidget);

      // add new boss widget
      _renderBoss();
      // Update the level label in case the game's level changed
      _updateLevelText();
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
