// lib/features/library/data/models/folder_model.dart
import 'package:equatable/equatable.dart';

class Folder extends Equatable {
  final String id;
  final String name;
  final String creatorName;
  final bool hasPlusBadge;
  final int moduleCount;
  final DateTime createdAt;

  const Folder({
    required this.id,
    required this.name,
    required this.creatorName,
    this.hasPlusBadge = false,
    required this.moduleCount,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, creatorName, hasPlusBadge, moduleCount, createdAt];

  Folder copyWith({
    String? id,
    String? name,
    String? creatorName,
    bool? hasPlusBadge,
    int? moduleCount,
    DateTime? createdAt,
  }) {
    return Folder(
      id: id ?? this.id,
      name: name ?? this.name,
      creatorName: creatorName ?? this.creatorName,
      hasPlusBadge: hasPlusBadge ?? this.hasPlusBadge,
      moduleCount: moduleCount ?? this.moduleCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Folder.fromJson(Map<String, dynamic> json) {
    return Folder(
      id: json['id'] as String,
      name: json['name'] as String,
      creatorName: json['creatorName'] as String,
      hasPlusBadge: json['hasPlusBadge'] as bool? ?? false,
      moduleCount: json['moduleCount'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'creatorName': creatorName,
      'hasPlusBadge': hasPlusBadge,
      'moduleCount': moduleCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
