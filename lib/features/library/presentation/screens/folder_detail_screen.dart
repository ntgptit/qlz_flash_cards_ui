// lib/features/library/presentation/screens/folder_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qlz_flash_cards_ui/core/routes/app_routes.dart';
import 'package:qlz_flash_cards_ui/features/library/logic/cubit/study_sets_cubit.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_empty_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_loading_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/navigation/qlz_app_bar.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/utils/qlz_chip.dart';

import '../../data/models/study_set_model.dart';
import '../../logic/states/study_sets_state.dart';
import '../widgets/study_set_item.dart';

/// Màn hình hiển thị chi tiết thư mục và danh sách học phần trong thư mục
class FolderDetailScreen extends StatelessWidget {
  final String folderId;
  final String folderName;

  const FolderDetailScreen({
    super.key,
    required this.folderId,
    required this.folderName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A092D),
      appBar: QlzAppBar(
        title: folderName,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<StudySetsCubit, StudySetsState>(
        builder: (context, state) {
          // Trạng thái loading - chưa có dữ liệu
          if (state.status == StudySetsStatus.loading &&
              state.studySets.isEmpty) {
            return const Center(
              child: QlzLoadingState(
                message: 'Đang tải học phần...',
                type: QlzLoadingType.circular,
              ),
            );
          }

          // Trạng thái lỗi
          if (state.status == StudySetsStatus.failure) {
            return QlzEmptyState.error(
              title: 'Không thể tải học phần',
              message: state.errorMessage ?? 'Đã xảy ra lỗi khi tải dữ liệu',
              onAction: () => context
                  .read<StudySetsCubit>()
                  .refreshStudySetsByFolder(folderId),
            );
          }

          // Trạng thái trống - không có dữ liệu
          if (state.studySets.isEmpty) {
            return QlzEmptyState.noData(
              title: 'Chưa có học phần',
              message: 'Thư mục này chưa có học phần nào',
              actionLabel: 'Tạo học phần',
              onAction: () {
                Navigator.pushNamed(
                  context,
                  '/create-study-module',
                );
              },
            );
          }

          // Trạng thái thành công - có dữ liệu
          return RefreshIndicator(
            onRefresh: () => context
                .read<StudySetsCubit>()
                .refreshStudySetsByFolder(folderId),
            child: _buildStudySetsList(context, state),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/create-study-module',
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  /// Xây dựng danh sách học phần trong thư mục
  Widget _buildStudySetsList(BuildContext context, StudySetsState state) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tất cả học phần',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                QlzChip(
                  label: 'Sắp xếp',
                  icon: Icons.sort,
                  type: QlzChipType.ghost,
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: state.status == StudySetsStatus.loading &&
                      state.studySets.isNotEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _buildStudySetsListView(context, state.studySets),
            ),
          ],
        ),
      ),
    );
  }

  /// Xây dựng ListView cho danh sách học phần
  Widget _buildStudySetsListView(
      BuildContext context, List<StudySet> studySets) {
    return ListView.builder(
      itemCount: studySets.length,
      itemBuilder: (context, index) {
        final studySet = studySets[index];
        return StudySetItem(
          studySet: studySet,
          onTap: () => _navigateToStudySetDetail(context, studySet),
        );
      },
    );
  }

  /// Điều hướng đến màn hình chi tiết học phần
  void _navigateToStudySetDetail(BuildContext context, StudySet studySet) {
    AppRoutes.navigateToModuleDetail(
      context,
      moduleId: studySet.id,
      moduleName: studySet.title,
    );
  }
}
