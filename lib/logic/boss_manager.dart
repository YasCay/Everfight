import 'dart:math';
import 'package:everfight/models/game_state.dart';
import 'package:everfight/util/settings.dart';
import 'package:everfight/models/boss.dart';
import 'package:everfight/models/enums.dart';

class BossManager {
  final List<Boss> _availableBosses = [
    Boss(
      name: 'Infernakor',
      baseHealth: 120,
      attack: 2,
      element: Element.fire,
      imagePath: 'boss/fire/Infernakor_front.png',
    ),
    Boss(
      name: 'Tidalion',
      baseHealth: 150,
      attack: 3,
      element: Element.water,
      imagePath: 'boss/water/Tidalion_front.png',
    ),
    Boss(
      name: 'Terragron',
      baseHealth: 180,
      attack: 4,
      element: Element.earth,
      imagePath: 'boss/earth/Terragron_front.png',
    ),
    Boss(
      name: 'Zephyra',
      baseHealth: 180,
      attack: 5,
      element: Element.air,
      imagePath: 'boss/air/Zephyra_front.png',
    ),
  ];

  final Random _random = Random();
  int _currentBossIndex = 0;
  Boss? _currentBoss;

  int get currentIndex => _currentBossIndex;
  Boss? get currentBoss => _currentBoss;
  bool get hasMoreBosses => _currentBossIndex < MAX_BOSS_COUNT;

  // Should be replaced later on with more complex logic
  static const double bossHealthScalePerLevel = 1.15;
  static const double bossAttackScalePerLevel = 1.10;

  Boss generateNextBoss(int level) {
    if (!hasMoreBosses) {
      throw StateError('All bosses defeated — no more bosses available.');
    }

    final template = _availableBosses[_random.nextInt(_availableBosses.length)];

    // Scale stats based on level
    final scaledHealth = (template.baseHealth * 
      pow(bossHealthScalePerLevel, level - 1)).round();

    final scaledAttack = (template.attack * 
      pow(bossAttackScalePerLevel, level - 1)).round();

    _currentBossIndex++;

    _currentBoss = Boss(
      name: template.name,
      baseHealth: scaledHealth,
      attack: scaledAttack,
      element: template.element,
      imagePath: template.imagePath,
    );

    return _currentBoss!;
  }

  void reset() {
    _currentBossIndex = 0;
    _currentBoss = null;
  }

  void loadState(GameState state) {
    _currentBossIndex = state.currentLevel - 1;
    _currentBoss = state.currentBoss != null
        ? Boss(
            name: state.currentBoss!.name,
            baseHealth: state.currentBoss!.baseHealth,
            attack: state.currentBoss!.attack,
            element: state.currentBoss!.element,
            imagePath: state.currentBoss!.imagePath,
          )
        : null;
  }
}
