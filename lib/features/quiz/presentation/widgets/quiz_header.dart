import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/features/quiz/presentation/providers/quiz_providers.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/data_display/qlz_progress.dart';

/// Hiển thị phần header của màn hình quiz bao gồm số câu hỏi, timer, và thanh tiến độ
/// Widget này không phụ thuộc vào QuizState trực tiếp, mà nhận các tham số đã được tính toán
class QuizHeader extends StatelessWidget {
  final int currentQuestionIndex;
  final int totalQuestions;
  final bool enableTimer;
  final String formattedRemainingTime;
  final double progress;

  const QuizHeader({
    super.key,
    required this.currentQuestionIndex,
    required this.totalQuestions,
    required this.enableTimer,
    required this.formattedRemainingTime,
    required this.progress,
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
                'Câu ${currentQuestionIndex + 1}/$totalQuestions',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (enableTimer)
                Row(
                  children: [
                    const Icon(
                      Icons.timer,
                      color: Colors.white70,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formattedRemainingTime,
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
            value: progress,
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

/// Consumer widget kết nối QuizHeader với Riverpod state
class QuizHeaderConsumer extends ConsumerWidget {
  const QuizHeaderConsumer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sử dụng select để chỉ rebuild khi các trường cụ thể thay đổi
    final currentQuestionIndex =
        ref.watch(quizProvider.select((state) => state.currentQuestionIndex));

    final totalQuestions =
        ref.watch(quizProvider.select((state) => state.questions.length));

    final enableTimer =
        ref.watch(quizProvider.select((state) => state.enableTimer));

    final formattedRemainingTime =
        ref.watch(quizProvider.select((state) => state.formattedRemainingTime));

    final progress = ref.watch(quizProvider.select((state) => state.progress));

    // Chuyển các giá trị đã được tính toán sang component presentational thuần túy
    return QuizHeader(
      currentQuestionIndex: currentQuestionIndex,
      totalQuestions: totalQuestions,
      enableTimer: enableTimer,
      formattedRemainingTime: formattedRemainingTime,
      progress: progress,
    );
  }
}
