import 'package:everfight/logic/boss_generator.dart';
import 'package:everfight/logic/boss_repository.dart';
import 'package:everfight/models/game_state.dart';
import 'package:everfight/util/settings.dart';
import 'package:everfight/models/boss.dart';

class BossManager {
  int _currentBossIndex = 0;
  Boss? _currentBoss;

  int get currentIndex => _currentBossIndex;
  Boss? get currentBoss => _currentBoss;
  bool get hasMoreBosses => _currentBossIndex < MAX_BOSS_COUNT;

  Boss generateNextBoss(int level) {
    _currentBossIndex++;

    var bossGenerator = BossGenerator(
      templates: BossRepository().templates,
    );

    _currentBoss = bossGenerator.generateBoss(level);

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
