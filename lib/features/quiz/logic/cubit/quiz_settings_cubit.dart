import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qlz_flash_cards_ui/features/quiz/data/models/quiz_settings.dart';
import 'package:qlz_flash_cards_ui/features/quiz/logic/states/quiz_settings_state.dart';

/// Cubit để quản lý trạng thái cài đặt của bài kiểm tra
class QuizSettingsCubit extends Cubit<QuizSettingsState> {
  QuizSettingsCubit() : super(const QuizSettingsState());

  /// Khởi tạo trạng thái với số lượng flashcards có sẵn
  void initialize(int totalFlashcards) {
    // Cập nhật số lượng câu hỏi mặc định là 10 hoặc tổng số flashcards nếu ít hơn
    final defaultCount = totalFlashcards < 10 ? totalFlashcards : 10;

    emit(state.copyWith(
      questionCount: defaultCount,
      maxQuestionCount: totalFlashcards,
    ));
  }

  /// Thiết lập loại bài kiểm tra
  void setQuizType(QuizType quizType) {
    emit(state.copyWith(
      quizType: quizType,
    ));
  }

  /// Thiết lập độ khó bài kiểm tra
  void setDifficulty(QuizDifficulty difficulty) {
    emit(state.copyWith(
      difficulty: difficulty,
    ));
  }

  /// Thiết lập số lượng câu hỏi
  void setQuestionCount(int count) {
    // Đảm bảo số lượng câu hỏi không vượt quá tổng số flashcards
    if (count > state.maxQuestionCount) {
      count = state.maxQuestionCount;
    }

    // Đảm bảo số lượng câu hỏi ít nhất là 1
    if (count < 1) {
      count = 1;
    }

    emit(state.copyWith(
      questionCount: count,
    ));
  }

  /// Bật/tắt tùy chọn trộn câu hỏi
  void setShuffleQuestions(bool value) {
    emit(state.copyWith(
      shuffleQuestions: value,
    ));
  }

  /// Bật/tắt tùy chọn hiển thị đáp án đúng
  void setShowCorrectAnswers(bool value) {
    emit(state.copyWith(
      showCorrectAnswers: value,
    ));
  }

  /// Bật/tắt bộ đếm thời gian
  void setEnableTimer(bool value) {
    emit(state.copyWith(
      enableTimer: value,
    ));
  }

  /// Thiết lập thời gian cho mỗi câu hỏi (tính bằng giây)
  void setTimePerQuestion(int seconds) {
    // Đảm bảo thời gian ít nhất là 5 giây
    if (seconds < 5) {
      seconds = 5;
    }

    // Đảm bảo thời gian không quá 300 giây (5 phút)
    if (seconds > 300) {
      seconds = 300;
    }

    emit(state.copyWith(
      timePerQuestion: seconds,
    ));
  }

  /// Reset toàn bộ cài đặt về mặc định
  void resetToDefaults(int totalFlashcards) {
    final defaultCount = totalFlashcards < 10 ? totalFlashcards : 10;

    emit(QuizSettingsState(
      questionCount: defaultCount,
      maxQuestionCount: totalFlashcards,
    ));
  }
}
