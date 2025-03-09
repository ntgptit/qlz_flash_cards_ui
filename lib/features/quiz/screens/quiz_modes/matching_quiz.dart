// lib/features/quiz/screens/quiz_modes/matching_quiz.dart

import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/features/quiz/models/quiz_question.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/cards/qlz_card.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/study/qlz_matching_game.dart';

/// Màn hình quiz nối cặp
class MatchingQuizScreen extends StatelessWidget {
  final MatchingQuestion question;
  final Function(Duration, int, int) onMatchingComplete;
  final bool isCompleted;
  final Duration? matchingCompletionTime;
  final int correctMatches;

  const MatchingQuizScreen({
    super.key,
    required this.question,
    required this.onMatchingComplete,
    this.isCompleted = false,
    this.matchingCompletionTime,
    this.correctMatches = 0,
  });

  @override
  Widget build(BuildContext context) {
    // Tạo các cặp nối từ danh sách flashcards
    final pairs = question.flashcards
        .map((card) => MatchingPair(
            term: card.term, definition: card.definition, id: card.id))
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: QlzCard(
            backgroundColor: AppColors.darkCard,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Nối mỗi thuật ngữ với định nghĩa đúng của nó. Nhấp vào một thuật ngữ, sau đó nhấp vào định nghĩa tương ứng.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: QlzMatchingGame(
            pairs: pairs,
            onGameComplete: onMatchingComplete,
            showTimer: true,
            shuffleDefinitions: true,
          ),
        ),
      ],
    );
  }
}
