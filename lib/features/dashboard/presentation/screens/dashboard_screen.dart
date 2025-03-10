import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/core/utils/time_formatter.dart';
import 'package:qlz_flash_cards_ui/features/dashboard/logic/cubit/dashboard_cubit.dart';
import 'package:qlz_flash_cards_ui/features/dashboard/logic/states/dashboard_state.dart';
import 'package:qlz_flash_cards_ui/features/dashboard/presentation/widgets/recommended_modules.dart';
import 'package:qlz_flash_cards_ui/features/dashboard/presentation/widgets/session_history.dart';
import 'package:qlz_flash_cards_ui/features/dashboard/presentation/widgets/streak_card.dart';
import 'package:qlz_flash_cards_ui/features/dashboard/presentation/widgets/study_chart.dart';
import 'package:qlz_flash_cards_ui/features/dashboard/presentation/widgets/study_stats_card.dart';
import 'package:qlz_flash_cards_ui/features/module/data/models/study_module_model.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/buttons/qlz_button.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardCubit>().loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state.status == DashboardStatus.initial ||
              (state.status == DashboardStatus.loading &&
                  state.stats.lastStudyDate == null)) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }
          if (state.status == DashboardStatus.failure) {
            return _buildErrorState(context);
          }
          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.darkSurface,
            onRefresh: () => context.read<DashboardCubit>().refreshDashboard(),
            child: _buildDashboardContent(state),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            'Không thể tải dữ liệu',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: AppColors.darkTextSecondary),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => context.read<DashboardCubit>().refreshDashboard(),
            child: const Text('Thử lại', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(DashboardState state) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        _buildSliverAppBar(),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              if (!state.hasStudiedToday) _buildTodayGoalCard(),
              const SizedBox(height: 16),
              _buildStatsOverview(state),
              const SizedBox(height: 16),
              StreakCard(
                currentStreak: state.stats.currentStreak,
                longestStreak: state.stats.longestStreak,
                hasStudiedToday: state.hasStudiedToday,
                onTap: () => _showMotivationSnackBar(context),
              ),
              const SizedBox(height: 24),
              StudyActivityChart(
                dailyStudyTime: state.filteredHistory.dailyStudyTime,
                dailyTermsLearned: state.filteredHistory.dailyTermsLearned,
                timePeriod: state.selectedTimePeriod,
                onPeriodChanged: (period) =>
                    context.read<DashboardCubit>().changeTimePeriod(period),
              ),
              const SizedBox(height: 24),
              RecommendedModules(
                modules: state.recommendedModules,
                onViewAll: () => _showSnackBar(context, 'Xem tất cả học phần'),
                onModuleTap: (module) =>
                    _navigateToModuleDetail(context, module),
              ),
              const SizedBox(height: 24),
              SessionHistory(
                sessions: state.filteredHistory.sessions,
                onViewAll: () => _showSnackBar(context, 'Xem toàn bộ lịch sử'),
                onSessionTap: (session) => _showSnackBar(
                    context, 'Chi tiết phiên: ${session.moduleName}'),
              ),
              const SizedBox(height: 40),
            ]),
          ),
        ),
      ],
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      elevation: 0,
      backgroundColor: AppColors.darkBackground,
      expandedHeight: 120,
      floating: true,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        title: Text(
          'Tổng quan học tập',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.darkText,
                fontWeight: FontWeight.bold,
              ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary.withOpacity(0.2),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: AppColors.primary),
          onPressed: () => _showSnackBar(context, 'Tìm kiếm đang phát triển'),
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none, color: AppColors.primary),
          onPressed: () => _showSnackBar(context, 'Thông báo đang phát triển'),
        ),
      ],
    );
  }

  Widget _buildTodayGoalCard() {
    return Card(
      elevation: 4,
      color: AppColors.darkCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              child: const Icon(Icons.calendar_today,
                  color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mục tiêu hôm nay',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.darkText,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Học 5 phút để duy trì chuỗi',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.darkTextSecondary,
                        ),
                  ),
                ],
              ),
            ),
            QlzButton.primary(
                label: 'Bắt đầu học ngay',
                onPressed: () => _showSnackBar(context, 'Bắt đầu học ngay'))
            // ElevatedButton(
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: AppColors.primary,
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(12),
            //     ),
            //   ),
            //   onPressed: () => _showSnackBar(context, 'Bắt đầu học ngay'),
            //   child: const Text('Học ngay'),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsOverview(DashboardState state) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StudyStatsCard(
                title: 'Tổng thời gian',
                value: state.stats.formattedStudyTime,
                subtitle: '${state.stats.totalSessionsCompleted} phiên',
                icon: Icons.timer_outlined,
                iconColor: AppColors.warning,
                onTap: () => _showSnackBar(context,
                    'Tổng thời gian: ${state.stats.formattedStudyTime}'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StudyStatsCard(
                title: 'Từ đã học',
                value: '${state.stats.totalTermsLearned}',
                subtitle: '${state.stats.totalDifficultTerms} từ khó',
                icon: Icons.school_outlined,
                iconColor: AppColors.success,
                onTap: () => _showSnackBar(
                    context, 'Tổng từ: ${state.stats.totalTermsLearned}'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        StudyStatsCard(
          title: state.periodLabel,
          value: '${state.periodTotalTermsLearned} từ',
          subtitle: TimeFormatter.formatDuration(state.periodTotalStudyTime),
          icon: Icons.insights_outlined,
          iconColor: AppColors.primary,
          onTap: () => _showSnackBar(context,
              '${state.periodLabel}: ${state.periodTotalTermsLearned} từ'),
        ),
      ],
    );
  }

  void _navigateToModuleDetail(BuildContext context, StudyModule module) {
    _showSnackBar(context, 'Mở học phần: ${module.title}');
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(message, style: const TextStyle(color: AppColors.darkText)),
        backgroundColor: AppColors.darkSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showMotivationSnackBar(BuildContext context) {
    _showSnackBar(context, 'Học ngay để duy trì chuỗi ngày của bạn!');
  }
}
