import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qlz_flash_cards_ui/features/auth/data/repositories/auth_repository.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/data/repositories/flashcard_repository.dart';
import 'package:qlz_flash_cards_ui/features/library/data/repositories/library_repository.dart';
import 'package:qlz_flash_cards_ui/features/module/data/repositories/module_repository.dart';
import 'package:qlz_flash_cards_ui/features/quiz/data/services/quiz_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

//-------------------------------------------------------------------------
// CORE DEPENDENCY PROVIDERS
//-------------------------------------------------------------------------

/// Provider for Dio HTTP client
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();

  // Cấu hình cơ bản cho Dio
  dio.options.connectTimeout = const Duration(seconds: 30);
  dio.options.receiveTimeout = const Duration(seconds: 30);

  // Thêm interceptors nếu cần
  if (kDebugMode) {
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  return dio;
});

/// Provider for SharedPreferences
/// Lưu ý: Provider này cần được override trong main.dart
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences provider chưa được khởi tạo. '
      'Hãy override provider này trong main.dart với giá trị thực.');
});

//-------------------------------------------------------------------------
// REPOSITORY PROVIDERS
//-------------------------------------------------------------------------

/// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthRepository(dio);
});

/// Provider for LibraryRepository
final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return LibraryRepository(dio, prefs);
});

/// Provider for ModuleRepository
final moduleRepositoryProvider = Provider<ModuleRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return ModuleRepository(dio, prefs);
});

/// Provider for FlashcardRepository
final flashcardRepositoryProvider = Provider<FlashcardRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return FlashcardRepository(dio, prefs);
});

/// Provider for QuizService
final quizServiceProvider = Provider<QuizService>((ref) {
  return QuizService();
});

//-------------------------------------------------------------------------
// UTILITY FOR DEBUG MODE
//-------------------------------------------------------------------------

/// Hằng số để kiểm tra xem ứng dụng có đang chạy ở chế độ debug hay không
const bool kDebugMode = !bool.fromEnvironment('dart.vm.product');

//-------------------------------------------------------------------------
// RIVERPOD CONTAINER INITIALIZATION
//-------------------------------------------------------------------------

/// Tiện ích để khởi tạo Riverpod container với dependencies đã được setup
class RiverpodInitializer {
  /// Khởi tạo providers trong một container riêng biệt
  static Future<ProviderContainer> initializeProviders() async {
    final prefs = await SharedPreferences.getInstance();

    // Override provider với instance thực
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
    );

    return container;
  }
}
