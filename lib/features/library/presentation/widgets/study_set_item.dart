// lib/features/library/presentation/widgets/study_set_item.dart
import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/cards/qlz_card.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/utils/qlz_avatar.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/utils/qlz_chip.dart';

import '../../data/models/study_set_model.dart';

class StudySetItem extends StatelessWidget {
  final StudySet studySet;
  final VoidCallback? onTap;

  const StudySetItem({
    required this.studySet,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return QlzCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      backgroundColor: AppColors.darkCard,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            studySet.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${studySet.wordCount} 단어', // "X terms" in Korean
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              QlzAvatar(
                name: studySet.creatorName,
                size: 32,
              ),
              const SizedBox(width: 8),
              Text(
                studySet.creatorName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              if (studySet.hasPlusBadge)
                const QlzChip(
                  label: 'Plus',
                  type: QlzChipType.primary,
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
