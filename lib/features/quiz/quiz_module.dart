// lib/features/quiz/quiz_module.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/data/models/flashcard_model.dart';
import 'package:qlz_flash_cards_ui/features/quiz/data/models/quiz_settings.dart';
import 'package:qlz_flash_cards_ui/features/quiz/data/services/quiz_service.dart';
import 'package:qlz_flash_cards_ui/features/quiz/logic/cubit/quiz_cubit.dart';
import 'package:qlz_flash_cards_ui/features/quiz/logic/cubit/quiz_settings_cubit.dart';
import 'package:qlz_flash_cards_ui/features/quiz/presentation/screens/quiz_screen.dart';
import 'package:qlz_flash_cards_ui/features/quiz/presentation/screens/quiz_screen_settings.dart';

/// Module quản lý tính năng quiz
final class QuizModule {
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
          create: (_) => QuizSettingsCubit()..initialize(flashcards.length),
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
  // static Widget provideRiverpodSettingsScreen({
  //   required WidgetRef ref,
  //   required String moduleId,
  //   required String moduleName,
  //   required List<Flashcard> flashcards,
  // }) {
  //   final quizSettingsCubit = ref.read(quizSettingsCubitProvider);
  //   quizSettingsCubit.initialize(flashcards.length);

  //   return BlocProvider.value(
  //     value: quizSettingsCubit,
  //     child: QuizScreenSettings(
  //       moduleId: moduleId,
  //       moduleName: moduleName,
  //       flashcards: flashcards,
  //     ),
  //   );
  // }

  /// Cung cấp màn hình quiz
  static Widget provideQuizScreen({
    required Map<String, dynamic> quizData,
  }) {
    final quizService = QuizService();
    final quizCubit = QuizCubit(quizService: quizService);

    // Khởi tạo Cubit với dữ liệu quiz
    _initializeQuizCubit(quizCubit, quizData);

    return BlocProvider<QuizCubit>(
      create: (context) => quizCubit,
      child: const QuizScreen(),
    );
  }

  /// Cung cấp màn hình quiz với Riverpod
  // static Widget provideRiverpodQuizScreen({
  //   required WidgetRef ref,
  //   required Map<String, dynamic> quizData,
  // }) {
  //   final quizCubit = ref.read(quizCubitProvider);

  //   // Khởi tạo Cubit với dữ liệu quiz
  //   _initializeQuizCubit(quizCubit, quizData);

  //   return BlocProvider.value(
  //     value: quizCubit,
  //     child: const QuizScreen(),
  //   );
  // }

  // Helper method để khởi tạo QuizCubit, giảm code trùng lặp
  static void _initializeQuizCubit(
      QuizCubit quizCubit, Map<String, dynamic> quizData) {
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
  }
}
