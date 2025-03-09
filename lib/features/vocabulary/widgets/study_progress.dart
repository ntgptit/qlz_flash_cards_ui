// // lib/features/vocabulary/widgets/study_progress.dart

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:qlz_flash_cards_ui/features/vocabulary/cubit/vocabulary_cubit.dart';
// import 'package:qlz_flash_cards_ui/features/vocabulary/cubit/vocabulary_state.dart';
// import 'package:qlz_flash_cards_ui/shared/widgets/cards/qlz_card.dart';
// import 'package:qlz_flash_cards_ui/shared/widgets/cards/qlz_progress_status_card.dart';
// import 'package:qlz_flash_cards_ui/shared/widgets/header/qlz_section_header.dart';

// final class StudyProgress extends StatelessWidget {
//   const StudyProgress({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<VocabularyCubit, VocabularyState>(
//       builder: (context, state) {
//         // Tính toán số lượng từ trong các trạng thái khác nhau
//         // Trong thực tế, bạn nên lấy chúng từ state hoặc repository
//         final notStudiedCount = state.flashcards.length;
//         const learningCount = 0;
//         const masteredCount = 0;

//         return Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const QlzSectionHeader(
//                 title: 'Tiến độ của bạn',
//                 subtitle:
//                     'Tiến độ của bạn dựa trên hai lần cuối cùng bạn học mỗi thuật ngữ ở tất cả các chế độ, ngoại trừ trò chơi.',
//               ),
//               const SizedBox(height: 16),
//               QlzCard(
//                 backgroundColor: const Color(0xFF12113A),
//                 padding: EdgeInsets.zero,
//                 hasBorder: false,
//                 child: Column(
//                   children: [
//                     QlzProgressStatusCard(
//                       status: ProgressStatus.notStudied,
//                       count: notStudiedCount,
//                       onTap: () {
//                         // TODO: Navigate to not studied terms
//                       },
//                       showArrow: true,
//                     ),
//                     const Divider(
//                       height: 1,
//                       color: Color.fromRGBO(255, 255, 255, 0.1),
//                     ),
//                     QlzProgressStatusCard(
//                       status: ProgressStatus.learning,
//                       count: learningCount,
//                       onTap: learningCount > 0
//                           ? () {
//                               // TODO: Navigate to learning terms
//                             }
//                           : null,
//                     ),
//                     const Divider(
//                       height: 1,
//                       color: Color.fromRGBO(255, 255, 255, 0.1),
//                     ),
//                     QlzProgressStatusCard(
//                       status: ProgressStatus.mastered,
//                       count: masteredCount,
//                       onTap: masteredCount > 0
//                           ? () {
//                               // TODO: Navigate to mastered terms
//                             }
//                           : null,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
