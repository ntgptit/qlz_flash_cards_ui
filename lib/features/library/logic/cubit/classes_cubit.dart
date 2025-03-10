// lib/features/library/logic/cubits/classes_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';

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
}
