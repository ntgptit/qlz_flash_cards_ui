import 'package:equatable/equatable.dart';

/// A model class representing study progress data for a specific module
class StudyProgress extends Equatable {
  /// The ID of the module this progress is for
  final String moduleId;
  
  /// Total time spent studying this module in seconds
  final int totalStudyTimeSeconds;
  
  /// The number of flashcards the user has marked as learned
  final int learnedCount;
  
  /// The IDs of the flashcards that have been learned
  final List<String> learnedIds;
  
  /// The number of flashcards the user has marked as not learned yet
  final int notLearnedCount;
  
  /// The IDs of the flashcards that have not been learned yet
  final List<String> notLearnedIds;
  
  /// The last time this module was studied
  final DateTime lastStudiedAt;
  
  /// The completion percentage of the module (0-100)
  final double completionPercentage;

  /// Creates a study progress instance
  const StudyProgress({
    required this.moduleId,
    this.totalStudyTimeSeconds = 0,
    this.learnedCount = 0,
    this.learnedIds = const [],
    this.notLearnedCount = 0,
    this.notLearnedIds = const [],
    required this.lastStudiedAt,
    this.completionPercentage = 0.0,
  });

  @override
  List<Object?> get props => [
    moduleId,
    totalStudyTimeSeconds,
    learnedCount,
    learnedIds,
    notLearnedCount,
    notLearnedIds,
    lastStudiedAt,
    completionPercentage,
  ];

  /// Creates a copy of this progress with the given field values overridden
  StudyProgress copyWith({
    String? moduleId,
    int? totalStudyTimeSeconds,
    int? learnedCount,
    List<String>? learnedIds,
    int? notLearnedCount,
    List<String>? notLearnedIds,
    DateTime? lastStudiedAt,
    double? completionPercentage,
  }) {
    return StudyProgress(
      moduleId: moduleId ?? this.moduleId,
      totalStudyTimeSeconds: totalStudyTimeSeconds ?? this.totalStudyTimeSeconds,
      learnedCount: learnedCount ?? this.learnedCount,
      learnedIds: learnedIds ?? this.learnedIds,
      notLearnedCount: notLearnedCount ?? this.notLearnedCount,
      notLearnedIds: notLearnedIds ?? this.notLearnedIds,
      lastStudiedAt: lastStudiedAt ?? this.lastStudiedAt,
      completionPercentage: completionPercentage ?? this.completionPercentage,
    );
  }

  /// Creates a StudyProgress instance from a JSON map
  factory StudyProgress.fromJson(Map<String, dynamic> json) {
    return StudyProgress(
      moduleId: json['moduleId'] as String,
      totalStudyTimeSeconds: json['totalStudyTimeSeconds'] as int? ?? 0,
      learnedCount: json['learnedCount'] as int? ?? 0,
      learnedIds: (json['learnedIds'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      notLearnedCount: json['notLearnedCount'] as int? ?? 0,
      notLearnedIds: (json['notLearnedIds'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      lastStudiedAt: DateTime.parse(json['lastStudiedAt'] as String),
      completionPercentage: (json['completionPercentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Converts this StudyProgress instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'moduleId': moduleId,
      'totalStudyTimeSeconds': totalStudyTimeSeconds,
      'learnedCount': learnedCount,
      'learnedIds': learnedIds,
      'notLearnedCount': notLearnedCount,
      'notLearnedIds': notLearnedIds,
      'lastStudiedAt': lastStudiedAt.toIso8601String(),
      'completionPercentage': completionPercentage,
    };
  }

  /// Creates an empty StudyProgress instance for a module
  factory StudyProgress.empty(String moduleId) {
    return StudyProgress(
      moduleId: moduleId,
      lastStudiedAt: DateTime.now(),
    );
  }
}