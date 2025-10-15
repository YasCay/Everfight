import 'package:everfight/screens/achievements.dart';
import 'package:everfight/screens/game.dart';
import 'package:everfight/screens/main_menu.dart';
import 'package:everfight/screens/unlockables.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart' hide Route;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Everfight',
      theme: ThemeData.dark(),
      home: GameWidget(game: RogueliteGame()),
    ),
  );
}

class RogueliteGame extends FlameGame with HasKeyboardHandlerComponents {
  late RouterComponent router;

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
  }
}
