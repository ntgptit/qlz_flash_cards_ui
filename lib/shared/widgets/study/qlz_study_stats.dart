// lib/shared/widgets/study/qlz_study_stats.dart

import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/cards/qlz_card.dart';

/// A widget to display study statistics.
final class QlzStudyStats extends StatelessWidget {
  /// The number of terms that have been mastered.
  final int masteredCount;

  /// The number of terms that are still being learned.
  final int learningCount;

  /// The number of terms that haven't been studied yet.
  final int notStudiedCount;

  /// The total number of terms.
  final int totalCount;

  /// The title of the stats widget.
  final String? title;

  /// Whether to show the term counts.
  final bool showCounts;

  /// Whether to show the progress bar.
  final bool showProgressBar;

  /// Whether to show the percentage.
  final bool showPercentage;

  /// The color of the mastered terms.
  final Color masteredColor;

  /// The color of the learning terms.
  final Color learningColor;

  /// The color of the not studied terms.
  final Color notStudiedColor;

  /// The background color of the card.
  final Color? backgroundColor;

  /// The padding around the card.
  final EdgeInsetsGeometry padding;

  /// Whether to show the card border.
  final bool showBorder;

  /// Whether to show the tappable rows.
  final bool showTappableRows;

  /// Callback when the mastered row is tapped.
  final VoidCallback? onMasteredTap;

  /// Callback when the learning row is tapped.
  final VoidCallback? onLearningTap;

  /// Callback when the not studied row is tapped.
  final VoidCallback? onNotStudiedTap;

  const QlzStudyStats({
    super.key,
    required this.masteredCount,
    required this.learningCount,
    required this.notStudiedCount,
    this.title,
    this.showCounts = true,
    this.showProgressBar = true,
    this.showPercentage = true,
    this.masteredColor = AppColors.success,
    this.learningColor = AppColors.warning,
    this.notStudiedColor = AppColors.primary,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(16),
    this.showBorder = false,
    this.showTappableRows = true,
    this.onMasteredTap,
    this.onLearningTap,
    this.onNotStudiedTap,
  }) : totalCount = masteredCount + learningCount + notStudiedCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final effectiveBackgroundColor = backgroundColor ??
        (isDarkMode ? const Color(0xFF12113A) : theme.colorScheme.surface);

    return QlzCard(
      backgroundColor: effectiveBackgroundColor,
      padding: EdgeInsets.zero,
      hasBorder: showBorder,
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(
                title!,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Progress Bar
            if (showProgressBar) _buildProgressBar(context),

            // Stats Rows
            const SizedBox(height: 16),
            _buildStatsRow(
              context,
              label: 'Mastered',
              count: masteredCount,
              color: masteredColor,
              onTap: showTappableRows ? onMasteredTap : null,
              showArrow: showTappableRows && onMasteredTap != null,
            ),
            const Divider(height: 1),
            _buildStatsRow(
              context,
              label: 'Learning',
              count: learningCount,
              color: learningColor,
              onTap: showTappableRows ? onLearningTap : null,
              showArrow: showTappableRows && onLearningTap != null,
            ),
            const Divider(height: 1),
            _buildStatsRow(
              context,
              label: 'Not Studied',
              count: notStudiedCount,
              color: notStudiedColor,
              onTap: showTappableRows ? onNotStudiedTap : null,
              showArrow: showTappableRows && onNotStudiedTap != null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Calculate percentages
    final masteredPercent = totalCount > 0 ? masteredCount / totalCount : 0.0;
    final learningPercent = totalCount > 0 ? learningCount / totalCount : 0.0;
    final notStudiedPercent =
        totalCount > 0 ? notStudiedCount / totalCount : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress Bar
        Container(
          height: 12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: isDarkMode
                ? const Color(0xFF1A1D3D)
                : theme.colorScheme.surfaceContainerHighest,
          ),
          child: Row(
            children: [
              // Mastered
              Flexible(
                flex: (masteredPercent * 100).round(),
                child: Container(
                  decoration: BoxDecoration(
                    color: masteredColor,
                    borderRadius: BorderRadius.horizontal(
                      left: const Radius.circular(6),
                      right: Radius.circular(
                        learningCount == 0 && notStudiedCount == 0 ? 6 : 0,
                      ),
                    ),
                  ),
                ),
              ),
              // Learning
              Flexible(
                flex: (learningPercent * 100).round(),
                child: Container(
                  decoration: BoxDecoration(
                    color: learningColor,
                    borderRadius: BorderRadius.horizontal(
                      right: Radius.circular(
                        notStudiedCount == 0 ? 6 : 0,
                      ),
                    ),
                  ),
                ),
              ),
              // Not Studied
              Flexible(
                flex: (notStudiedPercent * 100).round(),
                child: Container(
                  decoration: BoxDecoration(
                    color: notStudiedColor,
                    borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(6),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Percentage Text
        if (showPercentage) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(masteredPercent * 100).round()}% Mastered',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: masteredColor,
                ),
              ),
              Text(
                '${totalCount} Terms',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.7)
                      : Colors.black.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildStatsRow(
    BuildContext context, {
    required String label,
    required int count,
    required Color color,
    VoidCallback? onTap,
    bool showArrow = false,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: color,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  count.toString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            if (showCounts) ...[
              const Spacer(),
              Text(
                '$count terms',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.7)
                      : Colors.black.withOpacity(0.7),
                ),
              ),
            ],
            if (showArrow) ...[
              if (!showCounts) const Spacer(),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isDarkMode
                    ? Colors.white.withOpacity(0.7)
                    : Colors.black.withOpacity(0.7),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
