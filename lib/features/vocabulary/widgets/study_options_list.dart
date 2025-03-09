// // lib/features/vocabulary/widgets/study_options_list.dart

// import 'package:flutter/material.dart';
// import 'package:qlz_flash_cards_ui/core/routes/app_routes.dart';
// import 'package:qlz_flash_cards_ui/features/vocabulary/data/vocabulary.dart';
// import 'package:qlz_flash_cards_ui/shared/widgets/study/qlz_option_item.dart';

// final class StudyOptionsList extends StatelessWidget {
//   final Function(String route)? onOptionSelected;

//   const StudyOptionsList({super.key, this.onOptionSelected});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: Column(
//         children: _getStudyOptions().map((option) {
//           return QlzOptionItem(
//             label: option.label,
//             subtitle: option.subtitle,
//             icon: option.icon,
//             color: option.color,
//             onTap: () {
//               if (onOptionSelected != null) {
//                 onOptionSelected!(option.route);
//               } else {
//                 Navigator.pushNamed(context, option.route);
//               }
//             },
//           );
//         }).toList(),
//       ),
//     );
//   }

//   // Helper method to map StudyOptions to route constants
//   List<StudyOption> _getStudyOptions() {
//     return [
//       StudyOptions.flashcards.copyWith(route: AppRoutes.studyFlashcards),
//       StudyOptions.learn.copyWith(route: AppRoutes.learn),
//       StudyOptions.test.copyWith(route: AppRoutes.quizSettings),
//       StudyOptions.match.copyWith(route: AppRoutes.match),
//       StudyOptions.blast.copyWith(route: AppRoutes.blast),
//     ];
//   }
// }
