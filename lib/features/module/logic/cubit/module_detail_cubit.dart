// lib/features/module/logic/cubit/module_detail_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/module_repository.dart';
import '../states/module_detail_state.dart';

class ModuleDetailCubit extends Cubit<ModuleDetailState> {
  final ModuleRepository _repository;

  ModuleDetailCubit(this._repository) : super(const ModuleDetailState());

  // Load module details
  Future<void> loadModuleDetails(String moduleId, {bool forceRefresh = false}) async {
    emit(state.copyWith(status: ModuleDetailStatus.loading));

    try {
      final module = await _repository.getStudyModuleById(moduleId, forceRefresh: forceRefresh);
      emit(state.copyWith(
        status: ModuleDetailStatus.success,
        module: module,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ModuleDetailStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  // Delete module
  Future<bool> deleteModule(String moduleId) async {
    try {
      final result = await _repository.deleteStudyModule(moduleId);
      return result;
    } catch (e) {
      emit(state.copyWith(
        status: ModuleDetailStatus.failure,
        errorMessage: e.toString(),
      ));
      return false;
    }
  }
}