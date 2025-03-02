// lib/core/routes/app_routes.dart

import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/features/auth/screens/forgot_password_screen.dart';
import 'package:qlz_flash_cards_ui/features/auth/screens/login_screen.dart';
import 'package:qlz_flash_cards_ui/features/auth/screens/register_screen.dart';
import 'package:qlz_flash_cards_ui/features/class/create_class_screen.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/screens/flashcard_study_mode_screen.dart';
import 'package:qlz_flash_cards_ui/features/folder/screens/create_folder_screen.dart';
import 'package:qlz_flash_cards_ui/features/home/home_screen.dart';
import 'package:qlz_flash_cards_ui/features/library/library_screen.dart';
import 'package:qlz_flash_cards_ui/features/module/screens/create_study_module_screen.dart';
import 'package:qlz_flash_cards_ui/features/module/screens/list_study_module_of_folder_screen.dart';
import 'package:qlz_flash_cards_ui/features/module/screens/module_detail_screen.dart';
import 'package:qlz_flash_cards_ui/features/module/screens/module_settings_screen.dart';
import 'package:qlz_flash_cards_ui/features/profile/profile_screen.dart';
import 'package:qlz_flash_cards_ui/features/quiz/quiz_screen.dart';
import 'package:qlz_flash_cards_ui/features/study/study_screen.dart';
import 'package:qlz_flash_cards_ui/features/study/study_settings_screen.dart';
import 'package:qlz_flash_cards_ui/features/vocabulary/data/flashcard.dart';
import 'package:qlz_flash_cards_ui/features/welcome_screen.dart';

/// Routes for the application
sealed class AppRoutes {
  const AppRoutes._();

  // Route names as constants
  static const String welcome = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String library = '/library';
  static const String folderDetail = '/folder-detail';
  static const String listStudyModuleOfFolder = '/list-study-module-of-folder';
  static const String moduleDetail = '/module-detail';
  static const String studyFlashcards = '/study-flashcards';
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

  /// Generate route based on settings
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final arguments = settings.arguments as Map<String, dynamic>?;

    return MaterialPageRoute(
      settings: settings,
      builder: (context) => switch (settings.name) {
        welcome => const WelcomeScreen(),
        login => const LoginScreen(),
        register => const RegisterScreen(),
        forgotPassword => const ForgotPasswordScreen(),
        home => const HomeScreen(),
        library => const LibraryScreen(),
        folderDetail =>
          const ListStudyModuleOfFolderScreen(folderName: 'Unknown'),
        moduleDetail => const ModuleDetailScreen(),
        studyFlashcards => _buildFlashcardStudyModeScreen(arguments),
        learn => _buildStudySettingsScreen(arguments),
        quiz => const QuizScreen(),
        profile => const ProfileScreen(),
        createStudyModule => const CreateStudyModuleScreen(),
        moduleSettings => const ModuleSettingsScreen(),
        createFolder => const CreateFolderScreen(),
        createClass => const CreateClassScreen(),
        listStudyModuleOfFolder =>
          const ListStudyModuleOfFolderScreen(folderName: 'Unknown'),
        // Các route khác cho các tùy chọn học tập còn lại
        test => _buildPlaceholderScreen("Test Route"),
        match => _buildPlaceholderScreen("Match Route"),
        blast => _buildPlaceholderScreen("Blast Route"),
        _ => _buildErrorScreen(settings.name),
      },
    );
  }

  /// Build FlashcardStudyModeScreen with arguments
  static Widget _buildFlashcardStudyModeScreen(
      Map<String, dynamic>? arguments) {
    if (arguments == null) {
      return _buildErrorScreen("studyFlashcards (missing arguments)");
    }

    final flashcards = arguments['flashcards'] as List<Flashcard>?;
    final initialIndex = arguments['initialIndex'] as int? ?? 0;

    if (flashcards == null) {
      return _buildErrorScreen("studyFlashcards (missing flashcards)");
    }

    return FlashcardStudyModeScreen(
      flashcards: flashcards,
      initialIndex: initialIndex,
    );
  }

  /// Build StudySettingsScreen with arguments
  static Widget _buildStudySettingsScreen(Map<String, dynamic>? arguments) {
    if (arguments == null) {
      return _buildErrorScreen("learn (missing arguments)");
    }

    final flashcards = arguments['flashcards'] as List<Flashcard>?;
    final moduleName = arguments['moduleName'] as String? ?? 'Học phần';
    final moduleId = arguments['moduleId'] as String?;

    if (flashcards == null) {
      return _buildErrorScreen("learn (missing flashcards)");
    }

    return StudySettingsScreen(
      flashcards: flashcards,
      moduleName: moduleName,
      moduleId: moduleId,
    );
  }

  /// Build placeholder screen for routes that are not yet implemented
  static Widget _buildPlaceholderScreen(String title) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const Center(
        child: Text(
          'Tính năng này đang được phát triển',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  /// Build error screen for undefined routes
  static Widget _buildErrorScreen(String? routeName) {
    return Scaffold(
      body: Center(
        child: Text(
          'No route defined for $routeName',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}
