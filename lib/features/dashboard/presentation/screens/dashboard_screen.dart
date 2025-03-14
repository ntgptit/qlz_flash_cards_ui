import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/features/dashboard/logic/cubit/dashboard_cubit.dart';
import 'package:qlz_flash_cards_ui/features/dashboard/logic/states/dashboard_state.dart';
import 'package:qlz_flash_cards_ui/features/dashboard/presentation/widgets/recommended_modules.dart';
import 'package:qlz_flash_cards_ui/features/dashboard/presentation/widgets/session_history.dart';
import 'package:qlz_flash_cards_ui/features/dashboard/presentation/widgets/stats_overview.dart';
import 'package:qlz_flash_cards_ui/features/dashboard/presentation/widgets/streak_card.dart';
import 'package:qlz_flash_cards_ui/features/dashboard/presentation/widgets/study_chart.dart';
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
        buildWhen: (previous, current) => previous.status != current.status,
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                switch (index) {
                  case 0:
                    return state.hasStudiedToday
                        ? const SizedBox.shrink()
                        : _buildTodayGoalCard();
                  case 1:
                    return StatsOverview(state: state);
                  case 2:
                    return StreakCard(
                      currentStreak: state.stats.currentStreak,
                      longestStreak: state.stats.longestStreak,
                      hasStudiedToday: state.hasStudiedToday,
                      onTap: () => _showMotivationSnackBar(context),
                    );
                  case 3:
                    return StudyActivityChart(
                      dailyStudyTime: state.filteredHistory.dailyStudyTime,
                      dailyTermsLearned:
                          state.filteredHistory.dailyTermsLearned,
                      timePeriod: state.selectedTimePeriod,
                      onPeriodChanged: (period) => context
                          .read<DashboardCubit>()
                          .changeTimePeriod(period),
                    );
                  case 4:
                    return RecommendedModules(
                      modules: state.recommendedModules,
                      onViewAll: () =>
                          _showSnackBar(context, 'Xem tất cả học phần'),
                      onModuleTap: (module) =>
                          _navigateToModuleDetail(context, module),
                    );
                  case 5:
                    return SessionHistory(
                      sessions: state.filteredHistory.sessions,
                      onViewAll: () =>
                          _showSnackBar(context, 'Xem toàn bộ lịch sử'),
                      onSessionTap: (session) => _showSnackBar(
                          context, 'Chi tiết phiên: ${session.moduleName}'),
                    );
                  default:
                    return const SizedBox.shrink();
                }
              },
              childCount: 6,
            ),
          ),
        ),
      ],
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      elevation: 0,
      backgroundColor: AppColors.darkBackground,
      expandedHeight: 100,
      floating: true,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        title: Text(
          'Tổng quan học tập',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.darkText,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary.withOpacity(0.3),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: AppColors.primary, size: 28),
          onPressed: () => _showSnackBar(context, 'Tìm kiếm đang phát triển'),
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none,
              color: AppColors.primary, size: 28),
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
                color: AppColors.primary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.calendar_today,
                  color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Học 5 phút để duy trì chuỗi',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.darkTextSecondary,
                      fontSize: 12,
                    ),
              ),
            ),
            QlzButton.primary(
              label: 'Bắt đầu',
              onPressed: () => _showSnackBar(context, 'Bắt đầu học ngay'),
            ),
          ],
        ),
      ),
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
