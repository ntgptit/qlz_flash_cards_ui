import 'package:equatable/equatable.dart';
import 'package:qlz_flash_cards_ui/features/quiz/data/models/quiz_settings.dart';

class QuizSettingsState extends Equatable {
  final QuizType quizType;
  final QuizDifficulty difficulty;
  final int questionCount;
  final int maxQuestionCount;
  final bool shuffleQuestions;
  final bool showCorrectAnswers;
  final bool enableTimer;
  final int timePerQuestion;

  const QuizSettingsState({
    this.quizType = QuizType.multipleChoice,
    this.difficulty = QuizDifficulty.medium,
    this.questionCount = 1,
    this.maxQuestionCount = 1,
    this.shuffleQuestions = true,
    this.showCorrectAnswers = true,
    this.enableTimer = false,
    this.timePerQuestion = 30,
  });

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
