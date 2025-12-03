import 'package:everfight/game/game_phase.dart';
import 'package:everfight/logic/game_class.dart';
import 'package:everfight/logic/statistics_manager.dart';
import 'package:everfight/models/boss.dart';
import 'package:everfight/models/monster.dart';
import 'package:everfight/util/size_utils.dart';
import 'package:everfight/widgets/boss_widget.dart';
import 'package:everfight/widgets/damage_popup_component.dart';
import 'package:everfight/widgets/monster_widget.dart';
import 'package:everfight/widgets/pause_button.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:everfight/util/settings.dart';

class GameScene extends Component with HasGameReference<RogueliteGame> {
  late SpriteComponent background;
  late Boss boss;
  double timer = 0;
  bool isAnimating = false;
  TextComponent? levelText;
  PauseButton? pauseButton;
  final double levelFontSize = 24.0;

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
    
    addPauseButton();
    _createLevelText();

    game.teamManager.addListener(refreshTeamUI);

    await _initRun();
  }

  @override
  void onRemove() {
    game.teamManager.removeListener(refreshTeamUI);
    super.onRemove();
  }

  void addPauseButton() {
    if (pauseButton != null && children.contains(pauseButton)) {
      return;
    }

    var position = Vector2(
      game.size.x - SizeUtils.scalePercentage(game.size.x, 15) - 20,
      20,
    );

    pauseButton = PauseButton(
      onPressed: () {
        game.pauseEngine();
        game.showPauseMenu();
      },
      position: position,
    );
    pauseButton!.priority = 10;

    add(pauseButton!);
  }

  Future<void> _initRun() async {
    var countMonsterWidgets = children.whereType<MonsterWidget>().length;
    if (countMonsterWidgets > 0) {
      if (debugMode) {
        print(
            'GameScene already initialized with $countMonsterWidgets monster widgets, skipping _initRun.');
      }
      return;
    }

    removeAll(children);
    addPauseButton();
    _createLevelText();

    isAnimating = false;
    turnQueue.clear();
    currentTurnIndex = 0;

    if (game.currentLevel != 1 || game.teamManager.team.isNotEmpty) {
      boss = game.bossManager.currentBoss ??
          game.bossManager.generateNextBoss(game.currentLevel);
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

  void _createLevelText() {
    if (children.contains(levelText)) {
      _updateLevelText();
      return;
    }

    final fontSize = levelFontSize;
    final position = Vector2(
      SizeUtils.scalePercentage(game.size.x, 15),
      20,
    );

    levelText = TextComponent(
      text: 'Level ${game.currentLevel}',
      textRenderer: _textPaintForLevel(game.currentLevel, fontSize),
      anchor: Anchor.topRight,
    )
      ..position = position
      ..priority = 100;

    add(levelText!);
  }

  void _updateLevelText() {
    try {
      levelText!.text = 'Level ${game.currentLevel}';
      levelText!.textRenderer =
          _textPaintForLevel(game.currentLevel, levelFontSize);
    } catch (e) {
      if (debugMode) {
        print('Could not update level text: $e');
      }
    }
  }

  TextPaint _textPaintForLevel(int level, double fontSize) {
    final maxLevel = (MAX_BOSS_COUNT <= 0) ? 1 : MAX_BOSS_COUNT;
    final progress = (level / maxLevel).clamp(0.0, 1.0);

    final baseColor = Colors.white;

    final startColor = HSVColor.fromAHSV(1.0, 200, 0.9, 0.9).toColor();
    final endColor = HSVColor.fromAHSV(1.0, 40, 0.95, 1.0).toColor();

    final mainGlow = Color.lerp(startColor, endColor, progress) ?? startColor;

    final glowIntensity = (1.0 + progress * 3.0).clamp(1.0, 4.0);

    final layers = 6;
    final shadows = <Shadow>[];
    for (var i = 0; i < layers; i++) {
      final t = i / (layers - 1);
      final blur = (2.0 + t * 18.0) * glowIntensity;

      final layerBase = 0.3 * (1 - t) + 0.06;
      final opacity = (layerBase * (0.6 + progress * 0.8)).clamp(0.02, 0.95);

      final layerColor = Color.lerp(mainGlow, startColor, (1 - t) * 0.25)!
          .withValues(alpha: opacity);

      shadows.add(
          Shadow(color: layerColor, blurRadius: blur, offset: Offset(0, 0)));
    }

    final textStyle = TextStyle(
      color: baseColor,
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      shadows: shadows,
    );

    return TextPaint(style: textStyle);
  }

  Future<void> _restartRun() async {
    removeAll(children);
    addPauseButton();
    _createLevelText();
    _initRun();
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
    add(BossWidget(
        boss: boss, position: pos, width: bossWidth, height: bossHeight));
  }

  @override
  Future<void> update(double dt) async {
    super.update(dt);

    final phase = game.phaseController.phase;

    if (phase == GamePhase.restarting) {
      await _restartRun();
      return;
    }

    if (phase == GamePhase.selecting) return;
    if (phase == GamePhase.victory) return;
    if (phase == GamePhase.defeat) return;

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
    final aliveTeam = game.teamManager.team.where((m) => m.health > 0).toList()
      ..shuffle();

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
        print(
            'Skipping player attack – missing widgets (monster: ${monsterWidget != null}, boss: ${bossWidget != null})');
      }
      _advanceTurn();
      return;
    }

    isAnimating = true;

    monsterWidget.attack(
      target: bossWidget,
      applyDamage: () {
        StatisticsManager().recordDamageDealt(monster.name, monster.baseAttack);
        bossWidget.takeDamage(monster.baseAttack, (popupPosition) {
          final damagePopup = DamagePopupComponent(
            damage: monster.baseAttack,
            position: popupPosition,
          );
          damagePopup.priority = priority + 1;
          add(damagePopup);
        });
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
        print(
            'Skipping boss attack – missing widgets (monster: ${victimWidget != null}, boss: ${bossWidget != null})');
      }
      _advanceTurn();
      return;
    }

    bossWidget.attack(
      target: victimWidget,
      applyDamage: () {
        StatisticsManager().recordDamageTaken(boss.attack);
        victimWidget.takeDamage(boss.attack, (popupPosition) {
          final damagePopup = DamagePopupComponent(
            damage: boss.attack,
            position: popupPosition,
          );
          damagePopup.priority = priority + 1;
          add(damagePopup);
        });
      },
      onAttackFinished: () {
        isAnimating = false;
        if (victim.health <= 0) {
          victimWidget.defeated();
          StatisticsManager().recordMonsterDeath(victim.name);
          final aliveMonsters =
              game.teamManager.team.where((m) => m.health > 0).toList();
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
    StatisticsManager().recordBossDefeated(boss.element);

    for (final widget in children.whereType<MonsterWidget>()) {
      widget.heal();
    }

    game.phaseController.victory(() {
      boss = game.bossManager.generateNextBoss(game.currentLevel + 1);
      _loadBackground();
      var bossWidget = children.whereType<BossWidget>().first;
      remove(bossWidget);

      _renderBoss();
      _updateLevelText();
    });
  }

  void _onDefeat() {
    game.phaseController.defeat();
  }

  void refreshTeamUI() {
    removeWhere((c) => c is MonsterWidget);
    _renderTeam();
    turnQueue.clear();
    currentTurnIndex = 0;
  }
}
