import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qlz_flash_cards_ui/core/routes/app_routes.dart';
import 'package:qlz_flash_cards_ui/features/library/data/models/folder_model.dart';
import 'package:qlz_flash_cards_ui/features/library/domain/states/folders_state.dart';
import 'package:qlz_flash_cards_ui/features/library/presentation/providers/folders_provider.dart';
import 'package:qlz_flash_cards_ui/features/library/presentation/widgets/folder_item.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_empty_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_loading_state.dart';

/// Tab to display folders in the library screen
class FoldersTab extends ConsumerWidget {
  const FoldersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(foldersProvider);

    // Loading state
    if (state.status == FoldersStatus.loading && state.folders.isEmpty) {
      return const QlzLoadingState(
        type: QlzLoadingType.circular,
        message: 'Đang tải thư mục...',
      );
    }

    // Error state
    if (state.status == FoldersStatus.failure) {
      return QlzEmptyState.error(
        title: 'Không thể tải thư mục',
        message: state.errorMessage ?? 'Đã xảy ra lỗi khi tải dữ liệu',
        onAction: () => ref.read(foldersProvider.notifier).refreshFolders(),
      );
    }

    // Empty state
    if (state.folders.isEmpty) {
      return QlzEmptyState.noData(
        title: 'Chưa có thư mục',
        message:
            'Bạn chưa có thư mục nào. Hãy tạo thư mục mới để tổ chức học phần.',
        actionLabel: 'Tạo thư mục',
        onAction: () => Navigator.pushNamed(context, AppRoutes.createFolder),
      );
    }

    // Content state with refresh capability
    return RefreshIndicator(
      onRefresh: () => ref.read(foldersProvider.notifier).refreshFolders(),
      child: _buildFoldersList(context, state, ref),
    );
  }

  Widget _buildFoldersList(
      BuildContext context, FoldersState state, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: [
        // Loading indicator for refresh
        if (state.status == FoldersStatus.loading && state.folders.isNotEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          ),
        // List of folders
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: state.folders
              .map(
                (folder) => FolderItem(
                  folder: folder,
                  onTap: () => _navigateToFolderDetail(context, folder),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _navigateToFolderDetail(BuildContext context, Folder folder) {
    AppRoutes.navigateToFolderDetail(
      context,
      folderId: folder.id,
      folderName: folder.name,
    );
  }
}
