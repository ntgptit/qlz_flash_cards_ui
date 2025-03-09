import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/core/routes/app_routes.dart';
import 'route_params.dart';
import 'route_logger.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/class/create_class_screen.dart';
import '../../features/flashcard/screens/flashcard_study_mode_screen.dart';
import '../../features/folder/screens/create_folder_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/library/library_screen.dart';
import '../../features/module/screens/create_study_module_screen.dart';
import '../../features/module/screens/list_study_module_of_folder_screen.dart';
import '../../features/module/screens/module_detail_screen.dart';
import '../../features/module/screens/module_settings_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/quiz/models/quiz_settings.dart';
import '../../features/quiz/screens/quiz_screen.dart';
import '../../features/quiz/screens/quiz_screen_settings.dart';
import '../../features/study/screens/study_settings_screen.dart';
import '../../features/welcome_screen.dart';

/// Xây dựng các màn hình dựa trên route settings.
class RouteBuilder {
  static final Map<String, Widget Function(RouteParams)> _routeBuilders = {
    AppRoutes.welcome: (_) => const WelcomeScreen(),
    AppRoutes.login: (_) => const LoginScreen(),
    AppRoutes.register: (_) => const RegisterScreen(),
    AppRoutes.forgotPassword: (_) => const ForgotPasswordScreen(),
    AppRoutes.home: (_) => const HomeScreen(),
    AppRoutes.library: (_) => const LibraryScreen(),
    AppRoutes.folderDetail: (params) => ListStudyModuleOfFolderScreen(
          folderName: params.getString('folderName', 'Unknown'),
          folderId: params.getString('folderId'),
        ),
    AppRoutes.listStudyModuleOfFolder: (params) =>
        ListStudyModuleOfFolderScreen(
          folderName: params.getString('folderName', 'Unknown'),
          folderId: params.getString('folderId'),
        ),
    AppRoutes.moduleDetail: (_) => const ModuleDetailScreen(),
    AppRoutes.studyFlashcards: (params) => FlashcardStudyModeScreen(
          flashcards: params.getFlashcards('flashcards'),
          initialIndex: params.getInt('initialIndex', 0),
        ),
    AppRoutes.quizSettings: (params) => QuizScreenSettings(
          moduleId: params.getString('moduleId', ''),
          moduleName: params.getString('moduleName', 'Bài kiểm tra'),
          flashcards: params.getFlashcards('flashcards'),
        ),
    AppRoutes.quiz: (params) => QuizScreen(
          quizData: {
            'quizType': params.getEnum(
                'quizType', QuizType.values, QuizType.values.first),
            'difficulty': params.getEnum('difficulty', QuizDifficulty.values,
                QuizDifficulty.values.first),
            'flashcards': params.getFlashcards('flashcards'),
            'moduleId': params.getString('moduleId', ''),
            'moduleName': params.getString('moduleName', ''),
            'questionCount': params.getInt('questionCount', 10),
            'shuffleQuestions': params.getBool('shuffleQuestions', true),
            'showCorrectAnswers': params.getBool('showCorrectAnswers', true),
            'enableTimer': params.getBool('enableTimer', false),
            'timePerQuestion': params.getInt('timePerQuestion', 30),
          },
        ),
    AppRoutes.profile: (_) => const ProfileScreen(),
    AppRoutes.createStudyModule: (_) => const CreateStudyModuleScreen(),
    AppRoutes.moduleSettings: (_) => const ModuleSettingsScreen(),
    AppRoutes.createFolder: (_) => const CreateFolderScreen(),
    AppRoutes.createClass: (_) => const CreateClassScreen(),
    AppRoutes.learn: (params) => StudySettingsScreen(
          flashcards: params.getFlashcards('flashcards'),
          moduleName: params.getString('moduleName', 'Học phần'),
          moduleId: params.getString('moduleId'),
        ),
    AppRoutes.test: (params) => _buildPlaceholderScreen('Test Route', params),
    AppRoutes.match: (params) => _buildPlaceholderScreen('Match Route', params),
    AppRoutes.blast: (params) => _buildPlaceholderScreen('Blast Route', params),
  };

  static Route<dynamic> buildRoute(RouteSettings settings) {
    RouteLogger.logNavigation(settings);
    final params = RouteParams.fromSettings(settings);
    final builder = _routeBuilders[settings.name] ?? _errorScreenBuilder;

    try {
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
