// C:/Users/ntgpt/OneDrive/workspace/qlz_flash_cards_ui/lib/features/study/study_screen.dart
import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/features/study/controllers/study_screen_controller.dart';
import 'package:qlz_flash_cards_ui/features/study/data/study_enums.dart';
import 'package:qlz_flash_cards_ui/features/vocabulary/data/flashcard.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/buttons/qlz_button.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/data_display/qlz_progress.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_empty_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/inputs/qlz_text_field.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/layout/qlz_modal.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/layout/qlz_screen.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/navigation/qlz_app_bar.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/quiz/qlz_quiz_option.dart';

// Widget chính
class StudyScreen extends StatefulWidget {
  final List<Flashcard> flashcards;
  final String moduleName;
  final StudyGoal goal;
  final KnowledgeLevel knowledgeLevel;

  const StudyScreen({
    super.key,
    required this.flashcards,
    required this.moduleName,
    required this.goal,
    required this.knowledgeLevel,
  });

  factory StudyScreen.fromArguments(Map<String, dynamic> arguments) {
    final flashcards = (arguments['flashcards'] as List?)?.cast<Flashcard>() ?? [];
    final moduleName = arguments['moduleName'] as String? ?? 'Module';
    final goal = arguments['goal'] != null
        ? StudyGoal.values.byName(arguments['goal'])
        : StudyGoal.quickStudy;
    final knowledgeLevel = arguments['knowledgeLevel'] != null
        ? KnowledgeLevel.values.byName(arguments['knowledgeLevel'])
        : KnowledgeLevel.allNew;
    return StudyScreen(
      flashcards: flashcards,
      moduleName: moduleName,
      goal: goal,
      knowledgeLevel: knowledgeLevel,
    );
  }

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

// State quản lý logic
class _StudyScreenState extends State<StudyScreen> {
  late final StudyScreenController _controller;

  @override
  void initState() {
    super.initState();
    _controller = StudyScreenController();
    _controller.initialize(widget.flashcards);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Dialog hiển thị kết quả học tập
  void _showResultsDialog() {
    final stats = _controller.getStudyStatistics();
    QlzModal.showDialog(
      context: context,
      title: 'Study Session Results',
      isDismissible: false,
      backgroundColor: AppColors.darkCard,
      child: _ResultsDialogContent(stats: stats),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            setState(() {});
          },
          child: const Text('Continue Learning', style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.pop(context);
          },
          child: const Text('Finish Session', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  // Dialog khi hoàn thành module
  void _showModuleCompletionDialog() {
    QlzModal.showDialog(
      context: context,
      title: 'Module Completed! 🎉',
      isDismissible: false,
      backgroundColor: AppColors.darkCard,
      child: _ModuleCompletionContent(totalCards: widget.flashcards.length),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            _controller.resetForNewSession();
            setState(() {});
          },
          child: const Text('Review Again', style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.pop(context);
          },
          child: const Text('Finish', style: TextStyle(color: Colors.green)),
        ),
      ],
    );
  }

  // Xử lý câu trả lời trắc nghiệm
  void _handleMultipleChoiceAnswer(String answer) {
    if (_controller.isAnswerSubmitted) return;
    setState(() {
      _controller.checkMultipleChoiceAnswer(answer);
      if (_controller.isAnswerCorrect) {
        _controller.autoAdvanceAfterDelay(() => setState(() {}));
      }
    });
  }

  // Xử lý câu trả lời gõ
  void _handleTypingAnswer() {
    if (_controller.isAnswerSubmitted) return;
    setState(() {
      _controller.checkTypingAnswer();
      if (_controller.isAnswerCorrect) {
        _controller.autoAdvanceAfterDelay(() => setState(() {}));
      }
    });
  }

  // Chuyển bước tiếp theo
  void _handleNextStep() {
    _controller.nextStep(() {
      setState(() {});
      if (_controller.isModuleCompleted()) {
        _showModuleCompletionDialog();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.flashcards.isEmpty) {
      return QlzScreen(
        appBar: AppBar(title: const Text('Study')),
        child: QlzEmptyState.noData(
          title: 'No Flashcards',
          message: 'This module has no flashcards to study yet.',
          actionLabel: 'Go Back',
          onAction: () => Navigator.pop(context),
        ),
      );
    }

    final stats = _controller.getStudyStatistics();
    final completed = stats['completedCards'] as int;
    final total = widget.flashcards.length;
    final percentComplete = total > 0 ? (completed / total * 100).toInt() : 0;

    return Scaffold(
      backgroundColor: const Color(0xFF0A092D),
      appBar: QlzAppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: '${_controller.getCurrentPhase()} (${_controller.getCurrentPhaseCardIndex() + 1}/${_controller.getCurrentPhaseCardCount()})',
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: QlzProgress(
                value: _controller.getProgress(),
                height: 8,
                color: AppColors.primary,
                backgroundColor: const Color(0xFF282A4A),
              ),
            ),
            Expanded(
              child: _controller.currentMode == StudyMode.multipleChoice
                  ? MultipleChoiceView(
                      controller: _controller,
                      onAnswer: _handleMultipleChoiceAnswer,
                      onNext: _handleNextStep,
                    )
                  : TypingView(
                      controller: _controller,
                      onAnswer: _handleTypingAnswer,
                      onNext: _handleNextStep,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget nội dung dialog kết quả
class _ResultsDialogContent extends StatelessWidget {
  final Map<String, dynamic> stats;

  const _ResultsDialogContent({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Cards completed: ${stats['completedCards']}/${stats['totalCards']} (${stats['completionRate'].toStringAsFixed(0)}%)',
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Total cards studied: ${stats['cardsStudied']}',
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Accuracy rate: ${stats['accuracyRate'].toStringAsFixed(0)}%',
          style: TextStyle(
            color: stats['accuracyRate'] > 70 ? Colors.green : Colors.orange,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Multiple choice correct: ${stats['multipleChoiceCorrect']}',
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Typing correct: ${stats['typingCorrect']}',
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        if (stats['cardsNeedingReview'] > 0) ...[
          const SizedBox(height: 12),
          Text(
            'Cards still needing review: ${stats['cardsNeedingReview']}',
            style: const TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

// Widget nội dung dialog hoàn thành module
class _ModuleCompletionContent extends StatelessWidget {
  final int totalCards;

  const _ModuleCompletionContent({required this.totalCards});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Congratulations! You have successfully learned all the cards in this module.',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Total cards mastered: $totalCards',
          style: const TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// Widget giao diện trắc nghiệm
class MultipleChoiceView extends StatelessWidget {
  final StudyScreenController controller;
  final Function(String) onAnswer;
  final VoidCallback onNext;

  const MultipleChoiceView({super.key, 
    required this.controller,
    required this.onAnswer,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final currentCard = controller.getCurrentCard();
    if (currentCard == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            currentCard.flashcard.definition,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (controller.isAnswerSubmitted)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              controller.isAnswerCorrect
                  ? "잘했어요! (Well done!)"
                  : "조금만 더요, 아직 배우고 있잖아요! (Keep going, you're still learning!)",
              style: TextStyle(
                color: controller.isAnswerCorrect ? AppColors.success : AppColors.error,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!controller.isAnswerSubmitted)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Choose the correct answer',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ...List.generate(controller.options.length, (index) {
                final option = controller.options[index];
                final isSelected = controller.selectedAnswer == option;
                final isCorrectAnswer = currentCard.flashcard.term == option;
                QlzQuizOptionState optionState = QlzQuizOptionState.idle;
                if (controller.isAnswerSubmitted) {
                  if (isCorrectAnswer) {
                    optionState = QlzQuizOptionState.correct;
                  } else if (isSelected) {
                    optionState = QlzQuizOptionState.incorrect;
                  }
                } else if (isSelected) {
                  optionState = QlzQuizOptionState.selected;
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: QlzQuizOption(
                    text: option,
                    state: optionState,
                    onTap: () => onAnswer(option),
                  ),
                );
              }),
            ],
          ),
        ),
        const Spacer(),
        if (controller.isAnswerSubmitted && !controller.isAnswerCorrect)
          Padding(
            padding: const EdgeInsets.all(16),
            child: QlzButton.primary(
              label: 'Continue',
              isFullWidth: true,
              onPressed: onNext,
            ),
          ),
      ],
    );
  }
}

// Widget giao diện gõ
class TypingView extends StatelessWidget {
  final StudyScreenController controller;
  final VoidCallback onAnswer;
  final VoidCallback onNext;

  const TypingView({super.key, 
    required this.controller,
    required this.onAnswer,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final currentCard = controller.getCurrentCard();
    if (currentCard == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            currentCard.flashcard.definition,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (controller.isAnswerSubmitted)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.isAnswerCorrect
                      ? "잘했어요! (Well done!)"
                      : "아쉬워요. 정답은: (Too bad. The correct answer is:)",
                  style: TextStyle(
                    color: controller.isAnswerCorrect ? const Color(0xFF63E48D) : const Color(0xFFFF4D4F),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!controller.isAnswerCorrect) ...[
                  const SizedBox(height: 8),
                  Text(
                    currentCard.flashcard.term,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!controller.isAnswerSubmitted)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Type the exact term',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              QlzTextField(
                controller: controller.answerController,
                isDisabled: controller.isAnswerSubmitted,
                hintText: 'Enter your answer...',
                onSubmitted: (_) => onAnswer(),
                suffixIcon: Icons.send,
                onSuffixIconTap: controller.isAnswerSubmitted ? null : onAnswer,
              ),
            ],
          ),
        ),
        const Spacer(),
        if (controller.isAnswerSubmitted && !controller.isAnswerCorrect)
          Padding(
            padding: const EdgeInsets.all(16),
            child: QlzButton.primary(
              label: 'Continue',
              isFullWidth: true,
              onPressed: onNext,
            ),
          ),
      ],
    );
  }
}