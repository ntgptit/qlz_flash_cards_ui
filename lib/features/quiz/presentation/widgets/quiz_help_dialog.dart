// lib/features/quiz/presentation/widgets/quiz_help_dialog.dart
import 'package:flutter/material.dart';

class QuizHelpDialog extends StatelessWidget {
  const QuizHelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kiểu bài kiểm tra',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildHelpItem('Trắc nghiệm',
              'Chọn một đáp án đúng từ nhiều lựa chọn. Phù hợp để kiểm tra kiến thức tổng quát.'),
          _buildHelpItem('Tự luận',
              'Nhập câu trả lời của bạn. Tốt cho việc kiểm tra khả năng biểu đạt và hiểu sâu.'),
          _buildHelpItem('Đúng / Sai',
              'Xác định xem phát biểu là đúng hay sai. Phù hợp để kiểm tra các khái niệm cơ bản.'),
          _buildHelpItem('Ghép đôi',
              'Ghép các khái niệm với định nghĩa tương ứng. Tốt cho việc kiểm tra mối liên hệ giữa các thuật ngữ.'),
          const Divider(color: Colors.white24),
          const Text(
            'Tùy chọn thêm',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildHelpItem('Trộn câu hỏi',
              'Khi bật, thứ tự các câu hỏi sẽ được trộn ngẫu nhiên mỗi lần làm bài.'),
          _buildHelpItem('Hiển thị đáp án đúng',
              'Khi bật, đáp án đúng sẽ được hiển thị ngay sau khi bạn trả lời mỗi câu hỏi.'),
          _buildHelpItem('Bộ đếm thời gian',
              'Khi bật, mỗi câu hỏi sẽ có giới hạn thời gian để trả lời. Nếu hết thời gian, hệ thống sẽ tự động chuyển sang câu hỏi tiếp theo.'),
        ],
      ),
    );
  }

  // Widget cho mục trợ giúp
  Widget _buildHelpItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
