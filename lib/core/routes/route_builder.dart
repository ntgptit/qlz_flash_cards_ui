import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qlz_flash_cards_ui/core/managers/cubit_manager.dart';
import 'package:qlz_flash_cards_ui/core/routes/app_routes.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/flashcard_module.dart';
import 'package:qlz_flash_cards_ui/features/library/library_module.dart';
import 'package:qlz_flash_cards_ui/features/module/module_module.dart';

import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/class/create_class_screen.dart';
import '../../features/folder/screens/create_folder_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/quiz/models/quiz_settings.dart';
import '../../features/quiz/screens/quiz_screen.dart';
import '../../features/quiz/screens/quiz_screen_settings.dart';
import '../../features/study/screens/study_settings_screen.dart';
import '../../features/welcome_screen.dart';
import 'route_logger.dart';
import 'route_params.dart';

/// Xây dựng các màn hình dựa trên route settings.
class RouteBuilder {
  static final Map<String, Widget Function(RouteParams)> _routeBuilders = {
    AppRoutes.welcome: (_) => const WelcomeScreen(),

    // Auth routes with Riverpod
    AppRoutes.login: (_) => Consumer(
          builder: (context, ref, _) {
            final authCubit = ref.watch(authCubitProvider);
            return BlocProvider.value(
              value: authCubit,
              child: const LoginScreen(),
            );
          },
        ),

    AppRoutes.register: (_) => Consumer(
          builder: (context, ref, _) {
            final authCubit = ref.watch(authCubitProvider);
            return BlocProvider.value(
              value: authCubit,
              child: const RegisterScreen(),
            );
          },
        ),

    AppRoutes.forgotPassword: (_) => Consumer(
          builder: (context, ref, _) {
            final authCubit = ref.watch(authCubitProvider);
            return BlocProvider.value(
              value: authCubit,
              child: const ForgotPasswordScreen(),
            );
          },
        ),

    // Main routes
    AppRoutes.home: (_) => const HomeScreen(),

    // Library routes that use module pattern
    AppRoutes.library: (_) => LibraryModule.provideRiverpodScreen(),

    AppRoutes.folderDetail: (params) => Consumer(
          builder: (context, ref, _) {
            final folderName = params.getString('folderName', 'Unknown');
            final folderId = params.getString('folderId');
            return ModuleModule.provideRiverpodListScreen(
              ref: ref,
              folderName: folderName,
              folderId: folderId,
            );
          },
        ),

    AppRoutes.classDetail: (params) => Consumer(
          builder: (context, ref, _) {
            final classId = params.getString('classId');
            final className = params.getString('className', 'Unknown');
            return LibraryModule.provideRiverpodClassDetailScreen(
              ref: ref,
              classId: classId,
              className: className,
            );
          },
        ),

    AppRoutes.listStudyModuleOfFolder: (params) => Consumer(
          builder: (context, ref, _) {
            final folderName = params.getString('folderName', 'Unknown');
            final folderId = params.getString('folderId');
            return ModuleModule.provideRiverpodListScreen(
              ref: ref,
              folderName: folderName,
              folderId: folderId,
            );
          },
        ),

    AppRoutes.moduleDetail: (params) => Consumer(
          builder: (context, ref, _) {
            final moduleId = params.getString('moduleId', '');
            final moduleName = params.getString('moduleName', 'Module');
            return ModuleModule.provideRiverpodDetailScreen(
              ref: ref,
              moduleId: moduleId,
              moduleName: moduleName,
            );
          },
        ),

    AppRoutes.studyFlashcards: (params) => Consumer(
          builder: (context, ref, _) {
            final flashcards = params.getFlashcards('flashcards');
            final initialIndex = params.getInt('initialIndex', 0);
            return FlashcardModule.provideRiverpodStudyModeScreen(
              ref: ref,
              flashcards: flashcards,
              initialIndex: initialIndex,
            );
          },
        ),

    AppRoutes.quizSettings: (params) => Consumer(
          builder: (context, ref, _) {
            final moduleId = params.getString('moduleId', '');
            final moduleName = params.getString('moduleName', 'Bài kiểm tra');
            final flashcards = params.getFlashcards('flashcards');

            // Truyền ref tới các providers cần thiết
            return QuizScreenSettings(
              moduleId: moduleId,
              moduleName: moduleName,
              flashcards: flashcards,
            );
          },
        ),

    AppRoutes.quiz: (params) => Consumer(
          builder: (context, ref, _) {
            final quizData = {
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
            };

            // Truyền ref tới các providers cần thiết
            return QuizScreen(
              quizData: quizData,
            );
          },
        ),

    AppRoutes.profile: (_) => const ProfileScreen(),

    AppRoutes.createStudyModule: (_) => Consumer(
          builder: (context, ref, _) {
            return ModuleModule.provideRiverpodCreateScreen(ref: ref);
          },
        ),

    AppRoutes.moduleSettings: (params) => Consumer(
          builder: (context, ref, _) {
            final moduleId = params.getString('moduleId', 'new');
            return ModuleModule.provideRiverpodSettingsScreen(
              ref: ref,
              moduleId: moduleId,
            );
          },
        ),

    AppRoutes.createFolder: (_) => const CreateFolderScreen(),

    AppRoutes.createClass: (_) => const CreateClassScreen(),

    AppRoutes.learn: (params) => Consumer(
          builder: (context, ref, _) {
            final flashcards = params.getFlashcards('flashcards');
            final moduleName = params.getString('moduleName', 'Học phần');
            final moduleId = params.getString('moduleId');

            return StudySettingsScreen(
              flashcards: flashcards,
              moduleName: moduleName,
              moduleId: moduleId,
            );
          },
        ),

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
