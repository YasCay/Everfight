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
  late SpriteComponent _spriteComponent;
  late HealthBarComponent _hpBubble;
  late ShapeComponent _attackBubble;
  late TextComponent _attackText;
  late TextPaint _textPaint;
  @override
  final double width;
  @override
  final double height;
  final double textSpacing = 5.0;
  final double bubbleRadius = 15.0;

  BossWidget({
    required this.boss,
    required Vector2 position,
    required this.width,
    required this.height,
  }) : super(position: position, size: Vector2(width, height), anchor: Anchor.topLeft);

  @override
  Future<void> onLoad() async {
    _textPaint = TextPaint(
      style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold, shadows: [
        Shadow(
          offset: Offset(1, 1),
          blurRadius: 2,
          color: Colors.black,
        ),
      ]),
    );

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

    _spriteComponent = SpriteComponent(
      sprite: sprite,
      size: fittedSize,
      position: offset,
    );

    _hpBubble = HealthBarComponent(
      owner: boss,
      getCurrent: () => boss.health,
      getMax: () => boss.baseHealth,
      position: Vector2(8, height - 18),
      size: Vector2(width * 0.5, 16),
    );

    _attackText = TextComponent(
      text: '${boss.attack}',
      textRenderer: _textPaint,
      anchor: Anchor.center,
      position: Vector2(bubbleRadius, bubbleRadius),
    );

    _attackBubble = CircleComponent(
      radius: bubbleRadius,
      paint: Paint()..color = Colors.redAccent,
      position: Vector2(width - bubbleRadius, height - bubbleRadius),
      anchor: Anchor.center,
      children: [_attackText]
    );

    add(_spriteComponent);
    add(_hpBubble);
    add(_attackBubble);
  }

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRect(rect, Paint()..color = Colors.white.withValues(alpha: 0)..style = PaintingStyle.stroke..strokeWidth = 2);
    super.render(canvas);
  }

  void takeDamage(int damage) {
    boss.takeDamage(damage);

    final hitEffect = ColorEffect(
      Colors.red.withValues(alpha: 0.5),
      EffectController(duration: 0.1, reverseDuration: 0.1),
    );

    _spriteComponent.add(hitEffect);
  }

  void attack({
    required PositionComponent target,
    required VoidCallback applyDamage,
    required VoidCallback onAttackFinished,
  }) {
    final monsterCenter = position + Vector2(width / 2, height / 2);
    final bossCenter = target.position + Vector2(target.size.x / 2, target.size.y / 2);
    final moveVector = (bossCenter - monsterCenter) * 0.5;

    final reverseAttackEffect = MoveByEffect(
      -moveVector,
      EffectController(duration: 0.15),
    );

    final attackEffect = MoveByEffect(
      moveVector,
      EffectController(duration: 0.15),
      onComplete: () {
        applyDamage();
        add(reverseAttackEffect);
        onAttackFinished();
      },
    );

    add(attackEffect);
  }
}
