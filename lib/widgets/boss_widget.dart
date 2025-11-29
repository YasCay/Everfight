import 'dart:math' as math;

import 'package:everfight/models/boss.dart';
import 'package:everfight/widgets/health_bar_component.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart' hide Image;

class BossWidget extends PositionComponent {
  Boss boss;
  SpriteComponent? _spriteComponent;
  late HealthBarComponent _hpBubble;
  @override
  final double width;
  @override
  final double height;

  BossWidget({
    required this.boss,
    required Vector2 position,
    required this.width,
    required this.height,
  }) : super(
            position: position,
            size: Vector2(width, height),
            anchor: Anchor.topLeft);

  @override
  Future<void> onLoad() async {
    Image image = Flame.images.fromCache(boss.imagePath);
    Sprite sprite = Sprite(image);

    final imageSize = sprite.srcSize;
    final targetSize = Vector2(width, height);

    final scale = math.min(
      targetSize.x / imageSize.x,
      targetSize.y / imageSize.y,
    );

    final fittedSize = imageSize * scale;

    final offset = Vector2(
      (targetSize.x - fittedSize.x) / 2,
      (height - fittedSize.y) / 2,
    );

    final spriteComponent = SpriteComponent(
      sprite: sprite,
      size: fittedSize,
      position: offset,
    );
    _spriteComponent = spriteComponent;

    _hpBubble = HealthBarComponent(
      owner: boss,
      getCurrent: () => boss.health,
      getMax: () => boss.baseHealth,
      position: Vector2(width * 0.1, height - 18),
      size: Vector2(width * 0.8, 16),
    );

    add(spriteComponent);
    add(_hpBubble);
  }

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRect(
        rect,
        Paint()
          ..color = Colors.white.withValues(alpha: 0)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
    super.render(canvas);
  }

  void takeDamage(int damage, Function(Vector2) damagePopupCallback) {
    boss.takeDamage(damage);

    final spriteComponent = _spriteComponent;
    if (spriteComponent != null) {
      final hitEffect = ColorEffect(
        Colors.red.withValues(alpha: 0.5),
        EffectController(duration: 0.1, reverseDuration: 0.1),
      );
      spriteComponent.add(hitEffect);
    }

    // Add damage popup at center of boss
    final popupPosition = Vector2(width / 2, height / 3);
    damagePopupCallback(position + popupPosition);
  }

  void attack({
    required PositionComponent target,
    required VoidCallback applyDamage,
    required VoidCallback onAttackFinished,
  }) {
    final monsterCenter = position + Vector2(width / 2, height / 2);
    final bossCenter =
        target.position + Vector2(target.size.x / 2, target.size.y / 2);
    final moveVector = (bossCenter - monsterCenter) * 0.5;

    final reverseAttackEffect = MoveByEffect(
      -moveVector,
      EffectController(duration: 0.25),
      onComplete: () {
        onAttackFinished();
      },
    );

    final attackEffect = MoveByEffect(
      moveVector,
      EffectController(duration: 0.25),
      onComplete: () {
        applyDamage();
        add(reverseAttackEffect);
      },
    );

    add(attackEffect);
  }
}
