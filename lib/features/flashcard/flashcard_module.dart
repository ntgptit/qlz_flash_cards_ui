import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/data/models/flashcard_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/repositories/flashcard_repository.dart';
import 'logic/cubit/flashcard_cubit.dart';
import 'screens/flashcard_study_mode_screen.dart';

/// Entry point for the Flashcard feature module
/// Provides screens and initializes dependencies
class FlashcardModule {
  /// Provides the flashcard study mode screen with dependency injection
  static Widget provideStudyModeScreen({
    required List<Flashcard> flashcards,
    int initialIndex = 0,
  }) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Material(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        final prefs = snapshot.data!;
        final repository = FlashcardRepository(Dio(), prefs);
        
        return RepositoryProvider.value(
          value: repository,
          child: BlocProvider(
            create: (context) => FlashcardCubit(repository)
              ..initializeFlashcards(flashcards, initialIndex),
            child: const FlashcardStudyModeView(),
          ),
        );
      },
    );
  }
}