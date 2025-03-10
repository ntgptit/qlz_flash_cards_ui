// lib/features/library/presentation/tabs/folders_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qlz_flash_cards_ui/core/routes/app_routes.dart';
import 'package:qlz_flash_cards_ui/features/library/logic/cubit/folders_cubit.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_empty_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_loading_state.dart';

import '../../data/models/folder_model.dart';
import '../../logic/states/folders_state.dart';
import '../widgets/folder_item.dart';

/// Tab hiển thị danh sách thư mục
class FoldersTab extends StatelessWidget {
  const FoldersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FoldersCubit, FoldersState>(
      builder: (context, state) {
        // Trạng thái loading - chưa có dữ liệu
        if (state.status == FoldersStatus.loading && state.folders.isEmpty) {
          return const QlzLoadingState(
            type: QlzLoadingType.circular,
            message: 'Đang tải thư mục...',
          );
        }

        // Trạng thái lỗi
        if (state.status == FoldersStatus.failure) {
          return QlzEmptyState.error(
            title: 'Không thể tải thư mục',
            message: state.errorMessage ?? 'Đã xảy ra lỗi khi tải dữ liệu',
            onAction: () => context.read<FoldersCubit>().refreshFolders(),
          );
        }

        // Trạng thái trống - không có dữ liệu
        if (state.folders.isEmpty) {
          return QlzEmptyState.noData(
            title: 'Chưa có thư mục',
            message:
                'Bạn chưa có thư mục nào. Hãy tạo thư mục mới để tổ chức học phần.',
            actionLabel: 'Tạo thư mục',
            onAction: () =>
                Navigator.pushNamed(context, AppRoutes.createFolder),
          );
        }

        // Trạng thái thành công - có dữ liệu
        return RefreshIndicator(
          onRefresh: () => context.read<FoldersCubit>().refreshFolders(),
          child: _buildFoldersList(context, state),
        );
      },
    );
  }

  /// Xây dựng danh sách thư mục
  Widget _buildFoldersList(BuildContext context, FoldersState state) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: [
        // Hiển thị loading nếu đang tải lại dữ liệu
        if (state.status == FoldersStatus.loading && state.folders.isNotEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          ),
        // Danh sách thư mục
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
        // Khoảng trống dưới cùng để đảm bảo UX
        const SizedBox(height: 16),
      ],
    );
  }

  /// Điều hướng đến màn hình chi tiết thư mục
  void _navigateToFolderDetail(BuildContext context, Folder folder) {
    AppRoutes.navigateToFolderDetail(
      context,
      folderId: folder.id,
      folderName: folder.name,
    );
  }
}
