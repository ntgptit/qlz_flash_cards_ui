import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qlz_flash_cards_ui/core/providers/app_providers.dart';
import 'package:qlz_flash_cards_ui/features/dashboard/data/models/study_history_model.dart';
import 'package:qlz_flash_cards_ui/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:qlz_flash_cards_ui/features/dashboard/domain/states/dashboard_state.dart';

// Repository provider
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return DashboardRepository(dio, prefs);
});

// State notifier
class DashboardStateNotifier extends StateNotifier<DashboardState> {
  final DashboardRepository _repository;

  DashboardStateNotifier(this._repository) : super(const DashboardState());

  Future<void> loadDashboard({bool forceRefresh = false}) async {
    state = state.copyWith(status: DashboardStatus.loading);

    try {
      final stats = await _repository.getStudyStats(forceRefresh: forceRefresh);
      final history =
          await _repository.getStudyHistory(forceRefresh: forceRefresh);
      final modules =
          await _repository.getRecommendedModules(forceRefresh: forceRefresh);

      state = state.copyWith(
        status: DashboardStatus.success,
        stats: stats,
        history: history,
        recommendedModules: modules,
      );
    } catch (e) {
      state = state.copyWith(
        status: DashboardStatus.failure,
        errorMessage: e.toString(),
      );
    }
  }

  void changeTimePeriod(int days) {
    debugPrint(
        'DashboardProvider: Changing time period from ${state.selectedTimePeriod} to $days');

    if (state.selectedTimePeriod != days) {
      state = state.copyWith(selectedTimePeriod: days);
      debugPrint(
          'DashboardProvider: State updated with new period: ${state.selectedTimePeriod}');
    } else {
      debugPrint(
          'DashboardProvider: No change in time period, not updating state');
    }
  }

  void forceRefreshTimePeriod(int days) {
    debugPrint('DashboardProvider: Force refreshing with time period $days');

    state = state.copyWith(
        status: DashboardStatus.loading, selectedTimePeriod: days);

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        state = state.copyWith(
            status: DashboardStatus.success, selectedTimePeriod: days);
        debugPrint(
            'DashboardProvider: Forced refresh completed with period: $days');
      }
    });
  }

  Future<bool> recordStudySession(StudySessionEntry session) async {
    try {
      final result = await _repository.recordStudySession(session);

      if (result) {
        await loadDashboard(forceRefresh: true);
      }

      return result;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to record study session: ${e.toString()}',
      );

      return false;
    }
  }

  Future<void> refreshDashboard() async {
    await loadDashboard(forceRefresh: true);
  }
}

// Main provider
final dashboardProvider =
    StateNotifierProvider<DashboardStateNotifier, DashboardState>((ref) {
  final repository = ref.watch(dashboardRepositoryProvider);
  return DashboardStateNotifier(repository);
});
