// lib/features/library/presentation/tabs/folders_tab.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qlz_flash_cards_ui/core/routes/app_routes.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_empty_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_error_view.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_loading_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/folder_model.dart';
import '../../data/repositories/library_repository.dart';
import '../../logic/cubit/folders_cubit.dart';
import '../../logic/states/folders_state.dart';
import '../widgets/folder_item.dart';

class FoldersTab extends StatefulWidget {
  const FoldersTab({super.key});

  @override
  State<FoldersTab> createState() => _FoldersTabState();
}

class _FoldersTabState extends State<FoldersTab> {
  late FoldersCubit _cubit;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initCubit();
  }

  Future<void> _initCubit() async {
    // Khởi tạo repository và cubit
    final prefs = await SharedPreferences.getInstance();
    final repository = LibraryRepository(Dio(), prefs);
    _cubit = FoldersCubit(repository);
    
    // Đánh dấu là đã khởi tạo và load dữ liệu
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
      _cubit.loadFolders();
    }
  }

  @override
  void dispose() {
    // Đảm bảo đóng cubit khi widget bị hủy
    if (_isInitialized) {
      _cubit.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return BlocProvider<FoldersCubit>.value(
      value: _cubit,
      child: BlocBuilder<FoldersCubit, FoldersState>(
        builder: (context, state) {
          if (state.status == FoldersStatus.loading && state.folders.isEmpty) {
            return const QlzLoadingState(
              type: QlzLoadingType.circular,
              message: '로딩 중...', // "Loading..." in Korean
            );
          }

          if (state.status == FoldersStatus.failure) {
            return QlzErrorView(
              message: state.errorMessage ?? 'Failed to load folders',
              onRetry: () => _cubit.refreshFolders(),
            );
          }

          if (state.folders.isEmpty) {
            return QlzEmptyState.noData(
              title: 'Chưa có thư mục nào',
              message: 'Tạo thư mục đầu tiên để tổ chức học phần của bạn',
              actionLabel: 'Tạo thư mục',
              onAction: () => Navigator.pushNamed(context, AppRoutes.createFolder),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _cubit.refreshFolders(),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              children: [
                if (state.status == FoldersStatus.loading && state.folders.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                // Wrap the list items in a Column to prevent overflow
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: state.folders.map((folder) => 
                    FolderItem(
                      folder: folder,
                      onTap: () => _onFolderTap(context, folder),
                    ),
                  ).toList(),
                ),
                // Add some bottom padding
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  void _onFolderTap(BuildContext context, Folder folder) {
    Navigator.pushNamed(
      context,
      AppRoutes.folderDetail,
      arguments: {
        'folderId': folder.id,
        'folderName': folder.name,
      },
    );
  }
}