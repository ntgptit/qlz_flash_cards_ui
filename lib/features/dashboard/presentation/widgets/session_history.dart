import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/core/utils/time_formatter.dart';
import 'package:qlz_flash_cards_ui/features/dashboard/data/models/study_history_model.dart';
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

    // Guard Clause: Thoát sớm nếu danh sách rỗng
    if (displaySessions.isEmpty) {
      return const QlzEmptyState(
        title: 'Chưa có lịch sử học tập',
        message: 'Bắt đầu học để ghi lại tiến độ của bạn',
        icon: Icons.history,
        iconColor: AppColors.darkTextSecondary,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displaySessions.length,
          itemBuilder: (context, index) {
            return _buildSessionItem(
              context,
              displaySessions[index],
              showDivider: index < displaySessions.length - 1,
            );
          },
        ),
      ],
    );
  }

  Widget _buildSessionItem(BuildContext context, StudySessionEntry session,
      {bool showDivider = true}) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: Ink(
            decoration: BoxDecoration(
              color: Colors
                  .transparent, // Transparent để không có background khi không tap
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () => onSessionTap?.call(session),
              splashColor: AppColors.primary.withOpacity(0.1),
              highlightColor: AppColors.primary.withOpacity(0.05),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.menu_book_outlined,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.moduleName,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.darkText,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            TimeFormatter.formatDateTime(session.date),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.darkTextSecondary
                                          .withOpacity(0.85),
                                      fontSize: 12,
                                    ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${session.termsLearned}/${session.termsStudied} từ',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: session.termsLearned > 0
                                        ? AppColors.success
                                        : AppColors.darkText.withOpacity(0.9),
                                    fontSize: 14,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          TimeFormatter.formatDuration(session.durationSeconds),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.darkTextSecondary
                                        .withOpacity(0.85),
                                    fontSize: 12,
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (showDivider)
          const Padding(
            padding: EdgeInsets.only(
                left: 80), // Đẩy divider sang phải, bắt đầu từ sau icon
            child: Divider(
              height: 1.5,
              color: AppColors.darkBorder,
            ),
          ),
      ],
    );
  }
}
