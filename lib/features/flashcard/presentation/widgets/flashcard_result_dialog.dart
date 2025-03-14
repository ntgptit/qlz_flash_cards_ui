import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/buttons/qlz_button.dart';

class FlashcardResultDialog extends StatelessWidget {
  final int learnedCount;
  final int notLearnedCount;
  final int totalFlashcards;
  final VoidCallback? onRestart;
  final VoidCallback? onContinue;

  const FlashcardResultDialog({
    super.key,
    required this.learnedCount,
    required this.notLearnedCount,
    required this.totalFlashcards,
    this.onRestart,
    this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final completionRate = totalFlashcards > 0
        ? (learnedCount / totalFlashcards * 100).toStringAsFixed(1)
        : '0.0';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        const Text(
          "Chúc mừng! Bạn đã hoàn thành phiên học.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatColumn(
              label: "Đã thuộc",
              value: learnedCount.toString(),
              color: AppColors.success,
            ),
            _buildStatColumn(
              label: "Chưa thuộc",
              value: notLearnedCount.toString(),
              color: AppColors.warning,
            ),
            _buildStatColumn(
              label: "Hoàn thành",
              value: "$completionRate%",
              color: AppColors.primary,
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            if (onRestart != null)
              Expanded(
                child: QlzButton.secondary(
                  label: "Bắt đầu lại",
                  icon: Icons.refresh,
                  onPressed: () {
                    Navigator.pop(context);
                    onRestart!();
                  },
                ),
              ),
            if (onRestart != null && onContinue != null)
              const SizedBox(width: 16),
            if (onContinue != null)
              Expanded(
                child: QlzButton.primary(
                  label: "Tiếp tục",
                  icon: Icons.arrow_forward,
                  onPressed: () {
                    Navigator.pop(context);
                    onContinue!();
                  },
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatColumn({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
