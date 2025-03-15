import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/features/quiz/presentation/providers/quiz_settings_providers.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/inputs/qlz_text_field.dart';

class QuizOptionsSection extends ConsumerWidget {
  final bool hasAttemptedSubmit;

  const QuizOptionsSection({
    super.key,
    required this.hasAttemptedSubmit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(quizSettingsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tùy chọn thêm',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SwitchOption(
          label: 'Trộn câu hỏi',
          description: 'Trộn thứ tự các câu hỏi mỗi lần làm bài',
          value: settings.shuffleQuestions,
          onChanged: (value) => ref
              .read(quizSettingsProvider.notifier)
              .setShuffleQuestions(value),
        ),
        SwitchOption(
          label: 'Hiển thị đáp án đúng',
          description: 'Hiển thị đáp án đúng sau khi trả lời mỗi câu',
          value: settings.showCorrectAnswers,
          onChanged: (value) => ref
              .read(quizSettingsProvider.notifier)
              .setShowCorrectAnswers(value),
        ),
        SwitchOption(
          label: 'Bộ đếm thời gian',
          description: 'Giới hạn thời gian cho mỗi câu hỏi',
          value: settings.enableTimer,
          onChanged: (value) {
            ref.read(quizSettingsProvider.notifier).setEnableTimer(value);
            if (value) {
              Future.delayed(const Duration(milliseconds: 300), () {
                final focusNode = ref.read(timePerQuestionFocusProvider);
                FocusScope.of(context).requestFocus(focusNode);
              });
            }
          },
        ),
        if (settings.enableTimer) ...[
          const SizedBox(height: 16),
          TimePerQuestionInput(hasAttemptedSubmit: hasAttemptedSubmit),
          const SizedBox(height: 8),
          const TimePerQuestionSlider(),
        ],
      ],
    );
  }
}

class SwitchOption extends StatelessWidget {
  final String label;
  final String? description;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SwitchOption({
    super.key,
    required this.label,
    this.description,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    description!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            trackColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.primary.withOpacity(0.5);
              }
              return const Color(0xFF1A1D3D);
            }),
            thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.white;
              }
              return Colors.white.withOpacity(0.8);
            }),
          ),
        ],
      ),
    );
  }
}

class TimePerQuestionInput extends ConsumerWidget {
  final bool hasAttemptedSubmit;

  const TimePerQuestionInput({
    super.key,
    required this.hasAttemptedSubmit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(timePerQuestionControllerProvider);
    final focusNode = ref.watch(timePerQuestionFocusProvider);
    final timePerQuestion = ref.watch(timePerQuestionProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thời gian cho mỗi câu hỏi (giây)',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        QlzTextField(
          controller: controller,
          focusNode: focusNode,
          hintText: 'Nhập thời gian',
          keyboardType: TextInputType.number,
          onChanged: (value) {
            if (value.isNotEmpty) {
              final time = int.tryParse(value);
              if (time != null) {
                ref.read(timePerQuestionProvider.notifier).state = time;
              }
            }
          },
          onSubmitted: (_) {
            final text = controller.text.trim();
            if (text.isEmpty) {
              controller.text = '30';
              ref.read(timePerQuestionProvider.notifier).state = 30;
              ref.read(quizSettingsProvider.notifier).setTimePerQuestion(30);
              return;
            }
            final time = int.tryParse(text) ?? 30;
            final validatedTime = time.clamp(5, 300);
            if (time != validatedTime) {
              controller.text = validatedTime.toString();
            }
            ref.read(timePerQuestionProvider.notifier).state = validatedTime;
            ref
                .read(quizSettingsProvider.notifier)
                .setTimePerQuestion(validatedTime);
          },
          error: hasAttemptedSubmit &&
                  (controller.text.isEmpty ||
                      int.tryParse(controller.text) == null ||
                      int.parse(controller.text) < 5 ||
                      int.parse(controller.text) > 300)
              ? 'Vui lòng nhập thời gian từ 5 đến 300 giây'
              : null,
        ),
      ],
    );
  }
}

class TimePerQuestionSlider extends ConsumerWidget {
  const TimePerQuestionSlider({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timePerQuestion = ref.watch(timePerQuestionProvider);
    final controller = ref.watch(timePerQuestionControllerProvider);
    ref.listen<int>(timePerQuestionProvider, (previous, next) {
      if (next != int.tryParse(controller.text)) {
        controller.text = next.toString();
      }
    });
    return Row(
      children: [
        const Text(
          '5s',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        Expanded(
          child: Slider(
            value: timePerQuestion.toDouble(),
            min: 5,
            max: 300,
            divisions: 59,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.primary.withOpacity(0.3),
            label: '${timePerQuestion}s',
            onChanged: (double value) {
              final intValue = value.round();
              controller.text = intValue.toString();
              ref.read(timePerQuestionProvider.notifier).state = intValue;
              ref
                  .read(quizSettingsProvider.notifier)
                  .setTimePerQuestion(intValue);
            },
          ),
        ),
        const Text(
          '300s',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
