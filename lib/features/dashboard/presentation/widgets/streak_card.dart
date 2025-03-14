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
    // Fail Fast: Kiểm tra dữ liệu đầu vào không hợp lệ
    if (currentStreak < 0 ||
        longestStreak < 0 ||
        currentStreak > longestStreak) {
      return const QlzCard(
        backgroundColor: AppColors.darkCard,
        padding: EdgeInsets.all(16),
        // Đã loại bỏ margin
        child: Text(
          'Dữ liệu chuỗi ngày không hợp lệ',
          style: TextStyle(color: AppColors.error),
        ),
      );
    }

    return QlzCard(
      backgroundColor: AppColors.darkCard,
      padding: const EdgeInsets.all(16),
      // Đã loại bỏ margin
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
      BuildContext context, String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.darkTextSecondary
                    .withOpacity(0.85), // Tăng độ sáng
                fontSize: 14, // Chuẩn 14sp
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                // Từ titleLarge xuống titleMedium
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 18, // Giảm từ 20 xuống 18
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

        return _buildDayDot(context, weekDays[dayOfWeek], isActive, isToday);
      }),
    );
  }

  Widget _buildDayDot(
      BuildContext context, String day, bool isActive, bool isToday) {
    if (isActive) {
      return Column(
        children: [
          Container(
            width: 28, // Giảm từ 32 xuống 28
            height: 28,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.check,
                color: AppColors.darkText,
                size: 14, // Giảm từ 16 xuống 14
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            day,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isToday
                      ? AppColors.darkText
                      : AppColors.darkTextSecondary.withOpacity(0.85),
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12, // Chuẩn 12sp
                ),
          ),
        ],
      );
    }
    if (isToday) {
      return Column(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.3),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.warning, width: 2),
            ),
            child: const Center(
              child: Icon(
                Icons.close,
                color: AppColors.warning,
                size: 14, // Giảm từ 16 xuống 14
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            day,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.darkText,
                  fontWeight: FontWeight.bold,
                  fontSize: 12, // Chuẩn 12sp
                ),
          ),
        ],
      );
    }
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: AppColors.darkSurface,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              Icons.close,
              color: AppColors.darkTextSecondary
                  .withOpacity(0.7), // Tăng từ 0.5 lên 0.7
              size: 14, // Giảm từ 16 xuống 14
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          day,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.darkTextSecondary
                    .withOpacity(0.85), // Tăng độ sáng
                fontWeight: FontWeight.normal,
                fontSize: 12, // Chuẩn 12sp
              ),
        ),
      ],
    );
  }
}
