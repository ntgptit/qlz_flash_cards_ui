// lib/features/library/library_module.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qlz_flash_cards_ui/features/library/logic/cubit/classes_cubit.dart';
import 'package:qlz_flash_cards_ui/features/library/logic/cubit/folders_cubit.dart';
import 'package:qlz_flash_cards_ui/features/library/logic/cubit/study_sets_cubit.dart';
import 'package:qlz_flash_cards_ui/features/module/module_module.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/repositories/library_repository.dart';
import 'presentation/screens/class_detail_screen.dart';
import 'presentation/screens/library_screen.dart';

/// Entry point for the Library feature module.
/// Cung cấp các factory method để tạo screens với các dependencies đã được inject.
class LibraryModule {
  /// Cung cấp màn hình thư viện chính với tất cả cubits đã được inject
  static Widget provideLibraryScreen() {
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
        final repository = LibraryRepository(Dio(), prefs);

        // Đảm bảo các Cubit được đăng ký chính xác
        return MultiBlocProvider(
          providers: [
            BlocProvider<StudySetsCubit>(
              create: (context) => StudySetsCubit(repository)..loadStudySets(),
            ),
            BlocProvider<FoldersCubit>(
              create: (context) => FoldersCubit(repository)..loadFolders(),
            ),
            BlocProvider<ClassesCubit>(
              create: (context) => ClassesCubit(repository)..loadClasses(),
            ),
          ],
          child: const LibraryScreen(),
        );
      },
    );
  }

  /// Cung cấp màn hình chi tiết thư mục
  /// @deprecated Sử dụng ModuleModule.provideListScreen thay thế
  static Widget provideFolderDetailScreen({
    required String folderId,
    required String folderName,
  }) {
    // Chuyển tiếp sang ModuleModule để đồng bộ với RouteBuilder
    return ModuleModule.provideListScreen(
      folderId: folderId,
      folderName: folderName,
    );
  }

  /// Cung cấp màn hình chi tiết lớp học
  static Widget provideClassDetailScreen({
    required String classId,
    required String className,
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
        final repository = LibraryRepository(Dio(), prefs);

        return RepositoryProvider.value(
          value: repository,
          child: ClassDetailScreen(
            classId: classId,
            className: className,
          ),
        );
      },
    );
  }
}
