import 'package:flutter/material.dart';

enum ButtonColorType { green, orange, pink, purple }

class FlutterRectangleButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final ButtonColorType colorType;
  final List<String> groupTexts;

  const FlutterRectangleButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.colorType = ButtonColorType.green,
    this.groupTexts = const [],
  });

  static const _borderColor = Colors.black;

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

  double _calculateRequiredWidth(BuildContext context) {
    final texts = [...groupTexts];
    double maxWidth = 0;

    final textStyle = const TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.w900,
      letterSpacing: 1.5,
    );

    for (final t in texts) {
      final painter = TextPainter(
        text: TextSpan(text: t.toUpperCase(), style: textStyle),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();

      double width = painter.width;

      if (icon != null) {
        width += 26;
        width += 10;
      }

      width += 36;

      if (width > maxWidth) maxWidth = width;
    }

    return maxWidth;
  }

  @override
  Widget build(BuildContext context) {
    final fillColor = _getFill(colorType);

    return LayoutBuilder(
      builder: (context, constraints) {
        final requiredWidth = _calculateRequiredWidth(context);

        return GestureDetector(
          onTap: onPressed,
          child: Container(
            width: requiredWidth,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(3, 4),
                  blurRadius: 6,
                )
              ],
              border: Border.all(color: _borderColor, width: 1),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 26, color: Colors.black),
                  const SizedBox(width: 10),
                ],
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
