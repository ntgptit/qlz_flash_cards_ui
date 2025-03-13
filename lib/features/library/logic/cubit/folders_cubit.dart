// lib/features/library/logic/cubit/folders_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qlz_flash_cards_ui/features/library/data/models/folder_model.dart';

import '../../data/repositories/library_repository.dart';
import '../states/folders_state.dart';

class FoldersCubit extends Cubit<FoldersState> {
  final LibraryRepository _repository;

  FoldersCubit(this._repository) : super(const FoldersState());

  /// Tải danh sách thư mục
  Future<void> loadFolders({bool forceRefresh = false}) async {
    emit(state.copyWith(status: FoldersStatus.loading));

    try {
      final folders = await _repository.getFolders(forceRefresh: forceRefresh);
      emit(state.copyWith(
        status: FoldersStatus.success,
        folders: folders,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FoldersStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Làm mới danh sách thư mục
  Future<void> refreshFolders() async {
    await loadFolders(forceRefresh: true);
  }

  /// Tạo thư mục mới
  Future<bool> createFolder({
    required String title,
    String? description,
  }) async {
    if (title.trim().isEmpty) {
      emit(state.copyWith(
        validationError: 'Tiêu đề không được để trống',
      ));
      return false;
    }

    emit(state.copyWith(
      status: FoldersStatus.creating,
      validationError: null,
    ));

    try {
      final newFolder = await _repository.createFolder(
        name: title,
        description: description,
      );

      // Thêm thư mục mới vào danh sách hiện tại
      final updatedFolders = List<Folder>.from(state.folders)..add(newFolder);

      emit(state.copyWith(
        status: FoldersStatus.success,
        folders: updatedFolders,
      ));

      return true;
    } catch (e) {
      emit(state.copyWith(
        status: FoldersStatus.failure,
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
