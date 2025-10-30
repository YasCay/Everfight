import 'package:everfight/game/game_state.dart';
import 'package:everfight/models/enums.dart';
import 'package:everfight/models/monster.dart';
import 'package:everfight/overlays/monster_selection.dart';
import 'package:everfight/screens/achievements.dart';
import 'package:everfight/screens/game.dart';
import 'package:everfight/screens/main_menu.dart';
import 'package:everfight/screens/unlockables.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart' hide Route, Element;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Everfight',
      theme: ThemeData.dark(),
      home: SafeArea(
        child: GameWidget(
          game: RogueliteGame(),
          overlayBuilderMap: {
            'MonsterSelectionOverlay': (context, game) => MonsterSelectionOverlay(game: game as RogueliteGame),
          },
        )
      ),
    ),
  );
}

class RogueliteGame extends FlameGame with HasKeyboardHandlerComponents {
  late RouterComponent router;
  final List<Monster> playerTeam = [];
  final List<Monster> bosses = [];
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
    add(router);
    _initMonsters();
  }

  void _initMonsters() {
    bosses.addAll([
      Monster(name: 'Flamurai', baseHealth: 120, baseAttack: 2, element: Element.fire, imagePath: 'boss_fire.jpeg'),
      Monster(name: 'Frostfang', baseHealth: 150, baseAttack: 10, element: Element.water, imagePath: 'boss_water.jpeg'),
      Monster(name: 'Terra Titan', baseHealth: 180, baseAttack: 20, element: Element.earth, imagePath: 'boss_earth.jpeg'),
      Monster(name: 'Birdinator', baseHealth: 180, baseAttack: 20, element: Element.air, imagePath: 'boss_air.jpeg'),
    ]);
  }

  void showMonsterSelection() {
    overlays.add('MonsterSelectionOverlay');
  }

  void hideMonsterSelection() {
    overlays.remove('MonsterSelectionOverlay');
  }

  void healTeam() {
    for (final m in playerTeam) {
      m.resetHealth();
    }
  }
}
