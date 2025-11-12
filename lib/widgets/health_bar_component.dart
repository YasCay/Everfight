import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Image;

/// A simple health bar component for Flame `PositionComponent`s.
///
/// It can listen to an optional [Listenable] owner and uses the provided
/// getters to read current and max health. It renders a filled rounded
/// rectangle representing remaining health and an optional percentage text.
class HealthBarComponent extends PositionComponent {
  final Listenable? owner;
  final int Function() getCurrent;
  final int Function() getMax;
  final double borderRadius;
  final TextPaint? textPaint;

  HealthBarComponent({
    this.owner,
    required this.getCurrent,
    required this.getMax,
    Vector2? position,
    Vector2? size,
    this.borderRadius = 4.0,
    this.textPaint,
  }) : super(position: position ?? Vector2.zero(), size: size ?? Vector2(80, 12), anchor: Anchor.topLeft);

  late final TextPaint _internalTextPaint;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    owner?.addListener(_onOwnerChanged);
    _internalTextPaint = textPaint ??
        TextPaint(
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black)],
          ),
        );
  }

  void _onOwnerChanged() {
    // no-op: render reads getters each frame, so nothing needed here
  }

  @override
  void onRemove() {
    owner?.removeListener(_onOwnerChanged);
    super.onRemove();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final double current = getCurrent().toDouble();
    final double max = getMax().toDouble();
    final double pct = max <= 0 ? 0 : (current / max).clamp(0.0, 1.0);

    final Rect outer = Rect.fromLTWH(0, 0, size.x, size.y);
    final RRect outerR = RRect.fromRectAndRadius(outer, Radius.circular(borderRadius));

    // background
    final Paint bgPaint = Paint()..color = Colors.black.withOpacity(0.6);
    canvas.drawRRect(outerR, bgPaint);

    // filled part
    final Rect filled = Rect.fromLTWH(0, 0, size.x * pct, size.y);
    // color gradient from red (low) to green (full)
    final Color fillColor = Color.lerp(Colors.red, Colors.green, pct)!;
    final Paint fillPaint = Paint()..color = fillColor;
    final RRect filledR = RRect.fromRectAndRadius(filled, Radius.circular(borderRadius));
    canvas.drawRRect(filledR, fillPaint);

    // border
    final Paint borderPaint = Paint()..style = PaintingStyle.stroke..color = Colors.white.withOpacity(0.6)..strokeWidth = 1;
    canvas.drawRRect(outerR, borderPaint);

    // text (current / max or percentage)
    final text = '${getCurrent()} / ${getMax()}';
    _internalTextPaint.render(canvas, text, Vector2(size.x / 2, size.y / 2), anchor: Anchor.center);
  }
}
