import 'package:everfight/logic/boss_manager.dart';
import 'package:everfight/logic/game_phase_controller.dart';
import 'package:everfight/logic/team_manager.dart';
import 'package:everfight/models/game_state.dart';
import 'package:everfight/screens/achievements.dart';
import 'package:everfight/screens/game.dart';
import 'package:everfight/screens/main_menu.dart';
import 'package:everfight/screens/unlockables.dart';
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

  @override
  Future<void> onLoad() async {
    await Flame.images.loadAll(GameAssets.all);
    await super.onLoad();
    
    router = RouterComponent(
      initialRoute: 'menu',
      routes: {
        'menu': Route(MainMenu.new),
        'achievements': Route(AchievementsScene.new),
        'unlockables': Route(UnlockablesScene.new),
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
}