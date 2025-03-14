// lib/features/quiz/presentation/widgets/quiz_answers_section.dart
import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/features/quiz/data/models/quiz_answer.dart';
import 'package:qlz_flash_cards_ui/features/quiz/data/models/quiz_settings.dart';

class QuizAnswersSection extends StatelessWidget {
  final QuizType quizType;
  final String questionTypeLabel;
  final List<QuizAnswer> answers;
  final QuizAnswer? userAnswer;
  final QuizAnswer correctAnswer;
  final bool hasAnswered;
  final bool showCorrectAnswers;
  final Function(QuizAnswer) onAnswerSelected;

  const QuizAnswersSection({
    super.key,
    required this.quizType,
    required this.questionTypeLabel,
    required this.answers,
    required this.userAnswer,
    required this.correctAnswer,
    required this.hasAnswered,
    required this.showCorrectAnswers,
    required this.onAnswerSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          questionTypeLabel,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...answers.map((answer) => _buildAnswerOption(context, answer)),
      ],
    );
  }

  Widget _buildAnswerOption(BuildContext context, QuizAnswer answer) {
    final isSelected = hasAnswered && userAnswer?.id == answer.id;
    final isCorrect = answer.isCorrect;
    final shouldHighlightCorrect =
        showCorrectAnswers && hasAnswered && isCorrect;
    final shouldHighlightIncorrect =
        showCorrectAnswers && isSelected && !isCorrect;

    Color backgroundColor;
    Color borderColor;
    IconData? iconData;
    Color iconColor = Colors.white;

    if (shouldHighlightCorrect) {
      backgroundColor = AppColors.success.withOpacity(0.2);
      borderColor = AppColors.success;
      iconData = Icons.check_circle;
      iconColor = AppColors.success;
    } else if (shouldHighlightIncorrect) {
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
      onTap: hasAnswered ? null : () => onAnswerSelected(answer),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width:
                isSelected || shouldHighlightCorrect || shouldHighlightIncorrect
                    ? 2
                    : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                answer.text,
                style: TextStyle(
                  color: isSelected ||
                          shouldHighlightCorrect ||
                          shouldHighlightIncorrect
                      ? Colors.white
                      : Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: isSelected || shouldHighlightCorrect
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
}
