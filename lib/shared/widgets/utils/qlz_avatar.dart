// lib/shared/widgets/utils/qlz_avatar.dart

import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';

/// A custom avatar widget with support for images, initials,
/// badges, and placeholder fallbacks.
final class QlzAvatar extends StatelessWidget {
  /// The image URL for the avatar.
  final String? imageUrl;

  /// The image asset path for the avatar.
  final String? assetPath;

  /// The user's name for generating initials.
  final String? name;

  /// The size of the avatar.
  final double size;

  /// The shape of the avatar.
  final BoxShape shape;

  /// The background color for text-based avatars.
  final Color? backgroundColor;

  /// The color of the text for text-based avatars.
  final Color? textColor;

  /// The border width for the avatar.
  final double borderWidth;

  /// The border color for the avatar.
  final Color? borderColor;

  /// The badge to display on the avatar.
  final Widget? badge;

  /// The position of the badge.
  final Alignment badgeAlignment;

  /// Callback when the avatar is tapped.
  final VoidCallback? onTap;

  /// The icon to display for placeholder avatars.
  final IconData placeholderIcon;

  /// Whether to use a placeholder when image is not available.
  final bool usePlaceholder;

  /// Whether the user is online.
  final bool isOnline;

  /// The color of the online indicator.
  final Color onlineColor;

  /// The size of the online indicator.
  final double onlineIndicatorSize;

  /// Whether to show a plus badge.
  final bool showPlusBadge;

  /// The color of the plus badge.
  final Color? plusBadgeColor;

  const QlzAvatar({
    super.key,
    this.imageUrl,
    this.assetPath,
    this.name,
    this.size = 40,
    this.shape = BoxShape.circle,
    this.backgroundColor,
    this.textColor,
    this.borderWidth = 0,
    this.borderColor,
    this.badge,
    this.badgeAlignment = Alignment.bottomRight,
    this.onTap,
    this.placeholderIcon = Icons.person,
    this.usePlaceholder = true,
    this.isOnline = false,
    this.onlineColor = AppColors.success,
    this.onlineIndicatorSize = 12,
    this.showPlusBadge = false,
    this.plusBadgeColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final effectiveBackgroundColor = backgroundColor ??
        (isDarkMode
            ? const Color(0xFF1A1D3D)
            : theme.colorScheme.primary.withOpacity(0.1));

    final effectiveTextColor =
        textColor ?? (isDarkMode ? Colors.white : theme.colorScheme.primary);

    final effectiveBorderColor = borderColor ??
        (isDarkMode ? AppColors.darkBorder : AppColors.lightBorder);

    // Build the avatar content
    Widget avatarContent;

    if (imageUrl != null) {
      avatarContent = Container(
        decoration: BoxDecoration(
          shape: shape,
          image: DecorationImage(
            image: NetworkImage(imageUrl!),
            fit: BoxFit.cover,
            onError: (_, __) => usePlaceholder,
          ),
        ),
      );
    } else if (assetPath != null) {
      avatarContent = Container(
        decoration: BoxDecoration(
          shape: shape,
          image: DecorationImage(
            image: AssetImage(assetPath!),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else if (name != null && name!.isNotEmpty) {
      avatarContent = Container(
        decoration: BoxDecoration(
          color: effectiveBackgroundColor,
          shape: shape,
        ),
        alignment: Alignment.center,
        child: Text(
          _getInitials(name!),
          style: TextStyle(
            color: effectiveTextColor,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.4,
          ),
        ),
      );
    } else {
      avatarContent = Container(
        decoration: BoxDecoration(
          color: effectiveBackgroundColor,
          shape: shape,
        ),
        alignment: Alignment.center,
        child: Icon(
          placeholderIcon,
          size: size * 0.5,
          color: effectiveTextColor,
        ),
      );
    }

    // Add border if needed
    if (borderWidth > 0) {
      avatarContent = Container(
        decoration: BoxDecoration(
          shape: shape,
          border: Border.all(
            color: effectiveBorderColor,
            width: borderWidth,
          ),
        ),
        child: ClipRRect(
          borderRadius: shape == BoxShape.circle
              ? BorderRadius.circular(size / 2)
              : BorderRadius.zero,
          child: avatarContent,
        ),
      );
    }

    // Make tappable if needed
    if (onTap != null) {
      avatarContent = InkWell(
        onTap: onTap,
        customBorder: shape == BoxShape.circle ? const CircleBorder() : null,
        child: avatarContent,
      );
    }

    // Add badge or online indicator
    Widget result = Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: avatarContent,
        ),
        if (badge != null)
          Positioned(
            top: badgeAlignment.y > 0 ? null : 0,
            bottom: badgeAlignment.y < 0 ? null : 0,
            left: badgeAlignment.x < 0 ? null : 0,
            right: badgeAlignment.x > 0 ? null : 0,
            child: badge!,
          ),
        if (isOnline)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: onlineIndicatorSize,
              height: onlineIndicatorSize,
              decoration: BoxDecoration(
                color: onlineColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDarkMode ? AppColors.darkBackground : Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),
        if (showPlusBadge)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: plusBadgeColor ??
                    (isDarkMode
                        ? AppColors.primary.withOpacity(0.2)
                        : AppColors.primary.withOpacity(0.1)),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDarkMode ? AppColors.darkBackground : Colors.white,
                  width: 1,
                ),
              ),
              child: Text(
                'Plus',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: size * 0.2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );

    return result;
  }

  String _getInitials(String name) {
    final nameParts = name.trim().split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts.first[0]}${nameParts.last[0]}'.toUpperCase();
    } else if (nameParts.isNotEmpty) {
      return nameParts.first[0].toUpperCase();
    }
    return '';
  }
}
