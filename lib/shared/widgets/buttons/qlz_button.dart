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
  });

  /// Constructor tiện lợi cho Primary Button
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
  }) : variant = QlzButtonVariant.primary;

  /// Constructor tiện lợi cho Secondary Button
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
  }) : variant = QlzButtonVariant.secondary;

  /// Constructor tiện lợi cho Ghost Button
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
  }) : variant = QlzButtonVariant.ghost;

  /// Constructor tiện lợi cho Danger Button
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
  }) : variant = QlzButtonVariant.danger;

  @override
  Widget build(BuildContext context) {
    final EdgeInsets padding = _getPadding();
    final TextStyle textStyle = _getTextStyle(context);

    Widget button = _buildButton(context, padding, textStyle);

    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }

    if (isFullWidth) {
      button = SizedBox(width: double.infinity, child: button);
    }

    return button;
  }

  /// Build the appropriate button based on variant
  Widget _buildButton(
      BuildContext context, EdgeInsets padding, TextStyle textStyle) {
    final Widget content = _buildButtonContent(textStyle);

    return switch (variant) {
      QlzButtonVariant.primary => ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: _getButtonStyle(AppColors.primary, padding),
          child: content,
        ),
      QlzButtonVariant.secondary => OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: _getOutlineButtonStyle(padding),
          child: content,
        ),
      QlzButtonVariant.ghost => TextButton(
          onPressed: isLoading ? null : onPressed,
          style: _getGhostButtonStyle(padding),
          child: content,
        ),
      QlzButtonVariant.danger => ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: _getButtonStyle(AppColors.error, padding),
          child: content,
        ),
    };
  }

  /// Build the content inside the button (icon, label, loading indicator)
  Widget _buildButtonContent(TextStyle textStyle) {
    if (isLoading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
        crossAxisAlignment:
            CrossAxisAlignment.center, // Đảm bảo icon và text căn giữa
        children: [
          leadingWidget,
          const SizedBox(width: 8), // Giữ khoảng cách icon và text hợp lý
          Text(label, style: textStyle),
        ],
      );
    }

    return Text(label, style: textStyle);
  }

  /// Get button style for primary and danger variants
  ButtonStyle _getButtonStyle(Color backgroundColor, EdgeInsets padding) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: Colors.white,
      padding: padding,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
    );
  }

  /// Get outline button style for secondary variant
  ButtonStyle _getOutlineButtonStyle(EdgeInsets padding) {
    return OutlinedButton.styleFrom(
      foregroundColor: Colors.white,
      side: const BorderSide(color: Colors.white),
      padding: padding,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  /// Get ghost button style
  ButtonStyle _getGhostButtonStyle(EdgeInsets padding) {
    return TextButton.styleFrom(
      foregroundColor: Colors.white,
      padding: padding,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  /// Get button padding based on size
  EdgeInsets _getPadding() {
    return switch (size) {
      QlzButtonSize.small =>
        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      QlzButtonSize.medium =>
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      QlzButtonSize.large =>
        const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    };
  }

  /// Get text style based on size and variant
  TextStyle _getTextStyle(BuildContext context) {
    return TextStyle(
      color: _getTextColor(),
      fontWeight: FontWeight.w500,
      fontSize: switch (size) {
        QlzButtonSize.small => 14,
        QlzButtonSize.medium => 16,
        QlzButtonSize.large => 18,
      },
    );
  }

  /// Get text color based on variant
  Color _getTextColor() {
    return switch (variant) {
      QlzButtonVariant.primary || QlzButtonVariant.danger => Colors.white,
      QlzButtonVariant.secondary || QlzButtonVariant.ghost => Colors.white,
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
    return switch (variant) {
      QlzButtonVariant.primary ||
      QlzButtonVariant.danger =>
        Colors.white70, // Giúp icon dễ nhìn hơn
      QlzButtonVariant.secondary || QlzButtonVariant.ghost => Colors.white,
    };
  }
}
