// lib/shared/widgets/utils/qlz_chip.dart

import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';

/// Types of chips available
enum QlzChipType {
  primary,
  secondary,
  success,
  error,
  warning,
  info,
  ghost,
  custom,
}

/// A custom chip widget with various styles and options.
final class QlzChip extends StatelessWidget {
  /// The text label of the chip.
  final String label;

  /// The type of the chip.
  final QlzChipType type;

  /// Optional icon to display at the start of the chip.
  final IconData? icon;

  /// Optional callback when the chip is tapped.
  final VoidCallback? onTap;

  /// Optional callback when the chip is deleted.
  final VoidCallback? onDelete;

  /// Whether the chip is selected.
  final bool isSelected;

  /// Whether the chip is outlined.
  final bool isOutlined;

  /// Optional custom background color.
  final Color? backgroundColor;

  /// Optional custom text color.
  final Color? textColor;

  /// Optional custom border color.
  final Color? borderColor;

  /// Optional avatar widget to display at the start of the chip.
  final Widget? avatar;

  /// Optional custom padding.
  final EdgeInsetsGeometry? padding;

  /// The border radius of the chip.
  final BorderRadius? borderRadius;

  /// Whether to show elevation when the chip is selected.
  final bool showElevation;

  /// The elevation value when the chip is selected.
  final double elevation;

  const QlzChip({
    super.key,
    required this.label,
    this.type = QlzChipType.primary,
    this.icon,
    this.onTap,
    this.onDelete,
    this.isSelected = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.avatar,
    this.padding,
    this.borderRadius,
    this.showElevation = true,
    this.elevation = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Determine colors based on type
    final (typeColor, typeBgColor) = _getTypeColors(isDarkMode);

    // Apply custom colors if provided
    final effectiveBackgroundColor =
        backgroundColor ?? (isOutlined ? Colors.transparent : typeBgColor);

    final effectiveTextColor = textColor ??
        (isOutlined ? typeColor : _getTextColorForBackground(typeBgColor));

    final effectiveBorderColor = borderColor ?? typeColor;

    return Material(
      color: Colors.transparent,
      elevation: isSelected && showElevation ? elevation : 0,
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        child: Container(
          padding: padding ??
              const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
          decoration: BoxDecoration(
            color: effectiveBackgroundColor,
            borderRadius: borderRadius ?? BorderRadius.circular(16),
            border: Border.all(
              color: isOutlined ? effectiveBorderColor : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (avatar != null) ...[
                avatar!,
                const SizedBox(width: 4),
              ] else if (icon != null) ...[
                Icon(
                  icon!,
                  size: 16,
                  color: effectiveTextColor,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  color: effectiveTextColor,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (onDelete != null) ...[
                const SizedBox(width: 4),
                InkWell(
                  onTap: onDelete,
                  borderRadius: BorderRadius.circular(12),
                  child: Icon(
                    Icons.close,
                    size: this.onTap != null ? 16 : 18,
                    color: effectiveTextColor.withOpacity(0.7),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  (Color, Color) _getTypeColors(bool isDarkMode) {
    return switch (type) {
      QlzChipType.primary => (
          AppColors.primary,
          isDarkMode
              ? AppColors.primary.withOpacity(0.2)
              : AppColors.primary.withOpacity(0.1),
        ),
      QlzChipType.secondary => (
          AppColors.secondary,
          isDarkMode
              ? AppColors.secondary.withOpacity(0.2)
              : AppColors.secondary.withOpacity(0.1),
        ),
      QlzChipType.success => (
          AppColors.success,
          isDarkMode
              ? AppColors.success.withOpacity(0.2)
              : AppColors.success.withOpacity(0.1),
        ),
      QlzChipType.error => (
          AppColors.error,
          isDarkMode
              ? AppColors.error.withOpacity(0.2)
              : AppColors.error.withOpacity(0.1),
        ),
      QlzChipType.warning => (
          AppColors.warning,
          isDarkMode
              ? AppColors.warning.withOpacity(0.2)
              : AppColors.warning.withOpacity(0.1),
        ),
      QlzChipType.info => (
          Colors.blue,
          isDarkMode
              ? Colors.blue.withOpacity(0.2)
              : Colors.blue.withOpacity(0.1),
        ),
      QlzChipType.ghost => (
          Colors.white,
          Colors.transparent,
        ),
      QlzChipType.custom => (
          backgroundColor ?? AppColors.primary,
          backgroundColor ??
              (isDarkMode
                  ? AppColors.primary.withOpacity(0.2)
                  : AppColors.primary.withOpacity(0.1)),
        ),
    };
  }

  Color _getTextColorForBackground(Color bgColor) {
    // Calculate the luminance to determine if the background is light or dark
    final luminance = bgColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
