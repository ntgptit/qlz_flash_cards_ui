// lib/features/module/logic/states/module_settings_state.dart
import 'package:equatable/equatable.dart';

import '../../data/models/module_settings_model.dart';

enum ModuleSettingsStatus { initial, loading, success, failure }

class ModuleSettingsState extends Equatable {
  final ModuleSettings settings;
  final ModuleSettingsStatus status;
  final String? errorMessage;

  const ModuleSettingsState({
    this.settings = const ModuleSettings(),
    this.status = ModuleSettingsStatus.initial,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [settings, status, errorMessage];

  ModuleSettingsState copyWith({
    ModuleSettings? settings,
    ModuleSettingsStatus? status,
    String? errorMessage,
  }) {
    return ModuleSettingsState(
      settings: settings ?? this.settings,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}