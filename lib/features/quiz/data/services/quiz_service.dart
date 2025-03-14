import 'dart:math';

import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/data/models/flashcard_model.dart';
import 'package:qlz_flash_cards_ui/features/quiz/data/models/quiz_answer.dart';
import 'package:qlz_flash_cards_ui/features/quiz/data/models/quiz_question.dart';
import 'package:qlz_flash_cards_ui/features/quiz/data/models/quiz_settings.dart';

class QuizService {
  // Tối ưu hóa: Sử dụng thuật toán Fisher-Yates cho hiệu quả cao
  void _efficientShuffle<T>(List<T> list) {
    final random = Random();
    for (var i = list.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      // Swap
      final temp = list[i];
      list[i] = list[j];
      list[j] = temp;
    }
  }

  // Lựa chọn flashcards theo số lượng và trộn nếu cần thiết
  List<Flashcard> selectFlashcards(
      List<Flashcard> flashcards, int count, bool shuffle) {
    if (flashcards.isEmpty) return [];

    final effectiveCount = min(count, flashcards.length);

    if (shuffle) {
      final shuffled = List<Flashcard>.from(flashcards);
      _efficientShuffle(shuffled);
      return shuffled.take(effectiveCount).toList();
    } else {
      return flashcards.take(effectiveCount).toList();
    }
  }

  // Tạo danh sách câu hỏi từ các flashcard đã chọn
  List<QuizQuestion> createQuestions(
    List<Flashcard> selectedFlashcards,
    QuizType quizType,
    QuizDifficulty difficulty,
    List<Flashcard> allFlashcards,
  ) {
    return selectedFlashcards.map((flashcard) {
      return createQuestionFromFlashcard(
        flashcard: flashcard,
        quizType: quizType,
        difficulty: difficulty,
        allFlashcards: allFlashcards,
      );
    }).toList();
  }

  // Tạo một câu hỏi từ flashcard - phương thức public để dùng với provider
  QuizQuestion createQuestionFromFlashcard({
    required Flashcard flashcard,
    required QuizType quizType,
    required QuizDifficulty difficulty,
    required List<Flashcard> allFlashcards,
  }) {
    return switch (quizType) {
      QuizType.multipleChoice =>
        _createMultipleChoiceQuestion(flashcard, difficulty, allFlashcards),
      QuizType.trueFalse => _createTrueFalseQuestion(flashcard, difficulty),
      QuizType.fillInBlank => _createFillInBlankQuestion(flashcard, difficulty),
      QuizType.matching =>
        _createMatchingQuestion(flashcard, difficulty, allFlashcards),
      QuizType.flashcards => _createFlashcardQuestion(flashcard, difficulty),
    };
  }

  // Tối ưu hóa: Giảm số lần shuffle và tái sử dụng logic hiệu quả
  QuizQuestion _createMultipleChoiceQuestion(Flashcard flashcard,
      QuizDifficulty difficulty, List<Flashcard> allFlashcards) {
    final optionsCount = switch (difficulty) {
      QuizDifficulty.easy => 3,
      QuizDifficulty.medium => 4,
      QuizDifficulty.hard => 5,
    };

    final question = 'Ý nghĩa của "${flashcard.term}" là gì?';
    final correctAnswer = QuizAnswer(
      id: '0',
      text: flashcard.definition,
      isCorrect: true,
    );

    // Lọc và shuffle một lần duy nhất
    final otherFlashcards =
        allFlashcards.where((card) => card.id != flashcard.id).toList();

    // Xử lý trường hợp không đủ flashcards
    if (otherFlashcards.isEmpty) {
      // Trả về câu hỏi chỉ có 1 đáp án đúng
      return QuizQuestion(
        id: flashcard.id,
        question: question,
        answers: [correctAnswer],
        correctAnswer: correctAnswer,
        sourceFlashcard: flashcard,
        quizType: QuizType.multipleChoice,
        difficulty: difficulty,
      );
    }

    // Shuffle và chọn số lượng cần thiết
    _efficientShuffle(otherFlashcards);
    final wrongAnswersCount = min(optionsCount - 1, otherFlashcards.length);

    // Tạo wrong answers
    final wrongAnswers = otherFlashcards
        .take(wrongAnswersCount)
        .map((card) => QuizAnswer(
              id: card.id,
              text: card.definition,
              isCorrect: false,
            ))
        .toList();

    // Tạo danh sách tất cả câu trả lời hiệu quả hơn
    final allAnswers = <QuizAnswer>[correctAnswer, ...wrongAnswers];
    _efficientShuffle(allAnswers);

    return QuizQuestion(
      id: flashcard.id,
      question: question,
      answers: allAnswers,
      correctAnswer: correctAnswer,
      sourceFlashcard: flashcard,
      quizType: QuizType.multipleChoice,
      difficulty: difficulty,
    );
  }

  QuizQuestion _createTrueFalseQuestion(
      Flashcard flashcard, QuizDifficulty difficulty) {
    final random = Random();
    final isCorrectStatement = random.nextBool();

    final statement = isCorrectStatement
        ? '${flashcard.term} có nghĩa là ${flashcard.definition}.'
        : '${flashcard.term} có nghĩa là "${_getRandomWrongDefinition(flashcard)}"';

    final trueAnswer = QuizAnswer(
      id: 'true',
      text: 'Đúng',
      isCorrect: isCorrectStatement,
    );

    final falseAnswer = QuizAnswer(
      id: 'false',
      text: 'Sai',
      isCorrect: !isCorrectStatement,
    );

    final correctAnswer = isCorrectStatement ? trueAnswer : falseAnswer;

    return QuizQuestion(
      id: flashcard.id,
      question: statement,
      answers: [trueAnswer, falseAnswer],
      correctAnswer: correctAnswer,
      sourceFlashcard: flashcard,
      quizType: QuizType.trueFalse,
      difficulty: difficulty,
    );
  }

  QuizQuestion _createFillInBlankQuestion(
      Flashcard flashcard, QuizDifficulty difficulty) {
    final question = 'Điền ý nghĩa của từ "${flashcard.term}": ';

    final correctAnswer = QuizAnswer(
      id: flashcard.id,
      text: flashcard.definition,
      isCorrect: true,
    );

    final suggestedAnswersCount = switch (difficulty) {
      QuizDifficulty.easy => 3,
      QuizDifficulty.medium => 2,
      QuizDifficulty.hard => 0, // Không có gợi ý cho độ khó cao
    };

    final wrongAnswers = List.generate(
      suggestedAnswersCount,
      (index) => QuizAnswer(
        id: 'wrong_$index',
        text: _getRandomWrongDefinition(flashcard, seed: index),
        isCorrect: false,
      ),
    );

    final allAnswers = <QuizAnswer>[correctAnswer, ...wrongAnswers];
    _efficientShuffle(allAnswers);

    return QuizQuestion(
      id: flashcard.id,
      question: question,
      answers: allAnswers,
      correctAnswer: correctAnswer,
      sourceFlashcard: flashcard,
      quizType: QuizType.fillInBlank,
      difficulty: difficulty,
    );
  }

  QuizQuestion _createMatchingQuestion(Flashcard flashcard,
      QuizDifficulty difficulty, List<Flashcard> allFlashcards) {
    final question = 'Tìm định nghĩa đúng cho từ: ${flashcard.term}';

    final optionsCount = switch (difficulty) {
      QuizDifficulty.easy => 3,
      QuizDifficulty.medium => 4,
      QuizDifficulty.hard => 5,
    };

    final correctAnswer = QuizAnswer(
      id: flashcard.id,
      text: flashcard.definition,
      isCorrect: true,
    );

    // Lọc và shuffle một lần duy nhất
    final otherFlashcards =
        allFlashcards.where((card) => card.id != flashcard.id).toList();

    if (otherFlashcards.isEmpty) {
      return QuizQuestion(
        id: flashcard.id,
        question: question,
        answers: [correctAnswer],
        correctAnswer: correctAnswer,
        sourceFlashcard: flashcard,
        quizType: QuizType.matching,
        difficulty: difficulty,
      );
    }

    _efficientShuffle(otherFlashcards);
    final wrongAnswersCount = min(optionsCount - 1, otherFlashcards.length);

    final wrongAnswers = otherFlashcards
        .take(wrongAnswersCount)
        .map((card) => QuizAnswer(
              id: card.id,
              text: card.definition,
              isCorrect: false,
            ))
        .toList();

    final allAnswers = <QuizAnswer>[correctAnswer, ...wrongAnswers];
    _efficientShuffle(allAnswers);

    return QuizQuestion(
      id: flashcard.id,
      question: question,
      answers: allAnswers,
      correctAnswer: correctAnswer,
      sourceFlashcard: flashcard,
      quizType: QuizType.matching,
      difficulty: difficulty,
    );
  }

  QuizQuestion _createFlashcardQuestion(
      Flashcard flashcard, QuizDifficulty difficulty) {
    final question = flashcard.term;

    final correctAnswer = QuizAnswer(
      id: flashcard.id,
      text: flashcard.definition,
      isCorrect: true,
    );

    return QuizQuestion(
      id: flashcard.id,
      question: question,
      answers: [correctAnswer],
      correctAnswer: correctAnswer,
      sourceFlashcard: flashcard,
      quizType: QuizType.flashcards,
      difficulty: difficulty,
    );
  }

  String _getRandomWrongDefinition(Flashcard flashcard, {int? seed}) {
    final random = seed != null ? Random(seed) : Random();

    final prefixes = [
      'không phải ',
      'trái ngược với ',
      'không liên quan đến ',
    ];

    return '${prefixes[random.nextInt(prefixes.length)]}${flashcard.definition}';
  }

  // Tính điểm dựa trên số câu trả lời đúng
  (double, int) calculateScore(
      List<QuizQuestion> questions, List<QuizAnswer?> userAnswers) {
    int correctCount = 0;

    for (int i = 0; i < questions.length; i++) {
      if (i < userAnswers.length && userAnswers[i] != null) {
        final userAnswer = userAnswers[i]!;
        final correctAnswer = questions[i].correctAnswer;

        if (userAnswer.id == correctAnswer.id) {
          correctCount++;
        }
      }
    }

    final score =
        questions.isEmpty ? 0.0 : (correctCount / questions.length) * 100;
    return (score, correctCount);
  }

  // Lấy thông báo kết quả dựa trên điểm số
  (String, Color) getResultMessage(double percentage) {
    if (percentage >= 90) {
      return ('Xuất sắc!', Colors.green);
    } else if (percentage >= 75) {
      return ('Tuyệt vời!', Colors.green);
    } else if (percentage >= 60) {
      return ('Khá tốt!', Colors.amber);
    } else if (percentage >= 40) {
      return ('Cần cố gắng thêm', Colors.amber);
    } else {
      return ('Cố gắng lần sau nhé', Colors.red);
    }
  }

  // Lấy nhãn loại câu hỏi
  String getQuestionTypeLabel(QuizType quizType) {
    return switch (quizType) {
      QuizType.multipleChoice => 'Chọn đáp án đúng:',
      QuizType.trueFalse => 'Câu hỏi đúng/sai:',
      QuizType.fillInBlank => 'Chọn đáp án điền vào chỗ trống:',
      QuizType.matching => 'Ghép đôi:',
      QuizType.flashcards => 'Flashcard:',
    };
  }
}
