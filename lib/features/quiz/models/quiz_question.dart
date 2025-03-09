// lib/features/quiz/models/quiz_question.dart

import 'package:qlz_flash_cards_ui/features/flashcard/data/models/flashcard_model.dart';

/// Lớp cơ sở cho tất cả các loại câu hỏi
abstract class QuizQuestion {
  List<Flashcard> get flashcards;
}

/// Câu hỏi trắc nghiệm
class MultipleChoiceQuestion extends QuizQuestion {
  final Flashcard flashcard;
  final List<String> options;

  MultipleChoiceQuestion({
    required this.flashcard,
    required this.options,
  });

  @override
  List<Flashcard> get flashcards => [flashcard];
}

/// Câu hỏi đúng/sai
class TrueFalseQuestion extends QuizQuestion {
  final Flashcard flashcard;
  final bool isCorrectPairing;

  TrueFalseQuestion({
    required this.flashcard,
    required this.isCorrectPairing,
  });

  @override
  List<Flashcard> get flashcards => [flashcard];
}

/// Câu hỏi tự luận
class WrittenQuestion extends QuizQuestion {
  final Flashcard flashcard;

  WrittenQuestion({
    required this.flashcard,
  });

  @override
  List<Flashcard> get flashcards => [flashcard];
}

/// Câu hỏi nối cặp
class MatchingQuestion extends QuizQuestion {
  @override
  final List<Flashcard> flashcards;

  MatchingQuestion({
    required this.flashcards,
  });
}
