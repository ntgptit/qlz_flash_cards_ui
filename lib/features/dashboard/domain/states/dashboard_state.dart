import 'package:equatable/equatable.dart';
import 'package:qlz_flash_cards_ui/features/dashboard/data/models/study_history_model.dart';
import 'package:qlz_flash_cards_ui/features/dashboard/data/models/study_stats_model.dart';
import 'package:qlz_flash_cards_ui/features/module/data/models/study_module_model.dart';

enum DashboardStatus { initial, loading, success, failure }

class DashboardState extends Equatable {
  final DashboardStatus status;
  final StudyStatsModel stats;
  final StudyHistoryModel history;
  final List<StudyModule> recommendedModules;
  final String? errorMessage;
  final int selectedTimePeriod;

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

  StudyHistoryModel get filteredHistory {
    return history.getHistoryForPastDays(selectedTimePeriod);
  }

  bool get hasStudiedToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastStudyDate = stats.lastStudyDate;
    final lastStudyDay = lastStudyDate != null
        ? DateTime(lastStudyDate.year, lastStudyDate.month, lastStudyDate.day)
        : DateTime(1970, 1, 1); // Default to epoch if lastStudyDate is null
    return lastStudyDay.isAtSameMomentAs(today);
  }

  int get periodTotalStudyTime {
    final filtered = filteredHistory;
    return filtered.dailyStudyTime.values.fold(0, (sum, time) => sum + time);
  }

  int get periodTotalTermsLearned {
    final filtered = filteredHistory;
    return filtered.dailyTermsLearned.values
        .fold(0, (sum, count) => sum + count);
  }

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
