import 'package:everfight/game/game_state.dart';
import 'package:everfight/logic/game_state_controller.dart';
import 'package:everfight/logic/team_manager.dart';
import 'package:everfight/models/boss.dart';
import 'package:everfight/models/enums.dart';
import 'package:everfight/screens/achievements.dart';
import 'package:everfight/screens/game.dart';
import 'package:everfight/screens/main_menu.dart';
import 'package:everfight/screens/unlockables.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';

class RogueliteGame extends FlameGame with HasKeyboardHandlerComponents {
  late RouterComponent router;
  late GameStateController stateController;
  late TeamManager playerTeam;

  final List<Boss> bosses = [];
  int currentBossIndex = 0;
  GameState state = GameState.inMenues;

  @override
  Future<void> onLoad() async {
    router = RouterComponent(
      initialRoute: 'menu',
      routes: {
        'menu': Route(MainMenu.new),
        'achievements': Route(AchievementsScene.new),
        'unlockables': Route(UnlockablesScene.new),
        'game': Route(GameScene.new),
      },
    );
    playerTeam = TeamManager();
    stateController = GameStateController(this);
    add(router);
    _initMonsters();
  }

  void _initMonsters() {
    bosses.addAll([
      Boss(name: 'Infernakor', baseHealth: 120, attack: 2, element: Element.fire, imagePath: 'boss/fire/Infernakor_front.png'),
      Boss(name: 'Tidalion', baseHealth: 150, attack: 10, element: Element.water, imagePath: 'boss/water/Tidalion_front.png'),
      Boss(name: 'Terragron', baseHealth: 180, attack: 20, element: Element.earth, imagePath: 'boss/earth/Terragron_front.png'),
      Boss(name: 'Zephyra', baseHealth: 180, attack: 20, element: Element.air, imagePath: 'boss/air/Zephyra_front.png'),
    ]);
  }

  void showMonsterSelection() {
    overlays.add('MonsterSelectionOverlay');
  }

  void hideMonsterSelection() {
    overlays.remove('MonsterSelectionOverlay');
  }

  void healTeam() {
    for (final m in playerTeam.team) {
      m.resetHealth();
    }
  }
}