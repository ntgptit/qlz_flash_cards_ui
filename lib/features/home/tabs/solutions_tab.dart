// lib/features/home/tabs/solutions_tab.dart

import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/labels/qlz_label.dart';

final class SolutionsTab extends StatelessWidget {
  const SolutionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.lightbulb_outline,
            color: Colors.amber,
            size: 48,
          ),
          const SizedBox(height: 16),
          const QlzLabel(
            'Lời giải',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Đang phát triển tính năng giúp bạn giải đáp các bài tập',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
