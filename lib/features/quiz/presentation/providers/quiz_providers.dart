import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/data/models/flashcard_model.dart';
import 'package:qlz_flash_cards_ui/features/quiz/data/models/quiz_answer.dart';
import 'package:qlz_flash_cards_ui/features/quiz/data/models/quiz_question.dart';
import 'package:qlz_flash_cards_ui/features/quiz/data/models/quiz_settings.dart';
import 'package:qlz_flash_cards_ui/features/quiz/data/services/quiz_service.dart';
import 'package:qlz_flash_cards_ui/features/quiz/domain/states/quiz_state.dart';

final quizServiceProvider = Provider<QuizService>((ref) {
  return QuizService();
});

void efficientShuffle<T>(List<T> list) {
  final random = Random();
  for (var i = list.length - 1; i > 0; i--) {
    final j = random.nextInt(i + 1);
    final temp = list[i];
    list[i] = list[j];
    list[j] = temp;
  }
}

final quizProvider =
    StateNotifierProvider.autoDispose<QuizNotifier, QuizState>((ref) {
  final quizService = ref.read(quizServiceProvider);
  return QuizNotifier(quizService: quizService, ref: ref);
});

class QuizNotifier extends StateNotifier<QuizState> {
  final QuizService _quizService;
  final Ref _ref;
  Timer? _questionTimer;
  Timer? _quizTimer;
  bool _disposed = false;

  QuizNotifier({required QuizService quizService, required Ref ref})
      : _quizService = quizService,
        _ref = ref,
        super(const QuizState()) {
    _ref.onDispose(() {
      _disposed = true;
      _stopAllTimers();
    });
  }

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
    try {
      if (flashcards.isEmpty) {
        state = state.copyWith(status: QuizStatus.exited);
        return;
      }
      final limitedQuestionCount = questionCount.clamp(1, flashcards.length);
      final selectedFlashcards = _quizService.selectFlashcards(
        flashcards,
        limitedQuestionCount,
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
      if (enableTimer && !_disposed) {
        _startQuestionTimer();
      }
      if (!_disposed) {
        _startQuizTimer();
      }
    } catch (e, stackTrace) {
      debugPrint('Error initializing quiz: $e');
      debugPrint('Stack trace: $stackTrace');
      state = state.copyWith(status: QuizStatus.exited);
    }
  }

  void _startQuestionTimer() {
    _questionTimer?.cancel();
    if (_disposed || !state.enableTimer) return;
    state = state.copyWith(remainingTime: state.timePerQuestion);
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
        state = state.copyWith(remainingTime: newTime);
      }
    });
  }

  void _startQuizTimer() {
    _quizTimer?.cancel();
    if (_disposed) return;
    state = state.copyWith(elapsedTime: 0);
    _quizTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_disposed) {
        timer.cancel();
        return;
      }
      state = state.copyWith(elapsedTime: state.elapsedTime + 1);
    });
  }

  void _handleTimeUp() {
    if (_disposed) return;
    if (!state.hasAnsweredCurrentQuestion) {
      _answerCurrentQuestion(null);
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (!_disposed) {
          nextQuestion();
        }
      });
    }
  }

  void answerQuestion(QuizAnswer? answer) {
    if (_disposed || state.status != QuizStatus.inProgress) return;
    if (state.hasAnsweredCurrentQuestion) return;
    final isCorrect = answer?.isCorrect ?? false;
    _answerCurrentQuestion(answer);
    _questionTimer?.cancel();
    if (!state.showCorrectAnswers) {
      nextQuestion();
      return;
    }
    if (isCorrect) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (!_disposed) {
          nextQuestion();
        }
      });
      return;
    }
  }

  void _answerCurrentQuestion(QuizAnswer? answer) {
    if (_disposed) return;
    final updatedAnswers = List<QuizAnswer?>.from(state.userAnswers);
    while (updatedAnswers.length <= state.currentQuestionIndex) {
      updatedAnswers.add(null);
    }
    updatedAnswers[state.currentQuestionIndex] = answer;
    final isCorrect = answer?.isCorrect ?? false;
    state = state.copyWith(
      userAnswers: updatedAnswers,
      lastAnswerWasCorrect: isCorrect,
    );
  }

  void nextQuestion() {
    if (_disposed || state.status != QuizStatus.inProgress) return;
    if (state.currentQuestionIndex >= state.questions.length - 1) {
      _finishQuiz();
      return;
    }
    state =
        state.copyWith(currentQuestionIndex: state.currentQuestionIndex + 1);
    if (state.enableTimer) {
      _startQuestionTimer();
    }
  }

  void previousQuestion() {
    if (_disposed || state.status != QuizStatus.inProgress) return;
    if (state.currentQuestionIndex <= 0) return;
    state =
        state.copyWith(currentQuestionIndex: state.currentQuestionIndex - 1);
    if (state.enableTimer) {
      _startQuestionTimer();
    }
  }

  void _finishQuiz() {
    _stopAllTimers();
    if (_disposed) return;
    final (score, correctCount) =
        _quizService.calculateScore(state.questions, state.userAnswers);
    state = state.copyWith(
      status: QuizStatus.completed,
      score: score,
      correctAnswersCount: correctCount,
    );
  }

  void restartQuiz() {
    if (_disposed) return;
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
    if (!_disposed) {
      state = state.copyWith(status: QuizStatus.exited);
    }
  }

  void _stopAllTimers() {
    _questionTimer?.cancel();
    _quizTimer?.cancel();
  }
}

final currentQuestionProvider = Provider.autoDispose<QuizQuestion?>((ref) {
  try {
    final quizState = ref.watch(quizProvider);
    if (quizState.questions.isEmpty ||
        quizState.currentQuestionIndex >= quizState.questions.length) {
      return null;
    }
    return quizState.questions[quizState.currentQuestionIndex];
  } catch (e) {
    debugPrint('Error in currentQuestionProvider: $e');
    return null;
  }
}, dependencies: [quizProvider]);
