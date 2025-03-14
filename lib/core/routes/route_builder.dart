// lib/core/routes/route_builder.dart

import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/core/routes/app_routes.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/flashcard_module.dart';
import 'package:qlz_flash_cards_ui/features/library/library_module.dart';
import 'package:qlz_flash_cards_ui/features/module/module_module.dart';

import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/study/screens/study_settings_screen.dart';
import '../../features/welcome_screen.dart';
import 'route_logger.dart';
import 'route_params.dart';

/// Xây dựng các màn hình dựa trên route settings.
class RouteBuilder {
  static final Map<String, Widget Function(RouteParams)> _routeBuilders = {
    AppRoutes.welcome: (_) => const WelcomeScreen(),

    // Auth routes with Riverpod
    AppRoutes.login: (_) => const LoginScreen(),

    AppRoutes.register: (_) => const RegisterScreen(),

    AppRoutes.forgotPassword: (_) => const ForgotPasswordScreen(),

    // Main routes
    AppRoutes.home: (_) => const HomeScreen(),

    // Library routes that use module pattern
    AppRoutes.library: (_) => LibraryModule.provideRiverpodScreen(),

    AppRoutes.folderDetail: (params) {
      final folderName = params.getString('folderName', 'Unknown');
      final folderId = params.getString('folderId');
      return LibraryModule.provideRiverpodFolderDetailScreen(
        folderName: folderName,
        folderId: folderId,
      );
    },

    AppRoutes.classDetail: (params) {
      final classId = params.getString('classId');
      final className = params.getString('className', 'Unknown');
      return LibraryModule.provideRiverpodClassDetailScreen(
        classId: classId,
        className: className,
      );
    },

    AppRoutes.listStudyModuleOfFolder: (params) {
      final folderName = params.getString('folderName', 'Unknown');
      final folderId = params.getString('folderId');
      return ModuleModule.provideListScreen(
        folderName: folderName,
        folderId: folderId,
      );
    },

    AppRoutes.moduleDetail: (params) {
      final moduleId = params.getString('moduleId', '');
      final moduleName = params.getString('moduleName', 'Module');
      return ModuleModule.provideDetailScreen(
        moduleId: moduleId,
        moduleName: moduleName,
      );
    },

    AppRoutes.studyFlashcards: (params) {
      final flashcards = params.getFlashcards('flashcards');
      final initialIndex = params.getInt('initialIndex', 0);
      final validInitialIndex =
          flashcards.isEmpty ? 0 : initialIndex.clamp(0, flashcards.length - 1);

      return FlashcardModule.provideStudyModeScreen(
        flashcards: flashcards,
        initialIndex: validInitialIndex,
      );
    },

    // AppRoutes.quizSettings: (params) {
    //   final moduleId = params.getString('moduleId', '');
    //   final moduleName = params.getString('moduleName', 'Bài kiểm tra');
    //   final flashcards = params.getFlashcards('flashcards');

    //   return QuizModule.provideRiverpodSettingsScreen(
    //     moduleId: moduleId,
    //     moduleName: moduleName,
    //     flashcards: flashcards,
    //   );
    // },

    // AppRoutes.quiz: (params) {
    //   final quizData = {
    //     'quizType':
    //         params.getEnum('quizType', QuizType.values, QuizType.values.first),
    //     'difficulty': params.getEnum(
    //         'difficulty', QuizDifficulty.values, QuizDifficulty.values.first),
    //     'flashcards': params.getFlashcards('flashcards'),
    //     'moduleId': params.getString('moduleId', ''),
    //     'moduleName': params.getString('moduleName', ''),
    //     'questionCount': params.getInt('questionCount', 10),
    //     'shuffleQuestions': params.getBool('shuffleQuestions', true),
    //     'showCorrectAnswers': params.getBool('showCorrectAnswers', true),
    //     'enableTimer': params.getBool('enableTimer', false),
    //     'timePerQuestion': params.getInt('timePerQuestion', 30),
    //   };

    //   return QuizModule.provideRiverpodQuizScreen(
    //     quizData: quizData,
    //   );
    // },

    AppRoutes.profile: (_) => const ProfileScreen(),

    AppRoutes.createStudyModule: (_) => ModuleModule.provideCreateScreen(),

    AppRoutes.moduleSettings: (params) {
      final moduleId = params.getString('moduleId', 'new');
      return ModuleModule.provideSettingsScreen(
        moduleId: moduleId,
      );
    },

    AppRoutes.createFolder: (_) =>
        LibraryModule.provideRiverpodCreateFolderScreen(),

    AppRoutes.createClass: (_) =>
        LibraryModule.provideRiverpodCreateClassScreen(),

    AppRoutes.learn: (params) {
      final flashcards = params.getFlashcards('flashcards');
      final moduleName = params.getString('moduleName', 'Học phần');
      final moduleId = params.getString('moduleId');

      return StudySettingsScreen(
        flashcards: flashcards,
        moduleName: moduleName,
        moduleId: moduleId,
      );
    },

    // Placeholder routes
    AppRoutes.test: (params) => _buildPlaceholderScreen('Test Route', params),
    AppRoutes.match: (params) => _buildPlaceholderScreen('Match Route', params),
    AppRoutes.blast: (params) => _buildPlaceholderScreen('Blast Route', params),
  };

  static Route<dynamic> buildRoute(RouteSettings settings) {
    RouteLogger.logNavigation(settings);
    final params = RouteParams.fromSettings(settings);
    final builder = _routeBuilders[settings.name] ?? _errorScreenBuilder;

    try {
      // Không bọc toàn bộ builder trong ProviderScope nữa
      // vì các module riêng lẻ đã có ProviderScope của riêng chúng
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => builder(params),
      );
    } catch (e, stackTrace) {
      RouteLogger.logError(settings.name, e, stackTrace);
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => _buildErrorScreen('${settings.name} (Error: $e)'),
      );
    }
  }

  static Widget _buildPlaceholderScreen(String title, RouteParams params) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction, size: 64, color: Colors.amber),
            const SizedBox(height: 16),
            const Text('Tính năng này đang được phát triển',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Chức năng: $title'),
            if (params.params.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                  'Thông số: ${params.params.entries.map((e) => '${e.key}: ${e.value}').join(', ')}'),
            ],
          ],
        ),
      ),
    );
  }

  static Widget _buildErrorScreen(String routeName) {
    return Scaffold(
      appBar:
          AppBar(title: const Text('Route Error'), backgroundColor: Colors.red),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            Text('Không tìm thấy route "$routeName"',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Vui lòng kiểm tra lại cấu hình navigation.'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.canPop(RouteLogger.context)
                  ? Navigator.pop(RouteLogger.context)
                  : null,
              child: const Text('Quay lại'),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _errorScreenBuilder(RouteParams _) =>
      _buildErrorScreen('Unknown Route');
}
