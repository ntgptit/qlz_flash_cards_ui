import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qlz_flash_cards_ui/core/managers/cubit_manager.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/data/models/flashcard_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/repositories/flashcard_repository.dart';
import 'logic/cubit/flashcard_cubit.dart';
import 'screens/flashcard_study_mode_screen.dart';

/// Entry point for the Flashcard feature module
/// Provides screens and initializes dependencies
class FlashcardModule {
  //-------------------------------------------------------------------------
  // CURRENT METHODS (FOR BACKWARD COMPATIBILITY)
  //-------------------------------------------------------------------------

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

  //-------------------------------------------------------------------------
  // RIVERPOD METHODS
  //-------------------------------------------------------------------------

  /// Provides the flashcard study mode screen using Riverpod
  ///
  /// Uses Riverpod for dependency management instead of creating new instances
  static Widget provideRiverpodStudyModeScreen({
    required WidgetRef ref,
    required List<Flashcard> flashcards,
    int initialIndex = 0,
  }) {
    // Get repository from Riverpod provider
    final repository = ref.read(flashcardRepositoryProvider);

    // Create a new FlashcardCubit with initializeFlashcards
    // Note: We're creating a new cubit here instead of using an existing provider
    // because this cubit is specific to the flashcards passed in
    final flashcardCubit = FlashcardCubit(repository)
      ..initializeFlashcards(flashcards, initialIndex);

    return RepositoryProvider.value(
      value: repository,
      child: BlocProvider.value(
        value: flashcardCubit,
        child: const FlashcardStudyModeView(),
      ),
    );
  }

  //-------------------------------------------------------------------------
  // HELPER METHODS
  //-------------------------------------------------------------------------

  /// Utility method to wrap a widget with flashcard providers
  ///
  /// Returns a widget wrapped with FlashcardRepository and FlashcardCubit
  static Widget wrapWithFlashcardProviders({
    required Widget child,
    required WidgetRef ref,
    required List<Flashcard> flashcards,
    int initialIndex = 0,
  }) {
    final repository = ref.read(flashcardRepositoryProvider);
    final flashcardCubit = FlashcardCubit(repository)
      ..initializeFlashcards(flashcards, initialIndex);

    return MultiBlocProvider(
      providers: [
        RepositoryProvider<FlashcardRepository>.value(value: repository),
        BlocProvider<FlashcardCubit>.value(value: flashcardCubit),
      ],
      child: child,
    );
  }
}
