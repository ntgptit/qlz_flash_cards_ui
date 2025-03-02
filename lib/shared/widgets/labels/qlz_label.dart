// lib/shared/widgets/labels/qlz_label.dart

import 'package:flutter/material.dart';

/// A customizable text label component for the application
final class QlzLabel extends StatelessWidget {
  /// The label text
  final String text;

  /// Font size for the label
  final double? fontSize;

  /// Font weight for the label
  final FontWeight? fontWeight;

  /// Text color for the label
  final Color? color;

  /// Custom text style (overrides fontSize, fontWeight, and color)
  final TextStyle? style;

  /// Whether to automatically use uppercase
  final bool uppercase;

  /// Standard constructor for primary label
  const QlzLabel(
    this.text, {
    super.key,
    this.fontSize = 12,
    this.fontWeight = FontWeight.bold,
    this.color = Colors.white,
    this.style,
    this.uppercase = true,
  });

  /// Constructor for label with muted appearance
  const QlzLabel.muted(
    this.text, {
    super.key,
    this.fontSize = 16,
    this.fontWeight,
    this.color = Colors.white54,
    this.style,
    this.uppercase = false,
  });

  /// Constructor for secondary label (smaller, subdued)
  const QlzLabel.secondary(
    this.text, {
    super.key,
    this.fontSize = 12,
    this.fontWeight,
    this.color = Colors.white54,
    this.style,
    this.uppercase = true,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle defaultStyle = TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );

    final TextStyle effectiveStyle = style?.copyWith(
          color: style?.color ?? color,
          fontSize: style?.fontSize ?? fontSize,
          fontWeight: style?.fontWeight ?? fontWeight,
        ) ??
        defaultStyle;

    final String displayText = uppercase ? text.toUpperCase() : text;

    return Text(
      displayText,
      style: effectiveStyle,
    );
  }
}
