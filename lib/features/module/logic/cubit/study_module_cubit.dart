// lib/features/module/logic/cubit/study_module_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/module_repository.dart';
import '../states/study_module_state.dart';

class StudyModuleCubit extends Cubit<StudyModuleState> {
  final ModuleRepository _repository;

  StudyModuleCubit(this._repository) : super(const StudyModuleState());

  // Load all study modules
  Future<void> loadStudyModules({bool forceRefresh = false}) async {
    emit(state.copyWith(status: StudyModuleStatus.loading));

    try {
      final modules = await _repository.getStudyModules(forceRefresh: forceRefresh);
      emit(state.copyWith(
        status: StudyModuleStatus.success,
        modules: modules,
        hasReachedEnd: true, // For now, we load all at once
      ));
    } catch (e) {
      emit(state.copyWith(
        status: StudyModuleStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  // Load study modules for a folder
  Future<void> loadStudyModulesByFolder(String folderId, {bool forceRefresh = false}) async {
    emit(state.copyWith(status: StudyModuleStatus.loading));

    try {
      final modules = await _repository.getStudyModulesByFolder(folderId, forceRefresh: forceRefresh);
      emit(state.copyWith(
        status: StudyModuleStatus.success,
        modules: modules,
        hasReachedEnd: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: StudyModuleStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  // Refresh study modules
  Future<void> refreshStudyModules() async {
    await loadStudyModules(forceRefresh: true);
  }

  // Refresh folder study modules
  Future<void> refreshFolderStudyModules(String folderId) async {
    await loadStudyModulesByFolder(folderId, forceRefresh: true);
  }
}