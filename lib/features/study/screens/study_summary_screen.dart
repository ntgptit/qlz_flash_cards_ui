import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/data/models/flashcard_model.dart';

class StudySummaryScreen extends StatelessWidget {
  final List<Flashcard> recentlyStudiedFlashcards;
  final int correctAnswers;
  final VoidCallback onContinue;

  const StudySummaryScreen({
    super.key,
    required this.recentlyStudiedFlashcards,
    required this.correctAnswers,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final successRate = recentlyStudiedFlashcards.isEmpty
        ? 0.0
        : correctAnswers / recentlyStudiedFlashcards.length;
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Good job, you’re making progress!',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            LinearProgressIndicator(
              value: successRate,
              minHeight: 12,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                  _getSuccessRateColor(successRate)),
            ),
            const SizedBox(height: 24),
            const Text('Recently studied terms', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: recentlyStudiedFlashcards.length,
                itemBuilder: (context, index) {
                  final flashcard = recentlyStudiedFlashcards[index];
                  return Card(
                    child: ListTile(
                      title: Text(flashcard.term),
                      subtitle: Text(flashcard.definition),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: onContinue,
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSuccessRateColor(double rate) {
    if (rate >= 0.8) return Colors.green;
    if (rate >= 0.6) return Colors.blue;
    if (rate >= 0.4) return Colors.orange;
    return Colors.red;
  }
}
