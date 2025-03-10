// lib/features/dashboard/presentation/widgets/session_history.dart

import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/features/dashboard/data/models/study_history_model.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/cards/qlz_card.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/labels/qlz_label.dart';

/// A widget for displaying recent study session history
class SessionHistory extends StatelessWidget {
  /// List of study session entries
  final List<StudySessionEntry> sessions;

  /// Maximum number of sessions to display
  final int maxSessions;

  /// Callback when the "View All" button is pressed
  final VoidCallback? onViewAll;

  /// Callback when a session entry is tapped
  final Function(StudySessionEntry)? onSessionTap;

  /// Creates a session history widget
  const SessionHistory({
    super.key,
    required this.sessions,
    this.maxSessions = 5,
    this.onViewAll,
    this.onSessionTap,
  });

  @override
  Widget build(BuildContext context) {
    // Sort sessions by date (most recent first)
    final sortedSessions = List<StudySessionEntry>.from(sessions)
      ..sort((a, b) => b.date.compareTo(a.date));

    // Take only the specified maximum number
    final displaySessions = sortedSessions.length > maxSessions
        ? sortedSessions.sublist(0, maxSessions)
        : sortedSessions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const QlzLabel('LỊCH SỬ HỌC TẬP'),
              if (sessions.length > maxSessions)
                GestureDetector(
                  onTap: onViewAll,
                  child: const Row(
                    children: [
                      Text(
                        'Xem tất cả',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
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
        QlzCard(
          padding: EdgeInsets.zero,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: displaySessions.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: displaySessions
                      .asMap()
                      .map(
                        (index, session) => MapEntry(
                          index,
                          _buildSessionItem(
                            session,
                            showDivider: index < displaySessions.length - 1,
                          ),
                        ),
                      )
                      .values
                      .toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 48,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chưa có lịch sử học tập',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bắt đầu học để ghi lại tiến độ của bạn',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionItem(StudySessionEntry session,
      {bool showDivider = true}) {
    return InkWell(
      onTap: () => onSessionTap?.call(session),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.menu_book_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.moduleName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDateTime(session.date),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.7),
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
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: session.termsLearned > 0
                            ? AppColors.success
                            : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDuration(session.durationSeconds),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (showDivider)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Divider(
                  height: 1,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    // Format as "Hôm nay, 15:30" or "Hôm qua, 15:30" or "15/03, 15:30"
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String prefix;
    if (date == today) {
      prefix = 'Hôm nay';
    } else if (date == yesterday) {
      prefix = 'Hôm qua';
    } else {
      prefix =
          '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}';
    }

    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$prefix, $hour:$minute';
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) {
      return '$seconds giây';
    } else if (seconds < 3600) {
      return '${(seconds / 60).round()} phút';
    } else {
      final hours = seconds ~/ 3600;
      final minutes = (seconds % 3600) ~/ 60;
      return '$hours giờ ${minutes > 0 ? '$minutes phút' : ''}';
    }
  }
}
