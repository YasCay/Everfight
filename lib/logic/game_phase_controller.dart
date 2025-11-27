import 'package:everfight/game/game_phase.dart';
import 'package:everfight/logic/game_class.dart';
import 'package:everfight/logic/statistics_manager.dart';
import 'package:everfight/util/settings.dart';

class GamePhaseController {
  final RogueliteGame game;

  GamePhase phase = GamePhase.init;

  GamePhaseController(this.game);

  void startNewRun() {
    StatisticsManager().recordRunStarted();
    game.teamManager.clear();
    game.currentLevel = 1;
    phase = GamePhase.selecting;
    game.showMonsterSelection();
  }

  void onTeamSelected() {
    phase = GamePhase.idle;
  }

  void startCombat() {
    // if (phase != GamePhase.idle) return;
    if (phase != GamePhase.inCombat) {
      // Avoid unnecessary state changes
      phase = GamePhase.inCombat;
    }
  }

  void victory(void Function() nextBossCallback) {
    StatisticsManager().recordHighestLevel(game.currentLevel);
    phase = GamePhase.victory;
    game.currentLevel++;

    game.healTeam();

    if (game.currentLevel > MAX_BOSS_COUNT) {
      StatisticsManager().recordRunWon();
      for (var monster in game.teamManager.team) {
        StatisticsManager().recordWinWithMonster(monster.name);
      }
      game.router.pushReplacementNamed('menu');
      reset();
      game.saveGame();
    } else {
      game.currentLevel--;
      game.saveGame();
      game.currentLevel++;
      // Show reward overlay and set next boss
      nextBossCallback();
      phase = GamePhase.selecting;
      game.showMonsterSelection();
    }
  }

  void defeat() {
    StatisticsManager().recordHighestLevel(game.currentLevel);
    phase = GamePhase.defeat;
    game.router.pushReplacementNamed('menu');
    reset();
    game.saveGame();
  }

  void reset() {
    game.currentLevel = 1;
    game.teamManager.clear();
    game.bossManager.reset();

    phase = GamePhase.init;
  }

  void restartRun() {
    reset();
    phase = GamePhase.restarting;
  }

  bool get isCombatReady => phase == GamePhase.idle;
}
