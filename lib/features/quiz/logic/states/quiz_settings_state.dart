import 'package:equatable/equatable.dart';
import 'package:qlz_flash_cards_ui/features/quiz/data/models/quiz_settings.dart';

/// State chứa cài đặt của bài kiểm tra
class QuizSettingsState extends Equatable {
  /// Loại bài kiểm tra
  final QuizType quizType;

  /// Độ khó của bài kiểm tra
  final QuizDifficulty difficulty;

  /// Số lượng câu hỏi
  final int questionCount;

  /// Số lượng câu hỏi tối đa (dựa trên số flashcards có sẵn)
  final int maxQuestionCount;

  /// Có trộn câu hỏi hay không
  final bool shuffleQuestions;

  /// Có hiển thị đáp án đúng không
  final bool showCorrectAnswers;

  /// Có bật bộ đếm thời gian không
  final bool enableTimer;

  /// Thời gian cho mỗi câu hỏi (tính bằng giây)
  final int timePerQuestion;

  /// Constructor với giá trị mặc định
  const QuizSettingsState({
    this.quizType = QuizType.multipleChoice,
    this.difficulty = QuizDifficulty.medium,
    this.questionCount = 10,
    this.maxQuestionCount = 10,
    this.shuffleQuestions = true,
    this.showCorrectAnswers = true,
    this.enableTimer = false,
    this.timePerQuestion = 30,
  });

  /// Tạo bản sao với các giá trị được cập nhật
  QuizSettingsState copyWith({
    QuizType? quizType,
    QuizDifficulty? difficulty,
    int? questionCount,
    int? maxQuestionCount,
    bool? shuffleQuestions,
    bool? showCorrectAnswers,
    bool? enableTimer,
    int? timePerQuestion,
  }) {
    return QuizSettingsState(
      quizType: quizType ?? this.quizType,
      difficulty: difficulty ?? this.difficulty,
      questionCount: questionCount ?? this.questionCount,
      maxQuestionCount: maxQuestionCount ?? this.maxQuestionCount,
      shuffleQuestions: shuffleQuestions ?? this.shuffleQuestions,
      showCorrectAnswers: showCorrectAnswers ?? this.showCorrectAnswers,
      enableTimer: enableTimer ?? this.enableTimer,
      timePerQuestion: timePerQuestion ?? this.timePerQuestion,
    );
  }

  @override
  List<Object> get props => [
        quizType,
        difficulty,
        questionCount,
        maxQuestionCount,
        shuffleQuestions,
        showCorrectAnswers,
        enableTimer,
        timePerQuestion,
      ];
}
