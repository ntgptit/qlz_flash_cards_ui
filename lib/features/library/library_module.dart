// lib/features/library/library_module.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qlz_flash_cards_ui/core/providers/app_providers.dart';
import 'package:qlz_flash_cards_ui/features/library/logic/cubit/classes_cubit.dart';
import 'package:qlz_flash_cards_ui/features/library/logic/cubit/folders_cubit.dart';
import 'package:qlz_flash_cards_ui/features/library/logic/cubit/study_sets_cubit.dart';
import 'package:qlz_flash_cards_ui/features/library/presentation/screens/create_class_screen.dart';
import 'package:qlz_flash_cards_ui/features/library/presentation/screens/create_folder_screen.dart';
import 'package:qlz_flash_cards_ui/features/library/presentation/screens/folder_detail_screen.dart';
import 'package:qlz_flash_cards_ui/features/module/module_module.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/repositories/library_repository.dart';
import 'presentation/screens/class_detail_screen.dart';
import 'presentation/screens/library_screen.dart';

/// Entry point for the Library feature module.
/// Cung cấp các factory method để tạo screens với các dependencies đã được inject.
class LibraryModule {
  //-------------------------------------------------------------------------
  // PHƯƠNG THỨC HIỆN TẠI (GIỮU TƯƠNG THÍCH NGƯỢC)
  //-------------------------------------------------------------------------

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

  /// Cung cấp màn hình tạo thư mục
  static Widget provideCreateFolderScreen() {
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
        final foldersCubit = FoldersCubit(repository);

        return BlocProvider<FoldersCubit>(
          create: (context) => foldersCubit,
          child: const CreateFolderScreen(),
        );
      },
    );
  }

  /// Cung cấp màn hình tạo thư mục với Riverpod
  static Widget provideRiverpodCreateFolderScreen({
    required WidgetRef ref,
  }) {
    // Lấy foldersCubit từ Riverpod provider
    final foldersCubit = ref.watch(foldersCubitProvider);

    // Cung cấp foldersCubit thông qua BlocProvider
    return BlocProvider.value(
      value: foldersCubit,
      child: const CreateFolderScreen(),
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

  //-------------------------------------------------------------------------
  // PHƯƠNG THỨC SỬ DỤNG RIVERPOD
  //-------------------------------------------------------------------------

  /// Cung cấp màn hình thư viện chính với tất cả Cubits từ Riverpod
  ///
  /// Sử dụng Riverpod để quản lý dependencies thay vì tự tạo mới mỗi lần
  static Widget provideRiverpodScreen() {
    return Consumer(
      builder: (context, ref, _) {
        // Lấy các cubit từ Riverpod providers
        final studySetsCubit = ref.watch(studySetsCubitProvider);
        final foldersCubit = ref.watch(foldersCubitProvider);
        final classesCubit = ref.watch(classesCubitProvider);

        // Cung cấp cubits thông qua BlocProvider.value
        return MultiBlocProvider(
          providers: [
            BlocProvider<StudySetsCubit>.value(value: studySetsCubit),
            BlocProvider<FoldersCubit>.value(value: foldersCubit),
            BlocProvider<ClassesCubit>.value(value: classesCubit),
          ],
          child: const LibraryScreen(),
        );
      },
    );
  }

  /// Cung cấp màn hình chi tiết thư mục với Riverpod
  ///
  /// @deprecated Sử dụng ModuleModule.provideRiverpodListScreen thay thế
  static Widget provideRiverpodFolderDetailScreen({
    required WidgetRef ref,
    required String folderId,
    required String folderName,
  }) {
    print(
        "DEBUG-LibraryModule: Creating folder detail screen for ID: $folderId");

    // Sử dụng repository từ Riverpod
    final repository = ref.watch(libraryRepositoryProvider);

    // Tạo cubit mới để tránh lỗi về lifecycle
    final studySetsCubit = StudySetsCubit(repository);

    print("DEBUG-LibraryModule: Created new StudySetsCubit: $studySetsCubit");

    return MultiBlocProvider(
      providers: [
        BlocProvider<StudySetsCubit>(
          create: (context) => studySetsCubit,
        ),
        RepositoryProvider.value(value: repository),
      ],
      child: FolderDetailScreen(
        folderId: folderId,
        folderName: folderName,
      ),
    );
  }

  /// Cung cấp màn hình chi tiết lớp học với Riverpod
  static Widget provideRiverpodClassDetailScreen({
    required WidgetRef ref,
    required String classId,
    required String className,
  }) {
    // Lấy repository từ Riverpod provider
    final repository = ref.read(libraryRepositoryProvider);

    // Tùy chọn: Lấy cubit cụ thể nếu màn hình cần
    // Ví dụ nếu bạn có provider cho ClassDetailCubit:
    // final classDetailCubit = ref.read(classDetailCubitProvider(classId));

    return RepositoryProvider.value(
      value: repository,
      child: ClassDetailScreen(
        classId: classId,
        className: className,
      ),
    );
  }

  /// Cung cấp màn hình tạo lớp học
  static Widget provideCreateClassScreen() {
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
        final classesCubit = ClassesCubit(repository);

        return BlocProvider<ClassesCubit>(
          create: (context) => classesCubit,
          child: const CreateClassScreen(),
        );
      },
    );
  }

  /// Cung cấp màn hình tạo lớp học với Riverpod
  static Widget provideRiverpodCreateClassScreen({
    required WidgetRef ref,
  }) {
    // Lấy classesCubit từ Riverpod provider
    final classesCubit = ref.watch(classesCubitProvider);

    // Cung cấp classesCubit thông qua BlocProvider
    return BlocProvider.value(
      value: classesCubit,
      child: const CreateClassScreen(),
    );
  }

  //-------------------------------------------------------------------------
  // HELPER METHODS FOR RIVERPOD INTEGRATION
  //-------------------------------------------------------------------------

  /// Phương thức tiện ích để bọc widget với tất cả providers cần thiết
  ///
  /// Trả về widget được bọc với LibraryRepository và các Cubits cần thiết
  static Widget wrapWithLibraryProviders(Widget child, WidgetRef ref) {
    final repository = ref.read(libraryRepositoryProvider);
    final studySetsCubit = ref.read(studySetsCubitProvider);
    final foldersCubit = ref.read(foldersCubitProvider);
    final classesCubit = ref.read(classesCubitProvider);

    return MultiBlocProvider(
      providers: [
        RepositoryProvider<LibraryRepository>.value(value: repository),
        BlocProvider<StudySetsCubit>.value(value: studySetsCubit),
        BlocProvider<FoldersCubit>.value(value: foldersCubit),
        BlocProvider<ClassesCubit>.value(value: classesCubit),
      ],
      child: child,
    );
  }

  /// Phương thức tiện ích để bọc widget với repository của Library
  ///
  /// Sử dụng khi widget chỉ cần truy cập repository
  static Widget wrapWithLibraryRepository(Widget child, WidgetRef ref) {
    final repository = ref.read(libraryRepositoryProvider);

    return RepositoryProvider.value(
      value: repository,
      child: child,
    );
  }
}
