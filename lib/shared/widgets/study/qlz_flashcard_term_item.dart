// lib/shared/widgets/study/qlz_flashcard_term_item.dart

import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/data/models/flashcard_model.dart';

final class QlzFlashcardTermItem extends StatelessWidget {
  final Flashcard flashcard;
  final VoidCallback? onToggleDifficult;
  final VoidCallback? onPlayAudio;
  final VoidCallback? onTap;
  final bool showDivider;

  const QlzFlashcardTermItem({
    super.key,
    required this.flashcard,
    this.onToggleDifficult,
    this.onPlayAudio,
    this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        flashcard.term,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        flashcard.definition,
                        style: const TextStyle(
                          color: Color.fromRGBO(255, 255, 255, 0.6),
                          fontSize: 14,
                        ),
                      ),
                      if (flashcard.example != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          flashcard.example!,
                          style: const TextStyle(
                            color: Color.fromRGBO(255, 255, 255, 0.4),
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.volume_up_outlined,
                        color: Color.fromRGBO(255, 255, 255, 0.7),
                        size: 20,
                      ),
                      onPressed: onPlayAudio,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    IconButton(
                      icon: Icon(
                        flashcard.isDifficult
                            ? Icons.star
                            : Icons.star_border_outlined,
                        color: flashcard.isDifficult
                            ? Colors.amber
                            : const Color.fromRGBO(255, 255, 255, 0.7),
                        size: 20,
                      ),
                      onPressed: onToggleDifficult,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (showDivider)
            const Divider(
              height: 1,
              color: Color.fromRGBO(255, 255, 255, 0.1),
            ),
        ],
      ),
    );
  }
}
