// lib/features/quiz/presentation/screens/quiz_screen_settings.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qlz_flash_cards_ui/core/routes/app_routes.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/data/models/flashcard_model.dart';
import 'package:qlz_flash_cards_ui/features/quiz/data/models/quiz_settings.dart';
import 'package:qlz_flash_cards_ui/features/quiz/logic/cubit/quiz_settings_cubit.dart';
import 'package:qlz_flash_cards_ui/features/quiz/logic/states/quiz_settings_state.dart';
import 'package:qlz_flash_cards_ui/features/quiz/presentation/widgets/quiz_help_dialog.dart';
import 'package:qlz_flash_cards_ui/features/quiz/presentation/widgets/quiz_options_section.dart';
import 'package:qlz_flash_cards_ui/features/quiz/presentation/widgets/quiz_question_settings.dart';
import 'package:qlz_flash_cards_ui/features/quiz/presentation/widgets/quiz_type_section.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/buttons/qlz_button.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_snackbar.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/layout/qlz_modal.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/layout/qlz_screen.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/navigation/qlz_app_bar.dart';

/// Màn hình cài đặt bài kiểm tra
class QuizScreenSettings extends StatefulWidget {
  /// ID của module
  final String moduleId;

  /// Tên của module
  final String moduleName;

  /// Danh sách flashcards
  final List<Flashcard> flashcards;

  const QuizScreenSettings({
    super.key,
    required this.moduleId,
    required this.moduleName,
    required this.flashcards,
  });

  @override
  State<QuizScreenSettings> createState() => _QuizScreenSettingsState();
}

class _QuizScreenSettingsState extends State<QuizScreenSettings> {
  // Key cho form validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Biến để tracking nếu form đã được submit
  bool _hasAttemptedSubmit = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuizSettingsCubit, QuizSettingsState>(
      builder: (context, state) {
        return QlzScreen(
          appBar: QlzAppBar(
            title: 'Thiết lập bài kiểm tra',
            automaticallyImplyLeading: true,
            actions: [
              // Thêm nút help
              IconButton(
                icon: const Icon(Icons.help_outline),
                onPressed: () => _showHelpDialog(context),
                tooltip: 'Trợ giúp',
              ),
            ],
          ),
          padding: EdgeInsets.zero, // Không cần padding ở ngoài
          withScrollView: true,
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  QuizTypeSection(
                    selectedQuizType: state.quizType,
                    onQuizTypeSelected: (type) =>
                        _onQuizTypeSelected(context, type),
                  ),
                  const SizedBox(height: 24),
                  QuizQuestionSettings(
                    questionCount: state.questionCount,
                    maxQuestionCount: widget.flashcards.length,
                    hasAttemptedSubmit: _hasAttemptedSubmit,
                    onQuestionCountChanged: (count) => context
                        .read<QuizSettingsCubit>()
                        .setQuestionCount(count),
                  ),
                  const SizedBox(height: 24),
                  QuizOptionsSection(
                    shuffleQuestions: state.shuffleQuestions,
                    showCorrectAnswers: state.showCorrectAnswers,
                    enableTimer: state.enableTimer,
                    timePerQuestion: state.timePerQuestion,
                    hasAttemptedSubmit: _hasAttemptedSubmit,
                    onShuffleQuestionsChanged: (value) => context
                        .read<QuizSettingsCubit>()
                        .setShuffleQuestions(value),
                    onShowCorrectAnswersChanged: (value) => context
                        .read<QuizSettingsCubit>()
                        .setShowCorrectAnswers(value),
                    onEnableTimerChanged: (value) =>
                        context.read<QuizSettingsCubit>().setEnableTimer(value),
                    onTimePerQuestionChanged: (time) => context
                        .read<QuizSettingsCubit>()
                        .setTimePerQuestion(time),
                  ),
                  const SizedBox(height: 32),
                  _buildStartQuizButton(context, state),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Widget cho phần tiêu đề
  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Section 4: ${widget.moduleName}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Thiết lập bài kiểm tra',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tùy chỉnh bài kiểm tra theo nhu cầu của bạn',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  // Widget cho nút bắt đầu làm bài kiểm tra
  Widget _buildStartQuizButton(BuildContext context, QuizSettingsState state) {
    return QlzButton(
      label: 'Bắt đầu làm kiểm tra',
      isFullWidth: true,
      size: QlzButtonSize.large,
      variant: QlzButtonVariant.primary,
      onPressed: () => _validateAndStartQuiz(context, state),
    );
  }

  // Xử lý khi chọn loại quiz
  void _onQuizTypeSelected(BuildContext context, QuizType type) {
    // Kiểm tra trạng thái của cubit trước khi emit
    final cubit = context.read<QuizSettingsCubit>();
    if (cubit.isClosed) return; // Thêm kiểm tra này để tránh lỗi

    cubit.setQuizType(type);

    // Hiển thị tooltip giải thích
    final description = QuizTypeHelper.getQuizTypeDescription(type);

    QlzSnackbar.info(
      context: context,
      message: description,
      duration: const Duration(seconds: 3),
    );
  }

  // Hiện dialog trợ giúp
  void _showHelpDialog(BuildContext context) {
    QlzModal.showDialog(
      context: context,
      title: 'Trợ giúp thiết lập bài kiểm tra',
      child: const QuizHelpDialog(),
    );
  }

  // Validate và bắt đầu quiz
  void _validateAndStartQuiz(BuildContext context, QuizSettingsState state) {
    // Đánh dấu đã attempt submit để hiển thị lỗi nếu có
    setState(() {
      _hasAttemptedSubmit = true;
    });

    // Kiểm tra form hợp lệ
    if (_formKey.currentState?.validate() ?? false) {
      // Bắt đầu quiz
      _startQuiz(context, state);
    } else {
      // Hiển thị thông báo lỗi
      QlzSnackbar.error(
        context: context,
        message: 'Vui lòng kiểm tra lại các thông tin cài đặt',
        duration: const Duration(seconds: 3),
      );
    }
  }

  // Method để bắt đầu quiz
  void _startQuiz(BuildContext context, QuizSettingsState state) {
    // Xác thực lại các tham số
    int questionCount = state.questionCount;

    // Đảm bảo không vượt quá số lượng thẻ
    if (questionCount > widget.flashcards.length) {
      questionCount = widget.flashcards.length;
    }

    // Đảm bảo ít nhất 1 câu hỏi
    if (questionCount < 1) {
      questionCount = 1;
    }

    // Kiểm tra số lượng flashcards có đủ không
    if (widget.flashcards.isEmpty) {
      QlzSnackbar.error(
        context: context,
        message: 'Không có thẻ ghi nhớ nào để tạo bài kiểm tra',
        duration: const Duration(seconds: 3),
      );
      return;
    }

    // Hiển thị modal xác nhận
    QlzModal.showConfirmation(
      context: context,
      title: 'Bắt đầu bài kiểm tra?',
      message:
          'Bạn đã sẵn sàng bắt đầu bài kiểm tra với $questionCount câu hỏi?',
      confirmText: 'Bắt đầu',
      cancelText: 'Huỷ',
    ).then((confirmed) {
      if (confirmed) {
        // Chuyển sang màn hình quiz
        AppRoutes.navigateToQuiz(
          context,
          quizTypeIndex: state.quizType.index,
          difficultyIndex:
              QuizDifficulty.medium.index, // Gán giá trị mặc định là medium
          flashcards: widget.flashcards,
          moduleId: widget.moduleId,
          moduleName: widget.moduleName,
          questionCount: questionCount,
          shuffleQuestions: state.shuffleQuestions,
          showCorrectAnswers: state.showCorrectAnswers,
          enableTimer: state.enableTimer,
          timePerQuestion: state.timePerQuestion,
        );
      }
    });
  }
}
