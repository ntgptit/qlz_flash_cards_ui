// lib/shared/widgets/inputs/qlz_icon_button.dart

import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';

/// Icon button variants for different visual styles
enum QlzIconButtonVariant {
  /// Primary color filled background
  primary,

  /// Secondary color filled background
  secondary,

  /// Transparent background with border
  outlined,

  /// Completely transparent background
  ghost,

  /// Error/danger color filled background
  danger,
}

/// Size options for icon buttons
enum QlzIconButtonSize {
  /// Small icon button (32x32)
  small,

  /// Medium icon button (40x40)
  medium,

  /// Large icon button (48x48)
  large,
}

/// A customized icon button component for the application that supports
/// different variants, sizes, and states.
final class QlzIconButton extends StatelessWidget {
  /// The icon to display
  final IconData icon;

  /// Optional callback when the button is pressed
  final VoidCallback? onPressed;

  /// Button style variant
  final QlzIconButtonVariant variant;

  /// Button size
  final QlzIconButtonSize size;

  /// Whether the button is in a loading state
  final bool isLoading;

  /// Optional tooltip text
  final String? tooltip;

  /// Whether the button is disabled
  final bool isDisabled;

  /// Badge count to display (if greater than 0)
  final int badgeCount;

  /// Create a custom icon button with various styling options
  const QlzIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.variant = QlzIconButtonVariant.ghost,
    this.size = QlzIconButtonSize.medium,
    this.isLoading = false,
    this.tooltip,
    this.isDisabled = false,
    this.badgeCount = 0,
  });

  /// Convenience constructor for a primary filled icon button
  const QlzIconButton.primary({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = QlzIconButtonSize.medium,
    this.isLoading = false,
    this.tooltip,
    this.isDisabled = false,
    this.badgeCount = 0,
  }) : variant = QlzIconButtonVariant.primary;

  /// Convenience constructor for a secondary filled icon button
  const QlzIconButton.secondary({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = QlzIconButtonSize.medium,
    this.isLoading = false,
    this.tooltip,
    this.isDisabled = false,
    this.badgeCount = 0,
  }) : variant = QlzIconButtonVariant.secondary;

  /// Convenience constructor for an outlined icon button
  const QlzIconButton.outlined({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = QlzIconButtonSize.medium,
    this.isLoading = false,
    this.tooltip,
    this.isDisabled = false,
    this.badgeCount = 0,
  }) : variant = QlzIconButtonVariant.outlined;

  /// Convenience constructor for a ghost (transparent) icon button
  const QlzIconButton.ghost({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = QlzIconButtonSize.medium,
    this.isLoading = false,
    this.tooltip,
    this.isDisabled = false,
    this.badgeCount = 0,
  }) : variant = QlzIconButtonVariant.ghost;

  /// Convenience constructor for a danger/error icon button
  const QlzIconButton.danger({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = QlzIconButtonSize.medium,
    this.isLoading = false,
    this.tooltip,
    this.isDisabled = false,
    this.badgeCount = 0,
  }) : variant = QlzIconButtonVariant.danger;

  @override
  Widget build(BuildContext context) {
    // Define core properties
    final double buttonSize = _getButtonSize();
    final Color backgroundColor = _getBackgroundColor();
    final Color iconColor = _getIconColor();
    final double iconSize = _getIconSize();
    final BorderSide borderSide = _getBorderSide();

    // Create the button widget
    Widget button = Material(
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderSide.width > 0 ? 12 : 16),
        side: borderSide,
      ),
      child: InkWell(
        onTap: (isDisabled || isLoading) ? null : onPressed,
        borderRadius: BorderRadius.circular(borderSide.width > 0 ? 12 : 16),
        child: SizedBox(
          width: buttonSize,
          height: buttonSize,
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: iconSize,
                    height: iconSize,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                    ),
                  )
                : Icon(
                    icon,
                    color: iconColor,
                    size: iconSize,
                  ),
          ),
        ),
      ),
    );

    // Wrap with badge if needed
    if (badgeCount > 0) {
      button = Badge(
        label: Text(
          badgeCount > 99 ? '99+' : badgeCount.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
          ),
        ),
        backgroundColor: AppColors.error,
        child: button,
      );
    }

    // Wrap with tooltip if needed
    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    // Apply opacity if disabled
    if (isDisabled && !isLoading) {
      button = Opacity(
        opacity: 0.5,
        child: button,
      );
    }

    return button;
  }

  /// Get the size of the button based on the size enum
  double _getButtonSize() => switch (size) {
        QlzIconButtonSize.small => 32,
        QlzIconButtonSize.medium => 40,
        QlzIconButtonSize.large => 48,
      };

  /// Get the icon size based on the button size
  double _getIconSize() => switch (size) {
        QlzIconButtonSize.small => 16,
        QlzIconButtonSize.medium => 20,
        QlzIconButtonSize.large => 24,
      };

  /// Get the background color based on the variant
  Color _getBackgroundColor() {
    // Base opacity for the background
    final double opacity = variant == QlzIconButtonVariant.ghost ? 0.0 : 0.1;

    return switch (variant) {
      QlzIconButtonVariant.primary => AppColors.primary.withOpacity(opacity),
      QlzIconButtonVariant.secondary =>
        AppColors.secondary.withOpacity(opacity),
      QlzIconButtonVariant.outlined => Colors.transparent,
      QlzIconButtonVariant.ghost => Colors.transparent,
      QlzIconButtonVariant.danger => AppColors.error.withOpacity(opacity),
    };
  }

  /// Get the icon color based on the variant
  Color _getIconColor() => switch (variant) {
        QlzIconButtonVariant.primary => AppColors.primary,
        QlzIconButtonVariant.secondary => Colors.white,
        QlzIconButtonVariant.outlined => Colors.white,
        QlzIconButtonVariant.ghost => Colors.white,
        QlzIconButtonVariant.danger => AppColors.error,
      };

  /// Get the border side based on the variant
  BorderSide _getBorderSide() => switch (variant) {
        QlzIconButtonVariant.outlined => BorderSide(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        _ => BorderSide.none,
      };
}
