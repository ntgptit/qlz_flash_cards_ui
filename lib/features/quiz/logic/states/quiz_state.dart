// lib/features/quiz/logic/states/quiz_state.dart

import 'package:equatable/equatable.dart';
import 'package:qlz_flash_cards_ui/features/quiz/data/models/quiz_answer.dart';
import 'package:qlz_flash_cards_ui/features/quiz/data/models/quiz_question.dart';
import 'package:qlz_flash_cards_ui/features/quiz/data/models/quiz_settings.dart';

/// Trạng thái của quiz
enum QuizStatus {
  initial, // Trạng thái ban đầu
  inProgress, // Đang làm bài
  completed, // Đã hoàn thành
  exited, // Đã thoát
}

/// State quản lý trạng thái của màn hình quiz
class QuizState extends Equatable {
  /// Loại bài kiểm tra
  final QuizType quizType;

  /// Độ khó của bài kiểm tra
  final QuizDifficulty difficulty;

  /// ID của module
  final String moduleId;

  /// Tên của module
  final String moduleName;

  /// Danh sách câu hỏi
  final List<QuizQuestion> questions;

  /// Chỉ số câu hỏi hiện tại
  final int currentQuestionIndex;

  /// Danh sách câu trả lời của người dùng
  final List<QuizAnswer?> userAnswers;

  /// Trạng thái của quiz
  final QuizStatus status;

  /// Điểm số (0-100)
  final double score;

  /// Số câu trả lời đúng
  final int correctAnswersCount;

  /// Có hiển thị đáp án đúng không
  final bool showCorrectAnswers;

  /// Có bật bộ đếm thời gian không
  final bool enableTimer;

  /// Thời gian cho mỗi câu hỏi (giây)
  final int timePerQuestion;

  /// Thời gian còn lại cho câu hỏi hiện tại (giây)
  final int remainingTime;

  /// Thời gian đã trôi qua từ khi bắt đầu làm bài (giây)
  final int elapsedTime;

  /// Constructor với giá trị mặc định
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

  /// Tạo bản sao với các giá trị được cập nhật
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

  /// Lấy câu hỏi hiện tại
  QuizQuestion? get currentQuestion {
    if (questions.isEmpty || currentQuestionIndex >= questions.length) {
      return null;
    }
    return questions[currentQuestionIndex];
  }

  /// Kiểm tra xem đã trả lời câu hỏi hiện tại chưa
  bool get hasAnsweredCurrentQuestion {
    return currentQuestionIndex < userAnswers.length &&
        userAnswers[currentQuestionIndex] != null;
  }

  /// Lấy số lượng câu hỏi
  int get totalQuestions => questions.length;

  /// Lấy câu trả lời của người dùng cho câu hỏi hiện tại
  QuizAnswer? get currentUserAnswer {
    if (currentQuestionIndex >= userAnswers.length) {
      return null;
    }
    return userAnswers[currentQuestionIndex];
  }

  /// Kiểm tra xem đã trả lời đúng câu hỏi hiện tại chưa
  bool get isCurrentAnswerCorrect {
    final userAnswer = currentUserAnswer;
    final correctAnswer = currentQuestion?.correctAnswer;

    if (userAnswer == null || correctAnswer == null) {
      return false;
    }

    return userAnswer.id == correctAnswer.id;
  }

  /// Lấy thời gian đã làm bài dưới dạng chuỗi (MM:SS)
  String get formattedElapsedTime {
    final minutes = (elapsedTime ~/ 60).toString().padLeft(2, '0');
    final seconds = (elapsedTime % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Lấy thời gian còn lại dưới dạng chuỗi (MM:SS)
  String get formattedRemainingTime {
    final minutes = (remainingTime ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingTime % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Lấy tiến độ làm bài (0.0 - 1.0)
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
