import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/data/models/flashcard_model.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/presentation/screens/flashcard_study_mode_screen.dart';

class FlashcardModule {
  static Widget provideStudyModeScreen({
    required List<Flashcard> flashcards,
    int initialIndex = 0,
  }) {
    return FlashcardStudyModeScreen(
      flashcards: flashcards,
      initialIndex: initialIndex,
    );
  }
}
