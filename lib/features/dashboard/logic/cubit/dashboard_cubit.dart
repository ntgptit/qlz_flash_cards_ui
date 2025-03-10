// lib/features/dashboard/logic/cubit/dashboard_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/study_history_model.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../states/dashboard_state.dart';

/// Cubit for managing the dashboard state
class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository _repository;

  /// Creates a dashboard cubit with the given repository
  DashboardCubit(this._repository) : super(const DashboardState());

  /// Load all dashboard data
  Future<void> loadDashboard({bool forceRefresh = false}) async {
    emit(state.copyWith(status: DashboardStatus.loading));

    try {
      // Load study stats
      final stats = await _repository.getStudyStats(forceRefresh: forceRefresh);

      // Load study history
      final history =
          await _repository.getStudyHistory(forceRefresh: forceRefresh);

      // Load recommended modules
      final modules =
          await _repository.getRecommendedModules(forceRefresh: forceRefresh);

      emit(state.copyWith(
        status: DashboardStatus.success,
        stats: stats,
        history: history,
        recommendedModules: modules,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DashboardStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Change the selected time period for history display
  void changeTimePeriod(int days) {
    emit(state.copyWith(selectedTimePeriod: days));
  }

  /// Record a new study session
  Future<bool> recordStudySession(StudySessionEntry session) async {
    try {
      final result = await _repository.recordStudySession(session);

      if (result) {
        // Reload dashboard data to reflect changes
        await loadDashboard(forceRefresh: true);
      }

      return result;
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to record study session: ${e.toString()}',
      ));
      return false;
    }
  }

  /// Refresh dashboard data
  Future<void> refreshDashboard() async {
    await loadDashboard(forceRefresh: true);
  }
}
