import 'dart:ui';

import 'package:everfight/logic/achievement_manager.dart';
import 'package:everfight/logic/boss_manager.dart';
import 'package:everfight/logic/boss_repository.dart';
import 'package:everfight/logic/game_phase_controller.dart';
import 'package:everfight/logic/monster_repository.dart';
import 'package:everfight/logic/statistics_manager.dart';
import 'package:everfight/logic/team_manager.dart';
import 'package:everfight/logic/unlock_manager.dart';
import 'package:everfight/models/game_state.dart';
import 'package:everfight/screens/game.dart';
import 'package:everfight/screens/main_menu.dart';
import 'package:everfight/util/game_assets.dart';
import 'package:everfight/util/local_storage.dart';
import 'package:everfight/util/settings.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';

class RogueliteGame extends FlameGame with HasKeyboardHandlerComponents {
  @override
  bool get debugMode => DEBUG_MODE;

  late RouterComponent router;
  late GamePhaseController phaseController;
  late TeamManager teamManager;
  late BossManager bossManager;

  int currentLevel = 1;

  String currentOverlayTitle = '';
  String currentOverlayButtonText = '';
  VoidCallback? currentOverlayCallback;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    await UnlockManager().init();
    await StatisticsManager().init();
    await AchievementManager().init(this);
    await Flame.images.loadAll(GameAssets.all);
    await MonsterRepository().load();
    await BossRepository().load();

    router = RouterComponent(
      initialRoute: 'menu',
      routes: {
        'menu': Route(MainMenu.new),
        'game': Route(GameScene.new),
      },
    );

    teamManager = TeamManager();
    bossManager = BossManager();
    phaseController = GamePhaseController(this);

    GameState gameState = await LocalStorage.loadState();
    print('Loaded game state: $gameState');
    teamManager.loadState(gameState);
    bossManager.loadState(gameState);
    currentLevel = gameState.currentLevel;

    add(router);
  }

  void showMonsterSelection() {
    overlays.add('MonsterSelectionOverlay');
  }

  void hideMonsterSelection() {
    overlays.remove('MonsterSelectionOverlay');
    phaseController.onTeamSelected();
  }

  void showPauseMenu() {
    overlays.add('PauseMenu');
  }

  void hidePauseMenu() {
    overlays.remove('PauseMenu');
  }

  void showWinOverlay(VoidCallback onPressed) {
    currentOverlayTitle = "YOU WIN!";
    currentOverlayButtonText = "Continue";
    currentOverlayCallback = onPressed;
    overlays.add('winLoseOverlay');
  }

  void showLoseOverlay(VoidCallback onPressed) {
    currentOverlayTitle = "YOU DIED";
    currentOverlayButtonText = "Try Again";
    currentOverlayCallback = onPressed;
    overlays.add('winLoseOverlay');
  }

  void healTeam() {
    for (final m in teamManager.team) {
      m.resetHealth();
    }
  }

  void saveGame() {
    final state = GameState(
      currentLevel: currentLevel,
      team: teamManager.team,
      currentBoss: bossManager.currentBoss,
    );
    LocalStorage.saveState(state);
  }

  void resetRun() {
    teamManager.clear();
    bossManager.reset();
    currentLevel = 1;
    saveGame();
    phaseController.restartRun();
    resumeEngine();
  }
}
