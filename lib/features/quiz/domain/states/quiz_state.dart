import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/features/quiz/data/models/quiz_answer.dart';
import 'package:qlz_flash_cards_ui/features/quiz/data/models/quiz_question.dart';
import 'package:qlz_flash_cards_ui/features/quiz/data/models/quiz_settings.dart';

enum QuizStatus {
  initial, // Trạng thái ban đầu
  inProgress, // Đang làm bài
  completed, // Đã hoàn thành
  exited, // Đã thoát
}

@immutable
class QuizState extends Equatable {
  final QuizType quizType;
  final QuizDifficulty difficulty;
  final String moduleId;
  final String moduleName;
  final List<QuizQuestion> questions;
  final int currentQuestionIndex;
  final List<QuizAnswer?> userAnswers;
  final QuizStatus status;
  final double score;
  final int correctAnswersCount;
  final bool showCorrectAnswers;
  final bool enableTimer;
  final int timePerQuestion;
  final int remainingTime;
  final int elapsedTime;

  const QuizState({
    this.quizType = QuizType.multipleChoice,
    this.difficulty = QuizDifficulty.medium,
    this.moduleId = '',
    this.moduleName = '',
    this.questions = const [],
    this.currentQuestionIndex = 0,
    this.userAnswers = const [],
    this.status = QuizStatus.initial,
    this.score = 0,
    this.correctAnswersCount = 0,
    this.showCorrectAnswers = true,
    this.enableTimer = false,
    this.timePerQuestion = 30,
    this.remainingTime = 30,
    this.elapsedTime = 0,
  });

  QuizState copyWith({
    QuizType? quizType,
    QuizDifficulty? difficulty,
    String? moduleId,
    String? moduleName,
    List<QuizQuestion>? questions,
    int? currentQuestionIndex,
    List<QuizAnswer?>? userAnswers,
    QuizStatus? status,
    double? score,
    int? correctAnswersCount,
    bool? showCorrectAnswers,
    bool? enableTimer,
    int? timePerQuestion,
    int? remainingTime,
    int? elapsedTime,
  }) {
    return QuizState(
      quizType: quizType ?? this.quizType,
      difficulty: difficulty ?? this.difficulty,
      moduleId: moduleId ?? this.moduleId,
      moduleName: moduleName ?? this.moduleName,
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      userAnswers: userAnswers ?? this.userAnswers,
      status: status ?? this.status,
      score: score ?? this.score,
      correctAnswersCount: correctAnswersCount ?? this.correctAnswersCount,
      showCorrectAnswers: showCorrectAnswers ?? this.showCorrectAnswers,
      enableTimer: enableTimer ?? this.enableTimer,
      timePerQuestion: timePerQuestion ?? this.timePerQuestion,
      remainingTime: remainingTime ?? this.remainingTime,
      elapsedTime: elapsedTime ?? this.elapsedTime,
    );
  }

  // Computed properties
  QuizQuestion? get currentQuestion {
    if (questions.isEmpty || currentQuestionIndex >= questions.length) {
      return null;
    }
    return questions[currentQuestionIndex];
  }

  bool get hasAnsweredCurrentQuestion {
    return currentQuestionIndex < userAnswers.length &&
        userAnswers[currentQuestionIndex] != null;
  }

  int get totalQuestions => questions.length;

  QuizAnswer? get currentUserAnswer {
    if (currentQuestionIndex >= userAnswers.length) {
      return null;
    }
    return userAnswers[currentQuestionIndex];
  }

  bool get isCurrentAnswerCorrect {
    final userAnswer = currentUserAnswer;
    final correctAnswer = currentQuestion?.correctAnswer;
    if (userAnswer == null || correctAnswer == null) {
      return false;
    }
    return userAnswer.id == correctAnswer.id;
  }

  String get formattedElapsedTime {
    final minutes = (elapsedTime ~/ 60).toString().padLeft(2, '0');
    final seconds = (elapsedTime % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String get formattedRemainingTime {
    final minutes = (remainingTime ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingTime % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  double get progress {
    if (questions.isEmpty) return 0;
    return (currentQuestionIndex + 1) / questions.length;
  }

  @override
  List<Object?> get props => [
        quizType,
        difficulty,
        moduleId,
        moduleName,
        questions,
        currentQuestionIndex,
        userAnswers,
        status,
        score,
        correctAnswersCount,
        showCorrectAnswers,
        enableTimer,
        timePerQuestion,
        remainingTime,
        elapsedTime,
      ];
}
