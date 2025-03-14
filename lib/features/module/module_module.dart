// lib/features/module/module_module.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qlz_flash_cards_ui/features/module/presentation/screens/create_study_module_screen.dart';
import 'package:qlz_flash_cards_ui/features/module/presentation/screens/list_study_module_of_folder_screen.dart';
import 'package:qlz_flash_cards_ui/features/module/presentation/screens/module_detail_screen.dart';
import 'package:qlz_flash_cards_ui/features/module/presentation/screens/module_settings_screen.dart';

/// Module chịu trách nhiệm cung cấp các màn hình và dependencies liên quan đến module học
class ModuleModule {
  /// Cung cấp màn hình tạo học phần mới
  static Widget provideCreateScreen() {
    return const ProviderScope(
      child: CreateStudyModuleScreen(),
    );
  }

  /// Cung cấp màn hình danh sách học phần trong một thư mục
  static Widget provideListScreen({
    required String folderName,
    required String folderId,
  }) {
    return ProviderScope(
      child: ListStudyModuleOfFolderScreen(
        folderName: folderName,
        folderId: folderId,
      ),
    );
  }

  /// Cung cấp màn hình chi tiết học phần
  static Widget provideDetailScreen({
    required String moduleId,
    required String moduleName,
  }) {
    return ProviderScope(
      child: ModuleDetailScreen(
        id: moduleId,
        name: moduleName,
      ),
    );
  }

  /// Cung cấp màn hình cài đặt học phần
  static Widget provideSettingsScreen({String moduleId = 'new'}) {
    return ProviderScope(
      child: ModuleSettingsScreen(
        moduleId: moduleId,
      ),
    );
  }
}
