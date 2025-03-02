import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/utils/qlz_avatar.dart';

final class StudySetItem extends StatelessWidget {
  final String title;
  final int wordCount;
  final String creatorName;
  final bool hasPlusBadge;
  final VoidCallback? onTap;

  const StudySetItem({
    required this.title,
    required this.wordCount,
    required this.creatorName,
    required this.hasPlusBadge,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF12113A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // Word count
            Text(
              '$wordCount 단어', // "X terms" in Korean
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 12),

            // Creator info row
            Row(
              children: [
                // Creator avatar
                QlzAvatar(
                  name: creatorName,
                  size: 32,
                  imageUrl: 'assets/images/user_avatar.jpg',
                ),

                const SizedBox(width: 8),

                // Creator name
                Text(
                  creatorName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 5),
                // const Spacer(),

                // Plus badge
                if (hasPlusBadge)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1D3D),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: const Text(
                      'Plus',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
