// lib/features/module/logic/states/study_module_state.dart
import 'package:equatable/equatable.dart';

import '../../data/models/study_module_model.dart';

enum StudyModuleStatus { initial, loading, success, failure }

class StudyModuleState extends Equatable {
  final List<StudyModule> modules;
  final StudyModuleStatus status;
  final String? errorMessage;
  final bool hasReachedEnd;

  const StudyModuleState({
    this.modules = const [],
    this.status = StudyModuleStatus.initial,
    this.errorMessage,
    this.hasReachedEnd = false,
  });

  @override
  List<Object?> get props => [modules, status, errorMessage, hasReachedEnd];

  StudyModuleState copyWith({
    List<StudyModule>? modules,
    StudyModuleStatus? status,
    String? errorMessage,
    bool? hasReachedEnd,
  }) {
    return StudyModuleState(
      modules: modules ?? this.modules,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
    );
  }
}