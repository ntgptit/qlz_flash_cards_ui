import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/data/models/flashcard_model.dart';
import 'package:qlz_flash_cards_ui/features/module/module_module.dart';

import 'route_builder.dart';
import 'route_params.dart';

/// Quản lý các route trong ứng dụng.
class AppRoutes {
  const AppRoutes._();

  // Route names
  static const String welcome = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String library = '/library';
  static const String folderDetail = '/folder-detail';
  static const String classDetail = '/class-detail';
  static const String listStudyModuleOfFolder = '/list-study-module-of-folder';
  static const String moduleDetail = '/module-detail';
  static const String studyFlashcards = '/study-flashcards';
  static const String quizSettings = '/quiz-settings';
  static const String quiz = '/quiz';
  static const String profile = '/profile';
  static const String createStudyModule = '/create-study-module';
  static const String moduleSettings = '/module-settings';
  static const String createFolder = '/create-folder';
  static const String createClass = '/create-class';
  static const String learn = '/learn';
  static const String test = '/test';
  static const String match = '/match';
  static const String blast = '/blast';

  /// Tạo route dựa trên settings.
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return RouteBuilder.buildRoute(settings);
  }

  // Type-safe navigation methods
  static Future<dynamic> navigateToQuizSettings(
    BuildContext context, {
    required String moduleId,
    required String moduleName,
    required List flashcards,
  }) {
    return Navigator.pushNamed(
      context,
      quizSettings,
      arguments: RouteParams(
        routeName: quizSettings,
        params: {
          'moduleId': moduleId,
          'moduleName': moduleName,
          'flashcards': flashcards,
        },
      ).toMap(),
    );
  }

  static Future<dynamic> navigateToStudyFlashcards(
    BuildContext context, {
    required List<Flashcard> flashcards,
    int initialIndex = 0,
  }) {
    // Validate initialIndex trước khi tạo route
    final validInitialIndex =
        flashcards.isEmpty ? 0 : initialIndex.clamp(0, flashcards.length - 1);

    return Navigator.pushNamed(
      context,
      studyFlashcards,
      arguments: RouteParams(
        routeName: studyFlashcards,
        params: {
          'flashcards': flashcards,
          'initialIndex': validInitialIndex,
        },
      ).toMap(),
    );
  }

  static Future<dynamic> navigateToLearn(
    BuildContext context, {
    required List flashcards,
    required String moduleName,
    String? moduleId,
  }) {
    return Navigator.pushNamed(
      context,
      learn,
      arguments: RouteParams(
        routeName: learn,
        params: {
          'flashcards': flashcards,
          'moduleName': moduleName,
          'moduleId': moduleId,
        },
      ).toMap(),
    );
  }

  static Future<dynamic> navigateToModuleList(
    BuildContext context, {
    required String folderName,
    String? folderId,
  }) {
    return Navigator.pushNamed(
      context,
      listStudyModuleOfFolder,
      arguments: RouteParams(
        routeName: listStudyModuleOfFolder,
        params: {
          'folderName': folderName,
          'folderId': folderId,
        },
      ).toMap(),
    );
  }

  static Future<dynamic> navigateToModuleDetail(
    BuildContext context, {
    required String moduleId,
    required String moduleName,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ModuleModule.provideDetailScreen(
          moduleId: moduleId,
          moduleName: moduleName,
        ),
      ),
    );
  }

  static Future<dynamic> navigateToQuiz(
    BuildContext context, {
    required int quizTypeIndex,
    required int difficultyIndex,
    required List flashcards,
    required String moduleId,
    required String moduleName,
    int questionCount = 10,
    bool shuffleQuestions = true,
    bool showCorrectAnswers = true,
    bool enableTimer = false,
    int timePerQuestion = 30,
  }) {
    return Navigator.pushNamed(
      context,
      quiz,
      arguments: RouteParams(
        routeName: quiz,
        params: {
          'quizType': quizTypeIndex,
          'difficulty': difficultyIndex,
          'flashcards': flashcards,
          'moduleId': moduleId,
          'moduleName': moduleName,
          'questionCount': questionCount,
          'shuffleQuestions': shuffleQuestions,
          'showCorrectAnswers': showCorrectAnswers,
          'enableTimer': enableTimer,
          'timePerQuestion': timePerQuestion,
        },
      ).toMap(),
    );
  }

  static Future<dynamic> navigateToFolderDetail(
    BuildContext context, {
    required String folderName,
    String? folderId,
  }) {
    return Navigator.pushNamed(
      context,
      folderDetail,
      arguments: RouteParams(
        routeName: folderDetail,
        params: {
          'folderName': folderName,
          'folderId': folderId,
        },
      ).toMap(),
    );
  }

  static Future<dynamic> navigateToClassDetail(
    BuildContext context, {
    required String classId,
    required String className,
  }) {
    return Navigator.pushNamed(
      context,
      classDetail,
      arguments: RouteParams(
        routeName: classDetail,
        params: {
          'classId': classId,
          'className': className,
        },
      ).toMap(),
    );
  }
}
