// lib/features/quiz/screens/quiz_modes/quiz_base_screen.dart

import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/features/quiz/models/quiz_question.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/data_display/qlz_progress.dart';

/// Lớp cơ sở cho tất cả các màn hình quiz
/// Cung cấp các phương thức và thuộc tính chung
abstract class QuizBaseScreen<T extends QuizQuestion> extends StatefulWidget {
  final List<T> questions;
  final bool showCorrectAnswers;
  final VoidCallback onQuizCompleted;
  final Function(int) onMoveToQuestion;
  final int currentQuestionIndex;
  final bool isAnswerSubmitted;

  const QuizBaseScreen({
    super.key,
    required this.questions,
    required this.showCorrectAnswers,
    required this.onQuizCompleted,
    required this.onMoveToQuestion,
    required this.currentQuestionIndex,
    required this.isAnswerSubmitted,
  });
}

/// Lớp cơ sở cho state của các màn hình quiz
abstract class QuizBaseScreenState<T extends QuizBaseScreen<Q>,
    Q extends QuizQuestion> extends State<T> {
  /// Xử lý chuyển tiếp câu hỏi
  void moveToNextQuestion() {
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

  /// Tạo thanh tiến độ
  Widget buildProgressBar() {
    return QlzProgress(
      value: (widget.currentQuestionIndex + 1) / widget.questions.length,
      height: 4,
      color: AppColors.primary,
      backgroundColor: Colors.grey.withOpacity(0.2),
    );
  }

  /// Lấy câu hỏi hiện tại
  Q get currentQuestion => widget.questions[widget.currentQuestionIndex];
}
