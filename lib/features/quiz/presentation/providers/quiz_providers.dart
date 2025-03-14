import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/data/models/flashcard_model.dart';
import 'package:qlz_flash_cards_ui/features/quiz/data/models/quiz_answer.dart';
import 'package:qlz_flash_cards_ui/features/quiz/data/models/quiz_question.dart';
import 'package:qlz_flash_cards_ui/features/quiz/data/models/quiz_settings.dart';
import 'package:qlz_flash_cards_ui/features/quiz/data/services/quiz_service.dart';
import 'package:qlz_flash_cards_ui/features/quiz/domain/states/quiz_settings_state.dart';
import 'package:qlz_flash_cards_ui/features/quiz/domain/states/quiz_state.dart';
import 'package:riverpod/riverpod.dart';

// Quiz Service Provider
final quizServiceProvider = Provider<QuizService>((ref) {
  return QuizService();
});

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

// Field State Providers
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

// Quiz Provider
final quizProvider =
    StateNotifierProvider.autoDispose<QuizNotifier, QuizState>((ref) {
  final quizService = ref.watch(quizServiceProvider);
  return QuizNotifier(quizService: quizService);
});

class QuizNotifier extends StateNotifier<QuizState> {
  final QuizService _quizService;
  Timer? _questionTimer;
  Timer? _quizTimer;
  bool _disposed = false;

  QuizNotifier({required QuizService quizService})
      : _quizService = quizService,
        super(const QuizState());

  void initialize({
    required QuizType quizType,
    required QuizDifficulty difficulty,
    required List<Flashcard> flashcards,
    required String moduleId,
    required String moduleName,
    required int questionCount,
    required bool shuffleQuestions,
    required bool showCorrectAnswers,
    required bool enableTimer,
    required int timePerQuestion,
  }) {
    final selectedFlashcards = _quizService.selectFlashcards(
      flashcards,
      questionCount,
      shuffleQuestions,
    );

    final questions = _quizService.createQuestions(
      selectedFlashcards,
      quizType,
      difficulty,
      flashcards,
    );

    state = state.copyWith(
      quizType: quizType,
      difficulty: difficulty,
      moduleId: moduleId,
      moduleName: moduleName,
      questions: questions,
      currentQuestionIndex: 0,
      showCorrectAnswers: showCorrectAnswers,
      enableTimer: enableTimer,
      timePerQuestion: timePerQuestion,
      status: QuizStatus.inProgress,
    );

    if (enableTimer) {
      _startQuestionTimer();
    }

    _startQuizTimer();
  }

  void _startQuestionTimer() {
    _questionTimer?.cancel();
    if (!state.enableTimer) return;

    state = state.copyWith(
      remainingTime: state.timePerQuestion,
    );

    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_disposed) {
        timer.cancel();
        return;
      }

      final newTime = state.remainingTime - 1;
      if (newTime <= 0) {
        timer.cancel();
        _handleTimeUp();
      } else {
        state = state.copyWith(
          remainingTime: newTime,
        );
      }
    });
  }

  void _startQuizTimer() {
    _quizTimer?.cancel();

    state = state.copyWith(
      elapsedTime: 0,
    );

    _quizTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_disposed) {
        timer.cancel();
        return;
      }

      state = state.copyWith(
        elapsedTime: state.elapsedTime + 1,
      );
    });
  }

  void _handleTimeUp() {
    if (_disposed) return;

    if (!state.hasAnsweredCurrentQuestion) {
      _answerCurrentQuestion(null);

      Future.delayed(const Duration(milliseconds: 1500), () {
        if (_disposed) return;
        nextQuestion();
      });
    }
  }

  void answerQuestion(QuizAnswer? answer) {
    if (_disposed) return;
    if (state.status != QuizStatus.inProgress) return;
    if (state.hasAnsweredCurrentQuestion) return;

    _answerCurrentQuestion(answer);
    _questionTimer?.cancel();

    if (state.showCorrectAnswers) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (_disposed) return;
        nextQuestion();
      });
    } else {
      nextQuestion();
    }
  }

  void _answerCurrentQuestion(QuizAnswer? answer) {
    final updatedAnswers = List<QuizAnswer?>.from(state.userAnswers);

    while (updatedAnswers.length <= state.currentQuestionIndex) {
      updatedAnswers.add(null);
    }

    updatedAnswers[state.currentQuestionIndex] = answer;

    state = state.copyWith(
      userAnswers: updatedAnswers,
    );
  }

  void nextQuestion() {
    if (_disposed) return;
    if (state.status != QuizStatus.inProgress) return;

    if (state.currentQuestionIndex >= state.questions.length - 1) {
      _finishQuiz();
      return;
    }

    state = state.copyWith(
      currentQuestionIndex: state.currentQuestionIndex + 1,
    );

    if (state.enableTimer) {
      _startQuestionTimer();
    }
  }

  void previousQuestion() {
    if (_disposed) return;
    if (state.status != QuizStatus.inProgress) return;
    if (state.currentQuestionIndex <= 0) return;

    state = state.copyWith(
      currentQuestionIndex: state.currentQuestionIndex - 1,
    );

    if (state.enableTimer) {
      _startQuestionTimer();
    }
  }

  void _finishQuiz() {
    _stopAllTimers();

    final (score, correctCount) = _quizService.calculateScore(
      state.questions,
      state.userAnswers,
    );

    state = state.copyWith(
      status: QuizStatus.completed,
      score: score,
      correctAnswersCount: correctCount,
    );
  }

  void restartQuiz() {
    final questions = state.questions;

    state = state.copyWith(
      userAnswers: [],
      currentQuestionIndex: 0,
      status: QuizStatus.inProgress,
      score: 0,
      correctAnswersCount: 0,
      elapsedTime: 0,
    );

    if (state.enableTimer) {
      _startQuestionTimer();
    }

    _startQuizTimer();
  }

  void exitQuiz() {
    _stopAllTimers();

    state = state.copyWith(
      status: QuizStatus.exited,
    );
  }

  void _stopAllTimers() {
    _questionTimer?.cancel();
    _quizTimer?.cancel();
  }

  @override
  void dispose() {
    _disposed = true;
    _stopAllTimers();
    super.dispose();
  }
}

// Current Question Provider for efficient rebuild
final currentQuestionProvider = Provider.autoDispose<QuizQuestion?>((ref) {
  final quizState = ref.watch(quizProvider);

  if (quizState.questions.isEmpty ||
      quizState.currentQuestionIndex >= quizState.questions.length) {
    return null;
  }

  return quizState.questions[quizState.currentQuestionIndex];
});

// Question Generator Provider with memoization
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

// Helper function for efficient shuffle
void efficientShuffle<T>(List<T> list) {
  final random = Random();
  for (var i = list.length - 1; i > 0; i--) {
    final j = random.nextInt(i + 1);
    // Swap
    final temp = list[i];
    list[i] = list[j];
    list[j] = temp;
  }
}
