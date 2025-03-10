import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/cards/qlz_card.dart';

/// A card widget displaying the user's current study streak
class StreakCard extends StatelessWidget {
  /// The current streak (days in a row)
  final int currentStreak;

  /// The longest streak achieved
  final int longestStreak;

  /// Whether the user has studied today
  final bool hasStudiedToday;

  /// Callback when the card is tapped
  final VoidCallback? onTap;

  /// Creates a streak card
  const StreakCard({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
    required this.hasStudiedToday,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return QlzCard(
      backgroundColor: AppColors.darkCard,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      onTap: onTap,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: hasStudiedToday
                      ? AppColors.success.withOpacity(0.2)
                      : AppColors.warning.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  hasStudiedToday ? Icons.local_fire_department : Icons.alarm,
                  color:
                      hasStudiedToday ? AppColors.success : AppColors.warning,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasStudiedToday ? 'Hôm nay đã học' : 'Học ngay hôm nay',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasStudiedToday
                          ? 'Tiếp tục phát huy!'
                          : 'Duy trì chuỗi ngày học của bạn',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.darkTextSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStreakCounter(context),
        ],
      ),
    );
  }

  Widget _buildStreakCounter(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStreakInfo(
              context,
              'Chuỗi hiện tại',
              '$currentStreak ngày',
              AppColors.primary,
            ),
            _buildStreakInfo(
              context,
              'Chuỗi dài nhất',
              '$longestStreak ngày',
              AppColors.secondary,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildWeeklyDots(context),
      ],
    );
  }

  Widget _buildStreakInfo(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.darkTextSecondary,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }

  Widget _buildWeeklyDots(BuildContext context) {
    final now = DateTime.now();
    final weekDays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final dayOfWeek = (now.weekday - 1 + index) % 7;
        final isToday = index == now.weekday - 1;

        bool isActive = false;
        if (hasStudiedToday && isToday) {
          isActive = true;
        } else if (!hasStudiedToday && isToday) {
          isActive = false;
        } else if (index < now.weekday - 1) {
          isActive = currentStreak > (now.weekday - 1 - index);
        }

        return _buildDayDot(
          context,
          weekDays[dayOfWeek],
          isActive,
          isToday,
        );
      }),
    );
  }

  Widget _buildDayDot(
    BuildContext context,
    String day,
    bool isActive,
    bool isToday,
  ) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.success
                : isToday
                    ? AppColors.warning.withOpacity(0.3)
                    : AppColors.darkSurface,
            shape: BoxShape.circle,
            border: isToday && !isActive
                ? Border.all(color: AppColors.warning, width: 2)
                : null,
          ),
          child: Center(
            child: Icon(
              isActive ? Icons.check : Icons.close,
              color: isActive
                  ? AppColors.darkText
                  : isToday
                      ? AppColors.warning
                      : AppColors.darkTextSecondary.withOpacity(0.5),
              size: 16,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          day,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color:
                    isToday ? AppColors.darkText : AppColors.darkTextSecondary,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
        ),
      ],
    );
  }
}
