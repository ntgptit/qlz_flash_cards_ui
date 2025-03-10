// lib/features/library/logic/cubits/folders_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/library_repository.dart';
import '../states/folders_state.dart';

/// Cubit quản lý business logic cho folders
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
}
