import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/features/vocabulary/data/flashcard.dart';

class FlashcardContent extends StatelessWidget {
  final Flashcard flashcard;

  const FlashcardContent({super.key, required this.flashcard});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(flashcard.definition,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            if (flashcard.audioUrl != null)
              IconButton(
                icon: const Icon(Icons.volume_up),
                onPressed: () {},
              ),
          ],
        ),
      ),
    );
  }
}
