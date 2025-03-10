// lib/features/dashboard/presentation/widgets/streak_card.dart

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
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(vertical: 16),
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
                  borderRadius: BorderRadius.circular(10),
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasStudiedToday
                          ? 'Tiếp tục phát huy!'
                          : 'Duy trì chuỗi ngày học của bạn',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildStreakCounter(),
        ],
      ),
    );
  }

  Widget _buildStreakCounter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStreakInfo(
              'Chuỗi hiện tại',
              '$currentStreak ngày',
              AppColors.primary,
            ),
            _buildStreakInfo(
              'Chuỗi dài nhất',
              '$longestStreak ngày',
              AppColors.secondary,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildWeeklyDots(),
      ],
    );
  }

  Widget _buildStreakInfo(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyDots() {
    // Create a representation of the last 7 days
    // This could be enhanced to use actual data from history

    final now = DateTime.now();
    final weekDays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        // For demo purposes, we'll construct a pattern based on the current streak
        // In a real app, this would use actual historical data
        final dayOfWeek = (now.weekday - 1 + index) % 7;
        final isToday = index == now.weekday - 1;

        // Determine the status of this day
        bool isActive = false;
        if (hasStudiedToday && isToday) {
          isActive = true;
        } else if (!hasStudiedToday && isToday) {
          isActive = false;
        } else if (index < now.weekday - 1) {
          // Past days
          isActive = currentStreak > (now.weekday - 1 - index);
        }

        return _buildDayDot(
          weekDays[dayOfWeek],
          isActive,
          isToday,
        );
      }),
    );
  }

  Widget _buildDayDot(String day, bool isActive, bool isToday) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.success
                : isToday
                    ? AppColors.warning.withOpacity(0.3)
                    : const Color(0xFF1A1D3D),
            shape: BoxShape.circle,
            border: isToday && !isActive
                ? Border.all(color: AppColors.warning, width: 2)
                : null,
          ),
          child: Center(
            child: Icon(
              isActive ? Icons.check : Icons.close,
              color: isActive
                  ? Colors.white
                  : isToday
                      ? AppColors.warning
                      : Colors.white.withOpacity(0.3),
              size: 16,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          day,
          style: TextStyle(
            fontSize: 12,
            color: isToday ? Colors.white : Colors.white.withOpacity(0.7),
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
