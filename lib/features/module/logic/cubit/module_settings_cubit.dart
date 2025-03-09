// lib/features/module/logic/cubit/module_settings_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/module_settings_model.dart';
import '../../data/repositories/module_repository.dart';
import '../states/module_settings_state.dart';

class ModuleSettingsCubit extends Cubit<ModuleSettingsState> {
  final ModuleRepository _repository;
  String moduleId;

  ModuleSettingsCubit(this._repository, this.moduleId) : super(const ModuleSettingsState()) {
    loadSettings();
  }

  // Load settings for a module
  Future<void> loadSettings() async {
    emit(state.copyWith(status: ModuleSettingsStatus.loading));

    try {
      final settings = await _repository.getModuleSettings(moduleId);
      emit(state.copyWith(
        status: ModuleSettingsStatus.success,
        settings: settings,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ModuleSettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  // Update auto suggest
  void updateAutoSuggest(bool value) {
    final newSettings = state.settings.copyWith(autoSuggest: value);
    emit(state.copyWith(settings: newSettings));
    _saveSettings(newSettings);
  }

  // Update view permission
  void updateViewPermission(String viewPermission) {
    final newSettings = state.settings.copyWith(viewPermission: viewPermission);
    emit(state.copyWith(settings: newSettings));
    _saveSettings(newSettings);
  }

  // Update edit permission
  void updateEditPermission(String editPermission) {
    final newSettings = state.settings.copyWith(editPermission: editPermission);
    emit(state.copyWith(settings: newSettings));
    _saveSettings(newSettings);
  }

  // Save settings to repository
  Future<void> _saveSettings(ModuleSettings settings) async {
    try {
      await _repository.updateModuleSettings(moduleId, settings);
    } catch (e) {
      // Silently handle error - could show a toast or snackbar
    }
  }
}