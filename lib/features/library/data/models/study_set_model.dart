// lib/features/library/data/models/study_set_model.dart
import 'package:equatable/equatable.dart';

/// Model đại diện cho một học phần (Study Set)
class StudySet extends Equatable {
  /// ID duy nhất của học phần
  final String id;

  /// Tiêu đề của học phần
  final String title;

  /// Mô tả của học phần (nếu có)
  final String? description;

  /// Tên người tạo học phần
  final String creatorName;

  /// Người tạo có huy hiệu Plus hay không
  final bool hasPlusBadge;

  /// Số lượng từ vựng trong học phần
  final int wordCount;

  /// Ngày tạo học phần
  final DateTime createdAt;

  const StudySet({
    required this.id,
    required this.title,
    this.description,
    required this.creatorName,
    this.hasPlusBadge = false,
    required this.wordCount,
    required this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, title, description, creatorName, hasPlusBadge, wordCount, createdAt];

  /// Tạo bản sao của StudySet với các thuộc tính được thay đổi
  StudySet copyWith({
    String? id,
    String? title,
    String? description,
    String? creatorName,
    bool? hasPlusBadge,
    int? wordCount,
    DateTime? createdAt,
  }) {
    return StudySet(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      creatorName: creatorName ?? this.creatorName,
      hasPlusBadge: hasPlusBadge ?? this.hasPlusBadge,
      wordCount: wordCount ?? this.wordCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Tạo StudySet từ JSON
  factory StudySet.fromJson(Map<String, dynamic> json) {
    return StudySet(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      creatorName: json['creatorName'] as String,
      hasPlusBadge: json['hasPlusBadge'] as bool? ?? false,
      wordCount: json['wordCount'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Chuyển đổi StudySet thành JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'creatorName': creatorName,
      'hasPlusBadge': hasPlusBadge,
      'wordCount': wordCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
