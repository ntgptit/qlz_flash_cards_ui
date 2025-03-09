// lib/features/library/logic/states/classes_state.dart
import 'package:equatable/equatable.dart';

import '../../data/models/class_model.dart';

enum ClassesStatus { initial, loading, success, failure }

class ClassesState extends Equatable {
  final List<ClassModel> classes;
  final ClassesStatus status;
  final String? errorMessage;

  const ClassesState({
    this.classes = const [],
    this.status = ClassesStatus.initial,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [classes, status, errorMessage];

  ClassesState copyWith({
    List<ClassModel>? classes,
    ClassesStatus? status,
    String? errorMessage,
  }) {
    return ClassesState(
      classes: classes ?? this.classes,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}