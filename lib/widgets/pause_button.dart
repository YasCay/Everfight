import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' hide Image;

class PauseButton extends PositionComponent with TapCallbacks {
  final VoidCallback onPressed;

  PauseButton({required this.onPressed, Vector2? position})
      : super(
          position: position ?? Vector2(20, 20),
          size: Vector2(50, 50),
        );

  @override
  Future<void> onLoad() async {
    super.onLoad();
  }

  @override
  bool onTapUp(TapUpEvent event) {
    onPressed();
    return true;
  }

  @override
  void render(Canvas canvas) {
    // icon inside button
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.5);
    paint.style = PaintingStyle.fill;

    var rect = size.toRect();
    var rrect = RRect.fromRectAndRadius(rect, Radius.circular(12));
    canvas.drawRRect(rrect, paint);

    final icon = Icons.pause;
    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: size.x * 0.6,
          fontFamily: icon.fontFamily,
          color: Colors.black,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    final offset = Offset(
      (size.x - textPainter.width) / 2,
      (size.y - textPainter.height) / 2,
    );
    textPainter.paint(canvas, offset);

    super.render(canvas);
  }
}
