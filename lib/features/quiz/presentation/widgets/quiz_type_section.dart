// lib/features/quiz/presentation/widgets/quiz_type_section.dart
import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/features/quiz/data/models/quiz_settings.dart';
import 'package:qlz_flash_cards_ui/features/quiz/presentation/widgets/quiz_option_card.dart';

class QuizTypeSection extends StatelessWidget {
  final QuizType selectedQuizType;
  final Function(QuizType) onQuizTypeSelected;

  const QuizTypeSection({
    super.key,
    required this.selectedQuizType,
    required this.onQuizTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Các loại kiểm tra được hỗ trợ
    final quizTypes = [
      QuizType.multipleChoice, // Trắc nghiệm
      QuizType.fillInBlank, // Tự luận
      QuizType.trueFalse, // Đúng/sai
      QuizType.matching, // Ghép đôi
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kiểu bài kiểm tra',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: quizTypes.map((type) {
            return QuizOptionCard(
              title: QuizTypeHelper.getQuizTypeName(type),
              icon: QuizTypeHelper.getQuizTypeIcon(type),
              isSelected: selectedQuizType == type,
              onTap: () => onQuizTypeSelected(type),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Helper class để làm việc với các loại quiz
class QuizTypeHelper {
  // Lấy tên loại quiz dựa trên enum
  static String getQuizTypeName(QuizType type) {
    return switch (type) {
      QuizType.multipleChoice => 'Trắc nghiệm',
      QuizType.fillInBlank => 'Tự luận',
      QuizType.trueFalse => 'Đúng / Sai',
      QuizType.matching => 'Ghép đôi',
      _ => '', // Các trường hợp khác không hiển thị
    };
  }

  // Lấy icon cho loại quiz
  static IconData getQuizTypeIcon(QuizType type) {
    return switch (type) {
      QuizType.multipleChoice => Icons.format_list_bulleted,
      QuizType.fillInBlank => Icons.edit_outlined,
      QuizType.trueFalse => Icons.check_circle_outline,
      QuizType.matching => Icons.compare_arrows,
      _ => Icons.help_outline, // Icon mặc định
    };
  }

  // Lấy mô tả chi tiết cho loại quiz
  static String getQuizTypeDescription(QuizType type) {
    return switch (type) {
      QuizType.multipleChoice =>
        'Trắc nghiệm: Chọn đáp án đúng từ các lựa chọn',
      QuizType.fillInBlank => 'Tự luận: Viết câu trả lời của bạn',
      QuizType.trueFalse => 'Đúng/Sai: Xác định xem câu hỏi đúng hay sai',
      QuizType.matching =>
        'Ghép đôi: Ghép các khái niệm với định nghĩa tương ứng',
      _ => '', // Các trường hợp khác không hiển thị
    };
  }
}
