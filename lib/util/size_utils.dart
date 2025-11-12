import 'package:flutter/material.dart';

class SizeUtils {
  static double scalePercentage(double baseSize, double percentage) {
    var newSize = baseSize * (percentage / 100);
    return (newSize * 10).floorToDouble() / 10;
  }
  
  static double fitTextPainter(
    TextPainter textPainter,
    double containerWidth,
    List<String> texts, {
    double maxFontSize = 24,
    double minFontSize = 6,
  }) {
    final baseStyle = (textPainter.text as TextSpan?)?.style ?? const TextStyle();
    double fontSize = minFontSize;
    double lastFittingSize = minFontSize;

    while (fontSize <= maxFontSize) {
      bool allFit = true;

      for (final text in texts) {
        textPainter.text = TextSpan(
          text: text,
          style: baseStyle.copyWith(
            fontSize: fontSize,
          ),
        );

        textPainter.layout();
        if (textPainter.width > containerWidth) {
          allFit = false;
          break;
        }
      }

      if (!allFit) break;

      lastFittingSize = fontSize;
      fontSize += 0.5;
    }

    return lastFittingSize.clamp(minFontSize, maxFontSize);
  }
}