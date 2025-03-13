// C:/Users/ntgpt/OneDrive/workspace/qlz_flash_cards_ui/lib/features/module/logic/cubit/module_detail_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qlz_flash_cards_ui/features/module/data/repositories/module_repository.dart';
import 'package:qlz_flash_cards_ui/features/module/logic/states/module_detail_state.dart';

class ModuleDetailCubit extends Cubit<ModuleDetailState> {
  final ModuleRepository _repository;
  bool _isClosed = false;

  ModuleDetailCubit(this._repository) : super(const ModuleDetailState());

  @override
  Future<void> close() {
    _isClosed = true;
    return super.close();
  }

  // Kiểm tra xem cubit đã bị đóng chưa trước khi emit state mới
  void _safeEmit(ModuleDetailState newState) {
    if (!_isClosed) {
      emit(newState);
    }
  }

  Future<void> loadModuleDetails(String moduleId,
      {bool forceRefresh = false}) async {
    print("DEBUG-Cubit: Loading module details for ID: $moduleId");
    _safeEmit(state.copyWith(status: ModuleDetailStatus.loading));

    try {
      print("DEBUG-Cubit: Calling repository");
      final module = await _repository.getStudyModuleById(moduleId,
          forceRefresh: forceRefresh);

      print("DEBUG-Cubit: Repository returned data");
      _safeEmit(state.copyWith(
        status: ModuleDetailStatus.success,
        module: module,
      ));
      print("DEBUG-Cubit: Emitted success state");
    } catch (e) {
      print("DEBUG-Cubit: Error loading module: $e");
      _safeEmit(state.copyWith(
        status: ModuleDetailStatus.failure,
        errorMessage: 'Đã xảy ra lỗi: $e',
      ));
      print("DEBUG-Cubit: Emitted failure state");
    }
  }

  Future<bool> deleteModule(String moduleId) async {
    try {
      final result = await _repository.deleteStudyModule(moduleId);

      if (result) {
        _safeEmit(const ModuleDetailState(
          status: ModuleDetailStatus.success,
          module: null,
        ));
      }

      return result;
    } on NetworkTimeoutException catch (e) {
      _safeEmit(state.copyWith(
        status: ModuleDetailStatus.failure,
        errorMessage: 'Không thể kết nối đến máy chủ: ${e.message}',
      ));
      return false;
    } on PermissionException catch (e) {
      _safeEmit(state.copyWith(
        status: ModuleDetailStatus.failure,
        errorMessage: e.message,
      ));
      return false;
    } on ModuleException catch (e) {
      _safeEmit(state.copyWith(
        status: ModuleDetailStatus.failure,
        errorMessage: e.message,
      ));
      return false;
    } catch (e) {
      _safeEmit(state.copyWith(
        status: ModuleDetailStatus.failure,
        errorMessage: 'Đã xảy ra lỗi khi xóa học phần: $e',
      ));
      return false;
    }
  }
}
