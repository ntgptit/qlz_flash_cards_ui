// lib/features/dashboard/presentation/widgets/recommended_modules.dart

import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/features/module/data/models/study_module_model.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/cards/qlz_card.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/labels/qlz_label.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/utils/qlz_avatar.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/utils/qlz_chip.dart';

/// A widget for displaying recommended study modules
class RecommendedModules extends StatelessWidget {
  /// List of recommended modules
  final List<StudyModule> modules;

  /// Callback when the "View All" button is pressed
  final VoidCallback? onViewAll;

  /// Callback when a module is tapped
  final Function(StudyModule)? onModuleTap;

  /// Creates a recommended modules widget
  const RecommendedModules({
    super.key,
    required this.modules,
    this.onViewAll,
    this.onModuleTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const QlzLabel('GỢI Ý HỌC PHẦN'),
              if (modules.length > 3)
                GestureDetector(
                  onTap: onViewAll,
                  child: const Row(
                    children: [
                      Text(
                        'Xem tất cả',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (modules.isEmpty) _buildEmptyState() else _buildModuleList(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return QlzCard(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 48,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chưa có gợi ý học phần',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Học càng nhiều, gợi ý càng chính xác',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleList() {
    // Display at most 3 modules
    final displayModules = modules.length > 3 ? modules.sublist(0, 3) : modules;

    return Column(
      children:
          displayModules.map((module) => _buildModuleCard(module)).toList(),
    );
  }

  Widget _buildModuleCard(StudyModule module) {
    return QlzCard(
      margin: const EdgeInsets.only(bottom: 12, left: 20, right: 20),
      padding: const EdgeInsets.all(16),
      onTap: () => onModuleTap?.call(module),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.menu_book_outlined,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  module.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    QlzAvatar(
                      name: module.creatorName,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${module.termCount} từ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    if (module.hasPlusBadge) ...[
                      const SizedBox(width: 8),
                      const QlzChip(
                        label: 'Plus',
                        type: QlzChipType.primary,
                        padding:
                            EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white54,
            size: 16,
          ),
        ],
      ),
    );
  }
}
