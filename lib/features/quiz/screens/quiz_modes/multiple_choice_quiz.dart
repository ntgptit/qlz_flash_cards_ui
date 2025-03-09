// lib/features/quiz/screens/quiz_modes/multiple_choice_quiz.dart

import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/features/quiz/models/quiz_question.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/buttons/qlz_button.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/cards/qlz_card.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/data_display/qlz_progress.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/quiz/qlz_quiz_option.dart';

class MultipleChoiceQuizScreen extends StatefulWidget {
  final List<MultipleChoiceQuestion> questions;
  final bool showCorrectAnswers;
  final Function(int) onQuestionAnswered;
  final VoidCallback onQuizCompleted;
  final Function(int) onMoveToQuestion;
  final int currentQuestionIndex;
  final int? selectedOptionIndex;
  final bool isAnswerSubmitted;

  const MultipleChoiceQuizScreen({
    super.key,
    required this.questions,
    required this.showCorrectAnswers,
    required this.onQuestionAnswered,
    required this.onQuizCompleted,
    required this.onMoveToQuestion,
    required this.currentQuestionIndex,
    this.selectedOptionIndex,
    required this.isAnswerSubmitted,
  });

  @override
  State<MultipleChoiceQuizScreen> createState() =>
      _MultipleChoiceQuizScreenState();
}

class _MultipleChoiceQuizScreenState extends State<MultipleChoiceQuizScreen> {
  @override
  Widget build(BuildContext context) {
    // Lấy câu hỏi hiện tại
    final question = widget.questions[widget.currentQuestionIndex];
    final flashcard = question.flashcard;
    final options = question.options;
    final correctIndex = options.indexOf(flashcard.definition);

    return Column(
      children: [
        // Thanh tiến độ
        QlzProgress(
          value: (widget.currentQuestionIndex + 1) / widget.questions.length,
          height: 4,
          color: AppColors.primary,
          backgroundColor: Colors.grey.withOpacity(0.2),
        ),

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
                        'Chọn định nghĩa đúng cho:',
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
                      if (flashcard.example != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Ví dụ: ${flashcard.example}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Danh sách lựa chọn
                ...List.generate(options.length, (index) {
                  // Xác định trạng thái của lựa chọn
                  QlzQuizOptionState optionState = QlzQuizOptionState.idle;

                  if (widget.isAnswerSubmitted) {
                    if (index == correctIndex) {
                      optionState = QlzQuizOptionState.correct;
                    } else if (index == widget.selectedOptionIndex) {
                      optionState = QlzQuizOptionState.incorrect;
                    }
                  } else if (index == widget.selectedOptionIndex) {
                    optionState = QlzQuizOptionState.selected;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: QlzQuizOption(
                      text: options[index],
                      state: optionState,
                      onTap: () => _handleAnswer(index),
                    ),
                  );
                }),

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

  void _handleAnswer(int index) {
    if (widget.isAnswerSubmitted) return;

    widget.onQuestionAnswered(index);

    // Nếu không hiển thị đáp án đúng, chuyển sang câu tiếp theo sau một khoảng thời gian
    if (!widget.showCorrectAnswers) {
      _moveToNextQuestion();
    }
  }

  void _moveToNextQuestion() {
    // Chuyển sang câu hỏi tiếp theo sau khoảng thời gian
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;

      // Nếu còn câu hỏi tiếp theo
      if (widget.currentQuestionIndex < widget.questions.length - 1) {
        widget.onMoveToQuestion(widget.currentQuestionIndex + 1);
      } else {
        // Kết thúc bài kiểm tra
        widget.onQuizCompleted();
      }
    });
  }
}
