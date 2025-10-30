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
  final double padding = 5.0;
  final double spriteSize = 70.0;
  final double textSpacing = 5.0;
  final double bubbleRadius = 15.0;

  MonsterWidget({
    required this.monster,
    required Vector2 position,
    this.width = 80,
    this.height = 95,
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
    _spriteComponent = SpriteComponent()
      ..sprite = Sprite(image)
      ..size = Vector2.all(spriteSize)
      ..position = Vector2(padding, 0);

    _hpBubble = CircleComponent(
      radius: bubbleRadius,
      paint: Paint()..color = Colors.greenAccent,
      position: Vector2(bubbleRadius, height - bubbleRadius - 5),
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
      position: Vector2(spriteSize, height - bubbleRadius - 5),
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

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRect(rect, Paint()..color = Colors.white.withValues(alpha: 0)..style = PaintingStyle.stroke..strokeWidth = 2);
    super.render(canvas);
  }
}