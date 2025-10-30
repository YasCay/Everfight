import 'package:everfight/logic/game_class.dart';
import 'package:everfight/widgets/rectangle_button.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class UnlockablesScene extends Component with HasGameReference<RogueliteGame> {
  late TextPaint _paint;

  @override
  Future<void> onLoad() async {
    _paint = TextPaint(
      style: const TextStyle(fontSize: 28, color: Colors.white),
    );

    add(TextComponent(
      text: 'Unlockables',
      textRenderer: _paint,
      anchor: Anchor.center,
      position: Vector2(game.size.x / 2, 100),
    ));

    final unlocks = [
      'New Char 1',
      'New Char 2',
      'Endless Mode',
    ];

    for (int i = 0; i < unlocks.length; i++) {
      add(TextComponent(
        text: '- ${unlocks[i]}',
        textRenderer: _paint,
        position: Vector2(80, 180 + i * 40),
      ));
    }

    add(RectangleButton(
      label: 'Back',
      position: Vector2(game.size.x / 2 - 120, game.size.y - 100),
      size: Vector2(240, 50),
      onPressed: () => game.router.pushNamed('menu'),
    ));
  }
}