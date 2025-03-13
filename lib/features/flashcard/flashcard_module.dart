import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qlz_flash_cards_ui/core/providers/app_providers.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/data/models/flashcard_model.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/data/repositories/flashcard_repository.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/logic/cubit/flashcard_cubit.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/screens/flashcard_study_mode_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Factory class to provide flashcard screens and BLoC providers
class FlashcardModule {
  /// Provides a standalone study mode screen without Riverpod
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
              ..initializeFlashcards(
                  flashcards,
                  initialIndex.clamp(
                      0, flashcards.isEmpty ? 0 : flashcards.length - 1)),
            child: const FlashcardStudyModeView(),
          ),
        );
      },
    );
  }

  /// Provides a study mode screen using Riverpod for dependency injection
  static Widget provideRiverpodStudyModeScreen({
    required WidgetRef ref,
    required List<Flashcard> flashcards,
    int initialIndex = 0,
  }) {
    // Get repository from Riverpod
    final repository = ref.read(flashcardRepositoryProvider);

    // Create cubit with proper initialization
    final flashcardCubit = FlashcardCubit(repository)
      ..initializeFlashcards(
          flashcards,
          initialIndex.clamp(
              0, flashcards.isEmpty ? 0 : flashcards.length - 1));

    // Provide repository and cubit to widget tree
    return RepositoryProvider.value(
      value: repository,
      child: BlocProvider.value(
        value: flashcardCubit,
        child: const FlashcardStudyModeView(),
      ),
    );
  }

  /// Wraps any widget with flashcard providers
  static Widget wrapWithFlashcardProviders({
    required Widget child,
    required WidgetRef ref,
    required List<Flashcard> flashcards,
    int initialIndex = 0,
  }) {
    final repository = ref.read(flashcardRepositoryProvider);
    final flashcardCubit = FlashcardCubit(repository)
      ..initializeFlashcards(
          flashcards,
          initialIndex.clamp(
              0, flashcards.isEmpty ? 0 : flashcards.length - 1));

    return MultiBlocProvider(
      providers: [
        RepositoryProvider<FlashcardRepository>.value(value: repository),
        BlocProvider<FlashcardCubit>.value(value: flashcardCubit),
      ],
      child: child,
    );
  }
}
