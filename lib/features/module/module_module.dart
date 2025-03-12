import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qlz_flash_cards_ui/core/managers/cubit_manager.dart';
import 'package:qlz_flash_cards_ui/features/module/data/repositories/module_repository.dart';
import 'package:qlz_flash_cards_ui/features/module/screens/create_study_module_screen.dart';
import 'package:qlz_flash_cards_ui/features/module/screens/list_study_module_of_folder_screen.dart';
import 'package:qlz_flash_cards_ui/features/module/screens/module_detail_screen.dart';
import 'package:qlz_flash_cards_ui/features/module/screens/module_settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ModuleModule {
  // Các phương thức hiện tại - giữ nguyên để tương thích ngược
  static Widget provideCreateScreen() {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Material(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        final prefs = snapshot.data!;
        final repository = ModuleRepository(Dio(), prefs);
        return RepositoryProvider.value(
          value: repository,
          child: const CreateStudyModuleScreen(),
        );
      },
    );
  }

  static Widget provideListScreen({
    required String folderName,
    required String folderId,
  }) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Material(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        final prefs = snapshot.data!;
        final repository = ModuleRepository(Dio(), prefs);
        return RepositoryProvider.value(
          value: repository,
          child: ListStudyModuleOfFolderScreen(
            folderName: folderName,
            folderId: folderId,
          ),
        );
      },
    );
  }

  static Widget provideDetailScreen({
    required String moduleId,
    required String moduleName,
  }) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Material(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        final prefs = snapshot.data!;
        final repository = ModuleRepository(Dio(), prefs);
        return RepositoryProvider.value(
          value: repository,
          child: ModuleDetailScreen(
            id: moduleId,
            name: moduleName,
          ),
        );
      },
    );
  }

  static Widget provideSettingsScreen({String moduleId = 'new'}) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Material(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        final prefs = snapshot.data!;
        final repository = ModuleRepository(Dio(), prefs);
        return RepositoryProvider.value(
          value: repository,
          child: ModuleSettingsScreen(moduleId: moduleId),
        );
      },
    );
  }

  // PHƯƠNG THỨC MỚI SỬ DỤNG RIVERPOD

  /// Cung cấp màn hình tạo học phần sử dụng Riverpod
  static Widget provideRiverpodCreateScreen({required WidgetRef ref}) {
    // Lấy repository từ Riverpod provider
    final repository = ref.read(moduleRepositoryProvider);

    // Lấy cubit từ Riverpod provider nếu cần
    final createModuleCubit = ref.read(createModuleCubitProvider);

    return MultiBlocProvider(
      providers: [
        // Cung cấp cubit nếu màn hình cần
        BlocProvider.value(value: createModuleCubit),

        // Hoặc cung cấp repository
        RepositoryProvider.value(value: repository),
      ],
      child: const CreateStudyModuleScreen(),
    );
  }

  /// Cung cấp màn hình danh sách học phần trong thư mục sử dụng Riverpod
  static Widget provideRiverpodListScreen({
    required WidgetRef ref,
    required String folderName,
    required String folderId,
  }) {
    // Lấy repository từ Riverpod provider
    final repository = ref.read(moduleRepositoryProvider);

    // Lấy cubit từ Riverpod provider
    final studySetsCubit = ref.read(studySetsCubitProvider);

    return MultiBlocProvider(
      providers: [
        // Cung cấp cubit
        BlocProvider.value(value: studySetsCubit),

        // Cung cấp repository
        RepositoryProvider.value(value: repository),
      ],
      child: ListStudyModuleOfFolderScreen(
        folderName: folderName,
        folderId: folderId,
      ),
    );
  }

  /// Cung cấp màn hình chi tiết học phần sử dụng Riverpod
  static Widget provideRiverpodDetailScreen({
    required WidgetRef ref,
    required String moduleId,
    required String moduleName,
  }) {
    // Lấy repository từ Riverpod provider
    final repository = ref.read(moduleRepositoryProvider);

    // Lấy cubit từ provider với tham số moduleId
    final moduleDetailCubit = ref.read(moduleDetailCubitProvider(moduleId));

    return MultiBlocProvider(
      providers: [
        // Cung cấp cubit
        BlocProvider.value(value: moduleDetailCubit),

        // Cung cấp repository
        RepositoryProvider.value(value: repository),
      ],
      child: ModuleDetailScreen(
        id: moduleId,
        name: moduleName,
      ),
    );
  }

  /// Cung cấp màn hình cài đặt học phần sử dụng Riverpod
  static Widget provideRiverpodSettingsScreen({
    required WidgetRef ref,
    String moduleId = 'new',
  }) {
    // Lấy repository từ Riverpod provider
    final repository = ref.read(moduleRepositoryProvider);

    // Lấy cubit từ provider với tham số moduleId
    final moduleSettingsCubit = ref.read(moduleSettingsCubitProvider(moduleId));

    return MultiBlocProvider(
      providers: [
        // Cung cấp cubit
        BlocProvider.value(value: moduleSettingsCubit),

        // Cung cấp repository
        RepositoryProvider.value(value: repository),
      ],
      child: ModuleSettingsScreen(moduleId: moduleId),
    );
  }
}
