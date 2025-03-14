// lib/features/quiz/models/quiz_question.dart

import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/data/models/flashcard_model.dart';
import 'package:qlz_flash_cards_ui/features/quiz/data/models/quiz_answer.dart';
import 'package:qlz_flash_cards_ui/features/quiz/data/models/quiz_settings.dart';

/// Model cho câu hỏi trong bài kiểm tra
class QuizQuestion extends Equatable {
  /// Định danh duy nhất của câu hỏi
  final String id;

  /// Nội dung câu hỏi
  final String question;

  /// Danh sách các đáp án có thể chọn
  final List<QuizAnswer> answers;

  /// Đáp án đúng
  final QuizAnswer correctAnswer;

  /// Flashcard gốc
  final Flashcard sourceFlashcard;

  /// Loại câu hỏi
  final QuizType quizType;

  /// Độ khó của câu hỏi
  final QuizDifficulty difficulty;

  /// Constructor
  const QuizQuestion({
    required this.id,
    required this.question,
    required this.answers,
    required this.correctAnswer,
    required this.sourceFlashcard,
    required this.quizType,
    required this.difficulty,
  });

  /// Tạo câu hỏi từ flashcard
  factory QuizQuestion.fromFlashcard({
    required Flashcard flashcard,
    required QuizType quizType,
    required QuizDifficulty difficulty,
    required List<Flashcard> allFlashcards,
  }) {
    // Tạo question và answers tùy theo loại câu hỏi
    switch (quizType) {
      case QuizType.multipleChoice:
        return _createMultipleChoiceQuestion(
            flashcard, difficulty, allFlashcards);

      case QuizType.trueFalse:
        return _createTrueFalseQuestion(flashcard, difficulty);

      case QuizType.fillInBlank:
        return _createFillInBlankQuestion(flashcard, difficulty);

      case QuizType.matching:
        return _createMatchingQuestion(flashcard, difficulty, allFlashcards);

      case QuizType.flashcards:
        return _createFlashcardQuestion(flashcard, difficulty);
    }
  }

  /// Tạo câu hỏi dạng trắc nghiệm
  static QuizQuestion _createMultipleChoiceQuestion(Flashcard flashcard,
      QuizDifficulty difficulty, List<Flashcard> allFlashcards) {
    // Số lượng lựa chọn tùy theo độ khó
    final optionsCount = switch (difficulty) {
      QuizDifficulty.easy => 3,
      QuizDifficulty.medium => 4,
      QuizDifficulty.hard => 5,
    };

    // Tạo câu hỏi
    final question = 'Ý nghĩa của "${flashcard.term}" là gì?';

    // Đáp án đúng
    final correctAnswer = QuizAnswer(
      id: '0',
      text: flashcard.definition,
      isCorrect: true,
    );

    // Tạo các đáp án sai từ các flashcard khác
    final otherFlashcards =
        allFlashcards.where((card) => card.id != flashcard.id).toList();

    // Có thể không đủ flashcards khác để tạo đáp án sai
    final wrongAnswersCount = min(optionsCount - 1, otherFlashcards.length);

    // Trộn danh sách để chọn ngẫu nhiên
    otherFlashcards.shuffle();

    // Tạo danh sách đáp án sai
    final wrongAnswers = otherFlashcards
        .take(wrongAnswersCount)
        .map((card) => QuizAnswer(
              id: card.id,
              text: card.definition,
              isCorrect: false,
            ))
        .toList();

    // Kết hợp đáp án đúng và đáp án sai
    final allAnswers = [correctAnswer, ...wrongAnswers];

    // Trộn các đáp án
    allAnswers.shuffle();

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

  /// Tạo câu hỏi dạng đúng/sai
  static QuizQuestion _createTrueFalseQuestion(
      Flashcard flashcard, QuizDifficulty difficulty) {
    // Quyết định ngẫu nhiên xem câu hỏi là đúng hay sai
    final random = Random();
    final isCorrectStatement = random.nextBool();

    // Nội dung câu hỏi
    final statement = isCorrectStatement
        ? '${flashcard.term} có nghĩa là ${flashcard.definition}.'
        : '${flashcard.term} có nghĩa là "${_getRandomWrongDefinition(flashcard)}"';

    // Đáp án
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

    // Đáp án đúng dựa vào isCorrectStatement
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

  /// Tạo câu hỏi dạng điền vào chỗ trống
  static QuizQuestion _createFillInBlankQuestion(
      Flashcard flashcard, QuizDifficulty difficulty) {
    // Tạo câu hỏi dạng điền vào chỗ trống
    final question = 'Điền ý nghĩa của từ "${flashcard.term}": ';

    // Đáp án đúng
    final correctAnswer = QuizAnswer(
      id: flashcard.id,
      text: flashcard.definition,
      isCorrect: true,
    );

    // Tạo một số đáp án gợi ý khác (phụ thuộc vào độ khó)
    final suggestedAnswersCount = switch (difficulty) {
      QuizDifficulty.easy => 3,
      QuizDifficulty.medium => 2,
      QuizDifficulty.hard => 0, // Không có gợi ý cho độ khó cao
    };

    // Tạo các gợi ý ngẫu nhiên
    final wrongAnswers = List.generate(
      suggestedAnswersCount,
      (index) => QuizAnswer(
        id: 'wrong_$index',
        text: _getRandomWrongDefinition(flashcard, seed: index),
        isCorrect: false,
      ),
    );

    // Kết hợp đáp án
    final allAnswers = [correctAnswer, ...wrongAnswers];
    allAnswers.shuffle();

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

  /// Tạo câu hỏi dạng ghép đôi
  static QuizQuestion _createMatchingQuestion(Flashcard flashcard,
      QuizDifficulty difficulty, List<Flashcard> allFlashcards) {
    // Câu hỏi ghép từ với định nghĩa của nó
    final question = 'Tìm định nghĩa đúng cho từ: ${flashcard.term}';

    // Số lượng lựa chọn tùy thuộc vào độ khó
    final optionsCount = switch (difficulty) {
      QuizDifficulty.easy => 3,
      QuizDifficulty.medium => 4,
      QuizDifficulty.hard => 5,
    };

    // Đáp án đúng
    final correctAnswer = QuizAnswer(
      id: flashcard.id,
      text: flashcard.definition,
      isCorrect: true,
    );

    // Tạo các lựa chọn sai từ các flashcard khác
    final otherFlashcards =
        allFlashcards.where((card) => card.id != flashcard.id).toList();

    final wrongAnswersCount = min(optionsCount - 1, otherFlashcards.length);

    otherFlashcards.shuffle();

    final wrongAnswers = otherFlashcards
        .take(wrongAnswersCount)
        .map((card) => QuizAnswer(
              id: card.id,
              text: card.definition,
              isCorrect: false,
            ))
        .toList();

    // Kết hợp đáp án
    final allAnswers = [correctAnswer, ...wrongAnswers];
    allAnswers.shuffle();

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

  /// Tạo câu hỏi dạng flashcard
  static QuizQuestion _createFlashcardQuestion(
      Flashcard flashcard, QuizDifficulty difficulty) {
    // Đơn giản chỉ hiển thị flashcard và yêu cầu người dùng nhớ định nghĩa
    final question = flashcard.term;

    // Đáp án đúng
    final correctAnswer = QuizAnswer(
      id: flashcard.id,
      text: flashcard.definition,
      isCorrect: true,
    );

    // Flashcard chỉ có một đáp án (người dùng tự đánh giá)
    final answers = [correctAnswer];

    return QuizQuestion(
      id: flashcard.id,
      question: question,
      answers: answers,
      correctAnswer: correctAnswer,
      sourceFlashcard: flashcard,
      quizType: QuizType.flashcards,
      difficulty: difficulty,
    );
  }

  /// Helper để tạo định nghĩa sai ngẫu nhiên
  static String _getRandomWrongDefinition(Flashcard flashcard, {int? seed}) {
    // Trong thực tế, có thể sử dụng thuật toán phức tạp hơn hoặc dữ liệu từ API
    // Ở đây chỉ đơn giản là thêm "không phải" vào trước định nghĩa
    final random = seed != null ? Random(seed) : Random();
    final prefixes = [
      'không phải ',
      'trái ngược với ',
      'không liên quan đến ',
    ];

    return '${prefixes[random.nextInt(prefixes.length)]}${flashcard.definition}';
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
