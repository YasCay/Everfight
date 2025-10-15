import 'package:everfight/main.dart';
import 'package:everfight/widgets/rectangle_button.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class GameScene extends Component with HasGameReference<RogueliteGame> {
  late TextPaint _paint;

  @override
  Future<void> onLoad() async {
    _paint = TextPaint(
      style: const TextStyle(fontSize: 28, color: Colors.white),
    );

    add(TextComponent(
      text: 'Gameplay Scene',
      textRenderer: _paint,
      anchor: Anchor.center,
      position: game.size / 2,
    ));

    add(RectangleButton(
      label: 'Back to Menu',
      position: Vector2(game.size.x / 2 - 120, game.size.y - 120),
      size: Vector2(240, 50),
      onPressed: () => game.router.pushNamed('menu'),
    ));
  }
}