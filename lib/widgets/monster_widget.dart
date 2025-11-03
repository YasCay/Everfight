import 'dart:math' as math;

import 'package:everfight/models/boss.dart';
import 'package:everfight/models/monster.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart' hide Image;

class MonsterWidget extends PositionComponent {
  final Monster monster;
  late SpriteComponent _spriteComponent;
  late ShapeComponent _hpBubble;
  late ShapeComponent _attackBubble;
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

    Image image = await Flame.images.load(monster.imagePath);
    Sprite sprite = Sprite(image);

    final imageSize = sprite.srcSize; // original size
    final targetSize = Vector2(width, height);

    // aspect-fit scale
    final scale = math.min(
      targetSize.x / imageSize.x,
      targetSize.y / imageSize.y,
    );

    // new size (fits without stretching)
    final fittedSize = imageSize * scale;

    // center inside target area
    final offset = Vector2(
      (targetSize.x - fittedSize.x) / 2,
      (height - fittedSize.y) / 2,
    );

    _spriteComponent = SpriteComponent(
      sprite: sprite,
      size: fittedSize,
      position: offset,
    );

    _hpBubble = CircleComponent(
      radius: bubbleRadius,
      paint: Paint()..color = Colors.greenAccent,
      position: Vector2(bubbleRadius, height - bubbleRadius),
      anchor: Anchor.center,
      children: [
        TextComponent(
          text: '${monster.health}',
          textRenderer: _textPaint,
          anchor: Anchor.center,
          position: Vector2(bubbleRadius, bubbleRadius),
        ),
      ],
    );

    _attackBubble = CircleComponent(
      radius: bubbleRadius,
      paint: Paint()..color = Colors.redAccent,
      position: Vector2(width - bubbleRadius, height - bubbleRadius),
      anchor: Anchor.center,
      children: [
        TextComponent(
          text: '${monster.baseAttack}',
          textRenderer: _textPaint,
          anchor: Anchor.center,
          position: Vector2(bubbleRadius, bubbleRadius),
        ),
      ]
    );

    add(_spriteComponent);
    add(_hpBubble);
    add(_attackBubble);
  }
}

class BossWidget extends PositionComponent {
  final Boss boss;
  late SpriteComponent _spriteComponent;
  late ShapeComponent _hpBubble;
  late ShapeComponent _attackBubble;
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

    Image image = await Flame.images.load(boss.imagePath);
    Sprite sprite = Sprite(image);

    final imageSize = sprite.srcSize; // original size
    final targetSize = Vector2(width, height);

    // aspect-fit scale
    final scale = math.min(
      targetSize.x / imageSize.x,
      targetSize.y / imageSize.y,
    );

    // new size (fits without stretching)
    final fittedSize = imageSize * scale;

    // center inside target area
    final offset = Vector2(
      (targetSize.x - fittedSize.x) / 2,
      (height - fittedSize.y) / 2,
    );

    _spriteComponent = SpriteComponent(
      sprite: sprite,
      size: fittedSize,
      position: offset,
    );

    _hpBubble = CircleComponent(
      radius: bubbleRadius,
      paint: Paint()..color = Colors.greenAccent,
      position: Vector2(bubbleRadius, height - bubbleRadius),
      anchor: Anchor.center,
      children: [
        TextComponent(
          text: '${boss.health}',
          textRenderer: _textPaint,
          anchor: Anchor.center,
          position: Vector2(bubbleRadius, bubbleRadius),
        ),
      ],
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
}