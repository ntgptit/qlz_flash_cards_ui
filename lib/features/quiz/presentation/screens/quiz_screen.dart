// lib/features/quiz/screens/quiz_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/features/quiz/data/models/quiz_answer.dart';
import 'package:qlz_flash_cards_ui/features/quiz/data/models/quiz_settings.dart';
import 'package:qlz_flash_cards_ui/features/quiz/logic/cubit/quiz_cubit.dart';
import 'package:qlz_flash_cards_ui/features/quiz/logic/states/quiz_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/buttons/qlz_button.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/data_display/qlz_progress.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_empty_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/layout/qlz_modal.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/layout/qlz_screen.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/navigation/qlz_app_bar.dart';

/// Màn hình làm bài kiểm tra
class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QuizCubit, QuizState>(
      listener: (context, state) {
        // Xử lý khi trạng thái quiz thay đổi
        if (state.status == QuizStatus.completed) {
          _showResultModal(context, state);
        } else if (state.status == QuizStatus.exited) {
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        return QlzScreen(
          appBar: QlzAppBar(
            title: state.moduleName,
            automaticallyImplyLeading: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.exit_to_app),
                onPressed: () => _confirmExit(context),
              ),
            ],
          ),
          padding: EdgeInsets.zero,
          child: _buildQuizContent(context, state),
        );
      },
    );
  }

  /// Xây dựng nội dung chính của màn hình quiz
  Widget _buildQuizContent(BuildContext context, QuizState state) {
    // Kiểm tra trạng thái quiz
    if (state.status == QuizStatus.initial) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.questions.isEmpty) {
      return QlzEmptyState.error(
        title: 'Không có câu hỏi',
        message: 'Không thể tạo câu hỏi cho bài kiểm tra này.',
        actionLabel: 'Quay lại',
      );
    }

    // Lấy câu hỏi hiện tại
    final currentQuestion = state.currentQuestion;
    if (currentQuestion == null) {
      return QlzEmptyState.error(
        title: 'Lỗi bài kiểm tra',
        message: 'Không thể tải câu hỏi hiện tại.',
        actionLabel: 'Quay lại',
      );
    }

    return Column(
      children: [
        // Phần header và thanh tiến độ
        _buildQuizHeader(context, state),

        // Phần nội dung câu hỏi
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hiển thị câu hỏi
                  _buildQuestionCard(context, currentQuestion.question),

                  const SizedBox(height: 24),

                  // Hiển thị các đáp án
                  _buildAnswersSection(context, state),
                ],
              ),
            ),
          ),
        ),

        // Phần footer với nút điều hướng
        _buildQuizFooter(context, state),
      ],
    );
  }

  /// Xây dựng phần header của quiz
  Widget _buildQuizHeader(BuildContext context, QuizState state) {
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

  /// Xây dựng card hiển thị câu hỏi
  Widget _buildQuestionCard(BuildContext context, String question) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.darkBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Câu hỏi:',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            question,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Xây dựng phần hiển thị các đáp án
  Widget _buildAnswersSection(BuildContext context, QuizState state) {
    final currentQuestion = state.currentQuestion!;
    final currentUserAnswer = state.currentUserAnswer;
    final hasAnswered = state.hasAnsweredCurrentQuestion;
    final showCorrectAnswer = hasAnswered && state.showCorrectAnswers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getQuestionTypeLabel(currentQuestion.quizType),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...currentQuestion.answers.map((answer) {
          final isSelected = hasAnswered && currentUserAnswer?.id == answer.id;
          final isCorrect = answer.isCorrect;
          final shouldHighlightCorrect = showCorrectAnswer && isCorrect;
          final shouldHighlightIncorrect =
              showCorrectAnswer && isSelected && !isCorrect;

          return _buildAnswerOption(
            context,
            answer: answer,
            isSelected: isSelected,
            isCorrect: shouldHighlightCorrect,
            isIncorrect: shouldHighlightIncorrect,
            onTap: hasAnswered
                ? null
                : () => context.read<QuizCubit>().answerQuestion(answer),
          );
        }),
      ],
    );
  }

  /// Xây dựng một tùy chọn đáp án
  Widget _buildAnswerOption(
    BuildContext context, {
    required QuizAnswer answer,
    required bool isSelected,
    required bool isCorrect,
    required bool isIncorrect,
    required VoidCallback? onTap,
  }) {
    Color backgroundColor;
    Color borderColor;
    IconData? iconData;
    Color iconColor = Colors.white;

    if (isCorrect) {
      backgroundColor = AppColors.success.withOpacity(0.2);
      borderColor = AppColors.success;
      iconData = Icons.check_circle;
      iconColor = AppColors.success;
    } else if (isIncorrect) {
      backgroundColor = AppColors.error.withOpacity(0.2);
      borderColor = AppColors.error;
      iconData = Icons.cancel;
      iconColor = AppColors.error;
    } else if (isSelected) {
      backgroundColor = AppColors.primary.withOpacity(0.2);
      borderColor = AppColors.primary;
      iconData = Icons.radio_button_checked;
      iconColor = AppColors.primary;
    } else {
      backgroundColor = AppColors.darkCard;
      borderColor = AppColors.darkBorder;
      iconData = null;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: isSelected || isCorrect || isIncorrect ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                answer.text,
                style: TextStyle(
                  color: isSelected || isCorrect || isIncorrect
                      ? Colors.white
                      : Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: isSelected || isCorrect
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
            if (iconData != null)
              Icon(
                iconData,
                color: iconColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  /// Xây dựng phần footer của quiz
  Widget _buildQuizFooter(BuildContext context, QuizState state) {
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
          if (state.currentQuestionIndex > 0)
            QlzButton.secondary(
              label: 'Câu trước',
              icon: Icons.arrow_back,
              onPressed: () => context.read<QuizCubit>().previousQuestion(),
            )
          else
            const SizedBox(width: 120), // Placeholder để giữ layout

          // Nút tiếp theo
          QlzButton.primary(
            label: state.currentQuestionIndex < state.questions.length - 1
                ? 'Tiếp theo'
                : 'Hoàn thành',
            icon: state.currentQuestionIndex < state.questions.length - 1
                ? Icons.arrow_forward
                : Icons.check_circle,
            onPressed: state.hasAnsweredCurrentQuestion
                ? () => context.read<QuizCubit>().nextQuestion()
                : () => _confirmSkipQuestion(context),
          ),
        ],
      ),
    );
  }

  /// Hiển thị hộp thoại xác nhận khi bỏ qua câu hỏi
  void _confirmSkipQuestion(BuildContext context) {
    QlzModal.showConfirmation(
      context: context,
      title: 'Bỏ qua câu hỏi?',
      message:
          'Bạn chưa trả lời câu hỏi này. Bạn có chắc chắn muốn bỏ qua không?',
      confirmText: 'Bỏ qua',
      cancelText: 'Tiếp tục làm',
      isDanger: true,
    ).then((confirmed) {
      if (confirmed) {
        context.read<QuizCubit>().answerQuestion(null);
      }
    });
  }

  /// Hiển thị hộp thoại xác nhận khi thoát khỏi bài kiểm tra
  void _confirmExit(BuildContext context) {
    QlzModal.showConfirmation(
      context: context,
      title: 'Thoát bài kiểm tra?',
      message:
          'Tiến độ làm bài của bạn sẽ không được lưu. Bạn có chắc chắn muốn thoát không?',
      confirmText: 'Thoát',
      cancelText: 'Hủy',
      isDanger: true,
    ).then((confirmed) {
      if (confirmed) {
        context.read<QuizCubit>().exitQuiz();
      }
    });
  }

  /// Hiển thị modal kết quả khi hoàn thành bài kiểm tra
  void _showResultModal(BuildContext context, QuizState state) {
    QlzModal.showBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      title: 'Kết quả bài kiểm tra',
      height: MediaQuery.of(context).size.height * 0.8,
      child: _buildResultContent(context, state),
    );
  }

  /// Xây dựng nội dung modal kết quả
  Widget _buildResultContent(BuildContext context, QuizState state) {
    final score = state.score.round();
    final correctCount = state.correctAnswersCount;
    final totalQuestions = state.questions.length;
    final percentage = state.score;

    // Xác định thông báo kết quả dựa vào điểm số
    final (resultMessage, resultColor) = _getResultMessage(percentage);

    return Column(
      children: [
        const SizedBox(height: 16),

        // Biểu tượng kết quả
        Icon(
          percentage >= 70 ? Icons.emoji_events : Icons.emoji_emotions,
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
              onPressed: () {
                Navigator.of(context).pop();
                context.read<QuizCubit>().restartQuiz();
              },
            ),
            QlzButton.primary(
              label: 'Hoàn thành',
              icon: Icons.check_circle,
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ],
    );
  }

  /// Xác định thông báo kết quả dựa vào điểm số
  (String, Color) _getResultMessage(double percentage) {
    if (percentage >= 90) {
      return ('Xuất sắc!', AppColors.success);
    } else if (percentage >= 75) {
      return ('Tuyệt vời!', AppColors.success);
    } else if (percentage >= 60) {
      return ('Khá tốt!', AppColors.warning);
    } else if (percentage >= 40) {
      return ('Cần cố gắng thêm', AppColors.warning);
    } else {
      return ('Cố gắng lần sau nhé', AppColors.error);
    }
  }

  /// Lấy nhãn loại câu hỏi
  String _getQuestionTypeLabel(QuizType quizType) {
    return switch (quizType) {
      QuizType.multipleChoice => 'Chọn đáp án đúng:',
      QuizType.trueFalse => 'Câu hỏi đúng/sai:',
      QuizType.fillInBlank => 'Chọn đáp án điền vào chỗ trống:',
      QuizType.matching => 'Ghép đôi:',
      QuizType.flashcards => 'Flashcard:',
    };
  }
}
