// // lib/features/vocabulary/widgets/module_user_info.dart

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:qlz_flash_cards_ui/features/vocabulary/cubit/vocabulary_cubit.dart';
// import 'package:qlz_flash_cards_ui/features/vocabulary/cubit/vocabulary_state.dart';
// import 'package:qlz_flash_cards_ui/shared/widgets/cards/qlz_card.dart';
// import 'package:qlz_flash_cards_ui/shared/widgets/utils/qlz_avatar.dart';
// import 'package:qlz_flash_cards_ui/shared/widgets/utils/qlz_chip.dart';

// final class ModuleUserInfo extends StatelessWidget {
//   final String? username;
//   final String? avatarUrl;
//   final bool isPremium;
//   final int termCount;

//   const ModuleUserInfo({
//     super.key,
//     this.username = 'giapnguyen1994',
//     this.avatarUrl,
//     this.isPremium = true,
//     this.termCount = 0,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<VocabularyCubit, VocabularyState>(
//       builder: (context, state) {
//         final actualTermCount = state.flashcards.length;

//         return Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20),
//           child: QlzCard(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             child: Row(
//               children: [
//                 QlzAvatar(
//                   size: 32,
//                   assetPath: avatarUrl ?? 'assets/images/user_avatar.jpg',
//                   name: username, // Fallback to initials if image not available
//                 ),
//                 const SizedBox(width: 12),
//                 Text(
//                   username ?? 'Người dùng',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 if (isPremium)
//                   const QlzChip(
//                     label: 'Plus',
//                     type: QlzChipType.primary,
//                     padding: EdgeInsets.symmetric(
//                       horizontal: 8,
//                       vertical: 2,
//                     ),
//                   ),
//                 const Spacer(),
//                 QlzChip(
//                   label: '$actualTermCount thuật ngữ',
//                   type: QlzChipType.ghost,
//                   icon: Icons.style_outlined,
//                   textColor: const Color.fromRGBO(255, 255, 255, 0.6),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
