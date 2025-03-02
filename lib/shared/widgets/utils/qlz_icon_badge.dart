// lib/shared/widgets/utils/qlz_icon_badge.dart

import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';

/// A widget to display an icon with a badge (typically a notification counter).
final class QlzIconBadge extends StatelessWidget {
  /// The icon to display.
  final IconData icon;

  /// The badge count to display.
  final int? count;

  /// The size of the icon.
  final double iconSize;

  /// The color of the icon.
  final Color? iconColor;

  /// The background color of the badge.
  final Color? badgeColor;

  /// The text color of the badge.
  final Color? badgeTextColor;

  /// The size of the badge.
  final double badgeSize;

  /// The position of the badge.
  final Alignment badgeAlignment;

  /// Whether to show the badge when count is zero.
  final bool showZero;

  /// The maximum count to display before showing a '+' suffix.
  final int maxCount;

  /// Optional callback for when the icon is tapped.
  final VoidCallback? onTap;

  /// Whether to show a dot badge instead of a count.
  final bool showDot;

  /// The padding around the icon.
  final EdgeInsetsGeometry padding;

  /// The tooltip text to display when hovering.
  final String? tooltip;

  const QlzIconBadge({
    super.key,
    required this.icon,
    this.count,
    this.iconSize = 24,
    this.iconColor,
    this.badgeColor,
    this.badgeTextColor,
    this.badgeSize = 16,
    this.badgeAlignment = Alignment.topRight,
    this.showZero = false,
    this.maxCount = 99,
    this.onTap,
    this.showDot = false,
    this.padding = const EdgeInsets.all(8),
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final effectiveIconColor = iconColor ??
        (isDarkMode ? Colors.white : Colors.black.withOpacity(0.8));

    final effectiveBadgeColor = badgeColor ?? AppColors.error;

    final effectiveBadgeTextColor = badgeTextColor ?? Colors.white;

    // Check if we should show the badge
    final shouldShowBadge =
        showDot || (count != null && (count! > 0 || showZero));

    // Create the icon
    Widget iconWidget = Icon(
      icon,
      size: iconSize,
      color: effectiveIconColor,
    );

    // Apply padding
    iconWidget = Padding(
      padding: padding,
      child: iconWidget,
    );

    // Add tooltip if provided
    if (tooltip != null) {
      iconWidget = Tooltip(
        message: tooltip!,
        child: iconWidget,
      );
    }

    // Make the icon tappable if needed
    if (onTap != null) {
      iconWidget = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(padding.vertical),
        child: iconWidget,
      );
    }

    // Return early if no badge needed
    if (!shouldShowBadge) {
      return iconWidget;
    }

    // Create the badge content
    Widget badgeContent;
    if (showDot) {
      // Just a dot, no text
      badgeContent = Container(
        width: badgeSize * 0.75,
        height: badgeSize * 0.75,
        decoration: BoxDecoration(
          color: effectiveBadgeColor,
          shape: BoxShape.circle,
        ),
      );
    } else {
      // Counter badge
      final displayCount = count! > maxCount ? '$maxCount+' : count.toString();

      badgeContent = Container(
        constraints: BoxConstraints(
          minWidth: badgeSize,
          minHeight: badgeSize,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: effectiveBadgeColor,
          borderRadius: BorderRadius.circular(badgeSize / 2),
        ),
        child: Center(
          child: Text(
            displayCount,
            style: TextStyle(
              color: effectiveBadgeTextColor,
              fontSize: badgeSize * 0.65,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Position the badge according to alignment
    final badgeOffset = _getBadgeOffset();

    // Combine the icon and badge
    return Stack(
      clipBehavior: Clip.none,
      children: [
        iconWidget,
        Positioned(
          top: badgeOffset.dy,
          right: badgeOffset.dx,
          child: badgeContent,
        ),
      ],
    );
  }

  Offset _getBadgeOffset() {
    // Default is top-right
    double dx = 0;
    double dy = 0;

    if (badgeAlignment == Alignment.topRight) {
      dx = 0;
      dy = 0;
    } else if (badgeAlignment == Alignment.topLeft) {
      dx = iconSize - badgeSize / 2;
      dy = 0;
    } else if (badgeAlignment == Alignment.bottomRight) {
      dx = 0;
      dy = iconSize - badgeSize / 2;
    } else if (badgeAlignment == Alignment.bottomLeft) {
      dx = iconSize - badgeSize / 2;
      dy = iconSize - badgeSize / 2;
    }

    return Offset(dx, dy);
  }
}
