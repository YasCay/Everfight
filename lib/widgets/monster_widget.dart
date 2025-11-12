import 'dart:math' as math;

import 'package:everfight/models/monster.dart';
import 'package:everfight/widgets/health_bar_component.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart' hide Image;

class MonsterWidget extends PositionComponent {
  final Monster monster;
  late SpriteComponent _spriteComponent;
  late HealthBarComponent _hpBubble;
  late ShapeComponent _attackBubble;
  late TextComponent _attackText;
  late TextPaint _textPaint;
  @override
  final double width;
  @override
  final double height;
  final double bubbleRadius = 15.0;

  MonsterWidget({
    required this.monster,
    required Vector2 position,
    required this.width,
    required this.height,
  }) : super(position: position, size: Vector2(width, height), anchor: Anchor.topLeft);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _textPaint = TextPaint(
      style: const TextStyle(
        fontSize: 12,
        color: Colors.white,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            offset: Offset(1, 1),
            blurRadius: 2,
            color: Colors.black,
          ),
        ],
      ),
    );

    final image = Flame.images.fromCache(monster.imagePath);
    final sprite = Sprite(image);

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
      owner: monster,
      getCurrent: () => monster.health,
      getMax: () => monster.baseHealth,
      position: Vector2(8, height - 18),
      size: Vector2(width * 0.55, 14),
    );

    _attackText = TextComponent(
      text: '${monster.baseAttack}',
      textRenderer: _textPaint,
      anchor: Anchor.center,
      position: Vector2(bubbleRadius, bubbleRadius),
    );

    _attackBubble = CircleComponent(
      radius: bubbleRadius,
      paint: Paint()..color = Colors.redAccent,
      position: Vector2(width - bubbleRadius, height - bubbleRadius),
      anchor: Anchor.center,
      children: [_attackText],
    );

    add(_spriteComponent);
    add(_hpBubble);
    add(_attackBubble);
  }

  void takeDamage(int damage) {
    monster.takeDamage(damage);
    final hitEffect = ColorEffect(
      Colors.red.withOpacity(0.5),
      EffectController(duration: 0.1, reverseDuration: 0.1),
    );
    _spriteComponent.add(hitEffect);
  }

  void attack({
    required PositionComponent target,
    required VoidCallback applyDamage,
    required VoidCallback onAttackFinished,
  }) {
    final attackerCenter = position + Vector2(width / 2, height / 2);
    final targetCenter = target.position + Vector2(target.size.x / 2, target.size.y / 2);
    final moveVector = (targetCenter - attackerCenter) * 0.5;

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
