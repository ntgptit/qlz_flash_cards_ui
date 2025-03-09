// lib/features/library/data/models/class_model.dart
import 'package:equatable/equatable.dart';

class ClassModel extends Equatable {
  final String id;
  final String name;
  final int studyModulesCount;
  final String? creatorName;
  final DateTime createdAt;

  const ClassModel({
    required this.id,
    required this.name,
    required this.studyModulesCount,
    this.creatorName,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, studyModulesCount, creatorName, createdAt];

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

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'] as String,
      name: json['name'] as String,
      studyModulesCount: json['studyModulesCount'] as int,
      creatorName: json['creatorName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

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