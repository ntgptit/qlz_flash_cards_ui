// lib/features/flashcard/flashcard_module.dart

import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/data/models/flashcard_model.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/presentation/screens/flashcard_study_mode_screen.dart';

/// Quản lý các màn hình và components liên quan đến flashcard
class FlashcardModule {
  const FlashcardModule._();

  /// Cung cấp màn hình học flashcard
  static Widget provideStudyModeScreen({
    required List<Flashcard> flashcards,
    int initialIndex = 0,
  }) {
    // Đảm bảo chỉ có một ProviderScope tại thời điểm này
    return FlashcardStudyModeScreen(
      flashcards: flashcards,
      initialIndex: initialIndex,
    );
  }
}
