// lib/features/quiz/presentation/widgets/quiz_options_section.dart
import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/inputs/qlz_text_field.dart';

class QuizOptionsSection extends StatefulWidget {
  final bool shuffleQuestions;
  final bool showCorrectAnswers;
  final bool enableTimer;
  final int timePerQuestion;
  final bool hasAttemptedSubmit;
  final Function(bool) onShuffleQuestionsChanged;
  final Function(bool) onShowCorrectAnswersChanged;
  final Function(bool) onEnableTimerChanged;
  final Function(int) onTimePerQuestionChanged;

  const QuizOptionsSection({
    super.key,
    required this.shuffleQuestions,
    required this.showCorrectAnswers,
    required this.enableTimer,
    required this.timePerQuestion,
    required this.hasAttemptedSubmit,
    required this.onShuffleQuestionsChanged,
    required this.onShowCorrectAnswersChanged,
    required this.onEnableTimerChanged,
    required this.onTimePerQuestionChanged,
  });

  @override
  State<QuizOptionsSection> createState() => _QuizOptionsSectionState();
}

class _QuizOptionsSectionState extends State<QuizOptionsSection> {
  // Controller và focus node cho ô thời gian
  late final TextEditingController _timePerQuestionController;
  final FocusNode _timePerQuestionFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _timePerQuestionController =
        TextEditingController(text: widget.timePerQuestion.toString());
    _timePerQuestionFocusNode
        .addListener(_validateTimePerQuestionOnFocusChange);
  }

  @override
  void didUpdateWidget(QuizOptionsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Cập nhật text controller nếu giá trị bên ngoài thay đổi và khác với giá trị hiện tại
    if (widget.timePerQuestion.toString() != _timePerQuestionController.text) {
      _timePerQuestionController.text = widget.timePerQuestion.toString();
    }
  }

  @override
  void dispose() {
    _timePerQuestionController.dispose();
    _timePerQuestionFocusNode
        .removeListener(_validateTimePerQuestionOnFocusChange);
    _timePerQuestionFocusNode.dispose();
    super.dispose();
  }

  // Validate thời gian khi thay đổi focus
  void _validateTimePerQuestionOnFocusChange() {
    if (!_timePerQuestionFocusNode.hasFocus) {
      _validateAndUpdateTimePerQuestion();
    }
  }

  // Validate và cập nhật thời gian mỗi câu hỏi
  void _validateAndUpdateTimePerQuestion() {
    final text = _timePerQuestionController.text.trim();
    if (text.isEmpty) {
      // Nếu rỗng, đặt lại giá trị mặc định
      _timePerQuestionController.text = '30';
      widget.onTimePerQuestionChanged(30);
      return;
    }

    final time = int.tryParse(text) ?? 30;

    // Giới hạn giá trị trong khoảng hợp lệ (5-300 giây)
    final validatedTime = time.clamp(5, 300);

    // Cập nhật text controller nếu giá trị đã thay đổi
    if (time != validatedTime) {
      _timePerQuestionController.text = validatedTime.toString();
      // Di chuyển con trỏ về cuối text
      _timePerQuestionController.selection = TextSelection.fromPosition(
        TextPosition(offset: _timePerQuestionController.text.length),
      );
    }

    // Cập nhật state
    widget.onTimePerQuestionChanged(validatedTime);
  }

  @override
  Widget build(BuildContext context) {
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

        // Tùy chọn trộn câu hỏi
        _buildSwitchOption(
          label: 'Trộn câu hỏi',
          value: widget.shuffleQuestions,
          description: 'Trộn thứ tự các câu hỏi mỗi lần làm bài',
          onChanged: widget.onShuffleQuestionsChanged,
        ),

        // Tùy chọn hiển thị đáp án đúng
        _buildSwitchOption(
          label: 'Hiển thị đáp án đúng',
          value: widget.showCorrectAnswers,
          description: 'Hiển thị đáp án đúng sau khi trả lời mỗi câu',
          onChanged: widget.onShowCorrectAnswersChanged,
        ),

        // Tùy chọn bộ đếm thời gian
        _buildSwitchOption(
          label: 'Bộ đếm thời gian',
          value: widget.enableTimer,
          description: 'Giới hạn thời gian cho mỗi câu hỏi',
          onChanged: (value) {
            widget.onEnableTimerChanged(value);

            // Nếu bật timer, focus vào ô nhập thời gian
            if (value) {
              Future.delayed(const Duration(milliseconds: 300), () {
                FocusScope.of(context).requestFocus(_timePerQuestionFocusNode);
              });
            }
          },
        ),

        // Phần cài đặt thời gian cho mỗi câu hỏi
        if (widget.enableTimer) ...[
          const SizedBox(height: 16),
          const Text(
            'Thời gian cho mỗi câu hỏi (giây)',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          QlzTextField(
            controller: _timePerQuestionController,
            focusNode: _timePerQuestionFocusNode,
            hintText: 'Nhập thời gian',
            keyboardType: TextInputType.number,
            onChanged: (value) {
              if (value.isNotEmpty) {
                final time = int.tryParse(value);
                if (time != null) {
                  widget.onTimePerQuestionChanged(time);
                }
              }
            },
            onSubmitted: (_) => _validateAndUpdateTimePerQuestion(),
            error: widget.hasAttemptedSubmit &&
                    (_timePerQuestionController.text.isEmpty ||
                        int.tryParse(_timePerQuestionController.text) == null ||
                        int.parse(_timePerQuestionController.text) < 5 ||
                        int.parse(_timePerQuestionController.text) > 300)
                ? 'Vui lòng nhập thời gian từ 5 đến 300 giây'
                : null,
          ),
          const SizedBox(height: 8),
          // Thêm slider để điều chỉnh thời gian
          Row(
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
                  value: widget.timePerQuestion.toDouble(),
                  min: 5,
                  max: 300,
                  divisions: 59, // Chia thành khoảng 5s
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.primary.withOpacity(0.3),
                  label: '${widget.timePerQuestion}s',
                  onChanged: (double value) {
                    final intValue = value.round();
                    _timePerQuestionController.text = intValue.toString();
                    widget.onTimePerQuestionChanged(intValue);
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
          ),
        ],
      ],
    );
  }

  // Helper method để xây dựng các tùy chọn dạng switch có mô tả
  Widget _buildSwitchOption({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
    String? description,
  }) {
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
                    description,
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
