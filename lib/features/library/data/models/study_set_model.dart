// lib/features/library/data/models/study_set_model.dart
import 'package:equatable/equatable.dart';

class StudySet extends Equatable {
  final String id;
  final String title;
  final int wordCount;
  final String creatorName;
  final bool hasPlusBadge;
  final DateTime createdAt;

  const StudySet({
    required this.id,
    required this.title,
    required this.wordCount,
    required this.creatorName,
    this.hasPlusBadge = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, title, wordCount, creatorName, hasPlusBadge, createdAt];

  StudySet copyWith({
    String? id,
    String? title,
    int? wordCount,
    String? creatorName,
    bool? hasPlusBadge,
    DateTime? createdAt,
  }) {
    return StudySet(
      id: id ?? this.id,
      title: title ?? this.title,
      wordCount: wordCount ?? this.wordCount,
      creatorName: creatorName ?? this.creatorName,
      hasPlusBadge: hasPlusBadge ?? this.hasPlusBadge,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory StudySet.fromJson(Map<String, dynamic> json) {
    return StudySet(
      id: json['id'] as String,
      title: json['title'] as String,
      wordCount: json['wordCount'] as int,
      creatorName: json['creatorName'] as String,
      hasPlusBadge: json['hasPlusBadge'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'wordCount': wordCount,
      'creatorName': creatorName,
      'hasPlusBadge': hasPlusBadge,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}