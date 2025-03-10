// lib/features/dashboard/data/models/study_stats_model.dart

import 'package:equatable/equatable.dart';

/// A model that represents a user's overall study statistics
class StudyStatsModel extends Equatable {
  /// Total number of terms learned across all modules
  final int totalTermsLearned;

  /// Total number of terms marked as difficult
  final int totalDifficultTerms;

  /// Total number of study sessions completed
  final int totalSessionsCompleted;

  /// Total study time in seconds
  final int totalStudyTimeSeconds;

  /// Current streak (days in a row with study activity)
  final int currentStreak;

  /// Longest streak achieved
  final int longestStreak;

  /// Last study date
  final DateTime? lastStudyDate;

  /// Create a new study stats model
  const StudyStatsModel({
    this.totalTermsLearned = 0,
    this.totalDifficultTerms = 0,
    this.totalSessionsCompleted = 0,
    this.totalStudyTimeSeconds = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    required this.lastStudyDate,
  });

  @override
  List<Object?> get props => [
        totalTermsLearned,
        totalDifficultTerms,
        totalSessionsCompleted,
        totalStudyTimeSeconds,
        currentStreak,
        longestStreak,
        lastStudyDate,
      ];

  /// Create a copy of this model with specified changes
  StudyStatsModel copyWith({
    int? totalTermsLearned,
    int? totalDifficultTerms,
    int? totalSessionsCompleted,
    int? totalStudyTimeSeconds,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastStudyDate,
  }) {
    return StudyStatsModel(
      totalTermsLearned: totalTermsLearned ?? this.totalTermsLearned,
      totalDifficultTerms: totalDifficultTerms ?? this.totalDifficultTerms,
      totalSessionsCompleted:
          totalSessionsCompleted ?? this.totalSessionsCompleted,
      totalStudyTimeSeconds:
          totalStudyTimeSeconds ?? this.totalStudyTimeSeconds,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
    );
  }

  /// Create a study stats model from JSON
  factory StudyStatsModel.fromJson(Map<String, dynamic> json) {
    return StudyStatsModel(
      totalTermsLearned: json['totalTermsLearned'] as int? ?? 0,
      totalDifficultTerms: json['totalDifficultTerms'] as int? ?? 0,
      totalSessionsCompleted: json['totalSessionsCompleted'] as int? ?? 0,
      totalStudyTimeSeconds: json['totalStudyTimeSeconds'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      lastStudyDate: json['lastStudyDate'] != null
          ? DateTime.parse(json['lastStudyDate'] as String)
          : DateTime.now(),
    );
  }

  /// Convert this model to JSON
  Map<String, dynamic> toJson() {
    return {
      'totalTermsLearned': totalTermsLearned,
      'totalDifficultTerms': totalDifficultTerms,
      'totalSessionsCompleted': totalSessionsCompleted,
      'totalStudyTimeSeconds': totalStudyTimeSeconds,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastStudyDate': lastStudyDate?.toIso8601String(),
    };
  }

  /// Create an empty study stats model
  factory StudyStatsModel.empty() {
    return StudyStatsModel(
      lastStudyDate: DateTime.now(),
    );
  }

  /// Format study time in hours and minutes
  String get formattedStudyTime {
    final hours = totalStudyTimeSeconds ~/ 3600;
    final minutes = (totalStudyTimeSeconds % 3600) ~/ 60;

    if (hours > 0) {
      return '$hours giờ ${minutes > 0 ? '$minutes phút' : ''}';
    } else {
      return '$minutes phút';
    }
  }
}
