// lib/features/module/presentation/providers/module_detail_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qlz_flash_cards_ui/core/providers/app_providers.dart';
import 'package:qlz_flash_cards_ui/features/module/data/models/study_module_model.dart';
import 'package:qlz_flash_cards_ui/features/module/data/repositories/module_repository.dart';

// State định nghĩa cho ModuleDetail
enum ModuleDetailStatus { initial, loading, success, failure }

class ModuleDetailState {
  final StudyModule? module;
  final ModuleDetailStatus status;
  final String? errorMessage;
  final bool loadingTimedOut;

  const ModuleDetailState({
    this.module,
    this.status = ModuleDetailStatus.initial,
    this.errorMessage,
    this.loadingTimedOut = false,
  });

  ModuleDetailState copyWith({
    StudyModule? module,
    ModuleDetailStatus? status,
    String? errorMessage,
    bool? loadingTimedOut,
  }) {
    return ModuleDetailState(
      module: module ?? this.module,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      loadingTimedOut: loadingTimedOut ?? this.loadingTimedOut,
    );
  }
}

// StateNotifier cho dữ liệu chi tiết module
class ModuleDetailNotifier extends StateNotifier<ModuleDetailState> {
  final ModuleRepository _repository;

  ModuleDetailNotifier(this._repository) : super(const ModuleDetailState());

  Future<void> loadModuleDetails(String moduleId,
      {bool forceRefresh = false}) async {
    state = state.copyWith(status: ModuleDetailStatus.loading);

    try {
      final module = await _repository.getStudyModuleById(moduleId,
          forceRefresh: forceRefresh);

      state = state.copyWith(
        status: ModuleDetailStatus.success,
        module: module,
      );
    } catch (e) {
      state = state.copyWith(
        status: ModuleDetailStatus.failure,
        errorMessage: 'Đã xảy ra lỗi: $e',
      );
    }
  }

  void setLoadingTimedOut(bool value) {
    state = state.copyWith(loadingTimedOut: value);
  }

  Future<bool> deleteModule(String moduleId) async {
    try {
      final result = await _repository.deleteStudyModule(moduleId);
      if (result) {
        state = const ModuleDetailState(
          status: ModuleDetailStatus.success,
          module: null,
        );
      }
      return result;
    } catch (e) {
      state = state.copyWith(
        status: ModuleDetailStatus.failure,
        errorMessage: 'Đã xảy ra lỗi khi xóa học phần: $e',
      );
      return false;
    }
  }
}

// Provider factory cho module detail
final moduleDetailProvider = StateNotifierProvider.family<ModuleDetailNotifier,
    ModuleDetailState, String>(
  (ref, moduleId) {
    final repository = ref.watch(moduleRepositoryProvider);
    return ModuleDetailNotifier(repository);
  },
);

// Provider cho ModuleRepository
final moduleRepositoryProvider = Provider<ModuleRepository>((ref) {
  // Đảm bảo bạn đã cung cấp các dependencies cần thiết ở đây
  // Ví dụ:
  final dio = ref.watch(dioProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return ModuleRepository(dio, prefs);
});
