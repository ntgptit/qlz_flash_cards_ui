import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qlz_flash_cards_ui/core/providers/app_providers.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/data/models/flashcard_model.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/data/models/study_progress.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/data/repositories/flashcard_repository.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/domain/states/flashcard_state.dart';

// Repository provider
final flashcardRepositoryProvider = Provider<FlashcardRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return FlashcardRepository(dio, prefs);
});

// State notifier
class FlashcardStateNotifier extends StateNotifier<FlashcardState> {
  final FlashcardRepository _repository;
  Timer? _studyTimer;
  int _secondsStudied = 0;
  String? _currentModuleId;

  FlashcardStateNotifier(this._repository) : super(const FlashcardState());

  @override
  void dispose() {
    _stopStudyTimer();
    super.dispose();
  }

  void initializeFlashcards(List<Flashcard> flashcards, int initialIndex) {
    if (flashcards.isEmpty) {
      state = state.copyWith(
        status: FlashcardStatus.failure,
        errorMessage: 'No flashcards available',
      );
      return;
    }

    final validInitialIndex = initialIndex.clamp(0, flashcards.length - 1);
    _resetStudyTimer();

    state = state.copyWith(
      status: FlashcardStatus.success,
      flashcards: flashcards,
      currentIndex: validInitialIndex,
      learnedCount: 0,
      notLearnedCount: 0,
      learnedIds: const [],
      notLearnedIds: const [],
      isSessionCompleted: false,
    );
  }

  void onPageChanged(int newIndex) {
    if (newIndex == state.currentIndex) return;

    final validIndex = newIndex.clamp(0, state.flashcards.length - 1);
    state = state.copyWith(currentIndex: validIndex);
  }

  Future<void> loadFlashcardsFromModule(String moduleId,
      {bool forceRefresh = false}) async {
    state = state.copyWith(status: FlashcardStatus.loading);

    try {
      final flashcards = await _repository.getFlashcards(
        moduleId: moduleId,
        forceRefresh: forceRefresh,
      );

      if (flashcards.isEmpty) {
        state = state.copyWith(
          status: FlashcardStatus.failure,
          errorMessage: 'No flashcards available in this module',
        );
        return;
      }

      _currentModuleId = moduleId;
      final progress = await _repository.getStudyProgress(moduleId);

      state = state.copyWith(
        status: FlashcardStatus.success,
        flashcards: flashcards,
        currentIndex: 0,
        learnedCount: progress?.learnedCount ?? 0,
        notLearnedCount: progress?.notLearnedCount ?? 0,
        learnedIds: progress?.learnedIds ?? const [],
        notLearnedIds: progress?.notLearnedIds ?? const [],
      );

      _startStudyTimer();
    } catch (e) {
      state = state.copyWith(
        status: FlashcardStatus.failure,
        errorMessage: e.toString(),
      );
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

    state = state.copyWith(
      learnedCount: state.learnedCount + 1,
      learnedIds: learnedIds,
    );

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

    state = state.copyWith(
      notLearnedCount: state.notLearnedCount + 1,
      notLearnedIds: notLearnedIds,
    );

    if (_currentModuleId != null) {
      _saveProgress();
    }
  }

  Future<void> toggleDifficulty(String id) async {
    final index = state.flashcards.indexWhere((card) => card.id == id);
    if (index == -1) return;

    final flashcard = state.flashcards[index];
    final newDifficulty = !flashcard.isDifficult;

    await _repository.toggleDifficulty(id, newDifficulty);

    final updatedCards = List<Flashcard>.from(state.flashcards);
    updatedCards[index] = flashcard.copyWith(isDifficult: newDifficulty);

    state = state.copyWith(flashcards: updatedCards);
  }

  void resetStudySession() {
    state = state.copyWith(
      currentIndex: 0,
      learnedCount: 0,
      notLearnedCount: 0,
      learnedIds: const [],
      notLearnedIds: const [],
      isSessionCompleted: false,
    );

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

// Main provider
final flashcardProvider =
    StateNotifierProvider<FlashcardStateNotifier, FlashcardState>((ref) {
  final repository = ref.watch(flashcardRepositoryProvider);
  return FlashcardStateNotifier(repository);
});
