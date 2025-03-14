// lib/features/quiz/presentation/widgets/quiz_result_content.dart
import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/features/quiz/logic/states/quiz_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/buttons/qlz_button.dart';

class QuizResultContent extends StatelessWidget {
  final QuizState state;
  final VoidCallback onRestartPressed;
  final VoidCallback onFinishPressed;
  final String resultMessage;
  final Color resultColor;

  const QuizResultContent({
    super.key,
    required this.state,
    required this.onRestartPressed,
    required this.onFinishPressed,
    required this.resultMessage,
    required this.resultColor,
  });

  @override
  Widget build(BuildContext context) {
    final score = state.score.round();
    final correctCount = state.correctAnswersCount;
    final totalQuestions = state.questions.length;

    return Column(
      children: [
        const SizedBox(height: 16),

        // Biểu tượng kết quả
        Icon(
          state.score >= 70 ? Icons.emoji_events : Icons.emoji_emotions,
          size: 64,
          color: resultColor,
        ),

        const SizedBox(height: 16),

        // Thông báo kết quả
        Text(
          resultMessage,
          style: TextStyle(
            color: resultColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 24),

        // Điểm số
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$score',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 64,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '/100',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Số câu đúng
        Text(
          '$correctCount/$totalQuestions câu đúng',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 18,
          ),
        ),

        const SizedBox(height: 24),

        // Thời gian làm bài
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.darkBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.timer_outlined,
                color: Colors.white70,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Thời gian làm bài: ${state.formattedElapsedTime}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Nút hành động
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            QlzButton.secondary(
              label: 'Làm lại',
              icon: Icons.replay,
              onPressed: onRestartPressed,
            ),
            QlzButton.primary(
              label: 'Hoàn thành',
              icon: Icons.check_circle,
              onPressed: onFinishPressed,
            ),
          ],
        ),
      ],
    );
  }
}
