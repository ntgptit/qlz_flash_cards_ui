// lib/shared/widgets/study/qlz_progress_status_card.dart

import 'package:flutter/material.dart';

enum ProgressStatus {
  notStudied,
  learning,
  mastered,
}

final class QlzProgressStatusCard extends StatelessWidget {
  final ProgressStatus status;
  final int count;
  final VoidCallback? onTap;
  final bool showArrow;

  const QlzProgressStatusCard({
    super.key,
    required this.status,
    required this.count,
    this.onTap,
    this.showArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    // Xác định các thuộc tính dựa trên status
    final (label, color) = switch (status) {
      ProgressStatus.notStudied => ('Chưa học', Colors.blue),
      ProgressStatus.learning => ('Đang học', Colors.orange),
      ProgressStatus.mastered => ('Thành thạo', Colors.green),
    };

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: color,
                  width: 3,
                ),
              ),
              child: Center(
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            if (showArrow && onTap != null) ...[
              const Spacer(),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
