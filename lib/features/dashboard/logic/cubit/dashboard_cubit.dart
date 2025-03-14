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
    print(
        'DashboardCubit: Changing time period from ${state.selectedTimePeriod} to $days');

    // Chỉ emit state mới khi có sự thay đổi thực sự
    if (state.selectedTimePeriod != days) {
      final newState = state.copyWith(selectedTimePeriod: days);
      emit(newState);
      print(
          'DashboardCubit: State emitted with new period: ${newState.selectedTimePeriod}');
    } else {
      print('DashboardCubit: No change in time period, not emitting new state');
    }
  }

  void forceRefreshTimePeriod(int days) {
    // Đặt lại status thành loading rồi success để đảm bảo UI được refresh
    print('DashboardCubit: Force refreshing with time period $days');

    emit(state.copyWith(
        status: DashboardStatus.loading, selectedTimePeriod: days));

    // Sau một khoảng thời gian nhỏ, emit lại status success
    Future.delayed(const Duration(milliseconds: 100), () {
      if (isClosed) return; // Kiểm tra cubit đã bị đóng chưa

      emit(state.copyWith(
          status: DashboardStatus.success, selectedTimePeriod: days));

      print('DashboardCubit: Forced refresh completed with period: $days');
    });
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
