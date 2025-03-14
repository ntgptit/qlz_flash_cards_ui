import 'package:equatable/equatable.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/data/models/flashcard_model.dart';
import 'package:qlz_flash_cards_ui/features/quiz/data/models/quiz_answer.dart';
import 'package:qlz_flash_cards_ui/features/quiz/data/models/quiz_settings.dart';

/// Represents a quiz question with all necessary data
class QuizQuestion extends Equatable {
  final String id;
  final String question;
  final List<QuizAnswer> answers;
  final QuizAnswer correctAnswer;
  final Flashcard sourceFlashcard;
  final QuizType quizType;
  final QuizDifficulty difficulty;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.answers,
    required this.correctAnswer,
    required this.sourceFlashcard,
    required this.quizType,
    required this.difficulty,
  });

  /// Creates a question from a flashcard - moved to QuizService for deduplication
  /// This factory constructor is kept for backward compatibility but simply calls
  /// the appropriate method in QuizService
  factory QuizQuestion.fromFlashcard({
    required Flashcard flashcard,
    required QuizType quizType,
    required QuizDifficulty difficulty,
    required List<Flashcard> allFlashcards,
  }) {
    throw UnimplementedError(
        'The fromFlashcard factory is deprecated. Use QuizService.createQuestionFromFlashcard instead.');
  }

  @override
  List<Object?> get props => [
        id,
        question,
        answers,
        correctAnswer,
        sourceFlashcard,
        quizType,
        difficulty,
      ];
}
