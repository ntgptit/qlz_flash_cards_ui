// lib/features/module/presentation/providers/module_settings_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qlz_flash_cards_ui/core/providers/app_providers.dart';
import 'package:qlz_flash_cards_ui/features/module/data/models/module_settings_model.dart';
import 'package:qlz_flash_cards_ui/features/module/data/repositories/module_repository.dart';

// State definition for module settings
enum ModuleSettingsStatus { initial, loading, success, failure }

class ModuleSettingsState {
  final ModuleSettings settings;
  final ModuleSettingsStatus status;
  final String? errorMessage;

  const ModuleSettingsState({
    this.settings = const ModuleSettings(),
    this.status = ModuleSettingsStatus.initial,
    this.errorMessage,
  });

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

// StateNotifier for module settings
class ModuleSettingsNotifier extends StateNotifier<ModuleSettingsState> {
  final ModuleRepository _repository;
  final String moduleId;

  ModuleSettingsNotifier(this._repository, this.moduleId)
      : super(const ModuleSettingsState()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    state = state.copyWith(status: ModuleSettingsStatus.loading);

    try {
      final settings = await _repository.getModuleSettings(moduleId);

      state = state.copyWith(
        status: ModuleSettingsStatus.success,
        settings: settings,
      );
    } catch (e) {
      state = state.copyWith(
        status: ModuleSettingsStatus.failure,
        errorMessage: 'Đã xảy ra lỗi: $e',
      );
    }
  }

  void updateAutoSuggest(bool value) {
    final newSettings = state.settings.copyWith(autoSuggest: value);
    state = state.copyWith(settings: newSettings);
    _saveSettings(newSettings);
  }

  void updateViewPermission(String viewPermission) {
    final newSettings = state.settings.copyWith(viewPermission: viewPermission);
    state = state.copyWith(settings: newSettings);
    _saveSettings(newSettings);
  }

  void updateEditPermission(String editPermission) {
    final newSettings = state.settings.copyWith(editPermission: editPermission);
    state = state.copyWith(settings: newSettings);
    _saveSettings(newSettings);
  }

  Future<void> _saveSettings(ModuleSettings settings) async {
    try {
      await _repository.updateModuleSettings(moduleId, settings);
    } catch (e) {
      // Log errors but don't change state to maintain UI consistency
      // If needed, we could add a "lastSaveError" field to the state
    }
  }
}

// Provider for module settings - uses family to parameterize by moduleId
final moduleSettingsProvider = StateNotifierProvider.family<
    ModuleSettingsNotifier, ModuleSettingsState, String>(
  (ref, moduleId) {
    final repository = ref.watch(moduleRepositoryProvider);
    return ModuleSettingsNotifier(repository, moduleId);
  },
);
