import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/data/models/flashcard_model.dart';

import '../../data/models/study_progress.dart';
import '../../data/repositories/flashcard_repository.dart';
import '../states/flashcard_state.dart';

/// Business logic component for managing flashcard study sessions
class FlashcardCubit extends Cubit<FlashcardState> {
  final FlashcardRepository _repository;

  // Timer for tracking study session duration
  Timer? _studyTimer;
  int _secondsStudied = 0;

  // Current module ID if studying a specific module
  String? _currentModuleId;

  /// Creates a FlashcardCubit instance
  FlashcardCubit(this._repository) : super(const FlashcardState());

  @override
  Future<void> close() {
    _stopStudyTimer();
    return super.close();
  }

  /// Initializes a flashcard study session with the provided flashcards
  void initializeFlashcards(List<Flashcard> flashcards, int initialIndex) {
    if (flashcards.isEmpty) {
      emit(state.copyWith(
        status: FlashcardStatus.failure,
        errorMessage: 'No flashcards available',
      ));
      return;
    }

    emit(state.copyWith(
      status: FlashcardStatus.success,
      flashcards: flashcards,
      currentIndex: initialIndex,
    ));

    _startStudyTimer();
  }

  /// Loads flashcards from a specific module
  Future<void> loadFlashcardsFromModule(String moduleId,
      {bool forceRefresh = false}) async {
    emit(state.copyWith(status: FlashcardStatus.loading));

    try {
      final flashcards = await _repository.getFlashcards(
        moduleId: moduleId,
        forceRefresh: forceRefresh,
      );

      if (flashcards.isEmpty) {
        emit(state.copyWith(
          status: FlashcardStatus.failure,
          errorMessage: 'No flashcards available in this module',
        ));
        return;
      }

      _currentModuleId = moduleId;

      // Try to load previous study progress
      final progress = await _repository.getStudyProgress(moduleId);

      emit(state.copyWith(
        status: FlashcardStatus.success,
        flashcards: flashcards,
        currentIndex: 0,
        learnedCount: progress?.learnedCount ?? 0,
        notLearnedCount: progress?.notLearnedCount ?? 0,
      ));

      _startStudyTimer();
    } catch (e) {
      emit(state.copyWith(
        status: FlashcardStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Marks the current flashcard as learned and moves to the next card
  void markAsLearned() {
    if (!state.hasMoreFlashcards) return;
    final flashcardId = state.currentFlashcard?.id;
    final learnedIds = List<String>.from(state.learnedIds);
    if (flashcardId != null && !learnedIds.contains(flashcardId)) {
      learnedIds.add(flashcardId);
    }
    emit(state.copyWith(
      learnedCount: state.learnedCount + 1,
      learnedIds: learnedIds,
      currentIndex:
          (state.currentIndex + 1).clamp(0, state.flashcards.length - 1),
    ));
    if (_currentModuleId != null) {
      _saveProgress();
    }
  }

  /// Marks the current flashcard as not learned and moves to the next card
  void markAsNotLearned() {
    if (!state.hasMoreFlashcards) return;
    final flashcardId = state.currentFlashcard?.id;
    final notLearnedIds = List<String>.from(state.notLearnedIds);
    if (flashcardId != null && !notLearnedIds.contains(flashcardId)) {
      notLearnedIds.add(flashcardId);
    }
    emit(state.copyWith(
      notLearnedCount: state.notLearnedCount + 1,
      notLearnedIds: notLearnedIds,
      currentIndex:
          (state.currentIndex + 1).clamp(0, state.flashcards.length - 1),
    ));
    if (_currentModuleId != null) {
      _saveProgress();
    }
  }

  /// Toggles whether a flashcard is marked as difficult
  Future<void> toggleDifficulty(String id) async {
    // Get the current state of the flashcard
    final index = state.flashcards.indexWhere((card) => card.id == id);
    if (index == -1) return;

    final flashcard = state.flashcards[index];
    final newDifficulty = !flashcard.isDifficult;

    // Update the repository
    await _repository.toggleDifficulty(id, newDifficulty);

    // Update the state
    final updatedCards = List<Flashcard>.from(state.flashcards);
    updatedCards[index] = flashcard.copyWith(isDifficult: newDifficulty);

    emit(state.copyWith(flashcards: updatedCards));
  }

  /// Resets the study session to the beginning
  void resetStudySession() {
    emit(state.copyWith(
      currentIndex: 0,
      learnedCount: 0,
      notLearnedCount: 0,
      learnedIds: const [],
      notLearnedIds: const [],
    ));

    _resetStudyTimer();
  }

  /// Start the study timer
  void _startStudyTimer() {
    _stopStudyTimer();
    _secondsStudied = 0;
    _studyTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _secondsStudied++;
    });
  }

  /// Stop the study timer
  void _stopStudyTimer() {
    _studyTimer?.cancel();
    _studyTimer = null;
  }

  /// Reset the study timer
  void _resetStudyTimer() {
    _stopStudyTimer();
    _secondsStudied = 0;
    _startStudyTimer();
  }

  /// Save study progress to the repository
  Future<void> _saveProgress() async {
    if (_currentModuleId == null) return;

    final totalFlashcards = state.flashcards.length;
    final completionPercentage = totalFlashcards > 0
        ? ((state.learnedCount + state.notLearnedCount) / totalFlashcards) * 100
        : 0.0;

    final progress = StudyProgress(
      moduleId: _currentModuleId!,
      totalStudyTimeSeconds: _secondsStudied,
      learnedCount: state.learnedCount,
      learnedIds: state.learnedIds,
      notLearnedCount: state.notLearnedCount,
      notLearnedIds: state.notLearnedIds,
      lastStudiedAt: DateTime.now(),
      completionPercentage: completionPercentage,
    );

    await _repository.saveStudyProgress(_currentModuleId!, progress);
  }
}
