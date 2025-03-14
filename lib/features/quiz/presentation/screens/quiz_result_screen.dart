// // lib/features/quiz/screens/quiz_result_screen.dart

// import 'package:flutter/material.dart';
// import 'package:qlz_flash_cards_ui/config/app_colors.dart';
// import 'package:qlz_flash_cards_ui/features/quiz/data/models/quiz_result.dart';
// import 'package:qlz_flash_cards_ui/shared/widgets/cards/qlz_card.dart';
// import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_snackbar.dart';
// import 'package:qlz_flash_cards_ui/shared/widgets/buttons/qlz_button.dart';

// /// Màn hình hiển thị kết quả bài kiểm tra
// class QuizResultScreen extends StatefulWidget {
//   final QuizResult quizResult;
//   final VoidCallback onRestart;

//   const QuizResultScreen({
//     super.key,
//     required this.quizResult,
//     required this.onRestart,
//   });

//   @override
//   State<QuizResultScreen> createState() => _QuizResultScreenState();
// }

// class _QuizResultScreenState extends State<QuizResultScreen> {
//   bool _isLoading = false;

//   void _saveQuizResult() {
//     // Giả lập lưu kết quả
//     setState(() {
//       _isLoading = true;
//     });

//     Future.delayed(const Duration(seconds: 1), () {
//       if (!mounted) return;

//       setState(() {
//         _isLoading = false;
//       });

//       // Hiển thị thông báo thành công
//       QlzSnackbar.success(
//         context: context,
//         message: 'Đã lưu kết quả bài kiểm tra',
//       );

//       // Quay về màn hình trước
//       Navigator.of(context).pop();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final result = widget.quizResult;
//     final successRate = result.successRate;

//     // Xác định màu dựa trên tỷ lệ đúng
//     final Color resultColor = successRate >= 80
//         ? AppColors.success
//         : (successRate >= 60 ? AppColors.warning : AppColors.error);

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           // Card kết quả
//           QlzCard(
//             backgroundColor: AppColors.darkCard,
//             padding: const EdgeInsets.all(24),
//             child: Column(
//               children: [
//                 // Biểu tượng kết quả
//                 Container(
//                   width: 80,
//                   height: 80,
//                   decoration: BoxDecoration(
//                     color: resultColor.withOpacity(0.1),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     successRate >= 80
//                         ? Icons.emoji_events
//                         : (successRate >= 60
//                             ? Icons.thumb_up
//                             : Icons.sentiment_neutral),
//                     color: resultColor,
//                     size: 40,
//                   ),
//                 ),

//                 const SizedBox(height: 16),

//                 // Tỷ lệ đúng
//                 Text(
//                   '${successRate.toStringAsFixed(0)}%',
//                   style: TextStyle(
//                     color: resultColor,
//                     fontSize: 40,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),

//                 const SizedBox(height: 8),

//                 // Số câu đúng
//                 Text(
//                   '${result.correctAnswers}/${result.totalQuestions} câu đúng',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                   ),
//                 ),

//                 const SizedBox(height: 24),

//                 // Thông tin bài kiểm tra
//                 _buildInfoRow(
//                   icon: Icons.category,
//                   label: 'Loại kiểm tra',
//                   value: result.quizType.label,
//                 ),

//                 const SizedBox(height: 8),

//                 // Thời gian hoàn thành
//                 _buildInfoRow(
//                   icon: Icons.timer,
//                   label: 'Thời gian',
//                   value: result.formattedTime,
//                 ),

//                 const SizedBox(height: 8),

//                 // Ngày hoàn thành
//                 _buildInfoRow(
//                   icon: Icons.calendar_today,
//                   label: 'Ngày',
//                   value: _formatDate(result.completionDate),
//                 ),

//                 const SizedBox(height: 16),

//                 // Đánh giá
//                 Text(
//                   result.evaluation,
//                   style: TextStyle(
//                     color: Colors.white.withOpacity(0.7),
//                     fontSize: 14,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 24),

//           // Các nút hành động
//           Row(
//             children: [
//               // Nút làm lại bài kiểm tra
//               Expanded(
//                 child: QlzButton.secondary(
//                   label: 'Làm lại',
//                   icon: Icons.refresh,
//                   onPressed: widget.onRestart,
//                 ),
//               ),

//               const SizedBox(width: 16),

//               // Nút lưu kết quả
//               Expanded(
//                 child: QlzButton.primary(
//                   label: 'Lưu kết quả',
//                   icon: Icons.save,
//                   isLoading: _isLoading,
//                   onPressed: _saveQuizResult,
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 16),

//           // Nút quay về
//           QlzButton.ghost(
//             label: 'Quay về học phần',
//             isFullWidth: true,
//             onPressed: () => Navigator.of(context).pop(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoRow({
//     required IconData icon,
//     required String label,
//     required String value,
//   }) {
//     return Row(
//       children: [
//         Icon(
//           icon,
//           size: 18,
//           color: Colors.white70,
//         ),
//         const SizedBox(width: 8),
//         Text(
//           '$label: ',
//           style: const TextStyle(
//             color: Colors.white70,
//             fontSize: 14,
//           ),
//         ),
//         Expanded(
//           child: Text(
//             value,
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//             ),
//             textAlign: TextAlign.right,
//           ),
//         ),
//       ],
//     );
//   }

//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year}';
//   }
// }
