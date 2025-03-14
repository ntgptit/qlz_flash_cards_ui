// lib/features/quiz/presentation/widgets/quiz_question_settings.dart
import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/inputs/qlz_text_field.dart';

class QuizQuestionSettings extends StatefulWidget {
  final int questionCount;
  final int maxQuestionCount;
  final bool hasAttemptedSubmit;
  final Function(int) onQuestionCountChanged;

  const QuizQuestionSettings({
    super.key,
    required this.questionCount,
    required this.maxQuestionCount,
    required this.hasAttemptedSubmit,
    required this.onQuestionCountChanged,
  });

  @override
  State<QuizQuestionSettings> createState() => _QuizQuestionSettingsState();
}

class _QuizQuestionSettingsState extends State<QuizQuestionSettings> {
  // Controller và focus node
  late final TextEditingController _questionCountController;
  final FocusNode _questionCountFocusNode = FocusNode();

  // Min question count
  final int _minQuestionCount = 1;

  @override
  void initState() {
    super.initState();
    _questionCountController =
        TextEditingController(text: widget.questionCount.toString());
    _questionCountFocusNode.addListener(_validateQuestionCountOnFocusChange);
  }

  @override
  void didUpdateWidget(QuizQuestionSettings oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Cập nhật text controller nếu giá trị bên ngoài thay đổi và khác với giá trị hiện tại
    if (widget.questionCount.toString() != _questionCountController.text) {
      _questionCountController.text = widget.questionCount.toString();
    }
  }

  @override
  void dispose() {
    _questionCountController.dispose();
    _questionCountFocusNode.removeListener(_validateQuestionCountOnFocusChange);
    _questionCountFocusNode.dispose();
    super.dispose();
  }

  // Validate số lượng câu hỏi khi thay đổi focus
  void _validateQuestionCountOnFocusChange() {
    if (!_questionCountFocusNode.hasFocus) {
      _validateAndUpdateQuestionCount();
    }
  }

  // Validate và cập nhật số lượng câu hỏi
  void _validateAndUpdateQuestionCount() {
    final text = _questionCountController.text.trim();
    if (text.isEmpty) {
      // Nếu rỗng, đặt lại giá trị mặc định
      _questionCountController.text = '10';
      widget.onQuestionCountChanged(10);
      return;
    }

    final count = int.tryParse(text) ?? 10;

    // Giới hạn giá trị trong khoảng hợp lệ
    final validatedCount =
        count.clamp(_minQuestionCount, widget.maxQuestionCount);

    // Cập nhật text controller nếu giá trị đã thay đổi
    if (count != validatedCount) {
      _questionCountController.text = validatedCount.toString();
      // Di chuyển con trỏ về cuối text
      _questionCountController.selection = TextSelection.fromPosition(
        TextPosition(offset: _questionCountController.text.length),
      );
    }

    // Cập nhật state
    widget.onQuestionCountChanged(validatedCount);

    // Cập nhật state ngay lập tức để Slider cũng được cập nhật
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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
          '(tối đa ${widget.maxQuestionCount})',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        QlzTextField(
          controller: _questionCountController,
          focusNode: _questionCountFocusNode,
          hintText: 'Nhập số câu',
          keyboardType: TextInputType.number,
          onChanged: (value) {
            if (value.isNotEmpty) {
              final count = int.tryParse(value);
              if (count != null) {
                // Cập nhật ngay lập tức, không chờ đến khi mất focus
                _validateAndUpdateQuestionCount();
              }
            }
          },
          onSubmitted: (_) => _validateAndUpdateQuestionCount(),
          error: widget.hasAttemptedSubmit &&
                  (_questionCountController.text.isEmpty ||
                      int.tryParse(_questionCountController.text) == null ||
                      int.parse(_questionCountController.text) <
                          _minQuestionCount ||
                      int.parse(_questionCountController.text) >
                          widget.maxQuestionCount)
              ? 'Vui lòng nhập số từ $_minQuestionCount đến ${widget.maxQuestionCount}'
              : null,
        ),
        const SizedBox(height: 8),
        // Thêm slider để điều chỉnh số lượng câu hỏi
        Row(
          children: [
            Text(
              '$_minQuestionCount',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
            Expanded(
              child: Slider(
                value: widget.questionCount.toDouble(),
                min: _minQuestionCount.toDouble(),
                max: widget.maxQuestionCount.toDouble(),
                divisions: widget.maxQuestionCount - _minQuestionCount,
                activeColor: AppColors.primary,
                inactiveColor: AppColors.primary.withOpacity(0.3),
                label: widget.questionCount.toString(),
                onChanged: (double value) {
                  final intValue = value.round();
                  _questionCountController.text = intValue.toString();
                  widget.onQuestionCountChanged(intValue);
                },
              ),
            ),
            Text(
              '${widget.maxQuestionCount}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
