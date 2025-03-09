// lib/features/library/presentation/widgets/class_item.dart
import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/cards/qlz_card.dart';

import '../../data/models/class_model.dart';

class ClassItem extends StatelessWidget {
  final ClassModel classModel;
  final VoidCallback? onTap;

  const ClassItem({
    required this.classModel,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return QlzCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      backgroundColor: AppColors.darkCard,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.people_outline,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  classModel.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${classModel.studyModulesCount} học phần', // "X study modules" in Vietnamese
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}