// C:/Users/ntgpt/OneDrive/workspace/qlz_flash_cards_ui/lib/features/module/logic/cubit/study_module_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qlz_flash_cards_ui/features/module/data/repositories/module_repository.dart';
import 'package:qlz_flash_cards_ui/features/module/logic/states/study_module_state.dart';

class StudyModuleCubit extends Cubit<StudyModuleState> {
  final ModuleRepository _repository;
  bool _isClosed = false;

  StudyModuleCubit(this._repository) : super(const StudyModuleState());

  @override
  Future<void> close() {
    _isClosed = true;
    return super.close();
  }

  void _safeEmit(StudyModuleState newState) {
    if (!_isClosed) {
      emit(newState);
    }
  }

  Future<void> loadStudyModules({bool forceRefresh = false}) async {
    _safeEmit(state.copyWith(status: StudyModuleStatus.loading));

    try {
      final modules =
          await _repository.getStudyModules(forceRefresh: forceRefresh);

      _safeEmit(state.copyWith(
        status: StudyModuleStatus.success,
        modules: modules,
        hasReachedEnd: true, // For now, we load all at once
      ));
    } on NetworkTimeoutException catch (e) {
      _safeEmit(state.copyWith(
        status: StudyModuleStatus.failure,
        errorMessage: 'Không thể kết nối đến máy chủ: ${e.message}',
      ));
    } on ModuleException catch (e) {
      _safeEmit(state.copyWith(
        status: StudyModuleStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      _safeEmit(state.copyWith(
        status: StudyModuleStatus.failure,
        errorMessage: 'Đã xảy ra lỗi: $e',
      ));
    }
  }

  Future<void> loadStudyModulesByFolder(String folderId,
      {bool forceRefresh = false}) async {
    _safeEmit(state.copyWith(status: StudyModuleStatus.loading));

    try {
      final modules = await _repository.getStudyModulesByFolder(folderId,
          forceRefresh: forceRefresh);

      _safeEmit(state.copyWith(
        status: StudyModuleStatus.success,
        modules: modules,
        hasReachedEnd: true,
      ));
    } on NetworkTimeoutException catch (e) {
      _safeEmit(state.copyWith(
        status: StudyModuleStatus.failure,
        errorMessage: 'Không thể kết nối đến máy chủ: ${e.message}',
      ));
    } on ModuleException catch (e) {
      _safeEmit(state.copyWith(
        status: StudyModuleStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      _safeEmit(state.copyWith(
        status: StudyModuleStatus.failure,
        errorMessage: 'Đã xảy ra lỗi: $e',
      ));
    }
  }

  Future<void> refreshStudyModules() async {
    await loadStudyModules(forceRefresh: true);
  }

  Future<void> refreshFolderStudyModules(String folderId) async {
    await loadStudyModulesByFolder(folderId, forceRefresh: true);
  }
}
