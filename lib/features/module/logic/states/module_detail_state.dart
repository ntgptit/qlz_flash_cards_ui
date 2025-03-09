// lib/features/module/logic/states/module_detail_state.dart
import 'package:equatable/equatable.dart';

import '../../data/models/study_module_model.dart';

enum ModuleDetailStatus { initial, loading, success, failure }

class ModuleDetailState extends Equatable {
  final StudyModule? module;
  final ModuleDetailStatus status;
  final String? errorMessage;

  const ModuleDetailState({
    this.module,
    this.status = ModuleDetailStatus.initial,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [module, status, errorMessage];

  ModuleDetailState copyWith({
    StudyModule? module,
    ModuleDetailStatus? status,
    String? errorMessage,
  }) {
    return ModuleDetailState(
      module: module ?? this.module,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}