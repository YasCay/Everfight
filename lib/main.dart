import 'package:everfight/logic/game_class.dart';
import 'package:everfight/overlays/monster_selection.dart';
import 'package:flame/game.dart';
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
      home: GameWidget(
        game: RogueliteGame(),
        overlayBuilderMap: {
          'MonsterSelectionOverlay': (context, game) => MonsterSelectionOverlay(game: game as RogueliteGame),
        },
      ),
    ),
  );
}

