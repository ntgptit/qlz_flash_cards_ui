import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/buttons/qlz_button.dart';

class QuizFooter extends StatelessWidget {
  final int currentQuestionIndex;
  final int totalQuestions;
  final bool hasAnswered;
  final bool showContinueButton;
  final VoidCallback onPreviousPressed;
  final VoidCallback onNextPressed;
  final VoidCallback onSkipPressed;

  const QuizFooter({
    super.key,
    required this.currentQuestionIndex,
    required this.totalQuestions,
    required this.hasAnswered,
    this.showContinueButton = false,
    required this.onPreviousPressed,
    required this.onNextPressed,
    required this.onSkipPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isLastQuestion = currentQuestionIndex >= totalQuestions - 1;
    final showPreviousButton = currentQuestionIndex > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.darkCard,
        border: Border(
          top: BorderSide(
            color: AppColors.darkBorder,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Nút quay lại câu trước
          if (showPreviousButton)
            QlzButton.secondary(
              label: 'Câu trước',
              icon: Icons.arrow_back,
              onPressed: onPreviousPressed,
            )
          else
            const SizedBox(width: 120), // Placeholder để giữ layout

          // Nút tiếp theo/hoàn thành
          _buildNextButton(isLastQuestion),
        ],
      ),
    );
  }

  Widget _buildNextButton(bool isLastQuestion) {
    // Nếu đã trả lời sai và cần hiển thị nút xác nhận
    if (showContinueButton) {
      return QlzButton.primary(
        label: isLastQuestion ? 'Hoàn thành' : 'Tiếp tục',
        icon: isLastQuestion ? Icons.check_circle : Icons.arrow_forward,
        onPressed: onNextPressed,
      );
    }

    // Nếu đã trả lời (và trả lời đúng)
    if (hasAnswered) {
      return QlzButton.primary(
        label: isLastQuestion ? 'Hoàn thành' : 'Tiếp theo',
        icon: isLastQuestion ? Icons.check_circle : Icons.arrow_forward,
        onPressed: onNextPressed,
      );
    }

    // Nếu chưa trả lời
    return QlzButton.primary(
      label: isLastQuestion ? 'Hoàn thành' : 'Bỏ qua',
      icon: isLastQuestion ? Icons.check_circle : Icons.arrow_forward,
      onPressed: onSkipPressed,
    );
  }
}
