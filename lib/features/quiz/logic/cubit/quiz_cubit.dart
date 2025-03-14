// lib/features/quiz/logic/cubit/quiz_cubit.dart

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/data/models/flashcard_model.dart';
import 'package:qlz_flash_cards_ui/features/quiz/data/models/quiz_answer.dart';
import 'package:qlz_flash_cards_ui/features/quiz/data/models/quiz_settings.dart';
import 'package:qlz_flash_cards_ui/features/quiz/data/services/quiz_service.dart';
import 'package:qlz_flash_cards_ui/features/quiz/logic/states/quiz_state.dart';

/// Cubit quản lý trạng thái của màn hình quiz
class QuizCubit extends Cubit<QuizState> {
  /// Timer đếm thời gian cho mỗi câu hỏi
  Timer? _questionTimer;

  /// Timer đếm thời gian tổng quát
  Timer? _quizTimer;

  /// Service xử lý logic quiz
  final QuizService _quizService;

  /// Constructor
  QuizCubit({
    required QuizService quizService,
  })  : _quizService = quizService,
        super(const QuizState());

  /// Khởi tạo trạng thái quiz
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
    // Chọn flashcards để tạo câu hỏi
    final selectedFlashcards = _quizService.selectFlashcards(
      flashcards,
      questionCount,
      shuffleQuestions,
    );

    // Tạo danh sách câu hỏi
    final questions = _quizService.createQuestions(
      selectedFlashcards,
      quizType,
      difficulty,
      flashcards,
    );

    // Cập nhật trạng thái
    emit(state.copyWith(
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
    ));

    // Bắt đầu bộ đếm thời gian nếu được bật
    if (enableTimer) {
      _startQuestionTimer();
    }

    // Bắt đầu đếm thời gian làm bài
    _startQuizTimer();
  }

  /// Bắt đầu đếm thời gian cho câu hỏi hiện tại
  void _startQuestionTimer() {
    // Hủy timer cũ nếu có
    _questionTimer?.cancel();

    if (!state.enableTimer) return;

    // Đặt lại thời gian
    emit(state.copyWith(
      remainingTime: state.timePerQuestion,
    ));

    // Tạo timer mới
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final newTime = state.remainingTime - 1;

      if (newTime <= 0) {
        timer.cancel();

        // Tự động chuyển đến câu tiếp theo khi hết thời gian
        _handleTimeUp();
      } else {
        emit(state.copyWith(
          remainingTime: newTime,
        ));
      }
    });
  }

  /// Bắt đầu đếm thời gian làm bài
  void _startQuizTimer() {
    // Hủy timer cũ nếu có
    _quizTimer?.cancel();

    // Đặt lại thời gian
    emit(state.copyWith(
      elapsedTime: 0,
    ));

    // Tạo timer mới
    _quizTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      emit(state.copyWith(
        elapsedTime: state.elapsedTime + 1,
      ));
    });
  }

  /// Xử lý khi hết thời gian trả lời câu hỏi
  void _handleTimeUp() {
    // Nếu chưa chọn đáp án, tự động chọn một đáp án (thường là không trả lời)
    if (!state.hasAnsweredCurrentQuestion) {
      // Đánh dấu là không trả lời
      _answerCurrentQuestion(null);

      // Tự động chuyển đến câu tiếp theo sau một khoảng thời gian ngắn
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (!isClosed) nextQuestion();
      });
    }
  }

  /// Trả lời câu hỏi hiện tại
  void answerQuestion(QuizAnswer? answer) {
    if (state.status != QuizStatus.inProgress) return;
    if (state.hasAnsweredCurrentQuestion) return;

    _answerCurrentQuestion(answer);

    // Dừng timer cho câu hỏi hiện tại
    _questionTimer?.cancel();

    // Tự động chuyển câu hỏi nếu đã trả lời
    if (state.showCorrectAnswers) {
      // Nếu hiển thị đáp án đúng, chờ một khoảng thời gian để người dùng xem
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (!isClosed) nextQuestion();
      });
    } else {
      // Nếu không hiển thị đáp án đúng, chuyển câu hỏi ngay lập tức
      nextQuestion();
    }
  }

  /// Lưu câu trả lời vào trạng thái
  void _answerCurrentQuestion(QuizAnswer? answer) {
    // Cập nhật danh sách câu trả lời
    final updatedAnswers = List<QuizAnswer?>.from(state.userAnswers);

    // Đảm bảo danh sách đủ dài
    while (updatedAnswers.length <= state.currentQuestionIndex) {
      updatedAnswers.add(null);
    }

    // Cập nhật câu trả lời cho câu hỏi hiện tại
    updatedAnswers[state.currentQuestionIndex] = answer;

    // Cập nhật trạng thái
    emit(state.copyWith(
      userAnswers: updatedAnswers,
    ));
  }

  /// Chuyển đến câu hỏi tiếp theo
  void nextQuestion() {
    if (state.status != QuizStatus.inProgress) return;

    // Kiểm tra xem đã đến câu hỏi cuối cùng chưa
    if (state.currentQuestionIndex >= state.questions.length - 1) {
      // Đã hoàn thành tất cả câu hỏi
      _finishQuiz();
      return;
    }

    // Chuyển đến câu hỏi tiếp theo
    emit(state.copyWith(
      currentQuestionIndex: state.currentQuestionIndex + 1,
    ));

    // Bắt đầu timer cho câu hỏi mới nếu cần
    if (state.enableTimer) {
      _startQuestionTimer();
    }
  }

  /// Chuyển đến câu hỏi trước đó
  void previousQuestion() {
    if (state.status != QuizStatus.inProgress) return;
    if (state.currentQuestionIndex <= 0) return;

    // Chuyển đến câu hỏi trước đó
    emit(state.copyWith(
      currentQuestionIndex: state.currentQuestionIndex - 1,
    ));

    // Bắt đầu timer cho câu hỏi mới nếu cần
    if (state.enableTimer) {
      _startQuestionTimer();
    }
  }

  /// Kết thúc bài kiểm tra
  void _finishQuiz() {
    // Dừng các timer
    _stopAllTimers();

    // Tính điểm và thống kê
    final (score, correctCount) = _quizService.calculateScore(
      state.questions,
      state.userAnswers,
    );

    // Cập nhật trạng thái
    emit(state.copyWith(
      status: QuizStatus.completed,
      score: score,
      correctAnswersCount: correctCount,
    ));
  }

  /// Bắt đầu lại bài kiểm tra
  void restartQuiz() {
    // Đặt lại trạng thái và bắt đầu lại
    final quizType = state.quizType;
    final difficulty = state.difficulty;
    final questions = state.questions;
    final moduleId = state.moduleId;
    final moduleName = state.moduleName;
    final showCorrectAnswers = state.showCorrectAnswers;
    final enableTimer = state.enableTimer;
    final timePerQuestion = state.timePerQuestion;

    // Xóa các câu trả lời và đặt lại chỉ số câu hỏi
    emit(state.copyWith(
      userAnswers: [],
      currentQuestionIndex: 0,
      status: QuizStatus.inProgress,
      score: 0,
      correctAnswersCount: 0,
      elapsedTime: 0,
    ));

    // Bắt đầu lại timer
    if (enableTimer) {
      _startQuestionTimer();
    }

    _startQuizTimer();
  }

  /// Thoát khỏi bài kiểm tra
  void exitQuiz() {
    // Dừng các timer
    _stopAllTimers();

    // Cập nhật trạng thái
    emit(state.copyWith(
      status: QuizStatus.exited,
    ));
  }

  /// Dừng tất cả các timer
  void _stopAllTimers() {
    _questionTimer?.cancel();
    _quizTimer?.cancel();
  }

  @override
  Future<void> close() {
    // Đảm bảo dừng tất cả timer khi cubit bị hủy
    _stopAllTimers();
    return super.close();
  }
}
