import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Repository imports
import 'package:qlz_flash_cards_ui/features/auth/data/repositories/auth_repository.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/data/repositories/flashcard_repository.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/logic/cubit/flashcard_cubit.dart';
import 'package:qlz_flash_cards_ui/features/library/data/repositories/library_repository.dart';
import 'package:qlz_flash_cards_ui/features/library/logic/cubit/classes_cubit.dart';
import 'package:qlz_flash_cards_ui/features/library/logic/cubit/folders_cubit.dart';
import 'package:qlz_flash_cards_ui/features/library/logic/cubit/study_sets_cubit.dart';
import 'package:qlz_flash_cards_ui/features/module/data/repositories/module_repository.dart';
import 'package:qlz_flash_cards_ui/features/module/logic/cubit/create_module_cubit.dart';
import 'package:qlz_flash_cards_ui/features/module/logic/cubit/module_detail_cubit.dart';
import 'package:qlz_flash_cards_ui/features/module/logic/cubit/module_settings_cubit.dart';
import 'package:qlz_flash_cards_ui/features/module/logic/cubit/study_module_cubit.dart';
import 'package:qlz_flash_cards_ui/features/quiz/data/services/quiz_service.dart';
import 'package:qlz_flash_cards_ui/features/quiz/logic/cubit/quiz_cubit.dart';
import 'package:qlz_flash_cards_ui/features/quiz/logic/cubit/quiz_settings_cubit.dart';
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

//-------------------------------------------------------------------------
// GLOBAL CUBIT PROVIDERS
//-------------------------------------------------------------------------

/// Global HomeCubit provider
// final homeCubitProvider = Provider<HomeCubit>((ref) {
//   return HomeCubit();
// });

//-------------------------------------------------------------------------
// AUTH CUBIT PROVIDERS
//-------------------------------------------------------------------------

/// AuthCubit provider
// final authCubitProvider = Provider.autoDispose<AuthCubit>((ref) {
//   final repository = ref.watch(authRepositoryProvider);
//   final cubit = AuthCubit(repository);

//   // Dispose khi không còn cần thiết
//   ref.onDispose(() {
//     cubit.close();
//   });

//   return cubit;
// });

//-------------------------------------------------------------------------
// LIBRARY CUBIT PROVIDERS
//-------------------------------------------------------------------------

/// StudySetsCubit provider that loads data automatically
final studySetsCubitProvider = Provider.autoDispose<StudySetsCubit>((ref) {
  final repository = ref.watch(libraryRepositoryProvider);
  final cubit = StudySetsCubit(repository);

  // Tự động tải dữ liệu khi cubit được tạo
  cubit.loadStudySets();

  // Dispose khi không còn cần thiết
  ref.onDispose(() {
    cubit.close();
  });

  return cubit;
});

/// StudySetsCubit provider for a specific folder
final folderStudySetsCubitProvider =
    Provider.family.autoDispose<StudySetsCubit, String>((ref, folderId) {
  final repository = ref.watch(libraryRepositoryProvider);
  final cubit = StudySetsCubit(repository);

  // Tải dữ liệu cho folder cụ thể
  cubit.loadStudySetsByFolder(folderId);

  // Dispose khi không còn cần thiết
  ref.onDispose(() {
    cubit.close();
  });

  return cubit;
});

/// FoldersCubit provider that loads data automatically
final foldersCubitProvider = Provider.autoDispose<FoldersCubit>((ref) {
  final repository = ref.watch(libraryRepositoryProvider);
  final cubit = FoldersCubit(repository);

  // Tự động tải dữ liệu khi cubit được tạo
  cubit.loadFolders();

  // Dispose khi không còn cần thiết
  ref.onDispose(() {
    cubit.close();
  });

  return cubit;
});

/// ClassesCubit provider that loads data automatically
final classesCubitProvider = Provider.autoDispose<ClassesCubit>((ref) {
  final repository = ref.watch(libraryRepositoryProvider);
  final cubit = ClassesCubit(repository);

  // Tự động tải dữ liệu khi cubit được tạo
  cubit.loadClasses();

  // Dispose khi không còn cần thiết
  ref.onDispose(() {
    cubit.close();
  });

  return cubit;
});

//-------------------------------------------------------------------------
// MODULE CUBIT PROVIDERS
//-------------------------------------------------------------------------

/// StudyModuleCubit provider
final studyModuleCubitProvider = Provider.autoDispose<StudyModuleCubit>((ref) {
  final repository = ref.watch(moduleRepositoryProvider);
  final cubit = StudyModuleCubit(repository);

  // Dispose khi không còn cần thiết
  ref.onDispose(() {
    cubit.close();
  });

  return cubit;
});

/// CreateModuleCubit provider
final createModuleCubitProvider =
    Provider.autoDispose<CreateModuleCubit>((ref) {
  final repository = ref.watch(moduleRepositoryProvider);
  final cubit = CreateModuleCubit(repository);

  // Dispose khi không còn cần thiết
  ref.onDispose(() {
    cubit.close();
  });

  return cubit;
});

/// Provider family for ModuleDetailCubit that requires a module ID
final moduleDetailCubitProvider =
    Provider.family.autoDispose<ModuleDetailCubit, String>((ref, moduleId) {
  final repository = ref.watch(moduleRepositoryProvider);
  final cubit = ModuleDetailCubit(repository);

  // Tải dữ liệu cho module cụ thể
  cubit.loadModuleDetails(moduleId);

  // Dispose khi không còn cần thiết
  ref.onDispose(() {
    cubit.close();
  });

  return cubit;
});

/// Provider family for ModuleSettingsCubit that requires a module ID
final moduleSettingsCubitProvider =
    Provider.family.autoDispose<ModuleSettingsCubit, String>((ref, moduleId) {
  final repository = ref.watch(moduleRepositoryProvider);
  final cubit = ModuleSettingsCubit(repository, moduleId);

  // Dispose khi không còn cần thiết
  ref.onDispose(() {
    cubit.close();
  });

  return cubit;
});

//-------------------------------------------------------------------------
// FLASHCARD CUBIT PROVIDERS
//-------------------------------------------------------------------------

/// FlashcardCubit provider
final flashcardCubitProvider = Provider.autoDispose<FlashcardCubit>((ref) {
  final repository = ref.watch(flashcardRepositoryProvider);
  final cubit = FlashcardCubit(repository);

  // Dispose khi không còn cần thiết
  ref.onDispose(() {
    cubit.close();
  });

  return cubit;
});

//-------------------------------------------------------------------------
// QUIZ CUBIT PROVIDERS
//-------------------------------------------------------------------------

/// QuizSettingsCubit provider
final quizSettingsCubitProvider =
    Provider.autoDispose<QuizSettingsCubit>((ref) {
  final cubit = QuizSettingsCubit();

  // Dispose khi không còn cần thiết
  ref.onDispose(() {
    cubit.close();
  });

  return cubit;
});

/// QuizCubit provider
final quizCubitProvider = Provider.autoDispose<QuizCubit>((ref) {
  final quizService = QuizService();
  final cubit = QuizCubit(quizService: quizService);

  // Dispose khi không còn cần thiết
  ref.onDispose(() {
    cubit.close();
  });

  return cubit;
});

//-------------------------------------------------------------------------
// UTILITY FOR DEBUG MODE
//-------------------------------------------------------------------------

/// Hằng số để kiểm tra xem ứng dụng có đang chạy ở chế độ debug hay không
const bool kDebugMode = !bool.fromEnvironment('dart.vm.product');

//-------------------------------------------------------------------------
// RIVERPOD-BLOC HELPER UTILITIES
//-------------------------------------------------------------------------

/// Tiện ích để hỗ trợ tích hợp giữa Riverpod và Bloc
class RiverpodBlocHelper {
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

  /// Tạo BlocProvider từ một Riverpod provider
  static BlocProvider<T> getBlocProvider<T extends Cubit>(
    Provider<T> provider,
    WidgetRef ref,
  ) {
    return BlocProvider<T>.value(
      value: ref.read(provider),
    );
  }

  /// Bọc một widget với nhiều BlocProviders từ Riverpod
  static Widget wrapWithBlocs(
    Widget child,
    WidgetRef ref, {
    List<Provider> providers = const [],
  }) {
    final blocProviders = providers.map((provider) {
      return BlocProvider.value(
        value: ref.read(provider) as Cubit,
      );
    }).toList();

    return MultiBlocProvider(
      providers: blocProviders,
      child: child,
    );
  }
}
