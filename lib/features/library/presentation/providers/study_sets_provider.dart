import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qlz_flash_cards_ui/core/providers/app_providers.dart';
import 'package:qlz_flash_cards_ui/features/library/data/models/study_set_model.dart';
import 'package:qlz_flash_cards_ui/features/library/data/repositories/library_repository.dart';

enum StudySetsStatus { initial, loading, success, failure }

/// State class for study sets
class StudySetsState {
  final List<StudySet> studySets;
  final StudySetsStatus status;
  final String? errorMessage;
  final String? filter;
  final String? folderId;

  const StudySetsState({
    this.studySets = const [],
    this.status = StudySetsStatus.initial,
    this.errorMessage,
    this.filter,
    this.folderId,
  });

  StudySetsState copyWith({
    List<StudySet>? studySets,
    StudySetsStatus? status,
    String? errorMessage,
    String? filter,
    String? folderId,
  }) {
    return StudySetsState(
      studySets: studySets ?? this.studySets,
      status: status ?? this.status,
      errorMessage: errorMessage,
      filter: filter ?? this.filter,
      folderId: folderId ?? this.folderId,
    );
  }
}

/// StateNotifier that manages study sets state
class StudySetsNotifier extends StateNotifier<StudySetsState> {
  final LibraryRepository _repository;

  StudySetsNotifier(this._repository) : super(const StudySetsState());

  /// Loads all study sets with an optional filter
  Future<void> loadStudySets(
      {String? filter, bool forceRefresh = false}) async {
    state = state.copyWith(status: StudySetsStatus.loading);

    try {
      final studySets = await _repository.getStudySets(
        filter: filter,
        forceRefresh: forceRefresh,
      );

      state = state.copyWith(
        status: StudySetsStatus.success,
        studySets: studySets,
        filter: filter,
        folderId: null, // Reset folderId when viewing all study sets
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: StudySetsStatus.failure,
        errorMessage: e.toString(),
      );
    }
  }

  /// Loads study sets for a specific folder
  Future<void> loadStudySetsByFolder(String folderId,
      {bool forceRefresh = false}) async {
    state = state.copyWith(status: StudySetsStatus.loading);

    try {
      final studySets = await _repository.getStudySetsByFolder(
        folderId,
        forceRefresh: forceRefresh,
      );

      state = state.copyWith(
        status: StudySetsStatus.success,
        studySets: studySets,
        filter: null, // Reset filter when viewing by folder
        folderId: folderId,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: StudySetsStatus.failure,
        errorMessage: e.toString(),
      );
    }
  }

  /// Applies a filter to the study sets
  void applyFilter(String filter) {
    if (filter == state.filter) return;
    loadStudySets(filter: filter);
  }

  /// Refreshes the current view (either all study sets or by folder)
  Future<void> refreshStudySets() async {
    if (state.folderId != null) {
      await loadStudySetsByFolder(state.folderId!, forceRefresh: true);
    } else {
      await loadStudySets(filter: state.filter, forceRefresh: true);
    }
  }
}

/// Provider for study sets
final studySetsProvider =
    StateNotifierProvider.autoDispose<StudySetsNotifier, StudySetsState>((ref) {
  final repository = ref.watch(libraryRepositoryProvider);
  final notifier = StudySetsNotifier(repository);

  // Initialize by loading study sets
  notifier.loadStudySets();

  return notifier;
});

/// Provider for study sets filtered by folder
final folderStudySetsProvider = StateNotifierProvider.family
    .autoDispose<StudySetsNotifier, StudySetsState, String>((ref, folderId) {
  final repository = ref.watch(libraryRepositoryProvider);
  final notifier = StudySetsNotifier(repository);

  // Initialize by loading study sets for the specific folder
  notifier.loadStudySetsByFolder(folderId);

  return notifier;
});
