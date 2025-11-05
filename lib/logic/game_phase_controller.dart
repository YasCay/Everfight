import 'package:everfight/game/game_phase.dart';
import 'package:everfight/logic/game_class.dart';

class GamePhaseController {
  final RogueliteGame game;

  GamePhase phase = GamePhase.init;

  GamePhaseController(this.game);

  void startNewRun() {
    game.playerTeam.clear();
    game.currentBossIndex = 0;
    phase = GamePhase.selecting;
    game.showMonsterSelection();
  }

  void onTeamSelected() {
    phase = GamePhase.idle;
  }

  void startCombat() {
    // if (phase != GamePhase.idle) return;
    phase = GamePhase.inCombat;
  }

  void victory(void Function() nextBossCallback) {
    phase = GamePhase.victory;
    game.currentBossIndex++;

    game.healTeam();

    if (game.currentBossIndex >= game.bosses.length) {
      game.router.pushReplacementNamed('menu');
      phase = GamePhase.inMenues;
    } else {
      // Show reward overlay and set next boss
      nextBossCallback();
      phase = GamePhase.selecting;
      game.showMonsterSelection();
    }
  }

  void defeat() {
    phase = GamePhase.defeat;
    game.currentBossIndex = 0;
    game.playerTeam.clear();
    game.router.pushReplacementNamed('menu');
    phase = GamePhase.inMenues;
  }

  bool get isCombatReady => phase == GamePhase.idle;
}
