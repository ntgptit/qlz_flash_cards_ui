import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qlz_flash_cards_ui/core/providers/app_providers.dart';
import 'package:qlz_flash_cards_ui/features/library/data/models/folder_model.dart';
import 'package:qlz_flash_cards_ui/features/library/data/repositories/library_repository.dart';
import 'package:qlz_flash_cards_ui/features/library/logic/states/folders_state.dart';

/// Provider for folders
final foldersProvider =
    StateNotifierProvider.autoDispose<FoldersNotifier, FoldersState>((ref) {
  final repository = ref.watch(libraryRepositoryProvider);
  final notifier = FoldersNotifier(repository);

  // Initialize by loading folders
  notifier.loadFolders();

  return notifier;
});

// bool get isCreating => status == FoldersStatus.creating;

/// StateNotifier that manages folders state
class FoldersNotifier extends StateNotifier<FoldersState> {
  final LibraryRepository _repository;

  FoldersNotifier(this._repository) : super(const FoldersState());

  /// Loads all folders
  Future<void> loadFolders({bool forceRefresh = false}) async {
    state = state.copyWith(status: FoldersStatus.loading);

    try {
      final folders = await _repository.getFolders(forceRefresh: forceRefresh);

      state = state.copyWith(
        status: FoldersStatus.success,
        folders: folders,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: FoldersStatus.failure,
        errorMessage: e.toString(),
      );
    }
  }

  /// Refreshes the folders list
  Future<void> refreshFolders() async {
    await loadFolders(forceRefresh: true);
  }

  /// Creates a new folder
  Future<bool> createFolder({
    required String title,
    String? description,
  }) async {
    if (title.trim().isEmpty) {
      state = state.copyWith(
        validationError: 'Tiêu đề không được để trống',
      );
      return false;
    }

    state = state.copyWith(
      status: FoldersStatus.creating,
      validationError: null,
    );

    try {
      final newFolder = await _repository.createFolder(
        name: title,
        description: description,
      );

      final updatedFolders = List<Folder>.from(state.folders)..add(newFolder);

      state = state.copyWith(
        status: FoldersStatus.success,
        folders: updatedFolders,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        status: FoldersStatus.failure,
        errorMessage: e.toString(),
      );

      return false;
    }
  }

  void clearError() {
    state = state.copyWith(validationError: null);
  }
}
