// C:/Users/ntgpt/OneDrive/workspace/qlz_flash_cards_ui/lib/features/module/module_module.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qlz_flash_cards_ui/core/providers/app_providers.dart';
import 'package:qlz_flash_cards_ui/features/module/logic/cubit/module_detail_cubit.dart';
import 'package:qlz_flash_cards_ui/features/module/screens/create_study_module_screen.dart';
import 'package:qlz_flash_cards_ui/features/module/screens/list_study_module_of_folder_screen.dart';
import 'package:qlz_flash_cards_ui/features/module/screens/module_detail_screen.dart';
import 'package:qlz_flash_cards_ui/features/module/screens/module_settings_screen.dart';

class ModuleModule {
  // Riverpod-based providers (recommended approach)
  static Widget provideCreateScreen() {
    return Consumer(
      builder: (context, ref, _) {
        return provideRiverpodCreateScreen(ref: ref);
      },
    );
  }

  static Widget provideListScreen({
    required String folderName,
    required String folderId,
  }) {
    return Consumer(
      builder: (context, ref, _) {
        return provideRiverpodListScreen(
          ref: ref,
          folderName: folderName,
          folderId: folderId,
        );
      },
    );
  }

  static Widget provideDetailScreen({
    required String moduleId,
    required String moduleName,
  }) {
    return Consumer(
      builder: (context, ref, _) {
        return provideRiverpodDetailScreen(
          ref: ref,
          moduleId: moduleId,
          moduleName: moduleName,
        );
      },
    );
  }

  static Widget provideSettingsScreen({String moduleId = 'new'}) {
    return Consumer(
      builder: (context, ref, _) {
        return provideRiverpodSettingsScreen(
          ref: ref,
          moduleId: moduleId,
        );
      },
    );
  }

  // Riverpod-specific implementations
  static Widget provideRiverpodCreateScreen({required WidgetRef ref}) {
    final repository = ref.read(moduleRepositoryProvider);
    final createModuleCubit = ref.read(createModuleCubitProvider);

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: createModuleCubit),
        RepositoryProvider.value(value: repository),
      ],
      child: const CreateStudyModuleScreen(),
    );
  }

  static Widget provideRiverpodListScreen({
    required WidgetRef ref,
    required String folderName,
    required String folderId,
  }) {
    final repository = ref.read(moduleRepositoryProvider);
    final studyModuleCubit = ref.read(studyModuleCubitProvider);

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: studyModuleCubit),
        RepositoryProvider.value(value: repository),
      ],
      child: ListStudyModuleOfFolderScreen(
        folderName: folderName,
        folderId: folderId,
      ),
    );
  }

  static Widget provideRiverpodDetailScreen({
    required WidgetRef ref,
    required String moduleId,
    required String moduleName,
  }) {
    print("DEBUG-Module: Creating detail screen for module ID: $moduleId");

    // Tạo mới cubit với repository
    final repository = ref.watch(moduleRepositoryProvider);

    // Quan trọng: Tạo cubit mới ở đây thay vì sử dụng provider để tránh lỗi
    final moduleDetailCubit = ModuleDetailCubit(repository);

    print("DEBUG-Module: Created new cubit: $moduleDetailCubit");

    return MultiBlocProvider(
      providers: [
        BlocProvider<ModuleDetailCubit>(
          create: (context) => moduleDetailCubit,
        ),
        RepositoryProvider.value(value: repository),
      ],
      child: ModuleDetailScreen(
        id: moduleId,
        name: moduleName,
      ),
    );
  }

  static Widget provideRiverpodSettingsScreen({
    required WidgetRef ref,
    String moduleId = 'new',
  }) {
    final repository = ref.read(moduleRepositoryProvider);
    final moduleSettingsCubit = ref.read(moduleSettingsCubitProvider(moduleId));

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: moduleSettingsCubit),
        RepositoryProvider.value(value: repository),
      ],
      child: ModuleSettingsScreen(moduleId: moduleId),
    );
  }
}
