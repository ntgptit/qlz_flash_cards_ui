import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/features/dashboard/logic/states/dashboard_state.dart';
import 'package:qlz_flash_cards_ui/features/dashboard/presentation/widgets/study_stats_card.dart';

class StatsOverview extends StatelessWidget {
  final DashboardState state;

  const StatsOverview({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thống kê học tập',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StudyStatsCard(
                title: 'Tổng thời gian',
                value: state.stats.formattedStudyTime,
                subtitle: '${state.stats.totalSessionsCompleted} phiên',
                icon: Icons.timer_outlined,
                iconColor: AppColors.warning,
                onTap: () => _showSnackBar(context, 'Chi tiết thời gian học'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StudyStatsCard(
                title: 'Từ đã học',
                value: '${state.stats.totalTermsLearned}',
                subtitle: '${state.stats.totalDifficultTerms} từ khó',
                icon: Icons.school_outlined,
                iconColor: AppColors.success,
                onTap: () => _showSnackBar(context, 'Chi tiết từ đã học'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
