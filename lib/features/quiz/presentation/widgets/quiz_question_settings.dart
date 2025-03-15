import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qlz_flash_cards_ui/features/quiz/presentation/providers/quiz_settings_providers.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/inputs/qlz_text_field.dart';

class QuizQuestionSettings extends ConsumerWidget {
  final int maxQuestionCount;
  final bool hasAttemptedSubmit;

  const QuizQuestionSettings({
    super.key,
    required this.maxQuestionCount,
    required this.hasAttemptedSubmit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lắng nghe state của question count từ provider
    final questionCount = ref.watch(questionCountProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Số câu hỏi',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '(tối đa $maxQuestionCount)',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),

        // TextField control
        QuestionCountInput(
          maxQuestionCount: maxQuestionCount,
          hasAttemptedSubmit: hasAttemptedSubmit,
        ),

        const SizedBox(height: 8),

        // Range indicators
        QuestionCountRangeInfo(maxQuestionCount: maxQuestionCount),
      ],
    );
  }
}

class QuestionCountInput extends ConsumerWidget {
  final int maxQuestionCount;
  final bool hasAttemptedSubmit;

  const QuestionCountInput({
    super.key,
    required this.maxQuestionCount,
    required this.hasAttemptedSubmit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(questionCountControllerProvider);
    final focusNode = ref.watch(questionCountFocusProvider);
    final questionCount = ref.watch(questionCountProvider);

    return QlzTextField(
      controller: controller,
      focusNode: focusNode,
      hintText: 'Nhập số câu',
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      onChanged: (value) {
        if (value.isNotEmpty) {
          final count = int.tryParse(value);
          if (count != null) {
            ref.read(questionCountProvider.notifier).state = count;
          }
        }
      },
      onSubmitted: (_) {
        // Validate và cập nhật state
        final text = controller.text.trim();
        if (text.isEmpty) {
          controller.text = '10';
          ref.read(questionCountProvider.notifier).state = 10;
          ref.read(quizSettingsProvider.notifier).setQuestionCount(10);
          return;
        }

        final count = int.tryParse(text) ?? 10;
        final validatedCount = count.clamp(1, maxQuestionCount);

        if (count != validatedCount) {
          controller.text = validatedCount.toString();
        }

        ref.read(questionCountProvider.notifier).state = validatedCount;
        ref
            .read(quizSettingsProvider.notifier)
            .setQuestionCount(validatedCount);
      },
      error: hasAttemptedSubmit &&
              (controller.text.isEmpty ||
                  int.tryParse(controller.text) == null ||
                  int.parse(controller.text) < 1 ||
                  int.parse(controller.text) > maxQuestionCount)
          ? 'Vui lòng nhập số từ 1 đến $maxQuestionCount'
          : null,
    );
  }
}

class QuestionCountRangeInfo extends StatelessWidget {
  final int maxQuestionCount;
  final int minQuestionCount;

  const QuestionCountRangeInfo({
    super.key,
    required this.maxQuestionCount,
    this.minQuestionCount = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Tối thiểu: $minQuestionCount',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
        Text(
          'Tối đa: $maxQuestionCount',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
