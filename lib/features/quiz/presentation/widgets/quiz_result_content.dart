import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/features/quiz/presentation/providers/quiz_providers.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/buttons/qlz_button.dart';

/// Component hiển thị kết quả quiz - độc lập với Riverpod
class QuizResultContent extends StatelessWidget {
  /// Callback khi người dùng nhấn nút làm lại
  final VoidCallback onRestartPressed;

  /// Callback khi người dùng nhấn nút hoàn thành
  final VoidCallback onFinishPressed;

  /// Thông báo kết quả (vd: "Xuất sắc!", "Khá tốt!")
  final String resultMessage;

  /// Màu sắc của thông báo kết quả
  final Color resultColor;

  /// Điểm số (0-100)
  final int score;

  /// Số câu trả lời đúng
  final int correctCount;

  /// Tổng số câu hỏi
  final int totalQuestions;

  /// Thời gian làm bài đã định dạng (vd: "05:30")
  final String formattedElapsedTime;

  const QuizResultContent({
    super.key,
    required this.onRestartPressed,
    required this.onFinishPressed,
    required this.resultMessage,
    required this.resultColor,
    required this.score,
    required this.correctCount,
    required this.totalQuestions,
    required this.formattedElapsedTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),

        // Biểu tượng kết quả
        Icon(
          score >= 70 ? Icons.emoji_events : Icons.emoji_emotions,
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
                'Thời gian làm bài: $formattedElapsedTime',
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

/// Consumer component kết nối với Riverpod
class QuizResultConsumer extends ConsumerWidget {
  /// Callback khi người dùng nhấn nút làm lại
  final VoidCallback onRestartPressed;

  /// Callback khi người dùng nhấn nút hoàn thành
  final VoidCallback onFinishPressed;

  /// Thông báo kết quả tính từ điểm số
  final String resultMessage;

  /// Màu sắc thông báo kết quả
  final Color resultColor;

  const QuizResultConsumer({
    super.key,
    required this.onRestartPressed,
    required this.onFinishPressed,
    required this.resultMessage,
    required this.resultColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Chỉ lắng nghe các giá trị cần thiết từ state
    final score =
        ref.watch(quizProvider.select((state) => state.score.round()));
    final correctCount =
        ref.watch(quizProvider.select((state) => state.correctAnswersCount));
    final totalQuestions =
        ref.watch(quizProvider.select((state) => state.questions.length));
    final formattedElapsedTime =
        ref.watch(quizProvider.select((state) => state.formattedElapsedTime));

    // Chuyển các giá trị đã được tính toán sang component presentational thuần túy
    return QuizResultContent(
      onRestartPressed: onRestartPressed,
      onFinishPressed: onFinishPressed,
      resultMessage: resultMessage,
      resultColor: resultColor,
      score: score,
      correctCount: correctCount,
      totalQuestions: totalQuestions,
      formattedElapsedTime: formattedElapsedTime,
    );
  }
}
