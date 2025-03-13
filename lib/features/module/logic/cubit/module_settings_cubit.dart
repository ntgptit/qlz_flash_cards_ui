// C:/Users/ntgpt/OneDrive/workspace/qlz_flash_cards_ui/lib/features/module/logic/cubit/module_settings_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qlz_flash_cards_ui/features/module/data/models/module_settings_model.dart';
import 'package:qlz_flash_cards_ui/features/module/data/repositories/module_repository.dart';
import 'package:qlz_flash_cards_ui/features/module/logic/states/module_settings_state.dart';

class ModuleSettingsCubit extends Cubit<ModuleSettingsState> {
  final ModuleRepository _repository;
  final String moduleId;
  bool _isClosed = false;

  ModuleSettingsCubit(this._repository, this.moduleId)
      : super(const ModuleSettingsState()) {
    loadSettings();
  }

  @override
  Future<void> close() {
    _isClosed = true;
    return super.close();
  }

  void _safeEmit(ModuleSettingsState newState) {
    if (!_isClosed) {
      emit(newState);
    }
  }

  Future<void> loadSettings() async {
    _safeEmit(state.copyWith(status: ModuleSettingsStatus.loading));

    try {
      final settings = await _repository.getModuleSettings(moduleId);
      _safeEmit(state.copyWith(
        status: ModuleSettingsStatus.success,
        settings: settings,
      ));
    } on NetworkTimeoutException catch (e) {
      _safeEmit(state.copyWith(
        status: ModuleSettingsStatus.failure,
        errorMessage: 'Không thể kết nối đến máy chủ: ${e.message}',
      ));
    } on PermissionException catch (e) {
      _safeEmit(state.copyWith(
        status: ModuleSettingsStatus.failure,
        errorMessage: e.message,
      ));
    } on ModuleException catch (e) {
      _safeEmit(state.copyWith(
        status: ModuleSettingsStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      _safeEmit(state.copyWith(
        status: ModuleSettingsStatus.failure,
        errorMessage: 'Đã xảy ra lỗi: $e',
      ));
    }
  }

  void updateAutoSuggest(bool value) {
    final newSettings = state.settings.copyWith(autoSuggest: value);
    _safeEmit(state.copyWith(settings: newSettings));
    _saveSettings(newSettings);
  }

  void updateViewPermission(String viewPermission) {
    final newSettings = state.settings.copyWith(viewPermission: viewPermission);
    _safeEmit(state.copyWith(settings: newSettings));
    _saveSettings(newSettings);
  }

  void updateEditPermission(String editPermission) {
    final newSettings = state.settings.copyWith(editPermission: editPermission);
    _safeEmit(state.copyWith(settings: newSettings));
    _saveSettings(newSettings);
  }

  Future<void> _saveSettings(ModuleSettings settings) async {
    try {
      await _repository.updateModuleSettings(moduleId, settings);
    } on NetworkTimeoutException catch (e) {
      // Không cập nhật state vì chỉ muốn giữ trạng thái UI hiện tại
      // Log lỗi hoặc cả khi cần
    } on PermissionException catch (e) {
      // Hiển thị thông báo lỗi khi cần
    } catch (e) {
      // Log lỗi nhưng không thay đổi UI
    }
  }
}
