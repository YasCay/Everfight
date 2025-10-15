import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class RectangleButton extends PositionComponent with TapCallbacks {
  final String label;
  final VoidCallback onPressed;

  RectangleButton({
    required this.label,
    required Vector2 position,
    required Vector2 size,
    required this.onPressed,
  }) : super(position: position, size: size, anchor: Anchor.topLeft);

  @override
  void render(Canvas canvas) {
    // Draw the button rectangle
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final paint = Paint()..color = Colors.blueAccent;
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(12)), paint);

    // Draw centered text
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    );

    final tp = TextPainter(
      text: TextSpan(text: label, style: textStyle),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout(maxWidth: size.x);
    tp.paint(canvas, Offset((size.x - tp.width) / 2, (size.y - tp.height) / 2));
  }

  @override
  void onTapDown(TapDownEvent event) {
    onPressed();
  }
}