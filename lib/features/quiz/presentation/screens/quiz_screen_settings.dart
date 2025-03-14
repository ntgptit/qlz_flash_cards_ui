import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qlz_flash_cards_ui/core/routes/app_routes.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/data/models/flashcard_model.dart';
import 'package:qlz_flash_cards_ui/features/quiz/data/models/quiz_settings.dart';
import 'package:qlz_flash_cards_ui/features/quiz/domain/states/quiz_settings_state.dart';
import 'package:qlz_flash_cards_ui/features/quiz/presentation/providers/quiz_providers.dart';
import 'package:qlz_flash_cards_ui/features/quiz/presentation/widgets/quiz_help_dialog.dart';
import 'package:qlz_flash_cards_ui/features/quiz/presentation/widgets/quiz_options_section.dart';
import 'package:qlz_flash_cards_ui/features/quiz/presentation/widgets/quiz_question_settings.dart';
import 'package:qlz_flash_cards_ui/features/quiz/presentation/widgets/quiz_type_section.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/buttons/qlz_button.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_snackbar.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/layout/qlz_modal.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/layout/qlz_screen.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/navigation/qlz_app_bar.dart';

class QuizScreenSettings extends ConsumerStatefulWidget {
  final String moduleId;
  final String moduleName;
  final List<Flashcard> flashcards;

  const QuizScreenSettings({
    super.key,
    required this.moduleId,
    required this.moduleName,
    required this.flashcards,
  });

  @override
  ConsumerState<QuizScreenSettings> createState() => _QuizScreenSettingsState();
}

class _QuizScreenSettingsState extends ConsumerState<QuizScreenSettings> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Khởi tạo state sau khi frame đầu tiên được render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSettings();
    });
  }

  // Khởi tạo các settings một cách an toàn
  void _initializeSettings() {
    ref
        .read(quizSettingsProvider.notifier)
        .initialize(widget.flashcards.length);

    final settings = ref.read(quizSettingsProvider);
    ref.read(timePerQuestionProvider.notifier).state = settings.timePerQuestion;
    ref.read(questionCountProvider.notifier).state = settings.questionCount;

    // Đánh dấu đã khởi tạo và cập nhật UI
    ref.read(quizScreenStateProvider.notifier).setInitialized(true);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Hiển thị loading khi đang khởi tạo
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final screenState = ref.watch(quizScreenStateProvider);
    final settingsState = ref.watch(quizSettingsProvider);

    return QlzScreen(
      appBar: QlzAppBar(
        title: 'Thiết lập bài kiểm tra',
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(context),
            tooltip: 'Trợ giúp',
          ),
        ],
      ),
      padding: EdgeInsets.zero,
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

              // Quiz Type Selector
              QuizTypeSection(
                selectedQuizType: settingsState.quizType,
                onQuizTypeSelected: (type) =>
                    _onQuizTypeSelected(context, type, ref),
              ),
              const SizedBox(height: 24),

              // Question Count Settings
              QuizQuestionSettings(
                maxQuestionCount: widget.flashcards.length,
                hasAttemptedSubmit: screenState.hasAttemptedSubmit,
              ),
              const SizedBox(height: 24),

              // Quiz Options
              QuizOptionsSection(
                hasAttemptedSubmit: screenState.hasAttemptedSubmit,
              ),
              const SizedBox(height: 32),

              // Start Quiz Button
              _buildStartQuizButton(context, settingsState, ref),
            ],
          ),
        ),
      ),
    );
  }

  // Header with title and description
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

  // Start Quiz Button
  Widget _buildStartQuizButton(
      BuildContext context, QuizSettingsState state, WidgetRef ref) {
    return QlzButton(
      label: 'Bắt đầu làm kiểm tra',
      isFullWidth: true,
      size: QlzButtonSize.large,
      variant: QlzButtonVariant.primary,
      onPressed: () => _validateAndStartQuiz(context, state, ref),
    );
  }

  // OnQuizTypeSelected handler
  void _onQuizTypeSelected(BuildContext context, QuizType type, WidgetRef ref) {
    ref.read(quizSettingsProvider.notifier).setQuizType(type);
    final description = QuizTypeHelper.getQuizTypeDescription(type);
    QlzSnackbar.info(
      context: context,
      message: description,
      duration: const Duration(seconds: 3),
    );
  }

  // Show help dialog
  void _showHelpDialog(BuildContext context) {
    QlzModal.showDialog(
      context: context,
      title: 'Trợ giúp thiết lập bài kiểm tra',
      child: const QuizHelpDialog(),
    );
  }

  // Validation and starting quiz
  void _validateAndStartQuiz(
      BuildContext context, QuizSettingsState state, WidgetRef ref) {
    ref.read(quizScreenStateProvider.notifier).setHasAttemptedSubmit(true);

    // Validate question count
    final questionCountText = ref.read(questionCountControllerProvider).text;
    final questionCount = int.tryParse(questionCountText);

    // Validate time per question if enabled
    bool timeValid = true;
    if (state.enableTimer) {
      final timePerQuestionText =
          ref.read(timePerQuestionControllerProvider).text;
      final timePerQuestion = int.tryParse(timePerQuestionText);
      timeValid = timePerQuestion != null &&
          timePerQuestion >= 5 &&
          timePerQuestion <= 300;
    }

    final isValid = questionCount != null &&
        questionCount >= 1 &&
        questionCount <= widget.flashcards.length &&
        timeValid;

    if (isValid) {
      _startQuiz(context, state, ref);
    } else {
      QlzSnackbar.error(
        context: context,
        message: 'Vui lòng kiểm tra lại các thông tin cài đặt',
        duration: const Duration(seconds: 3),
      );
    }
  }

  // Start quiz with current settings
  void _startQuiz(
      BuildContext context, QuizSettingsState state, WidgetRef ref) {
    final questionCount = ref.read(questionCountProvider);

    if (widget.flashcards.isEmpty) {
      QlzSnackbar.error(
        context: context,
        message: 'Không có thẻ ghi nhớ nào để tạo bài kiểm tra',
        duration: const Duration(seconds: 3),
      );
      return;
    }

    QlzModal.showConfirmation(
      context: context,
      title: 'Bắt đầu bài kiểm tra?',
      message:
          'Bạn đã sẵn sàng bắt đầu bài kiểm tra với $questionCount câu hỏi?',
      confirmText: 'Bắt đầu',
      cancelText: 'Huỷ',
    ).then((confirmed) {
      if (confirmed) {
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
          timePerQuestion: ref.read(timePerQuestionProvider),
        );
      }
    });
  }
}
