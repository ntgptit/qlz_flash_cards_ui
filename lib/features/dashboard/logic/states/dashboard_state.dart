// lib/features/dashboard/logic/states/dashboard_state.dart

import 'package:equatable/equatable.dart';

import '../../../../features/module/data/models/study_module_model.dart';
import '../../data/models/study_history_model.dart';
import '../../data/models/study_stats_model.dart';

/// Possible states for the dashboard
enum DashboardStatus { initial, loading, success, failure }

/// State for the dashboard feature
class DashboardState extends Equatable {
  /// Current status of the dashboard data
  final DashboardStatus status;

  /// Study statistics
  final StudyStatsModel stats;

  /// Study history
  final StudyHistoryModel history;

  /// Recommended modules for study
  final List<StudyModule> recommendedModules;

  /// Error message if status is failure
  final String? errorMessage;

  /// Selected time period for history display (in days)
  final int selectedTimePeriod;

  /// Creates a dashboard state
  const DashboardState({
    this.status = DashboardStatus.initial,
    this.stats = const StudyStatsModel(lastStudyDate: null),
    this.history = const StudyHistoryModel(),
    this.recommendedModules = const [],
    this.errorMessage,
    this.selectedTimePeriod = 7, // Default to showing a week
  });

  @override
  List<Object?> get props => [
        status,
        stats,
        history,
        recommendedModules,
        errorMessage,
        selectedTimePeriod,
      ];

  /// Create a copy of this state with the specified changes
  DashboardState copyWith({
    DashboardStatus? status,
    StudyStatsModel? stats,
    StudyHistoryModel? history,
    List<StudyModule>? recommendedModules,
    String? errorMessage,
    int? selectedTimePeriod,
  }) {
    return DashboardState(
      status: status ?? this.status,
      stats: stats ?? this.stats,
      history: history ?? this.history,
      recommendedModules: recommendedModules ?? this.recommendedModules,
      errorMessage: errorMessage,
      selectedTimePeriod: selectedTimePeriod ?? this.selectedTimePeriod,
    );
  }

  /// Get filtered history based on selected time period
  StudyHistoryModel get filteredHistory {
    return history.getHistoryForPastDays(selectedTimePeriod);
  }

  /// Check if user has studied today
  bool get hasStudiedToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastStudyDate = stats.lastStudyDate;

    final lastStudyDay = lastStudyDate != null
        ? DateTime(lastStudyDate.year, lastStudyDate.month, lastStudyDate.day)
        : DateTime(1970, 1, 1); // Default to epoch if lastStudyDate is null

    return lastStudyDay.isAtSameMomentAs(today);
  }

  /// Get total study time in the selected period (in seconds)
  int get periodTotalStudyTime {
    final filtered = filteredHistory;
    return filtered.dailyStudyTime.values.fold(0, (sum, time) => sum + time);
  }

  /// Get total terms learned in the selected period
  int get periodTotalTermsLearned {
    final filtered = filteredHistory;
    return filtered.dailyTermsLearned.values
        .fold(0, (sum, count) => sum + count);
  }

  /// Format the selected time period as a human-readable string
  String get periodLabel {
    return switch (selectedTimePeriod) {
      7 => '7 ngày qua',
      14 => '14 ngày qua',
      30 => '30 ngày qua',
      90 => '3 tháng qua',
      _ => '$selectedTimePeriod ngày qua'
    };
  }
}
