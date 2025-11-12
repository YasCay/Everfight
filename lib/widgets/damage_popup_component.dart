import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

class DamagePopupComponent extends PositionComponent with HasPaint {
  DamagePopupComponent({
    required int damage,
    required Vector2 position,
  }) : super(
          position: position,
          anchor: Anchor.center,
        ) {
    _textComponent = TextComponent(
      text: '-$damage',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 36,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              offset: Offset(0, 0),
              blurRadius: 8,
              color: Colors.red,
            ),
            Shadow(
              offset: Offset(2, 2),
              blurRadius: 4,
              color: Colors.black,
            ),
          ],
        ),
      ),
      anchor: Anchor.center,
    );

    paint = Paint()..color = Colors.white;
  }

  late final TextComponent _textComponent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(_textComponent);

    // Move upwards effect
    final moveEffect = MoveByEffect(
      Vector2(0, -100),
      EffectController(duration: 1.5),
    );

    // Fade out effect - starts after 0.5s, takes 1s
    final fadeEffect = OpacityEffect.fadeOut(
      EffectController(duration: 1.0, startDelay: 0.5),
    );

    // Remove after animation
    final removeEffect = RemoveEffect(
      delay: 1.5,
    );

    add(moveEffect);
    add(fadeEffect);
    add(removeEffect);
  }
}
