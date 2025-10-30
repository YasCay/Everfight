import 'package:everfight/game/game_state.dart';
import 'package:everfight/logic/game_class.dart';

class GameStateController {
  final RogueliteGame game;

  GameState phase = GameState.init;

  GameStateController(this.game);

  void startRun() {
    game.playerTeam.clear();
    game.currentBossIndex = 0;
    phase = GameState.selecting;
    game.showMonsterSelection();
  }

  void onTeamSelected() {
    phase = GameState.idle;
  }

  void startCombat() {
    if (phase != GameState.idle) return;
    phase = GameState.inCombat;
  }

  void victory() {
    phase = GameState.victory;
    game.healTeam();
    game.currentBossIndex++;
  }

  void defeat() {
    phase = GameState.defeat;
    game.playerTeam.clear();
    game.currentBossIndex = 0;
  }

  bool get isCombatReady => phase == GameState.idle;
}
