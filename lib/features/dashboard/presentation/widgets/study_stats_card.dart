// lib/features/dashboard/presentation/widgets/study_stats_card.dart

import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/cards/qlz_card.dart';

/// A card widget displaying study statistics
class StudyStatsCard extends StatelessWidget {
  /// The title of the stat
  final String title;

  /// The value of the stat
  final String value;

  /// The subtitle or description of the stat
  final String? subtitle;

  /// The icon to display
  final IconData icon;

  /// The color of the icon
  final Color? iconColor;

  /// Background color of the icon circle
  final Color? iconBackgroundColor;

  /// Whether to show a border on the card
  final bool showBorder;

  /// Whether the card is tappable
  final VoidCallback? onTap;

  /// Creates a study stats card
  const StudyStatsCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.iconColor,
    this.iconBackgroundColor,
    this.showBorder = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final effectiveIconColor = iconColor ?? AppColors.primary;
    final effectiveIconBackgroundColor = iconBackgroundColor ??
        (isDarkMode
            ? effectiveIconColor.withOpacity(0.2)
            : effectiveIconColor.withOpacity(0.1));

    return QlzCard(
      onTap: onTap,
      hasBorder: showBorder,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: effectiveIconBackgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: effectiveIconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color.fromRGBO(255, 255, 255, 0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
