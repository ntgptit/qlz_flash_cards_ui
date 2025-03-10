// lib/features/library/logic/cubits/study_sets_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/library_repository.dart';
import '../states/study_sets_state.dart';

/// Cubit quản lý business logic cho study sets
class StudySetsCubit extends Cubit<StudySetsState> {
  final LibraryRepository _repository;

  StudySetsCubit(this._repository) : super(const StudySetsState());

  /// Tải tất cả study sets với bộ lọc tùy chọn
  Future<void> loadStudySets(
      {String? filter, bool forceRefresh = false}) async {
    emit(state.copyWith(status: StudySetsStatus.loading));

    try {
      final studySets = await _repository.getStudySets(
        filter: filter,
        forceRefresh: forceRefresh,
      );

      emit(state.copyWith(
        status: StudySetsStatus.success,
        studySets: studySets,
        filter: filter,
        folderId: null, // Reset folderId khi xem tất cả study sets
      ));
    } catch (e) {
      emit(state.copyWith(
        status: StudySetsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Tải study sets theo thư mục
  Future<void> loadStudySetsByFolder(String folderId,
      {bool forceRefresh = false}) async {
    emit(state.copyWith(status: StudySetsStatus.loading));

    try {
      final studySets = await _repository.getStudySetsByFolder(
        folderId,
        forceRefresh: forceRefresh,
      );

      emit(state.copyWith(
        status: StudySetsStatus.success,
        studySets: studySets,
        filter: null, // Reset bộ lọc khi xem theo thư mục
        folderId: folderId,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: StudySetsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Áp dụng bộ lọc cho study sets
  void applyFilter(String filter) {
    if (filter == state.filter) return;
    loadStudySets(filter: filter);
  }

  /// Làm mới danh sách study sets
  Future<void> refreshStudySets() async {
    // Nếu đang xem theo thư mục, gọi refresh theo thư mục
    if (state.folderId != null) {
      await refreshStudySetsByFolder(state.folderId!);
    } else {
      // Ngược lại, làm mới tất cả study sets với bộ lọc hiện tại
      await loadStudySets(filter: state.filter, forceRefresh: true);
    }
  }

  /// Làm mới danh sách study sets theo thư mục
  Future<void> refreshStudySetsByFolder(String folderId) async {
    await loadStudySetsByFolder(folderId, forceRefresh: true);
  }
}
