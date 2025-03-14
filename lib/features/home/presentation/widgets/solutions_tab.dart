import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/labels/qlz_label.dart';

class SolutionsTab extends StatelessWidget {
  const SolutionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.lightbulb_outline,
            color: AppColors.warning,
            size: 48,
          ),
          const SizedBox(height: 16),
          QlzLabel(
            'Lời giải',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.darkText,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Đang phát triển tính năng giúp bạn giải đáp các bài tập',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.darkTextSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
