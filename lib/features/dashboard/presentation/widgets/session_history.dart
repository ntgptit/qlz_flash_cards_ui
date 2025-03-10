import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/core/utils/time_formatter.dart';
import 'package:qlz_flash_cards_ui/features/dashboard/data/models/study_history_model.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/cards/qlz_card_item.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_empty_state.dart';

class SessionHistory extends StatelessWidget {
  final List<StudySessionEntry> sessions;
  final int maxSessions;
  final VoidCallback? onViewAll;
  final Function(StudySessionEntry)? onSessionTap;

  const SessionHistory({
    super.key,
    required this.sessions,
    this.maxSessions = 5,
    this.onViewAll,
    this.onSessionTap,
  });

  @override
  Widget build(BuildContext context) {
    final sortedSessions = List<StudySessionEntry>.from(sessions)
      ..sort((a, b) => b.date.compareTo(a.date));
    final displaySessions = sortedSessions.length > maxSessions
        ? sortedSessions.sublist(0, maxSessions)
        : sortedSessions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LỊCH SỬ HỌC TẬP',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
              ),
              if (sessions.length > maxSessions)
                GestureDetector(
                  onTap: onViewAll,
                  child: Row(
                    children: [
                      Text(
                        'Xem tất cả',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: displaySessions.isEmpty
              ? const QlzEmptyState(
                  title: 'Chưa có lịch sử học tập',
                  message: 'Bắt đầu học để ghi lại tiến độ của bạn',
                  icon: Icons.history,
                  // titleColor: AppColors.darkText,
                  // messageColor: AppColors.darkTextSecondary,
                  iconColor: AppColors.darkTextSecondary,
                )
              : Column(
                  children: displaySessions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final session = entry.value;
                    return _buildSessionItem(
                      context,
                      session,
                      showDivider: index < displaySessions.length - 1,
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildSessionItem(
    BuildContext context,
    StudySessionEntry session, {
    bool showDivider = true,
  }) {
    return Column(
      children: [
        QlzCardItem(
          icon: Icons.menu_book_outlined,
          iconColor: AppColors.primary,
          title: session.moduleName,
          titleStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.darkText,
                fontWeight: FontWeight.w500,
              ),
          subtitle: TimeFormatter.formatDateTime(session.date),
          subtitleStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.darkTextSecondary,
              ),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${session.termsLearned}/${session.termsStudied} từ',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: session.termsLearned > 0
                          ? AppColors.success
                          : AppColors.darkText,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                TimeFormatter.formatDuration(session.durationSeconds),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.darkTextSecondary,
                    ),
              ),
            ],
          ),
          onTap: () => onSessionTap?.call(session),
        ),
        if (showDivider)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Divider(
              height: 1,
              color: AppColors.darkBorder,
            ),
          ),
      ],
    );
  }
}
