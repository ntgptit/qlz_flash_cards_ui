// lib/core/routes/route_builder.dart

import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/core/routes/app_routes.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/flashcard_module.dart';
import 'package:qlz_flash_cards_ui/features/library/library_module.dart';
import 'package:qlz_flash_cards_ui/features/module/module_module.dart';
import 'package:qlz_flash_cards_ui/features/quiz/data/models/quiz_settings.dart';
import 'package:qlz_flash_cards_ui/features/quiz/quiz_module.dart';

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

    AppRoutes.quizSettings: (params) {
      final moduleId = params.getString('moduleId', '');
      final moduleName = params.getString('moduleName', 'Bài kiểm tra');
      final flashcards = params.getFlashcards('flashcards');

      return QuizModule.provideRiverpodSettingsScreen(
        moduleId: moduleId,
        moduleName: moduleName,
        flashcards: flashcards,
      );
    },

    AppRoutes.quiz: (params) {
      final quizData = {
        'quizType':
            params.getEnum('quizType', QuizType.values, QuizType.values.first),
        'difficulty': params.getEnum(
            'difficulty', QuizDifficulty.values, QuizDifficulty.values.first),
        'flashcards': params.getFlashcards('flashcards'),
        'moduleId': params.getString('moduleId', ''),
        'moduleName': params.getString('moduleName', ''),
        'questionCount': params.getInt('questionCount', 10),
        'shuffleQuestions': params.getBool('shuffleQuestions', true),
        'showCorrectAnswers': params.getBool('showCorrectAnswers', true),
        'enableTimer': params.getBool('enableTimer', false),
        'timePerQuestion': params.getInt('timePerQuestion', 30),
      };

      return QuizModule.provideRiverpodQuizScreen(
        quizData: quizData,
      );
    },

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
    // Log lỗi chi tiết vào console
    debugPrint('[${DateTime.now().toIso8601String()}] '
        'NAVIGATION ERROR:\n'
        'Route: "$routeName"\n'
        'Stack: ${StackTrace.current.toString().split('\n').take(3).join('\n')}');

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.redAccent.withOpacity(0.05),
                Colors.blueAccent.withOpacity(0.05),
              ],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                margin: const EdgeInsets.all(20),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Animated error icon with bounce effect
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: child,
                          );
                        },
                        child: const Icon(
                          Icons.warning_amber_rounded,
                          size: 100,
                          color: Colors.redAccent,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Tiêu đề thân thiện hơn
                      Text(
                        'Ôi không! Có gì đó sai rồi',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[900],
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      // Thông tin lỗi với style rõ ràng
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.redAccent.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Không tìm thấy: ',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '"$routeName"',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Hướng dẫn người dùng
                      Text(
                        'Đừng lo! Bạn có thể:\n'
                        '1. Kiểm tra lại đường dẫn\n'
                        '2. Quay lại màn hình trước\n'
                        '3. Liên hệ hỗ trợ nếu cần',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      // Các nút hành động
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Nút Quay lại
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            onPressed: () =>
                                Navigator.canPop(RouteLogger.context)
                                    ? Navigator.pop(RouteLogger.context)
                                    : null,
                            icon:
                                const Icon(Icons.arrow_back_ios_new, size: 18),
                            label: const Text(
                              'Quay lại',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Nút Trang chủ
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.blueAccent,
                              side: BorderSide(
                                  color: Colors.blueAccent.withOpacity(0.5)),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              Navigator.popUntil(
                                RouteLogger.context,
                                (route) => route.isFirst,
                              );
                            },
                            icon: const Icon(Icons.home_outlined, size: 18),
                            label: const Text(
                              'Trang chủ',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _errorScreenBuilder(RouteParams _) =>
      _buildErrorScreen('Unknown Route');
}
