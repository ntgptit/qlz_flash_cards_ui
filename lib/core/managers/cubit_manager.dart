// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// // Repository imports
// import 'package:qlz_flash_cards_ui/features/auth/data/repositories/auth_repository.dart';
// // Cubit imports
// import 'package:qlz_flash_cards_ui/features/auth/logic/cubit/auth_cubit.dart';
// import 'package:qlz_flash_cards_ui/features/flashcard/data/repositories/flashcard_repository.dart';
// import 'package:qlz_flash_cards_ui/features/flashcard/logic/cubit/flashcard_cubit.dart';
// import 'package:qlz_flash_cards_ui/features/home/logic/cubit/home_cubit.dart';
// import 'package:qlz_flash_cards_ui/features/library/data/repositories/library_repository.dart';
// import 'package:qlz_flash_cards_ui/features/library/logic/cubit/classes_cubit.dart';
// import 'package:qlz_flash_cards_ui/features/library/logic/cubit/folders_cubit.dart';
// import 'package:qlz_flash_cards_ui/features/library/logic/cubit/study_sets_cubit.dart';
// import 'package:qlz_flash_cards_ui/features/module/data/repositories/module_repository.dart';
// import 'package:qlz_flash_cards_ui/features/module/logic/cubit/create_module_cubit.dart';
// import 'package:qlz_flash_cards_ui/features/module/logic/cubit/module_detail_cubit.dart';
// import 'package:qlz_flash_cards_ui/features/module/logic/cubit/module_settings_cubit.dart';
// import 'package:qlz_flash_cards_ui/features/module/logic/cubit/study_module_cubit.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// //-------------------------------------------------------------------------
// // GLOBAL PROVIDERS
// //-------------------------------------------------------------------------

// /// Provider for Dio HTTP client
// final dioProvider = Provider<Dio>((ref) => Dio());

// /// Provider for SharedPreferences
// final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
//   throw UnimplementedError(
//       'You need to override this provider with the actual instance');
// });

// /// Provider for LibraryRepository
// final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
//   final dio = ref.watch(dioProvider);
//   final prefs = ref.watch(sharedPreferencesProvider);
//   return LibraryRepository(dio, prefs);
// });

// /// Provider for ModuleRepository
// final moduleRepositoryProvider = Provider<ModuleRepository>((ref) {
//   final dio = ref.watch(dioProvider);
//   final prefs = ref.watch(sharedPreferencesProvider);
//   return ModuleRepository(dio, prefs);
// });

// /// Provider for FlashcardRepository
// final flashcardRepositoryProvider = Provider<FlashcardRepository>((ref) {
//   final dio = ref.watch(dioProvider);
//   final prefs = ref.watch(sharedPreferencesProvider);
//   return FlashcardRepository(dio, prefs);
// });

// /// Provider for AuthRepository
// final authRepositoryProvider = Provider<AuthRepository>((ref) {
//   final dio = ref.watch(dioProvider);
//   return AuthRepository(dio);
// });

// //-------------------------------------------------------------------------
// // CUBIT PROVIDERS
// //-------------------------------------------------------------------------

// /// Global HomeCubit provider
// final homeCubitProvider = Provider.autoDispose<HomeCubit>((ref) {
//   return HomeCubit();
// });

// /// AuthCubit provider
// final authCubitProvider = Provider.autoDispose<AuthCubit>((ref) {
//   final repository = ref.watch(authRepositoryProvider);
//   return AuthCubit(repository);
// });

// /// StudySetsCubit provider that loads data automatically
// final studySetsCubitProvider = Provider.autoDispose<StudySetsCubit>((ref) {
//   final repository = ref.watch(libraryRepositoryProvider);
//   final cubit = StudySetsCubit(repository);

//   // Automatically load data when the cubit is created
//   cubit.loadStudySets();

//   // Dispose when no longer needed
//   ref.onDispose(() {
//     cubit.close();
//   });

//   return cubit;
// });

// /// FoldersCubit provider that loads data automatically
// final foldersCubitProvider = Provider.autoDispose<FoldersCubit>((ref) {
//   final repository = ref.watch(libraryRepositoryProvider);
//   final cubit = FoldersCubit(repository);

//   // Automatically load data when the cubit is created
//   cubit.loadFolders();

//   // Dispose when no longer needed
//   ref.onDispose(() {
//     cubit.close();
//   });

//   return cubit;
// });

// /// ClassesCubit provider that loads data automatically
// final classesCubitProvider = Provider.autoDispose<ClassesCubit>((ref) {
//   final repository = ref.watch(libraryRepositoryProvider);
//   final cubit = ClassesCubit(repository);

//   // Automatically load data when the cubit is created
//   cubit.loadClasses();

//   // Dispose when no longer needed
//   ref.onDispose(() {
//     cubit.close();
//   });

//   return cubit;
// });

// /// StudyModuleCubit provider
// final studyModuleCubitProvider = Provider.autoDispose<StudyModuleCubit>((ref) {
//   final repository = ref.watch(moduleRepositoryProvider);
//   final cubit = StudyModuleCubit(repository);

//   // Dispose when no longer needed
//   ref.onDispose(() {
//     cubit.close();
//   });

//   return cubit;
// });

// /// CreateModuleCubit provider
// final createModuleCubitProvider =
//     Provider.autoDispose<CreateModuleCubit>((ref) {
//   final repository = ref.watch(moduleRepositoryProvider);
//   final cubit = CreateModuleCubit(repository);

//   // Dispose when no longer needed
//   ref.onDispose(() {
//     cubit.close();
//   });

//   return cubit;
// });

// /// FlashcardCubit provider
// final flashcardCubitProvider = Provider.autoDispose<FlashcardCubit>((ref) {
//   final repository = ref.watch(flashcardRepositoryProvider);
//   final cubit = FlashcardCubit(repository);

//   // Dispose when no longer needed
//   ref.onDispose(() {
//     cubit.close();
//   });

//   return cubit;
// });

// //-------------------------------------------------------------------------
// // PROVIDERS WITH PARAMETERS
// //-------------------------------------------------------------------------

// /// Provider family for ModuleDetailCubit that requires a module ID
// final moduleDetailCubitProvider =
//     Provider.family.autoDispose<ModuleDetailCubit, String>((ref, moduleId) {
//   final repository = ref.watch(moduleRepositoryProvider);
//   final cubit = ModuleDetailCubit(repository);

//   // Load module details for the specific ID
//   cubit.loadModuleDetails(moduleId);

//   // Dispose when no longer needed
//   ref.onDispose(() {
//     cubit.close();
//   });

//   return cubit;
// });

// /// Provider family for ModuleSettingsCubit that requires a module ID
// final moduleSettingsCubitProvider =
//     Provider.family.autoDispose<ModuleSettingsCubit, String>((ref, moduleId) {
//   final repository = ref.watch(moduleRepositoryProvider);
//   final cubit = ModuleSettingsCubit(repository, moduleId);

//   // Dispose when no longer needed
//   ref.onDispose(() {
//     cubit.close();
//   });

//   return cubit;
// });

// /// A utility class to help with Riverpod + Bloc integration
// class RiverpodBlocHelper {
//   /// Initialize SharedPreferences in the app's main function
//   static Future<ProviderContainer> initializeProviders() async {
//     final prefs = await SharedPreferences.getInstance();

//     // Override the provider with the actual instance
//     final container = ProviderContainer(
//       overrides: [
//         sharedPreferencesProvider.overrideWithValue(prefs),
//       ],
//     );

//     return container;
//   }

//   /// Get a BlocProvider for a specific Cubit from a Riverpod provider
//   static BlocProvider<T> getBlocProvider<T extends Cubit>(
//     Provider<T> provider,
//     WidgetRef ref,
//   ) {
//     return BlocProvider<T>.value(
//       value: ref.read(provider),
//     );
//   }

//   /// Wrap a widget with all necessary BlocProviders for a specific feature
//   static Widget wrapWithBlocs(
//     Widget child,
//     WidgetRef ref, {
//     List<Provider> providers = const [],
//   }) {
//     final blocProviders = providers.map((provider) {
//       return BlocProvider.value(
//         value: ref.read(provider) as Cubit,
//       );
//     }).toList();

//     return MultiBlocProvider(
//       providers: blocProviders,
//       child: child,
//     );
//   }
// }
