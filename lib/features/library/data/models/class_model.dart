// lib/features/library/data/models/class_model.dart
import 'package:equatable/equatable.dart';

/// Model đại diện cho một lớp học
class ClassModel extends Equatable {
  /// ID duy nhất của lớp học
  final String id;

  /// Tên lớp học
  final String name;

  /// Số lượng học phần trong lớp học
  final int studyModulesCount;

  /// Tên người tạo lớp học (nếu có)
  final String? creatorName;

  /// Ngày tạo lớp học
  final DateTime createdAt;

  const ClassModel({
    required this.id,
    required this.name,
    required this.studyModulesCount,
    this.creatorName,
    required this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, name, studyModulesCount, creatorName, createdAt];

  /// Tạo bản sao của ClassModel với các thuộc tính được thay đổi
  ClassModel copyWith({
    String? id,
    String? name,
    int? studyModulesCount,
    String? creatorName,
    DateTime? createdAt,
  }) {
    return ClassModel(
      id: id ?? this.id,
      name: name ?? this.name,
      studyModulesCount: studyModulesCount ?? this.studyModulesCount,
      creatorName: creatorName ?? this.creatorName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Tạo ClassModel từ JSON
  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'] as String,
      name: json['name'] as String,
      studyModulesCount: json['studyModulesCount'] as int,
      creatorName: json['creatorName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Chuyển đổi ClassModel thành JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'studyModulesCount': studyModulesCount,
      'creatorName': creatorName,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
