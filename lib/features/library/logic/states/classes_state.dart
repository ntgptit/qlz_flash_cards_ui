// lib/features/library/logic/states/classes_state.dart
import 'package:equatable/equatable.dart';

import '../../data/models/class_model.dart';

/// Trạng thái có thể của classes
enum ClassesStatus { initial, loading, creating, success, failure }

/// Lớp state quản lý trạng thái của classes
class ClassesState extends Equatable {
  /// Danh sách các lớp học
  final List<ClassModel> classes;

  /// Trạng thái hiện tại
  final ClassesStatus status;

  /// Thông báo lỗi (nếu có)
  final String? errorMessage;

  /// Lỗi validation khi tạo lớp học (nếu có)
  final String? validationError;

  const ClassesState({
    this.classes = const [],
    this.status = ClassesStatus.initial,
    this.errorMessage,
    this.validationError,
  });

  @override
  List<Object?> get props => [classes, status, errorMessage, validationError];

  /// Tạo bản sao của state với các thuộc tính được thay đổi
  ClassesState copyWith({
    List<ClassModel>? classes,
    ClassesStatus? status,
    String? errorMessage,
    String? validationError,
  }) {
    return ClassesState(
      classes: classes ?? this.classes,
      status: status ?? this.status,
      errorMessage: errorMessage,
      validationError: validationError,
    );
  }

  /// Kiểm tra trạng thái đang tạo lớp học
  bool get isCreating => status == ClassesStatus.creating;
}
