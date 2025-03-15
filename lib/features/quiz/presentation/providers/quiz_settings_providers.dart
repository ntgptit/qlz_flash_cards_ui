import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/data/models/flashcard_model.dart';
import 'package:qlz_flash_cards_ui/features/quiz/data/models/quiz_question.dart';
import 'package:qlz_flash_cards_ui/features/quiz/data/models/quiz_settings.dart';
import 'package:qlz_flash_cards_ui/features/quiz/domain/states/quiz_settings_state.dart';
import 'package:riverpod/riverpod.dart';

// Import các cung cấp dịch vụ từ quiz_providers.dart
// nhưng không import quizSettingsProvider để tránh circular dependency
import 'quiz_providers.dart' show quizServiceProvider;

// -------------------------------------------------------------------------
// QUIZ SETTINGS STATE MANAGEMENT
// -------------------------------------------------------------------------

// Quiz Settings Provider
final quizSettingsProvider =
    StateNotifierProvider.autoDispose<QuizSettingsNotifier, QuizSettingsState>(
        (ref) {
  return QuizSettingsNotifier();
});

class QuizSettingsNotifier extends StateNotifier<QuizSettingsState> {
  QuizSettingsNotifier() : super(const QuizSettingsState());

  void initialize(int totalFlashcards) {
    if (totalFlashcards <= 0) {
      state = state.copyWith(
        questionCount: 1,
        maxQuestionCount: 1,
      );
      return;
    }

    final defaultCount = totalFlashcards;
    state = state.copyWith(
      questionCount: defaultCount,
      maxQuestionCount: totalFlashcards,
    );
  }

  void setQuizType(QuizType quizType) {
    if (quizType == state.quizType) return;
    state = state.copyWith(
      quizType: quizType,
    );
  }

  void setDifficulty(QuizDifficulty difficulty) {
    if (difficulty == state.difficulty) return;
    state = state.copyWith(
      difficulty: difficulty,
    );
  }

  void setQuestionCount(int count) {
    if (count == state.questionCount) return;
    count = _validateQuestionCount(count);
    state = state.copyWith(
      questionCount: count,
    );
  }

  int _validateQuestionCount(int count) {
    if (count > state.maxQuestionCount) {
      return state.maxQuestionCount;
    }
    if (count < 1) {
      return 1;
    }
    return count;
  }

  void setShuffleQuestions(bool value) {
    if (value == state.shuffleQuestions) return;
    state = state.copyWith(
      shuffleQuestions: value,
    );
  }

  void setShowCorrectAnswers(bool value) {
    if (value == state.showCorrectAnswers) return;
    state = state.copyWith(
      showCorrectAnswers: value,
    );
  }

  void setEnableTimer(bool value) {
    if (value == state.enableTimer) return;
    state = state.copyWith(
      enableTimer: value,
    );
  }

  void setTimePerQuestion(int seconds) {
    if (seconds == state.timePerQuestion) return;
    seconds = _validateTimePerQuestion(seconds);
    state = state.copyWith(
      timePerQuestion: seconds,
    );
  }

  int _validateTimePerQuestion(int seconds) {
    if (seconds < 5) {
      return 5;
    }
    if (seconds > 300) {
      return 300;
    }
    return seconds;
  }

  void resetToDefaults(int totalFlashcards) {
    if (totalFlashcards <= 0) {
      state = const QuizSettingsState(
        maxQuestionCount: 0,
        questionCount: 0,
      );
      return;
    }

    final defaultCount = totalFlashcards < 10 ? totalFlashcards : 10;
    state = QuizSettingsState(
      questionCount: defaultCount,
      maxQuestionCount: totalFlashcards,
    );
  }
}

// -------------------------------------------------------------------------
// QUIZ SCREEN STATE MANAGEMENT
// -------------------------------------------------------------------------

// UI State Providers
final quizScreenStateProvider =
    StateNotifierProvider.autoDispose<QuizScreenStateNotifier, QuizScreenState>(
        (ref) {
  return QuizScreenStateNotifier();
});

class QuizScreenState {
  final bool hasAttemptedSubmit;
  final bool isInitialized;

  QuizScreenState({
    this.hasAttemptedSubmit = false,
    this.isInitialized = false,
  });

  QuizScreenState copyWith({
    bool? hasAttemptedSubmit,
    bool? isInitialized,
  }) {
    return QuizScreenState(
      hasAttemptedSubmit: hasAttemptedSubmit ?? this.hasAttemptedSubmit,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class QuizScreenStateNotifier extends StateNotifier<QuizScreenState> {
  QuizScreenStateNotifier() : super(QuizScreenState());

  void setHasAttemptedSubmit(bool value) {
    state = state.copyWith(hasAttemptedSubmit: value);
  }

  void setInitialized(bool value) {
    state = state.copyWith(isInitialized: value);
  }
}

// -------------------------------------------------------------------------
// FORM FIELD PROVIDERS
// -------------------------------------------------------------------------

// Time per question field providers
final timePerQuestionProvider = StateProvider.autoDispose<int>((ref) {
  return ref.watch(quizSettingsProvider).timePerQuestion;
});

final timePerQuestionControllerProvider =
    Provider.autoDispose<TextEditingController>((ref) {
  final controller = TextEditingController(
      text: ref.watch(timePerQuestionProvider).toString());
  ref.onDispose(() => controller.dispose());
  return controller;
});

final timePerQuestionFocusProvider = Provider.autoDispose<FocusNode>((ref) {
  final focusNode = FocusNode();
  final controller = ref.watch(timePerQuestionControllerProvider);

  focusNode.addListener(() {
    if (!focusNode.hasFocus) {
      final text = controller.text.trim();
      if (text.isEmpty) {
        controller.text = '30';
        ref.read(timePerQuestionProvider.notifier).state = 30;
        ref.read(quizSettingsProvider.notifier).setTimePerQuestion(30);
        return;
      }

      final time = int.tryParse(text) ?? 30;
      final validatedTime = time.clamp(5, 300);

      if (time != validatedTime) {
        controller.text = validatedTime.toString();
      }

      ref.read(timePerQuestionProvider.notifier).state = validatedTime;
      ref.read(quizSettingsProvider.notifier).setTimePerQuestion(validatedTime);
    }
  });

  ref.onDispose(() {
    focusNode.dispose();
  });

  return focusNode;
});

// Question count field providers
final questionCountProvider = StateProvider.autoDispose<int>((ref) {
  return ref.watch(quizSettingsProvider).questionCount;
});

final questionCountControllerProvider =
    Provider.autoDispose<TextEditingController>((ref) {
  final controller =
      TextEditingController(text: ref.watch(questionCountProvider).toString());
  ref.onDispose(() => controller.dispose());
  return controller;
});

final questionCountFocusProvider = Provider.autoDispose<FocusNode>((ref) {
  final focusNode = FocusNode();
  final controller = ref.watch(questionCountControllerProvider);
  final maxCount = ref.watch(quizSettingsProvider).maxQuestionCount;

  focusNode.addListener(() {
    if (!focusNode.hasFocus) {
      final text = controller.text.trim();
      if (text.isEmpty) {
        controller.text = '10';
        ref.read(questionCountProvider.notifier).state = 10;
        ref.read(quizSettingsProvider.notifier).setQuestionCount(10);
        return;
      }

      final count = int.tryParse(text) ?? 10;
      final validatedCount = count.clamp(1, maxCount);

      if (count != validatedCount) {
        controller.text = validatedCount.toString();
      }

      ref.read(questionCountProvider.notifier).state = validatedCount;
      ref.read(quizSettingsProvider.notifier).setQuestionCount(validatedCount);
    }
  });

  ref.onDispose(() {
    focusNode.dispose();
  });

  return focusNode;
});

// Question Generator Provider with memoization - moved here to solve dependency issues
final questionGeneratorProvider = Provider.family
    .autoDispose<QuizQuestion, (Flashcard, QuizDifficulty, List<Flashcard>)>(
        (ref, params) {
  final (flashcard, difficulty, allFlashcards) = params;
  final quizService = ref.watch(quizServiceProvider);

  return quizService.createQuestionFromFlashcard(
    flashcard: flashcard,
    quizType: ref.watch(quizSettingsProvider).quizType,
    difficulty: difficulty,
    allFlashcards: allFlashcards,
  );
});
