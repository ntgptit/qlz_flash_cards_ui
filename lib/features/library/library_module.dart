import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/features/library/presentation/screens/class/class_detail_screen.dart';
import 'package:qlz_flash_cards_ui/features/library/presentation/screens/class/create_class_screen.dart';
import 'package:qlz_flash_cards_ui/features/library/presentation/screens/folder/create_folder_screen.dart';
import 'package:qlz_flash_cards_ui/features/library/presentation/screens/folder/folder_detail_screen.dart';
import 'package:qlz_flash_cards_ui/features/library/presentation/screens/library_screen.dart';

/// Entry point for the Library feature module.
/// Cung cấp các factory method để tạo screens với các dependencies đã được inject sử dụng Riverpod.
class LibraryModule {
  /// Cung cấp màn hình thư viện chính
  ///
  /// Sử dụng Riverpod để quản lý state và dependencies
  static Widget provideRiverpodScreen() {
    return const LibraryScreen();
  }

  /// Cung cấp màn hình chi tiết thư mục
  ///
  /// [folderName] Tên hiển thị của thư mục
  /// [folderId] ID duy nhất của thư mục, sử dụng cho việc tải dữ liệu
  static Widget provideRiverpodFolderDetailScreen({
    required String folderName,
    String? folderId,
  }) {
    return FolderDetailScreen(
      folderId: folderId ?? '',
      folderName: folderName,
    );
  }

  /// Cung cấp màn hình tạo thư mục mới
  static Widget provideRiverpodCreateFolderScreen() {
    return const CreateFolderScreen();
  }

  /// Cung cấp màn hình chi tiết lớp học
  ///
  /// [classId] ID duy nhất của lớp học
  /// [className] Tên hiển thị của lớp học
  static Widget provideRiverpodClassDetailScreen({
    required String classId,
    required String className,
  }) {
    return ClassDetailScreen(
      classId: classId,
      className: className,
    );
  }

  /// Cung cấp màn hình tạo lớp học mới
  static Widget provideRiverpodCreateClassScreen() {
    return const CreateClassScreen();
  }
}
