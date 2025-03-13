// lib/features/library/logic/cubits/classes_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qlz_flash_cards_ui/features/library/data/models/class_model.dart';

import '../../data/repositories/library_repository.dart';
import '../states/classes_state.dart';

/// Cubit quản lý business logic cho classes
class ClassesCubit extends Cubit<ClassesState> {
  final LibraryRepository _repository;

  ClassesCubit(this._repository) : super(const ClassesState());

  /// Tải danh sách lớp học
  Future<void> loadClasses({bool forceRefresh = false}) async {
    emit(state.copyWith(status: ClassesStatus.loading));

    try {
      final classes = await _repository.getClasses(forceRefresh: forceRefresh);
      emit(state.copyWith(
        status: ClassesStatus.success,
        classes: classes,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ClassesStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Làm mới danh sách lớp học
  Future<void> refreshClasses() async {
    await loadClasses(forceRefresh: true);
  }

  /// Tạo lớp học mới
  Future<bool> createClass(
      {required String name,
      required String description,
      required bool allowMembersToAdd}) async {
    if (name.trim().isEmpty) {
      emit(state.copyWith(
        validationError: 'Vui lòng nhập tên lớp học',
      ));
      return false;
    }

    emit(state.copyWith(
      status: ClassesStatus.creating,
      validationError: null,
    ));

    try {
      final newClass = await _repository.createClass(
        name: name,
        description: description,
        allowMembersToAdd: allowMembersToAdd,
      );

      // Thêm lớp học mới vào danh sách hiện tại
      final updatedClasses = List<ClassModel>.from(state.classes)
        ..add(newClass);

      emit(state.copyWith(
        status: ClassesStatus.success,
        classes: updatedClasses,
      ));

      return true;
    } catch (e) {
      emit(state.copyWith(
        status: ClassesStatus.failure,
        errorMessage: e.toString(),
      ));
      return false;
    }
  }

  /// Xóa thông báo lỗi
  void clearError() {
    emit(state.copyWith(
      errorMessage: null,
      validationError: null,
    ));
  }
}
