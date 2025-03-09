// lib/features/quiz/factory/quiz_factory.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/features/quiz/models/quiz_question.dart';
import 'package:qlz_flash_cards_ui/features/quiz/models/quiz_settings.dart';
import 'package:qlz_flash_cards_ui/features/quiz/screens/quiz_modes/matching_quiz.dart';
import 'package:qlz_flash_cards_ui/features/quiz/screens/quiz_modes/multiple_choice_quiz.dart';
import 'package:qlz_flash_cards_ui/features/quiz/screens/quiz_modes/true_false_quiz.dart';
import 'package:qlz_flash_cards_ui/features/quiz/screens/quiz_modes/written_quiz_simplified.dart';
import 'package:qlz_flash_cards_ui/features/vocabulary/data/flashcard.dart';

/// Factory pattern cho Quiz
abstract class QuizFactory {
  /// Tạo Widget cho loại quiz tương ứng
  Widget createQuizScreen({
    required List<QuizQuestion> questions,
    required bool showCorrectAnswers,
    required Function onQuestionAnswered,
    required VoidCallback onQuizCompleted,
    required Function(int) onMoveToQuestion,
    required int currentQuestionIndex,
    required bool isAnswerSubmitted,
    dynamic additionalData,
  });

  /// Tạo danh sách câu hỏi theo loại quiz
  List<QuizQuestion> createQuestions(
      List<Flashcard> flashcards, int questionCount);

  /// Tạo factory dựa trên cài đặt quiz
  static QuizFactory createFromType(QuizType type,
      {bool useSimplifiedWritten = true}) {
    return switch (type) {
      QuizType.multipleChoice => MultipleChoiceQuizFactory(),
      QuizType.trueFalse => TrueFalseQuizFactory(),
      QuizType.written => useSimplifiedWritten
          ? WrittenQuizSimplifiedFactory()
          : WrittenQuizFactory(),
      QuizType.matching => MatchingQuizFactory(),
    };
  }
}

// Các lớp factory cụ thể cho từng loại quiz

/// Factory cho quiz trắc nghiệm
class MultipleChoiceQuizFactory extends QuizFactory {
  @override
  Widget createQuizScreen({
    required List<QuizQuestion> questions,
    required bool showCorrectAnswers,
    required Function onQuestionAnswered,
    required VoidCallback onQuizCompleted,
    required Function(int) onMoveToQuestion,
    required int currentQuestionIndex,
    required bool isAnswerSubmitted,
    dynamic additionalData,
  }) {
    final typedQuestions = questions.cast<MultipleChoiceQuestion>();
    return MultipleChoiceQuizScreen(
      questions: typedQuestions,
      showCorrectAnswers: showCorrectAnswers,
      onQuestionAnswered: (index) => onQuestionAnswered(index),
      onQuizCompleted: onQuizCompleted,
      onMoveToQuestion: onMoveToQuestion,
      currentQuestionIndex: currentQuestionIndex,
      selectedOptionIndex: additionalData as int?,
      isAnswerSubmitted: isAnswerSubmitted,
    );
  }

  @override
  List<QuizQuestion> createQuestions(
      List<Flashcard> flashcards, int questionCount) {
    // Giới hạn số lượng flashcards nếu cần
    if (flashcards.length > questionCount) {
      flashcards = flashcards.sublist(0, questionCount);
    }

    return flashcards
        .map(
          (card) => MultipleChoiceQuestion(
            flashcard: card,
            options: _generateMultipleChoiceOptions(card, flashcards),
          ),
        )
        .toList();
  }

  /// Tạo các lựa chọn cho câu hỏi trắc nghiệm
  List<String> _generateMultipleChoiceOptions(
      Flashcard card, List<Flashcard> allCards) {
    final random = Random();
    final List<String> options = [card.definition];

    // Tạo danh sách các thẻ khác để lấy định nghĩa làm lựa chọn sai
    final otherCards = allCards.where((c) => c.id != card.id).toList();

    // Nếu không đủ thẻ khác để tạo đủ 4 lựa chọn, thì tạo định nghĩa ngẫu nhiên
    if (otherCards.length < 3) {
      final additionalOptions = [
        'Đây là một lựa chọn không chính xác',
        'Đây là một định nghĩa khác',
        'Đây là một định nghĩa sai',
        'Không phải định nghĩa này',
      ];

      while (options.length < 4 && additionalOptions.isNotEmpty) {
        final randomIndex = random.nextInt(additionalOptions.length);
        options.add(additionalOptions[randomIndex]);
        additionalOptions.removeAt(randomIndex);
      }
    } else {
      // Lấy ngẫu nhiên 3 thẻ khác để làm lựa chọn sai
      otherCards.shuffle();
      for (int i = 0; i < 3 && i < otherCards.length; i++) {
        options.add(otherCards[i].definition);
      }
    }

    // Xáo trộn các lựa chọn
    options.shuffle();

    return options;
  }
}

/// Factory cho quiz đúng/sai
class TrueFalseQuizFactory extends QuizFactory {
  @override
  Widget createQuizScreen({
    required List<QuizQuestion> questions,
    required bool showCorrectAnswers,
    required Function onQuestionAnswered,
    required VoidCallback onQuizCompleted,
    required Function(int) onMoveToQuestion,
    required int currentQuestionIndex,
    required bool isAnswerSubmitted,
    dynamic additionalData,
  }) {
    final typedQuestions = questions.cast<TrueFalseQuestion>();
    return TrueFalseQuizScreen(
      questions: typedQuestions,
      showCorrectAnswers: showCorrectAnswers,
      onQuestionAnswered: (value) => onQuestionAnswered(value),
      onQuizCompleted: onQuizCompleted,
      onMoveToQuestion: onMoveToQuestion,
      currentQuestionIndex: currentQuestionIndex,
      isAnswerSubmitted: isAnswerSubmitted,
    );
  }

  @override
  List<QuizQuestion> createQuestions(
      List<Flashcard> flashcards, int questionCount) {
    // Giới hạn số lượng flashcards nếu cần
    if (flashcards.length > questionCount) {
      flashcards = flashcards.sublist(0, questionCount);
    }

    final Random random = Random();
    return flashcards
        .map(
          (card) => TrueFalseQuestion(
            flashcard: card,
            isCorrectPairing: random.nextBool(),
          ),
        )
        .toList();
  }
}

/// Factory cho quiz tự luận
class WrittenQuizFactory extends QuizFactory {
  @override
  Widget createQuizScreen({
    required List<QuizQuestion> questions,
    required bool showCorrectAnswers,
    required Function onQuestionAnswered,
    required VoidCallback onQuizCompleted,
    required Function(int) onMoveToQuestion,
    required int currentQuestionIndex,
    required bool isAnswerSubmitted,
    dynamic additionalData,
  }) {
    final typedQuestions = questions.cast<WrittenQuestion>();
    return WrittenQuizSimplified(
      questions: typedQuestions,
      onAnswerSubmitted: (answer) => onQuestionAnswered(answer),
      onQuizCompleted: onQuizCompleted,
      onMoveToQuestion: onMoveToQuestion,
      currentQuestionIndex: currentQuestionIndex,
      isAnswerSubmitted: isAnswerSubmitted,
      totalQuestions: questions.length,
      showAnswerImmediately: showCorrectAnswers,
      submittedAnswer: additionalData as String?,
    );
  }

  @override
  List<QuizQuestion> createQuestions(
      List<Flashcard> flashcards, int questionCount) {
    if (flashcards.length > questionCount) {
      flashcards = flashcards.sublist(0, questionCount);
    }
    return flashcards.map((card) => WrittenQuestion(flashcard: card)).toList();
  }

  /// Kiểm tra xem câu trả lời của người dùng có đúng không
  bool isAnswerCorrect(String userAnswer, String correctAnswer) {
    // Kiểm tra đáp án người dùng có đúng không (cho phép một chút sai sót)
    final lowerUserAnswer = userAnswer.trim().toLowerCase();
    final lowerCorrectAnswer = correctAnswer.trim().toLowerCase();

    if (lowerUserAnswer == lowerCorrectAnswer) return true;

    // Nếu đáp án dài trên 10 ký tự, cho phép sai khác 20%
    if (lowerCorrectAnswer.length > 10) {
      final double similarity =
          _calculateSimilarity(lowerUserAnswer, lowerCorrectAnswer);
      return similarity >= 0.8; // 80% giống nhau
    }

    return false;
  }

  /// Tính độ tương tự giữa hai chuỗi
  double _calculateSimilarity(String s1, String s2) {
    // Thuật toán đơn giản tính độ tương tự giữa hai chuỗi
    if (s1 == s2) return 1.0;

    final int maxLength = max(s1.length, s2.length);
    if (maxLength == 0) return 1.0;

    int sameChars = 0;
    final int minLength = min(s1.length, s2.length);

    for (int i = 0; i < minLength; i++) {
      if (s1[i] == s2[i]) sameChars++;
    }

    return sameChars / maxLength;
  }
}

/// Factory cho quiz tự luận phiên bản đơn giản
class WrittenQuizSimplifiedFactory extends QuizFactory {
  @override
  Widget createQuizScreen({
    required List<QuizQuestion> questions,
    required bool showCorrectAnswers,
    required Function onQuestionAnswered,
    required VoidCallback onQuizCompleted,
    required Function(int) onMoveToQuestion,
    required int currentQuestionIndex,
    required bool isAnswerSubmitted,
    dynamic additionalData,
  }) {
    final typedQuestions = questions.cast<WrittenQuestion>();
    return WrittenQuizSimplified(
      questions: typedQuestions,
      onAnswerSubmitted: (answer) => onQuestionAnswered(answer),
      onQuizCompleted: onQuizCompleted,
      onMoveToQuestion: onMoveToQuestion,
      currentQuestionIndex: currentQuestionIndex,
      isAnswerSubmitted: isAnswerSubmitted,
      totalQuestions: questions.length,
    );
  }

  @override
  List<QuizQuestion> createQuestions(
      List<Flashcard> flashcards, int questionCount) {
    // Giới hạn số lượng flashcards nếu cần
    if (flashcards.length > questionCount) {
      flashcards = flashcards.sublist(0, questionCount);
    }

    return flashcards
        .map(
          (card) => WrittenQuestion(
            flashcard: card,
          ),
        )
        .toList();
  }

  /// Kiểm tra xem câu trả lời của người dùng có đúng không
  bool isAnswerCorrect(String userAnswer, String correctAnswer) {
    // Kiểm tra đáp án người dùng có đúng không (cho phép một chút sai sót)
    final lowerUserAnswer = userAnswer.trim().toLowerCase();
    final lowerCorrectAnswer = correctAnswer.trim().toLowerCase();

    if (lowerUserAnswer == lowerCorrectAnswer) return true;

    // Nếu đáp án dài trên 10 ký tự, cho phép sai khác 20%
    if (lowerCorrectAnswer.length > 10) {
      final double similarity =
          _calculateSimilarity(lowerUserAnswer, lowerCorrectAnswer);
      return similarity >= 0.8; // 80% giống nhau
    }

    return false;
  }

  /// Tính độ tương tự giữa hai chuỗi
  double _calculateSimilarity(String s1, String s2) {
    // Thuật toán đơn giản tính độ tương tự giữa hai chuỗi
    if (s1 == s2) return 1.0;

    final int maxLength = max(s1.length, s2.length);
    if (maxLength == 0) return 1.0;

    int sameChars = 0;
    final int minLength = min(s1.length, s2.length);

    for (int i = 0; i < minLength; i++) {
      if (s1[i] == s2[i]) sameChars++;
    }

    return sameChars / maxLength;
  }
}

/// Factory cho quiz nối cặp
class MatchingQuizFactory extends QuizFactory {
  @override
  Widget createQuizScreen({
    required List<QuizQuestion> questions,
    required bool showCorrectAnswers,
    required Function onQuestionAnswered,
    required VoidCallback onQuizCompleted,
    required Function(int) onMoveToQuestion,
    required int currentQuestionIndex,
    required bool isAnswerSubmitted,
    dynamic additionalData,
  }) {
    // Matching quiz chỉ có một câu hỏi với nhiều flashcards
    final matchingQuestion = questions.first as MatchingQuestion;
    final matchingData = additionalData as Map<String, dynamic>?;

    return MatchingQuizScreen(
      question: matchingQuestion,
      onMatchingComplete: (duration, correctMatches, totalPairs) {
        onQuestionAnswered({
          'duration': duration,
          'correctMatches': correctMatches,
          'totalPairs': totalPairs,
        });
        onQuizCompleted();
      },
      isCompleted: isAnswerSubmitted,
      matchingCompletionTime: matchingData?['completionTime'] as Duration?,
      correctMatches: matchingData?['correctMatches'] as int? ?? 0,
    );
  }

  @override
  List<QuizQuestion> createQuestions(
      List<Flashcard> flashcards, int questionCount) {
    // Nối cặp chỉ tạo ra một câu hỏi duy nhất với nhiều cặp
    // Giới hạn số lượng flashcards nếu cần
    if (flashcards.length > questionCount) {
      flashcards = flashcards.sublist(0, questionCount);
    }

    return [
      MatchingQuestion(
        flashcards: flashcards,
      ),
    ];
  }
}
