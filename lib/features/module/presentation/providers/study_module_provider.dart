// lib/features/module/presentation/providers/study_module_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qlz_flash_cards_ui/core/providers/app_providers.dart';
import 'package:qlz_flash_cards_ui/features/module/data/models/study_module_model.dart';
import 'package:qlz_flash_cards_ui/features/module/data/repositories/module_repository.dart';

// State định nghĩa cho danh sách modules
enum StudyModuleStatus { initial, loading, success, failure }

class StudyModuleState {
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

// StateNotifier cho danh sách study modules
class StudyModuleNotifier extends StateNotifier<StudyModuleState> {
  final ModuleRepository _repository;

  StudyModuleNotifier(this._repository) : super(const StudyModuleState());

  Future<void> loadStudyModules({bool forceRefresh = false}) async {
    state = state.copyWith(status: StudyModuleStatus.loading);

    try {
      final modules =
          await _repository.getStudyModules(forceRefresh: forceRefresh);

      state = state.copyWith(
        status: StudyModuleStatus.success,
        modules: modules,
        hasReachedEnd: true, // For now, we load all at once
      );
    } catch (e) {
      state = state.copyWith(
        status: StudyModuleStatus.failure,
        errorMessage: 'Đã xảy ra lỗi: $e',
      );
    }
  }

  Future<void> loadStudyModulesByFolder(String folderId,
      {bool forceRefresh = false}) async {
    state = state.copyWith(status: StudyModuleStatus.loading);

    try {
      final modules = await _repository.getStudyModulesByFolder(
        folderId,
        forceRefresh: forceRefresh,
      );

      state = state.copyWith(
        status: StudyModuleStatus.success,
        modules: modules,
        hasReachedEnd: true,
      );
    } catch (e) {
      state = state.copyWith(
        status: StudyModuleStatus.failure,
        errorMessage: 'Đã xảy ra lỗi: $e',
      );
    }
  }

  Future<void> refreshStudyModules() async {
    await loadStudyModules(forceRefresh: true);
  }

  Future<void> refreshFolderStudyModules(String folderId) async {
    await loadStudyModulesByFolder(folderId, forceRefresh: true);
  }
}

// Provider cho StudyModuleNotifier
final studyModuleProvider =
    StateNotifierProvider<StudyModuleNotifier, StudyModuleState>(
  (ref) {
    final repository = ref.watch(moduleRepositoryProvider);
    return StudyModuleNotifier(repository);
  },
);
