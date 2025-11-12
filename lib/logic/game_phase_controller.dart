import 'package:everfight/game/game_phase.dart';
import 'package:everfight/logic/game_class.dart';
import 'package:everfight/util/settings.dart';

class GamePhaseController {
  final RogueliteGame game;

  GamePhase phase = GamePhase.init;

  GamePhaseController(this.game);

  void startNewRun() {
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
    phase = GamePhase.victory;
    game.currentLevel++;

    game.healTeam();

    if (game.currentLevel >= MAX_BOSS_COUNT) {
      game.router.pushReplacementNamed('menu');
      phase = GamePhase.init;
    } else {
      // Show reward overlay and set next boss
      nextBossCallback();
      phase = GamePhase.selecting;
      game.showMonsterSelection();
    }
  }

  void defeat() {
    phase = GamePhase.defeat;
    game.currentLevel = 1;
    game.teamManager.clear();
    game.router.pushReplacementNamed('menu');
    phase = GamePhase.init;
  }

  bool get isCombatReady => phase == GamePhase.idle;
}
