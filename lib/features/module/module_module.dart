import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qlz_flash_cards_ui/features/module/data/repositories/module_repository.dart';
import 'package:qlz_flash_cards_ui/features/module/screens/create_study_module_screen.dart';
import 'package:qlz_flash_cards_ui/features/module/screens/list_study_module_of_folder_screen.dart';
import 'package:qlz_flash_cards_ui/features/module/screens/module_detail_screen.dart';
import 'package:qlz_flash_cards_ui/features/module/screens/module_settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ModuleModule {
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
}