// lib/features/quiz/screens/quiz_modes/true_false_quiz.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/features/quiz/models/quiz_question.dart';
import 'package:qlz_flash_cards_ui/features/quiz/screens/quiz_modes/quiz_base_screen.dart';
import 'package:qlz_flash_cards_ui/features/vocabulary/data/flashcard.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/cards/qlz_card.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/buttons/qlz_button.dart';

/// Màn hình quiz đúng/sai
class TrueFalseQuizScreen extends QuizBaseScreen<TrueFalseQuestion> {
  final Function(bool) onQuestionAnswered;

  const TrueFalseQuizScreen({
    super.key,
    required super.questions,
    required super.showCorrectAnswers,
    required this.onQuestionAnswered,
    required super.onQuizCompleted,
    required super.onMoveToQuestion,
    required super.currentQuestionIndex,
    required super.isAnswerSubmitted,
  });

  @override
  State<TrueFalseQuizScreen> createState() => _TrueFalseQuizScreenState();
}

class _TrueFalseQuizScreenState
    extends QuizBaseScreenState<TrueFalseQuizScreen, TrueFalseQuestion> {
  @override
  Widget build(BuildContext context) {
    // Lấy câu hỏi hiện tại
    final question = currentQuestion;
    final flashcard = question.flashcard;

    // Nội dung câu hỏi - nếu isCorrectPairing=true thì hiển thị định nghĩa đúng, ngược lại hiển thị định nghĩa sai
    final displayDefinition = question.isCorrectPairing
        ? flashcard.definition
        : _getRandomIncorrectDefinition(flashcard);

    return Column(
      children: [
        // Thanh tiến độ
        buildProgressBar(),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card câu hỏi
                QlzCard(
                  backgroundColor: AppColors.darkCard,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Định nghĩa dưới đây có đúng với thuật ngữ này không?',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        flashcard.term,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Text(
                          displayDefinition,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Nút Đúng/Sai
                Row(
                  children: [
                    // Nút "Đúng"
                    Expanded(
                      child: QlzCard(
                        backgroundColor: widget.isAnswerSubmitted &&
                                question.isCorrectPairing
                            ? AppColors.success.withOpacity(0.2)
                            : AppColors.darkCard,
                        hasBorder: widget.isAnswerSubmitted &&
                            question.isCorrectPairing,
                        borderRadius: BorderRadius.circular(12),
                        padding: const EdgeInsets.all(20),
                        onTap: widget.isAnswerSubmitted
                            ? null
                            : () => _handleAnswer(true),
                        child: Column(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              color: widget.isAnswerSubmitted &&
                                      question.isCorrectPairing
                                  ? AppColors.success
                                  : Colors.white,
                              size: 40,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Đúng',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Nút "Sai"
                    Expanded(
                      child: QlzCard(
                        backgroundColor: widget.isAnswerSubmitted &&
                                !question.isCorrectPairing
                            ? AppColors.success.withOpacity(0.2)
                            : AppColors.darkCard,
                        hasBorder: widget.isAnswerSubmitted &&
                            !question.isCorrectPairing,
                        borderRadius: BorderRadius.circular(12),
                        padding: const EdgeInsets.all(20),
                        onTap: widget.isAnswerSubmitted
                            ? null
                            : () => _handleAnswer(false),
                        child: Column(
                          children: [
                            Icon(
                              Icons.cancel_outlined,
                              color: widget.isAnswerSubmitted &&
                                      !question.isCorrectPairing
                                  ? AppColors.success
                                  : Colors.white,
                              size: 40,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Sai',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Hiển thị đáp án đúng
                if (widget.isAnswerSubmitted && widget.showCorrectAnswers)
                  QlzCard(
                    backgroundColor: AppColors.darkCard,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Đáp án đúng: ${question.isCorrectPairing ? 'Đúng' : 'Sai'}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Định nghĩa đúng: ${flashcard.definition}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // Hiển thị nút "Tiếp theo" khi đã chọn đáp án và hiển thị đáp án đúng
                if (widget.isAnswerSubmitted && widget.showCorrectAnswers)
                  Center(
                    child: QlzButton(
                      label: widget.currentQuestionIndex <
                              widget.questions.length - 1
                          ? 'Tiếp theo'
                          : 'Xem kết quả',
                      onPressed: widget.currentQuestionIndex <
                              widget.questions.length - 1
                          ? () => widget
                              .onMoveToQuestion(widget.currentQuestionIndex + 1)
                          : widget.onQuizCompleted,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _handleAnswer(bool userAnswer) {
    if (widget.isAnswerSubmitted) return;

    widget.onQuestionAnswered(userAnswer);

    // Nếu không hiển thị đáp án đúng, chuyển sang câu tiếp theo sau một khoảng thời gian
    if (!widget.showCorrectAnswers) {
      moveToNextQuestion();
    }
  }

  String _getRandomIncorrectDefinition(Flashcard flashcard) {
    // Tạo định nghĩa sai ngẫu nhiên cho câu hỏi
    final random = Random();

    // Lấy danh sách tất cả các flashcard từ tất cả các câu hỏi
    final allFlashcards = widget.questions.map((q) => q.flashcard).toList();
    final otherFlashcards =
        allFlashcards.where((f) => f.id != flashcard.id).toList();

    if (otherFlashcards.isNotEmpty) {
      // Lấy ngẫu nhiên một định nghĩa từ flashcard khác
      return otherFlashcards[random.nextInt(otherFlashcards.length)].definition;
    } else {
      // Nếu không có flashcard khác, trả về một định nghĩa sai cố định
      final incorrectDefinitions = [
        'Định nghĩa này không chính xác cho thuật ngữ trên.',
        'Đây là một định nghĩa sai cho thuật ngữ này.',
        'Định nghĩa này không phù hợp với thuật ngữ đã cho.',
      ];
      return incorrectDefinitions[random.nextInt(incorrectDefinitions.length)];
    }
  }
}
