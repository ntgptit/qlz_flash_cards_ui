// lib/features/quiz/quiz_module.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qlz_flash_cards_ui/core/providers/app_providers.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/data/models/flashcard_model.dart';
import 'package:qlz_flash_cards_ui/features/quiz/data/models/quiz_settings.dart';
import 'package:qlz_flash_cards_ui/features/quiz/logic/cubit/quiz_cubit.dart';
import 'package:qlz_flash_cards_ui/features/quiz/logic/cubit/quiz_settings_cubit.dart';
import 'package:qlz_flash_cards_ui/features/quiz/presentation/screens/quiz_screen.dart';
import 'package:qlz_flash_cards_ui/features/quiz/presentation/screens/quiz_screen_settings.dart';

/// Module quản lý tính năng quiz
class QuizModule {
  const QuizModule._();

  /// Cung cấp màn hình thiết lập quiz
  static Widget provideSettingsScreen({
    required String moduleId,
    required String moduleName,
    required List<Flashcard> flashcards,
  }) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<QuizSettingsCubit>(
          create: (_) => QuizSettingsCubit(),
        ),
      ],
      child: QuizScreenSettings(
        moduleId: moduleId,
        moduleName: moduleName,
        flashcards: flashcards,
      ),
    );
  }

  /// Cung cấp màn hình thiết lập quiz với Riverpod
  static Widget provideRiverpodSettingsScreen({
    required WidgetRef ref,
    required String moduleId,
    required String moduleName,
    required List<Flashcard> flashcards,
  }) {
    final quizSettingsCubit = ref.read(quizSettingsCubitProvider);

    return BlocProvider.value(
      value: quizSettingsCubit,
      child: QuizScreenSettings(
        moduleId: moduleId,
        moduleName: moduleName,
        flashcards: flashcards,
      ),
    );
  }

  /// Cung cấp màn hình quiz
  static Widget provideQuizScreen({
    required Map<String, dynamic> quizData,
  }) {
    final quizType = quizData['quizType'] as QuizType;
    final difficulty = quizData['difficulty'] as QuizDifficulty;
    final flashcards = quizData['flashcards'] as List<Flashcard>;
    final moduleId = quizData['moduleId'] as String;
    final moduleName = quizData['moduleName'] as String;
    final questionCount = quizData['questionCount'] as int;
    final shuffleQuestions = quizData['shuffleQuestions'] as bool;
    final showCorrectAnswers = quizData['showCorrectAnswers'] as bool;
    final enableTimer = quizData['enableTimer'] as bool;
    final timePerQuestion = quizData['timePerQuestion'] as int;

    return BlocProvider<QuizCubit>(
      create: (context) => QuizCubit(
        quizType: quizType,
        difficulty: difficulty,
        flashcards: flashcards,
        moduleId: moduleId,
        moduleName: moduleName,
        questionCount: questionCount,
        shuffleQuestions: shuffleQuestions,
        showCorrectAnswers: showCorrectAnswers,
        enableTimer: enableTimer,
        timePerQuestion: timePerQuestion,
      ),
      child: const QuizScreen(),
    );
  }

  /// Cung cấp màn hình quiz với Riverpod
  static Widget provideRiverpodQuizScreen({
    required WidgetRef ref,
    required Map<String, dynamic> quizData,
  }) {
    final quizCubit = ref.read(quizCubitProvider);

    // Khởi tạo Cubit với dữ liệu quiz
    quizCubit.initialize(
      quizType: quizData['quizType'] as QuizType,
      difficulty: quizData['difficulty'] as QuizDifficulty,
      flashcards: quizData['flashcards'] as List<Flashcard>,
      moduleId: quizData['moduleId'] as String,
      moduleName: quizData['moduleName'] as String,
      questionCount: quizData['questionCount'] as int,
      shuffleQuestions: quizData['shuffleQuestions'] as bool,
      showCorrectAnswers: quizData['showCorrectAnswers'] as bool,
      enableTimer: quizData['enableTimer'] as bool,
      timePerQuestion: quizData['timePerQuestion'] as int,
    );

    return BlocProvider.value(
      value: quizCubit,
      child: const QuizScreen(),
    );
  }
}
