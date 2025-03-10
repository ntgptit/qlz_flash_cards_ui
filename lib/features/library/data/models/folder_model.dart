// lib/features/library/data/models/folder_model.dart
import 'package:equatable/equatable.dart';

/// Model đại diện cho một thư mục
class Folder extends Equatable {
  /// ID duy nhất của thư mục
  final String id;

  /// Tên thư mục
  final String name;

  /// Tên người tạo thư mục
  final String creatorName;

  /// Người tạo có huy hiệu Plus hay không
  final bool hasPlusBadge;

  /// Số lượng học phần trong thư mục
  final int moduleCount;

  /// Ngày tạo thư mục
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
  List<Object?> get props =>
      [id, name, creatorName, hasPlusBadge, moduleCount, createdAt];

  /// Tạo bản sao của Folder với các thuộc tính được thay đổi
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

  /// Tạo Folder từ JSON
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

  /// Chuyển đổi Folder thành JSON
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
