// lib/features/dashboard/data/models/study_history_model.dart

import 'package:equatable/equatable.dart';

/// A model representing a single study session history entry
class StudySessionEntry extends Equatable {
  /// Date of the study session
  final DateTime date;

  /// Module ID that was studied
  final String moduleId;

  /// Name of the module or set
  final String moduleName;

  /// Number of terms studied
  final int termsStudied;

  /// Number of terms marked as learned
  final int termsLearned;

  /// Duration of the study session in seconds
  final int durationSeconds;

  /// Create a new study session entry
  const StudySessionEntry({
    required this.date,
    required this.moduleId,
    required this.moduleName,
    required this.termsStudied,
    required this.termsLearned,
    required this.durationSeconds,
  });

  @override
  List<Object?> get props => [
        date,
        moduleId,
        moduleName,
        termsStudied,
        termsLearned,
        durationSeconds,
      ];

  /// Convert this entry to JSON
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'moduleId': moduleId,
      'moduleName': moduleName,
      'termsStudied': termsStudied,
      'termsLearned': termsLearned,
      'durationSeconds': durationSeconds,
    };
  }

  /// Create an entry from JSON
  factory StudySessionEntry.fromJson(Map<String, dynamic> json) {
    return StudySessionEntry(
      date: DateTime.parse(json['date'] as String),
      moduleId: json['moduleId'] as String,
      moduleName: json['moduleName'] as String,
      termsStudied: json['termsStudied'] as int,
      termsLearned: json['termsLearned'] as int,
      durationSeconds: json['durationSeconds'] as int,
    );
  }
}

/// A model that contains daily study history for analytics
class StudyHistoryModel extends Equatable {
  /// Map of date strings to study time in seconds
  final Map<String, int> dailyStudyTime;

  /// Map of date strings to terms learned count
  final Map<String, int> dailyTermsLearned;

  /// List of study session entries
  final List<StudySessionEntry> sessions;

  /// Create a study history model
  const StudyHistoryModel({
    this.dailyStudyTime = const {},
    this.dailyTermsLearned = const {},
    this.sessions = const [],
  });

  @override
  List<Object?> get props => [dailyStudyTime, dailyTermsLearned, sessions];

  /// Create a copy of this model with specified changes
  StudyHistoryModel copyWith({
    Map<String, int>? dailyStudyTime,
    Map<String, int>? dailyTermsLearned,
    List<StudySessionEntry>? sessions,
  }) {
    return StudyHistoryModel(
      dailyStudyTime: dailyStudyTime ?? this.dailyStudyTime,
      dailyTermsLearned: dailyTermsLearned ?? this.dailyTermsLearned,
      sessions: sessions ?? this.sessions,
    );
  }

  /// Convert this model to JSON
  Map<String, dynamic> toJson() {
    return {
      'dailyStudyTime': dailyStudyTime,
      'dailyTermsLearned': dailyTermsLearned,
      'sessions': sessions.map((session) => session.toJson()).toList(),
    };
  }

  /// Create a model from JSON
  factory StudyHistoryModel.fromJson(Map<String, dynamic> json) {
    return StudyHistoryModel(
      dailyStudyTime: (json['dailyStudyTime'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, value as int),
          ) ??
          {},
      dailyTermsLearned:
          (json['dailyTermsLearned'] as Map<String, dynamic>?)?.map(
                (key, value) => MapEntry(key, value as int),
              ) ??
              {},
      sessions: (json['sessions'] as List<dynamic>?)
              ?.map(
                  (e) => StudySessionEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Create an empty history model
  factory StudyHistoryModel.empty() {
    return const StudyHistoryModel();
  }

  /// Add a new study session to the history
  StudyHistoryModel addSession(StudySessionEntry session) {
    // Format date as ISO date string (YYYY-MM-DD)
    final dateString = _formatDateToString(session.date);

    // Update daily study time
    final updatedDailyStudyTime = Map<String, int>.from(dailyStudyTime);
    updatedDailyStudyTime[dateString] =
        (updatedDailyStudyTime[dateString] ?? 0) + session.durationSeconds;

    // Update daily terms learned
    final updatedDailyTermsLearned = Map<String, int>.from(dailyTermsLearned);
    updatedDailyTermsLearned[dateString] =
        (updatedDailyTermsLearned[dateString] ?? 0) + session.termsLearned;

    // Add session to list
    final updatedSessions = List<StudySessionEntry>.from(sessions)
      ..add(session);

    return StudyHistoryModel(
      dailyStudyTime: updatedDailyStudyTime,
      dailyTermsLearned: updatedDailyTermsLearned,
      sessions: updatedSessions,
    );
  }

  /// Get the history for the past n days
  StudyHistoryModel getHistoryForPastDays(int days) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));

    // Filter sessions by date
    final filteredSessions =
        sessions.where((session) => session.date.isAfter(cutoffDate)).toList();

    // Create a map of dates to study time
    final filteredDailyStudyTime = <String, int>{};
    final filteredDailyTermsLearned = <String, int>{};

    // Include all dates in range, even those with no data
    for (int i = 0; i < days; i++) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dateString = _formatDateToString(date);

      filteredDailyStudyTime[dateString] = dailyStudyTime[dateString] ?? 0;
      filteredDailyTermsLearned[dateString] =
          dailyTermsLearned[dateString] ?? 0;
    }

    return StudyHistoryModel(
      dailyStudyTime: filteredDailyStudyTime,
      dailyTermsLearned: filteredDailyTermsLearned,
      sessions: filteredSessions,
    );
  }

  /// Format a date to string (YYYY-MM-DD)
  String _formatDateToString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
