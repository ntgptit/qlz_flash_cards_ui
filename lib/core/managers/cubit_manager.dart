import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Features
import 'package:qlz_flash_cards_ui/features/flashcard/data/repositories/flashcard_repository.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/logic/cubit/flashcard_cubit.dart';
import 'package:qlz_flash_cards_ui/features/home/logic/cubit/home_cubit.dart';
import 'package:qlz_flash_cards_ui/features/library/data/repositories/library_repository.dart';
import 'package:qlz_flash_cards_ui/features/library/logic/cubit/classes_cubit.dart';
import 'package:qlz_flash_cards_ui/features/library/logic/cubit/folders_cubit.dart';
import 'package:qlz_flash_cards_ui/features/library/logic/cubit/study_sets_cubit.dart';
import 'package:qlz_flash_cards_ui/features/module/data/repositories/module_repository.dart';
import 'package:qlz_flash_cards_ui/features/module/logic/cubit/create_module_cubit.dart';
import 'package:qlz_flash_cards_ui/features/module/logic/cubit/module_detail_cubit.dart';
import 'package:qlz_flash_cards_ui/features/module/logic/cubit/module_settings_cubit.dart';
import 'package:qlz_flash_cards_ui/features/module/logic/cubit/study_module_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A manager class that centralizes the creation and provision of Cubits throughout the app.
///
/// This follows the service locator pattern to provide a single source of truth
/// for all Cubits, making them easily accessible and reusable across the app.
class CubitManager {
  /// Singleton instance
  static final CubitManager _instance = CubitManager._internal();

  /// Factory constructor that returns the singleton instance
  factory CubitManager() => _instance;

  /// Private constructor for singleton pattern
  CubitManager._internal();

  /// Dio instance for API calls
  late final Dio _dio;

  /// SharedPreferences instance for local storage
  late final SharedPreferences _prefs;

  /// Repositories
  late final LibraryRepository _libraryRepository;
  late final ModuleRepository _moduleRepository;
  late final FlashcardRepository _flashcardRepository;

  /// Global cubits
  late final HomeCubit _homeCubit;

  /// Flag to check if the manager has been initialized
  bool _isInitialized = false;

  /// Initializes the manager with necessary dependencies
  /// Must be called before using any other methods
  Future<void> initialize() async {
    if (_isInitialized) return;

    _dio = Dio();
    _prefs = await SharedPreferences.getInstance();

    // Initialize repositories
    _libraryRepository = LibraryRepository(_dio, _prefs);
    _moduleRepository = ModuleRepository(_dio, _prefs);
    _flashcardRepository = FlashcardRepository(_dio, _prefs);

    // Initialize global cubits
    _homeCubit = HomeCubit();

    _isInitialized = true;
  }

  /// Provides all global Cubits for the app
  ///
  /// These Cubits will be available throughout the app lifecycle
  List<BlocProvider> get globalProviders {
    _ensureInitialized();

    return [
      // Global cubits that should persist throughout the app
      BlocProvider<HomeCubit>(create: (_) => _homeCubit),
    ];
  }

  /// Get the Home Cubit instance
  HomeCubit get homeCubit {
    _ensureInitialized();
    return _homeCubit;
  }

  /// Provides Cubits for the Library feature
  List<BlocProvider> getLibraryProviders() {
    _ensureInitialized();

    return [
      BlocProvider<StudySetsCubit>(
        create: (context) =>
            StudySetsCubit(_libraryRepository)..loadStudySets(),
      ),
      BlocProvider<FoldersCubit>(
        create: (context) => FoldersCubit(_libraryRepository)..loadFolders(),
      ),
      BlocProvider<ClassesCubit>(
        create: (context) => ClassesCubit(_libraryRepository)..loadClasses(),
      ),
    ];
  }

  /// Provides Cubits for the Module feature
  List<BlocProvider> getModuleProviders() {
    _ensureInitialized();

    return [
      BlocProvider<StudyModuleCubit>(
        create: (context) => StudyModuleCubit(_moduleRepository),
      ),
    ];
  }

  /// Provides Cubits specifically for the Home feature
  List<BlocProvider> getHomeProviders() {
    _ensureInitialized();

    return [
      BlocProvider<HomeCubit>.value(value: _homeCubit),
    ];
  }

  /// Creates a ModuleDetailCubit for a specific module
  ModuleDetailCubit createModuleDetailCubit(String moduleId) {
    _ensureInitialized();
    return ModuleDetailCubit(_moduleRepository)..loadModuleDetails(moduleId);
  }

  /// Creates a ModuleSettingsCubit for a specific module
  ModuleSettingsCubit createModuleSettingsCubit(String moduleId) {
    _ensureInitialized();
    return ModuleSettingsCubit(_moduleRepository, moduleId);
  }

  /// Creates a CreateModuleCubit
  CreateModuleCubit createCreateModuleCubit() {
    _ensureInitialized();
    return CreateModuleCubit(_moduleRepository);
  }

  /// Creates a FlashcardCubit
  FlashcardCubit createFlashcardCubit() {
    _ensureInitialized();
    return FlashcardCubit(_flashcardRepository);
  }

  /// Ensures the manager has been initialized before use
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
          'CubitManager must be initialized before use. Call initialize() first.');
    }
  }
}
