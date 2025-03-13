import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';

/// Icon button variants for different visual styles
enum QlzIconButtonVariant {
  primary,
  secondary,
  outlined,
  ghost,
  danger,
}

/// Size options for icon buttons
enum QlzIconButtonSize {
  small,
  medium,
  large,
}

/// A customized icon button component for the application that supports
/// different variants, sizes, and states.
final class QlzIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final QlzIconButtonVariant variant;
  final QlzIconButtonSize size;
  final bool isLoading;
  final String? tooltip;
  final bool isDisabled;
  final int badgeCount;

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
    final double buttonSize = _getButtonSize();
    final Color backgroundColor = _getBackgroundColor();
    final Color iconColor = _getIconColor();
    final double iconSize = _getIconSize();
    final BorderSide borderSide = _getBorderSide();

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
      button = Badge.count(
        count: badgeCount,
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

    // Apply disabled effect using ColorFiltered
    if (isDisabled && !isLoading) {
      button = ColorFiltered(
        colorFilter: ColorFilter.mode(
          Colors.grey.withOpacity(0.5),
          BlendMode.saturation,
        ),
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
  Color _getBackgroundColor() => switch (variant) {
        QlzIconButtonVariant.primary => AppColors.primary.withOpacity(0.1),
        QlzIconButtonVariant.secondary => AppColors.secondary.withOpacity(0.1),
        QlzIconButtonVariant.outlined => Colors.transparent,
        QlzIconButtonVariant.ghost => Colors.transparent,
        QlzIconButtonVariant.danger => AppColors.error.withOpacity(0.1),
      };

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
