import 'package:everfight/logic/game_class.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class LevelTextComponent extends TextComponent {
  final RogueliteGame gameRef;

  LevelTextComponent(this.gameRef)
      : super(
          text: 'Level ${gameRef.currentLevel}',
          textRenderer: TextPaint(
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        );

  @override
  void update(double dt) {
    super.update(dt);

    text = 'Level ${gameRef.currentLevel}';
  }
}
