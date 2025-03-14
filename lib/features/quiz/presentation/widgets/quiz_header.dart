// lib/features/quiz/presentation/widgets/quiz_header.dart
import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/features/quiz/logic/states/quiz_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/data_display/qlz_progress.dart';

class QuizHeader extends StatelessWidget {
  final QuizState state;

  const QuizHeader({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.darkCard,
        border: Border(
          bottom: BorderSide(
            color: AppColors.darkBorder,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Hiển thị thông tin câu hỏi hiện tại
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Câu ${state.currentQuestionIndex + 1}/${state.questions.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (state.enableTimer)
                Row(
                  children: [
                    const Icon(
                      Icons.timer,
                      color: Colors.white70,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      state.formattedRemainingTime,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          const SizedBox(height: 8),

          // Thanh tiến độ
          QlzProgress(
            value: state.progress,
            height: 8,
            type: QlzProgressType.linear,
            color: AppColors.primary,
            backgroundColor: AppColors.darkSurface,
          ),
        ],
      ),
    );
  }
}
