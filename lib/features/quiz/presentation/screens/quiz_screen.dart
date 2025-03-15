import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qlz_flash_cards_ui/features/quiz/domain/states/quiz_state.dart';
import 'package:qlz_flash_cards_ui/features/quiz/presentation/providers/quiz_providers.dart';
import 'package:qlz_flash_cards_ui/features/quiz/presentation/widgets/quiz_answers_section.dart';
import 'package:qlz_flash_cards_ui/features/quiz/presentation/widgets/quiz_footer.dart';
import 'package:qlz_flash_cards_ui/features/quiz/presentation/widgets/quiz_header.dart';
import 'package:qlz_flash_cards_ui/features/quiz/presentation/widgets/quiz_question_card.dart';
import 'package:qlz_flash_cards_ui/features/quiz/presentation/widgets/quiz_result_content.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_empty_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/layout/qlz_modal.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/layout/qlz_screen.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/navigation/qlz_app_bar.dart';

class QuizScreen extends ConsumerWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    try {
      // Sử dụng selector để chỉ rebuild khi status thay đổi
      final status = ref.watch(quizProvider.select((state) => state.status));

      // Lắng nghe các thay đổi trạng thái
      ref.listen<QuizStatus>(quizProvider.select((state) => state.status),
          (previous, current) => _handleStatusChange(context, current, ref));

      return QlzScreen(
        appBar: _buildAppBar(context, ref),
        padding: EdgeInsets.zero,
        child: _buildContent(context, ref, status),
      );
    } catch (e, stackTrace) {
      debugPrint('Error building QuizScreen: $e');
      debugPrint('Stack trace: $stackTrace');

      return Scaffold(
        appBar: AppBar(
          title: const Text('Quiz'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(
          child: Text(
              'An error occurred while loading the quiz. Please try again.'),
        ),
      );
    }
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref) {
    try {
      final moduleName =
          ref.watch(quizProvider.select((state) => state.moduleName));

      return QlzAppBar(
        title: moduleName,
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => _confirmExit(context, ref),
          ),
        ],
      );
    } catch (e) {
      debugPrint('Error building app bar: $e');
      return AppBar(
        title: const Text('Quiz'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      );
    }
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, QuizStatus status) {
    try {
      // Kiểm tra trạng thái ban đầu
      if (status == QuizStatus.initial) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      // Nếu đã thoát, quay về màn hình trước
      if (status == QuizStatus.exited) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pop();
        });
        return const Center(child: CircularProgressIndicator());
      }

      // Lấy các dữ liệu cần thiết từ state
      final questions =
          ref.watch(quizProvider.select((state) => state.questions));

      // Kiểm tra danh sách câu hỏi
      if (questions.isEmpty) {
        return QlzEmptyState.error(
          title: 'Không có câu hỏi',
          message: 'Không thể tạo câu hỏi cho bài kiểm tra này.',
          actionLabel: 'Quay lại',
          onAction: () => Navigator.of(context).pop(),
        );
      }

      // Sử dụng provider riêng cho câu hỏi hiện tại để tối ưu hóa rebuild
      final currentQuestion = ref.watch(currentQuestionProvider);

      if (currentQuestion == null) {
        return QlzEmptyState.error(
          title: 'Lỗi bài kiểm tra',
          message: 'Không thể tải câu hỏi hiện tại.',
          actionLabel: 'Quay lại',
          onAction: () => Navigator.of(context).pop(),
        );
      }

      return SafeArea(
        child: Column(
          children: [
            // Sử dụng QuizHeaderConsumer thay vì QuizHeaderView
            const QuizHeaderConsumer(),

            // Quiz Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quiz Question
                      QuizQuestionCard(question: currentQuestion.question),
                      const SizedBox(height: 24),

                      // Quiz Answers
                      const QuizAnswersView(),
                    ],
                  ),
                ),
              ),
            ),

            // Quiz Footer
            const QuizFooterView(),
          ],
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('Error building content: $e');
      debugPrint('Stack trace: $stackTrace');

      return QlzEmptyState.error(
        title: 'Lỗi bài kiểm tra',
        message: 'Đã xảy ra lỗi khi tải bài kiểm tra. Vui lòng thử lại sau.',
        actionLabel: 'Quay lại',
        onAction: () => Navigator.of(context).pop(),
      );
    }
  }

  void _handleStatusChange(
      BuildContext context, QuizStatus status, WidgetRef ref) {
    try {
      switch (status) {
        case QuizStatus.completed:
          _showResultModal(context, ref);
          break;
        case QuizStatus.exited:
          Navigator.of(context).pop();
          break;
        default:
          // Do nothing for other status values
          break;
      }
    } catch (e) {
      debugPrint('Error handling status change: $e');
    }
  }

  void _confirmExit(BuildContext context, WidgetRef ref) {
    try {
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
          ref.read(quizProvider.notifier).exitQuiz();
        }
      });
    } catch (e) {
      debugPrint('Error in confirm exit: $e');
      Navigator.of(context).pop(); // Fallback exit
    }
  }

  void _showResultModal(BuildContext context, WidgetRef ref) {
    try {
      // Sử dụng provider để lấy kết quả
      final quizService = ref.read(quizServiceProvider);
      final state = ref.read(quizProvider);

      final (resultMessage, resultColor) =
          quizService.getResultMessage(state.score);

      QlzModal.showBottomSheet(
        context: context,
        isDismissible: false,
        enableDrag: false,
        title: 'Kết quả bài kiểm tra',
        height: MediaQuery.of(context).size.height * 0.8,
        child: QuizResultConsumer(
          onRestartPressed: () {
            Navigator.of(context).pop();
            ref.read(quizProvider.notifier).restartQuiz();
          },
          onFinishPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
          resultMessage: resultMessage,
          resultColor: resultColor,
        ),
      );
    } catch (e) {
      debugPrint('Error showing result modal: $e');
      // Fallback to basic navigation
      Navigator.of(context).pop();
    }
  }
}

// -------------------- OPTIMIZED SUB-COMPONENTS --------------------

// Answers section that only rebuilds when answers or question changes
class QuizAnswersView extends ConsumerWidget {
  const QuizAnswersView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    try {
      // Sử dụng provider có sẵn để lấy câu hỏi hiện tại
      final currentQuestion = ref.watch(currentQuestionProvider);
      if (currentQuestion == null) return const SizedBox.shrink();

      // Lấy các state cần thiết
      final userAnswer =
          ref.watch(quizProvider.select((s) => s.currentUserAnswer));
      final hasAnswered =
          ref.watch(quizProvider.select((s) => s.hasAnsweredCurrentQuestion));
      final showCorrectAnswers =
          ref.watch(quizProvider.select((s) => s.showCorrectAnswers));

      // Lấy service để hiển thị nhãn
      final quizService = ref.read(quizServiceProvider);

      return QuizAnswersSection(
        quizType: currentQuestion.quizType,
        questionTypeLabel:
            quizService.getQuestionTypeLabel(currentQuestion.quizType),
        answers: currentQuestion.answers,
        userAnswer: userAnswer,
        correctAnswer: currentQuestion.correctAnswer,
        hasAnswered: hasAnswered,
        showCorrectAnswers: showCorrectAnswers,
        onAnswerSelected: (answer) =>
            ref.read(quizProvider.notifier).answerQuestion(answer),
      );
    } catch (e) {
      debugPrint('Error in QuizAnswersView: $e');
      return const Center(
        child: Text(
          'Không thể tải câu trả lời',
          style: TextStyle(color: Colors.white),
        ),
      );
    }
  }
}

// Footer component that only rebuilds when relevant data changes
class QuizFooterView extends ConsumerWidget {
  const QuizFooterView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    try {
      final currentQuestionIndex =
          ref.watch(quizProvider.select((s) => s.currentQuestionIndex));
      final totalQuestions =
          ref.watch(quizProvider.select((s) => s.questions.length));
      final hasAnswered =
          ref.watch(quizProvider.select((s) => s.hasAnsweredCurrentQuestion));

      return QuizFooter(
        currentQuestionIndex: currentQuestionIndex,
        totalQuestions: totalQuestions,
        hasAnswered: hasAnswered,
        onPreviousPressed: () =>
            ref.read(quizProvider.notifier).previousQuestion(),
        onNextPressed: () => ref.read(quizProvider.notifier).nextQuestion(),
        onSkipPressed: () => _confirmSkipQuestion(context, ref),
      );
    } catch (e) {
      debugPrint('Error in QuizFooterView: $e');
      return Container(); // Fallback empty container
    }
  }

  void _confirmSkipQuestion(BuildContext context, WidgetRef ref) {
    try {
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
          ref.read(quizProvider.notifier).answerQuestion(null);
        }
      });
    } catch (e) {
      debugPrint('Error confirming skip: $e');
    }
  }
}
