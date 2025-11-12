import 'package:everfight/util/size_utils.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

enum ButtonColorType { green, orange, pink, purple }

class RectangleButton extends PositionComponent with TapCallbacks {
  RectangleButton({
    required this.label,
    required Vector2 position,
    required Vector2 size,
    required this.onPressed,
    this.colorType = ButtonColorType.green,
    this.icon,
    this.groupTexts = const [],
  }) : super(position: position, size: size, anchor: Anchor.topLeft);

  final String label;
  final VoidCallback onPressed;
  final ButtonColorType colorType;
  final IconData? icon;
  final List<String> groupTexts;
  double? fontSize;

  static const _borderColor = Colors.black; // vorher: Color(0xFF2D2D2D)

  static const _fillGreen = Color(0xFF8ED16F);
  static const _fillOrange = Color(0xFFFFB34D);
  static const _fillPink = Color(0xFFFFA6C9);
  static const _fillPurple = Color(0xFFD1C6FF);

  static Color _getFill(ButtonColorType type) {
    switch (type) {
      case ButtonColorType.green:
        return _fillGreen;
      case ButtonColorType.orange:
        return _fillOrange;
      case ButtonColorType.pink:
        return _fillPink;
      case ButtonColorType.purple:
        return _fillPurple;
    }
  }

  bool _isPressed = false;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final radius = Radius.circular(12);

    // Shadow
    final shadowOffset = _isPressed ? const Offset(1, 1) : const Offset(3, 4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.shift(shadowOffset), radius),
      Paint()..color = Colors.black.withValues(alpha: 0.18),
    );

    // Border
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, radius),
      Paint()
        ..color = _borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0,
    );

    // Fill
    final fillColor = _getFill(colorType);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(2), radius),
      Paint()..color = fillColor,
    );

    // Optional Icon
    double textLeft = rect.left + SizeUtils.scalePercentage(rect.width, 7);
    if (icon != null) {
      final iconPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(icon!.codePoint),
          style: TextStyle(
            fontFamily: icon!.fontFamily,
            package: icon!.fontPackage,
            fontSize: 28,
            color: Colors.black,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      iconPainter.paint(
        canvas,
        Offset(rect.left + SizeUtils.scalePercentage(rect.width, 4.5), rect.top + (rect.height - iconPainter.height) / 2),
      );
      textLeft = textLeft + iconPainter.width;
    }

    if (fontSize == null) {
      final newGroupTexts = groupTexts.map((e) => e.toUpperCase()).toList();
      // Calculate fitting font size
      final dummyPainter = TextPainter(
        text: TextSpan(
          text: label.toUpperCase(),
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '',
      );

      fontSize = SizeUtils.fitTextPainter(
        dummyPainter,
        rect.right - textLeft - SizeUtils.scalePercentage(rect.width, 4.5),
        newGroupTexts,
        maxFontSize: 24,
        minFontSize: 6,
      );
    }

    // Label
    final textPainter = TextPainter(
      text: TextSpan(
        text: label.toUpperCase(),
        style: TextStyle(
          color: Colors.black,
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
        ),
      ),
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '',
    )..layout(maxWidth: rect.right - textLeft - SizeUtils.scalePercentage(rect.width, 4.5));

    textPainter.paint(
      canvas,
      Offset(textLeft, rect.top + (rect.height - textPainter.height) / 2),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    _isPressed = true;
  }

  @override
  void onTapUp(TapUpEvent event) {
    _isPressed = false;
    onPressed();
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    _isPressed = false;
  }
}