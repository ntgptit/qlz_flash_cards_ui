// lib/features/quiz/presentation/screens/quiz_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qlz_flash_cards_ui/features/quiz/data/services/quiz_service.dart';
import 'package:qlz_flash_cards_ui/features/quiz/logic/cubit/quiz_cubit.dart';
import 'package:qlz_flash_cards_ui/features/quiz/logic/states/quiz_state.dart';
import 'package:qlz_flash_cards_ui/features/quiz/presentation/widgets/quiz_answers_section.dart';
import 'package:qlz_flash_cards_ui/features/quiz/presentation/widgets/quiz_footer.dart';
import 'package:qlz_flash_cards_ui/features/quiz/presentation/widgets/quiz_header.dart';
import 'package:qlz_flash_cards_ui/features/quiz/presentation/widgets/quiz_question_card.dart';
import 'package:qlz_flash_cards_ui/features/quiz/presentation/widgets/quiz_result_content.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_empty_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/layout/qlz_modal.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/layout/qlz_screen.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/navigation/qlz_app_bar.dart';

/// Màn hình làm bài kiểm tra
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  // Sử dụng một instance service để sử dụng các helper method
  final QuizService _quizService = QuizService();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QuizCubit, QuizState>(
      listener: _quizStateListener,
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

  /// Listener để phản ứng với các thay đổi trạng thái
  void _quizStateListener(BuildContext context, QuizState state) {
    // Xử lý khi trạng thái quiz thay đổi
    if (state.status == QuizStatus.completed) {
      _showResultModal(context, state);
    } else if (state.status == QuizStatus.exited) {
      Navigator.of(context).pop();
    }
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
        QuizHeader(state: state),

        // Phần nội dung câu hỏi
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hiển thị câu hỏi
                  QuizQuestionCard(question: currentQuestion.question),

                  const SizedBox(height: 24),

                  // Hiển thị các đáp án
                  QuizAnswersSection(
                    quizType: currentQuestion.quizType,
                    questionTypeLabel: _quizService.getQuestionTypeLabel(
                      currentQuestion.quizType,
                    ),
                    answers: currentQuestion.answers,
                    userAnswer: state.currentUserAnswer,
                    correctAnswer: currentQuestion.correctAnswer,
                    hasAnswered: state.hasAnsweredCurrentQuestion,
                    showCorrectAnswers: state.showCorrectAnswers,
                    onAnswerSelected: (answer) =>
                        context.read<QuizCubit>().answerQuestion(answer),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Phần footer với nút điều hướng
        QuizFooter(
          currentQuestionIndex: state.currentQuestionIndex,
          totalQuestions: state.questions.length,
          hasAnswered: state.hasAnsweredCurrentQuestion,
          onPreviousPressed: () => context.read<QuizCubit>().previousQuestion(),
          onNextPressed: () => context.read<QuizCubit>().nextQuestion(),
          onSkipPressed: () => _confirmSkipQuestion(context),
        ),
      ],
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
    // Lấy thông báo kết quả dựa vào điểm số
    final (resultMessage, resultColor) =
        _quizService.getResultMessage(state.score);

    QlzModal.showBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      title: 'Kết quả bài kiểm tra',
      height: MediaQuery.of(context).size.height * 0.8,
      child: QuizResultContent(
        state: state,
        onRestartPressed: () {
          Navigator.of(context).pop();
          context.read<QuizCubit>().restartQuiz();
        },
        onFinishPressed: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
        resultMessage: resultMessage,
        resultColor: resultColor,
      ),
    );
  }
}
