import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/data/models/flashcard_model.dart';
import 'package:qlz_flash_cards_ui/features/quiz/data/models/quiz_settings.dart';
import 'package:qlz_flash_cards_ui/features/quiz/presentation/providers/quiz_providers.dart';
import 'package:qlz_flash_cards_ui/features/quiz/presentation/screens/quiz_screen.dart';
import 'package:qlz_flash_cards_ui/features/quiz/presentation/screens/quiz_screen_settings.dart';

/// Модуль для работы с тестированием
final class QuizModule {
  const QuizModule._();

  /// Provides the quiz settings screen with Riverpod integration
  static Widget provideRiverpodSettingsScreen({
    required String moduleId,
    required String moduleName,
    required List<Flashcard> flashcards,
  }) {
    return ProviderScope(
      overrides: const [
        // Override providers as needed
      ],
      child: QuizScreenSettings(
        moduleId: moduleId,
        moduleName: moduleName,
        flashcards: flashcards,
      ),
    );
  }

  /// Provides the quiz screen with Riverpod integration and pre-initialized state
  static Widget provideRiverpodQuizScreen({
    required Map<String, dynamic> quizData,
  }) {
    return ProviderScope(
      overrides: [
        quizProvider.overrideWith((ref) {
          // Sử dụng ref.read thay vì ref.watch để tránh dependency cycles
          final quizService = ref.read(quizServiceProvider);
          final notifier = QuizNotifier(quizService: quizService);

          // Khởi tạo trực tiếp thay vì dùng microtask để tránh lỗi timing
          notifier.initialize(
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

          return notifier;
        }),
      ],
      child: const QuizScreen(),
    );
  }

  /// Provides the quiz result screen with Riverpod integration
  static Widget provideRiverpodResultScreen({
    required String moduleId,
    required String moduleName,
    required double score,
    required int correctAnswers,
    required int totalQuestions,
    required int completionTimeInSeconds,
  }) {
    // This would be implemented similarly to the above methods,
    // creating a screen with proper provider overrides
    throw UnimplementedError('Quiz result screen not yet implemented');
  }
}
