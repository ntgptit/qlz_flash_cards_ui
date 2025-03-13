import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/data/models/flashcard_model.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/data/models/study_progress.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/data/repositories/flashcard_repository.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/logic/states/flashcard_state.dart';

class FlashcardCubit extends Cubit<FlashcardState> {
  final FlashcardRepository _repository;
  Timer? _studyTimer;
  int _secondsStudied = 0;
  String? _currentModuleId;

  FlashcardCubit(this._repository) : super(const FlashcardState());

  @override
  Future<void> close() {
    _stopStudyTimer();
    return super.close();
  }

  void initializeFlashcards(List<Flashcard> flashcards, int initialIndex) {
    if (flashcards.isEmpty) {
      emit(state.copyWith(
        status: FlashcardStatus.failure,
        errorMessage: 'No flashcards available',
      ));
      return;
    }

    // Ensure initialIndex is within valid bounds
    final validInitialIndex = initialIndex.clamp(0, flashcards.length - 1);

    // Reset study session data
    _resetStudyTimer();

    emit(state.copyWith(
      status: FlashcardStatus.success,
      flashcards: flashcards,
      currentIndex: validInitialIndex,
      learnedCount: 0,
      notLearnedCount: 0,
      learnedIds: const [],
      notLearnedIds: const [],
      isSessionCompleted: false,
    ));
  }

  // Add method to handle page changes from UI (for better one-way data flow)
  void onPageChanged(int newIndex) {
    if (newIndex == state.currentIndex) return;

    final validIndex = newIndex.clamp(0, state.flashcards.length - 1);
    emit(state.copyWith(currentIndex: validIndex));
  }

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
      final progress = await _repository.getStudyProgress(moduleId);
      emit(state.copyWith(
        status: FlashcardStatus.success,
        flashcards: flashcards,
        currentIndex: 0,
        learnedCount: progress?.learnedCount ?? 0,
        notLearnedCount: progress?.notLearnedCount ?? 0,
        learnedIds: progress?.learnedIds ?? const [],
        notLearnedIds: progress?.notLearnedIds ?? const [],
      ));
      _startStudyTimer();
    } catch (e) {
      emit(state.copyWith(
        status: FlashcardStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void markAsLearned() {
    if (!state.hasMoreFlashcards) return;

    final flashcardId = state.currentFlashcard?.id;
    if (flashcardId == null) return;

    final learnedIds = List<String>.from(state.learnedIds);
    if (!learnedIds.contains(flashcardId)) {
      learnedIds.add(flashcardId);
    }

    emit(state.copyWith(
      learnedCount: state.learnedCount + 1,
      learnedIds: learnedIds,
      // Don't auto-increment currentIndex anymore, let UI/PageView handle it
    ));

    if (_currentModuleId != null) {
      _saveProgress();
    }
  }

  void markAsNotLearned() {
    if (!state.hasMoreFlashcards) return;

    final flashcardId = state.currentFlashcard?.id;
    if (flashcardId == null) return;

    final notLearnedIds = List<String>.from(state.notLearnedIds);
    if (!notLearnedIds.contains(flashcardId)) {
      notLearnedIds.add(flashcardId);
    }

    emit(state.copyWith(
      notLearnedCount: state.notLearnedCount + 1,
      notLearnedIds: notLearnedIds,
      // Don't auto-increment currentIndex anymore, let UI/PageView handle it
    ));

    if (_currentModuleId != null) {
      _saveProgress();
    }
  }

  Future<void> toggleDifficulty(String id) async {
    final index = state.flashcards.indexWhere((card) => card.id == id);
    if (index == -1) return;

    final flashcard = state.flashcards[index];
    final newDifficulty = !flashcard.isDifficult;

    // Update in repository
    await _repository.toggleDifficulty(id, newDifficulty);

    // Update in state
    final updatedCards = List<Flashcard>.from(state.flashcards);
    updatedCards[index] = flashcard.copyWith(isDifficult: newDifficulty);

    emit(state.copyWith(flashcards: updatedCards));
  }

  void resetStudySession() {
    emit(state.copyWith(
      currentIndex: 0,
      learnedCount: 0,
      notLearnedCount: 0,
      learnedIds: const [],
      notLearnedIds: const [],
      isSessionCompleted: false,
    ));
    _resetStudyTimer();
  }

  void _startStudyTimer() {
    _stopStudyTimer();
    _secondsStudied = 0;
    _studyTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _secondsStudied++;
    });
  }

  void _stopStudyTimer() {
    _studyTimer?.cancel();
    _studyTimer = null;
  }

  void _resetStudyTimer() {
    _stopStudyTimer();
    _secondsStudied = 0;
    _startStudyTimer();
  }

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
