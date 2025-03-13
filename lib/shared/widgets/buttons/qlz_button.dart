import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';

/// Button variant types for the application
enum QlzButtonVariant { primary, secondary, ghost, danger }

/// Button size options
enum QlzButtonSize { small, medium, large }

/// A customized button component for the application that supports
/// different variants, sizes, and states.
final class QlzButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final String? imageAssetPath;
  final double imageSize;
  final VoidCallback? onPressed;
  final QlzButtonVariant variant;
  final QlzButtonSize size;
  final bool isFullWidth;
  final bool isLoading;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final EdgeInsets? padding; // Thêm tham số padding tùy chọn

  const QlzButton({
    super.key,
    required this.label,
    this.icon,
    this.imageAssetPath,
    this.imageSize = 24,
    this.onPressed,
    this.variant = QlzButtonVariant.primary,
    this.size = QlzButtonSize.medium,
    this.isFullWidth = false,
    this.isLoading = false,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.padding, // Thêm vào constructor chính
  });

  const QlzButton.primary({
    super.key,
    required this.label,
    this.icon,
    this.imageAssetPath,
    this.imageSize = 24,
    this.onPressed,
    this.size = QlzButtonSize.medium,
    this.isFullWidth = false,
    this.isLoading = false,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.padding, // Thêm vào constructor primary
  }) : variant = QlzButtonVariant.primary;

  const QlzButton.secondary({
    super.key,
    required this.label,
    this.icon,
    this.imageAssetPath,
    this.imageSize = 24,
    this.onPressed,
    this.size = QlzButtonSize.medium,
    this.isFullWidth = false,
    this.isLoading = false,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.padding, // Thêm vào constructor secondary
  }) : variant = QlzButtonVariant.secondary;

  const QlzButton.ghost({
    super.key,
    required this.label,
    this.icon,
    this.imageAssetPath,
    this.imageSize = 24,
    this.onPressed,
    this.size = QlzButtonSize.medium,
    this.isFullWidth = false,
    this.isLoading = false,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.padding, // Thêm vào constructor ghost
  }) : variant = QlzButtonVariant.ghost;

  const QlzButton.danger({
    super.key,
    required this.label,
    this.icon,
    this.imageAssetPath,
    this.imageSize = 24,
    this.onPressed,
    this.size = QlzButtonSize.medium,
    this.isFullWidth = false,
    this.isLoading = false,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.padding, // Thêm vào constructor danger
  }) : variant = QlzButtonVariant.danger;

  @override
  Widget build(BuildContext context) {
    final EdgeInsets effectivePadding =
        padding ?? _getPadding(); // Ưu tiên padding tùy chỉnh
    final TextStyle textStyle = _getTextStyle(context);

    Widget button = _buildButton(context, effectivePadding, textStyle);

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.darkText,
            ),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(4),
        ),
        child: button,
      );
    }

    if (isFullWidth) {
      button = SizedBox(width: double.infinity, child: button);
    }

    return button;
  }

  /// Build the appropriate button based on variant
  Widget _buildButton(
    BuildContext context,
    EdgeInsets padding,
    TextStyle textStyle,
  ) {
    final Widget content = _buildButtonContent(textStyle);

    return switch (variant) {
      QlzButtonVariant.primary => ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: _getButtonStyle(
            backgroundColor: backgroundColor ?? AppColors.primary,
            foregroundColor: foregroundColor ?? AppColors.darkText,
            padding: padding,
            borderColor: borderColor,
          ),
          child: content,
        ),
      QlzButtonVariant.secondary => OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: _getOutlineButtonStyle(
            backgroundColor: backgroundColor ?? Colors.transparent,
            foregroundColor: foregroundColor ?? AppColors.darkText,
            borderColor: borderColor ?? AppColors.darkText,
            padding: padding,
          ),
          child: content,
        ),
      QlzButtonVariant.ghost => TextButton(
          onPressed: isLoading ? null : onPressed,
          style: _getGhostButtonStyle(
            foregroundColor: foregroundColor ?? AppColors.darkText,
            padding: padding,
          ),
          child: content,
        ),
      QlzButtonVariant.danger => ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: _getButtonStyle(
            backgroundColor: backgroundColor ?? AppColors.error,
            foregroundColor: foregroundColor ?? AppColors.darkText,
            padding: padding,
            borderColor: borderColor,
          ),
          child: content,
        ),
    };
  }

  /// Build the content inside the button (icon, label, loading indicator)
  Widget _buildButtonContent(TextStyle textStyle) {
    if (isLoading) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            foregroundColor ?? AppColors.darkText,
          ),
        ),
      );
    }

    Widget? leadingWidget;

    if (imageAssetPath != null) {
      leadingWidget =
          Image.asset(imageAssetPath!, width: imageSize, height: imageSize);
    } else if (icon != null) {
      leadingWidget = Icon(
        icon,
        size: _getIconSize(),
        color: _getIconColor(),
      );
    }

    if (leadingWidget != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          leadingWidget,
          const SizedBox(width: 8),
          Text(label, style: textStyle),
        ],
      );
    }

    return Text(label, style: textStyle);
  }

  /// Get button style for primary and danger variants
  ButtonStyle _getButtonStyle({
    required Color backgroundColor,
    required Color foregroundColor,
    required EdgeInsets padding,
    Color? borderColor,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      padding: padding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: borderColor != null
            ? BorderSide(color: borderColor)
            : BorderSide.none,
      ),
      elevation: 0,
    );
  }

  /// Get outline button style for secondary variant
  ButtonStyle _getOutlineButtonStyle({
    required Color backgroundColor,
    required Color foregroundColor,
    required Color borderColor,
    required EdgeInsets padding,
  }) {
    return OutlinedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      side: BorderSide(color: borderColor),
      padding: padding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  /// Get ghost button style
  ButtonStyle _getGhostButtonStyle({
    required Color foregroundColor,
    required EdgeInsets padding,
  }) {
    return TextButton.styleFrom(
      foregroundColor: foregroundColor,
      padding: padding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  /// Get button padding based on size, standardized with 16dp where possible
  EdgeInsets _getPadding() {
    return switch (size) {
      QlzButtonSize.small =>
        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      QlzButtonSize.medium =>
        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      QlzButtonSize.large =>
        const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    };
  }

  /// Get text style based on size and variant
  TextStyle _getTextStyle(BuildContext context) {
    return Theme.of(context).textTheme.labelLarge!.copyWith(
          color: _getTextColor(),
          fontWeight: FontWeight.w500,
          fontSize: switch (size) {
            QlzButtonSize.small => 14,
            QlzButtonSize.medium => 16,
            QlzButtonSize.large => 18,
          },
        );
  }

  /// Get text color based on variant and foregroundColor
  Color _getTextColor() {
    return foregroundColor ??
        switch (variant) {
          QlzButtonVariant.primary => AppColors.darkText,
          QlzButtonVariant.secondary => AppColors.darkText,
          QlzButtonVariant.ghost => AppColors.darkText,
          QlzButtonVariant.danger => AppColors.darkText,
        };
  }

  /// Get icon size based on button size
  double _getIconSize() {
    return switch (size) {
      QlzButtonSize.small => 16,
      QlzButtonSize.medium => 20,
      QlzButtonSize.large => 24,
    };
  }

  /// Get icon color to contrast with button background
  Color _getIconColor() {
    return foregroundColor ??
        switch (variant) {
          QlzButtonVariant.primary => AppColors.darkTextSecondary,
          QlzButtonVariant.secondary => AppColors.darkText,
          QlzButtonVariant.ghost => AppColors.darkText,
          QlzButtonVariant.danger => AppColors.darkTextSecondary,
        };
  }
}
