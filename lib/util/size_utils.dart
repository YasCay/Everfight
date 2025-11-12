import 'package:flutter/material.dart';

class SizeUtils {
  static double scalePercentage(double baseSize, double percentage) {
    return baseSize * (percentage / 100);
  }
  
  static TextPainter fitTextPainter(
    TextPainter textPainter,
    double containerWidth,
    List<String> texts, {
    double maxFontSize = 24,
    double minFontSize = 6,
    double letterSpacing = 0,
    String fontFamily = 'Arial',
    FontWeight fontWeight = FontWeight.normal,
  }) {
    // Extract existing style, fallback if null
    final baseStyle = (textPainter.text as TextSpan?)?.style ?? const TextStyle();
    double fontSize = maxFontSize;
    String originalText = (textPainter.text as TextSpan?)?.text ?? '';

    while (fontSize >= minFontSize) {
      bool fits = true;

      for (final text in texts) {
        textPainter.text = TextSpan(
          text: text,
          style: baseStyle.copyWith(fontSize: fontSize),
        );
        textPainter.layout();

        if (textPainter.width > containerWidth) {
          fits = false;
          break;
        }
      }

      if (fits) break;
      fontSize -= 0.5;
    }

    // Apply the final font size
    textPainter.text = TextSpan(
      text: originalText,
      children: (textPainter.text as TextSpan?)?.children,
      style: baseStyle.copyWith(fontSize: fontSize.clamp(minFontSize, maxFontSize)),
    );
    textPainter.layout();

    return textPainter;
  }
}