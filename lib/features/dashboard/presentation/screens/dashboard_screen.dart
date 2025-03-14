import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/features/dashboard/domain/states/dashboard_state.dart';
import 'package:qlz_flash_cards_ui/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:qlz_flash_cards_ui/features/dashboard/presentation/widgets/recommended_modules.dart';
import 'package:qlz_flash_cards_ui/features/dashboard/presentation/widgets/session_history.dart';
import 'package:qlz_flash_cards_ui/features/dashboard/presentation/widgets/stats_overview.dart';
import 'package:qlz_flash_cards_ui/features/dashboard/presentation/widgets/streak_card.dart';
import 'package:qlz_flash_cards_ui/features/dashboard/presentation/widgets/study_chart.dart';
import 'package:qlz_flash_cards_ui/features/module/data/models/study_module_model.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/buttons/qlz_button.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  static const double horizontalPadding = 16.0;

  @override
  void initState() {
    super.initState();
    // Sử dụng ref để truy cập provider ở initState
    Future.microtask(
        () => ref.read(dashboardProvider.notifier).loadDashboard());
  }

  @override
  Widget build(BuildContext context) {
    // Theo dõi thay đổi trong state
    final state = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: _buildBody(state),
    );
  }

  Widget _buildBody(DashboardState state) {
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
      return _buildErrorState();
    }

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.darkSurface,
      onRefresh: () => ref.read(dashboardProvider.notifier).refreshDashboard(),
      child: _buildDashboardContent(state),
    );
  }

  Widget _buildErrorState() {
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
          QlzButton.primary(
            label: 'Thử lại',
            onPressed: () =>
                ref.read(dashboardProvider.notifier).refreshDashboard(),
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
          padding: const EdgeInsets.only(top: 8),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              if (!state.hasStudiedToday)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 8,
                  ),
                  child: _buildTodayGoalCard(),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 8,
                ),
                child: StatsOverview(state: state),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 8,
                ),
                child: StreakCard(
                  currentStreak: state.stats.currentStreak,
                  longestStreak: state.stats.longestStreak,
                  hasStudiedToday: state.hasStudiedToday,
                  onTap: () => _showMotivationSnackBar(context),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 8,
                ),
                child: StudyActivityChart(
                  dailyStudyTime: state.filteredHistory.dailyStudyTime,
                  dailyTermsLearned: state.filteredHistory.dailyTermsLearned,
                  timePeriod: state.selectedTimePeriod,
                  onPeriodChanged: (period) => ref
                      .read(dashboardProvider.notifier)
                      .changeTimePeriod(period),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 8,
                ),
                child: RecommendedModules(
                  modules: state.recommendedModules,
                  onViewAll: () =>
                      _showSnackBar(context, 'Xem tất cả học phần'),
                  onModuleTap: (module) =>
                      _navigateToModuleDetail(context, module),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 8,
                ),
                child: SessionHistory(
                  sessions: state.filteredHistory.sessions,
                  onViewAll: () =>
                      _showSnackBar(context, 'Xem toàn bộ lịch sử'),
                  onSessionTap: (session) => _showSnackBar(
                      context, 'Chi tiết phiên: ${session.moduleName}'),
                ),
              ),
              const SizedBox(height: 16),
            ]),
          ),
        ),
      ],
    );
  }

  // Các phương thức khác giữ nguyên, chỉ thay đổi context.read với ref.read
  // ...

  SliverAppBar _buildSliverAppBar() {
    // Giữ nguyên
    return const SliverAppBar(
        // ...
        );
  }

  Widget _buildTodayGoalCard() {
    // Giữ nguyên
    return const Card(
        // ...
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
        margin: const EdgeInsets.all(horizontalPadding),
      ),
    );
  }

  void _showMotivationSnackBar(BuildContext context) {
    _showSnackBar(context, 'Học ngay để duy trì chuỗi ngày của bạn!');
  }
}
