import 'dart:math' as math;

import 'package:everfight/models/monster.dart';
import 'package:everfight/widgets/boss_widget.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:everfight/widgets/health_bar_component.dart';

class MonsterWidget extends PositionComponent {
  final Monster monster;
  late SpriteComponent spriteComponent;
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

  MonsterWidget({
    required this.monster,
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

    Image image = Flame.images.fromCache(monster.imagePath);
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
      owner: monster,
      getCurrent: () => monster.health,
      getMax: () => monster.baseHealth,
      position: Vector2(8, height - 18),
      size: Vector2(width * 0.55, 14),
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
}

class BossWidget extends PositionComponent {
  final Boss boss;
  late SpriteComponent spriteComponent;
  late HealthBarComponent _hpBubble;
  late ShapeComponent _attackBubble;
  late TextPaint _textPaint;
  @override
  final double width;
  @override
  final double height;
  final double textSpacing = 5.0;
  final double bubbleRadius = 15.0;

  void takeDamage(int damage) {
    monster.takeDamage(damage);
    _hpText.text = '${monster.health}';

    final hitEffect = ColorEffect(
      Colors.red.withValues(alpha: 0.5),
      EffectController(duration: 0.1, reverseDuration: 0.1),
    );

    _spriteComponent.add(hitEffect);
  }

  void attack(BossWidget target, VoidCallback onHit) {
    final monsterCenter = position + Vector2(width / 2, height / 2);
    final bossCenter = target.position + Vector2(target.width / 2, target.height / 2);
    final moveVector = (bossCenter - monsterCenter) * 0.5;

    final reverseAttackEffect = MoveByEffect(
      -moveVector,
      EffectController(duration: 0.15),
      onComplete: onHit,
    );

    final attackEffect = MoveByEffect(
      moveVector,
      EffectController(duration: 0.15),
      onComplete: () {
        target.takeDamage(monster.baseAttack);
        add(reverseAttackEffect);
      },
    );

    _hpBubble = HealthBarComponent(
      owner: boss,
      getCurrent: () => boss.health,
      getMax: () => boss.baseHealth,
      position: Vector2(8, height - 18),
      size: Vector2(width * 0.5, 16),
    );

    _attackBubble = CircleComponent(
      radius: bubbleRadius,
      paint: Paint()..color = Colors.redAccent,
      position: Vector2(width - bubbleRadius, height - bubbleRadius),
      anchor: Anchor.center,
      children: [
        TextComponent(
          text: '${boss.attack}',
          textRenderer: _textPaint,
          anchor: Anchor.center,
          position: Vector2(bubbleRadius, bubbleRadius),
        ),
      ]
    );

    add(spriteComponent);
    add(_hpBubble);
    add(_attackBubble);
  }
}
