// lib/features/dashboard/presentation/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/features/dashboard/logic/cubit/dashboard_cubit.dart';
import 'package:qlz_flash_cards_ui/features/dashboard/logic/states/dashboard_state.dart';
import 'package:qlz_flash_cards_ui/features/dashboard/presentation/widgets/recommended_modules.dart';
import 'package:qlz_flash_cards_ui/features/dashboard/presentation/widgets/session_history.dart';
import 'package:qlz_flash_cards_ui/features/dashboard/presentation/widgets/streak_card.dart';
import 'package:qlz_flash_cards_ui/features/dashboard/presentation/widgets/study_chart.dart';
import 'package:qlz_flash_cards_ui/features/dashboard/presentation/widgets/study_stats_card.dart';
import 'package:qlz_flash_cards_ui/features/module/data/models/study_module_model.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/buttons/qlz_button.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_empty_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_loading_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_snackbar.dart';

/// Main screen for the study dashboard
class DashboardScreen extends StatefulWidget {
  /// Creates a dashboard screen
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load dashboard data when screen initializes
    context.read<DashboardCubit>().loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A092D),
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state.status == DashboardStatus.initial ||
              (state.status == DashboardStatus.loading &&
                  state.stats.lastStudyDate == null)) {
            return const QlzLoadingState(
              message: 'Đang tải dữ liệu học tập...',
            );
          }

          if (state.status == DashboardStatus.failure) {
            return QlzEmptyState.error(
              title: 'Không thể tải dữ liệu',
              message:
                  state.errorMessage ?? 'Đã xảy ra lỗi khi tải dữ liệu học tập',
              onAction: () => context.read<DashboardCubit>().refreshDashboard(),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<DashboardCubit>().refreshDashboard(),
            child: _buildDashboardContent(state),
          );
        },
      ),
    );
  }

  Widget _buildDashboardContent(DashboardState state) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // App Bar
        SliverAppBar(
          backgroundColor: Colors.transparent,
          expandedHeight: 100,
          floating: true,
          pinned: false,
          flexibleSpace: FlexibleSpaceBar(
            title: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                'Tổng quan học tập',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            titlePadding:
                const EdgeInsetsDirectional.only(start: 0, bottom: 16),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // Action for search
              },
            ),
            IconButton(
              icon: const Icon(Icons.notifications_none),
              onPressed: () {
                // Action for notifications
              },
            ),
          ],
        ),

        // Today's goal
        if (!state.hasStudiedToday)
          SliverToBoxAdapter(
            child: _buildTodayGoalCard(),
          ),

        // Stats overview
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildStatsOverview(state),
          ),
        ),

        // Streak card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: StreakCard(
              currentStreak: state.stats.currentStreak,
              longestStreak: state.stats.longestStreak,
              hasStudiedToday: state.hasStudiedToday,
              onTap: () {
                // Navigate to flashcard study screen or show options
                QlzSnackbar.info(
                  context: context,
                  message: 'Bắt đầu học ngay để duy trì chuỗi ngày học!',
                );
              },
            ),
          ),
        ),

        // Activity chart
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: StudyActivityChart(
              dailyStudyTime: state.filteredHistory.dailyStudyTime,
              dailyTermsLearned: state.filteredHistory.dailyTermsLearned,
              timePeriod: state.selectedTimePeriod,
              onPeriodChanged: (period) {
                context.read<DashboardCubit>().changeTimePeriod(period);
              },
            ),
          ),
        ),

        // Recommended modules
        SliverToBoxAdapter(
          child: Column(
            children: [
              RecommendedModules(
                modules: state.recommendedModules,
                onViewAll: () {
                  // Navigate to full recommendations list
                  QlzSnackbar.info(
                    context: context,
                    message: 'Đang tải danh sách đề xuất đầy đủ...',
                  );
                },
                onModuleTap: (module) {
                  _navigateToModuleDetail(context, module);
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),

        // Recent study sessions
        SliverToBoxAdapter(
          child: Column(
            children: [
              SessionHistory(
                sessions: state.filteredHistory.sessions,
                onViewAll: () {
                  // Navigate to full history
                  QlzSnackbar.info(
                    context: context,
                    message: 'Đang tải lịch sử học tập đầy đủ...',
                  );
                },
                onSessionTap: (session) {
                  // Navigate to module or show session details
                  QlzSnackbar.info(
                    context: context,
                    message: 'Chi tiết phiên học: ${session.moduleName}',
                  );
                },
              ),
              const SizedBox(height: 40), // Bottom padding
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTodayGoalCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.calendar_today,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bạn chưa học hôm nay',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hãy dành ít nhất 5 phút để duy trì chuỗi học tập',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            QlzButton.primary(
              label: 'Học ngay',
              size: QlzButtonSize.small,
              onPressed: () {
                // Start a study session
                QlzSnackbar.info(
                  context: context,
                  message: 'Chọn học phần để bắt đầu học...',
                );
              },
            ),
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
                subtitle: '${state.stats.totalSessionsCompleted} phiên học',
                icon: Icons.timer_outlined,
                iconColor: Colors.amber,
                onTap: () {
                  QlzSnackbar.info(
                    context: context,
                    message:
                        'Tổng thời gian học: ${state.stats.formattedStudyTime}',
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StudyStatsCard(
                title: 'Từ đã học',
                value: '${state.stats.totalTermsLearned}',
                subtitle: '${state.stats.totalDifficultTerms} từ khó',
                icon: Icons.school_outlined,
                iconColor: Colors.green,
                onTap: () {
                  QlzSnackbar.info(
                    context: context,
                    message:
                        'Tổng số từ đã học: ${state.stats.totalTermsLearned}',
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        StudyStatsCard(
          title: state.periodLabel,
          value: '${state.periodTotalTermsLearned} từ',
          subtitle: '${_formatTime(state.periodTotalStudyTime)} thời gian học',
          icon: Icons.insights_outlined,
          iconColor: Colors.blue,
          onTap: () {
            QlzSnackbar.info(
              context: context,
              message:
                  'Trong ${state.periodLabel}: ${state.periodTotalTermsLearned} từ',
            );
          },
        ),
      ],
    );
  }

  String _formatTime(int seconds) {
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

  void _navigateToModuleDetail(BuildContext context, StudyModule module) {
    // Navigate to module detail screen
    // Example:
    // Navigator.pushNamed(
    //   context,
    //   '/module-detail',
    //   arguments: {
    //     'moduleId': module.id,
    //     'moduleName': module.title,
    //   },
    // );

    // For now, just show a snackbar
    QlzSnackbar.info(
      context: context,
      message: 'Đang mở học phần: ${module.title}',
    );
  }
}
