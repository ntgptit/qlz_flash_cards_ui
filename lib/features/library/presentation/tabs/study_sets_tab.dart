// lib/features/library/presentation/tabs/study_sets_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qlz_flash_cards_ui/core/routes/app_routes.dart';
import 'package:qlz_flash_cards_ui/features/library/logic/cubit/study_sets_cubit.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_empty_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_loading_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/header/qlz_section_header.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/inputs/qlz_text_field.dart';

import '../../data/models/study_set_model.dart';
import '../../logic/states/study_sets_state.dart';
import '../widgets/filter_dropdown.dart';
import '../widgets/study_set_item.dart';

/// Tab hiển thị danh sách học phần
class StudySetsTab extends StatelessWidget {
  const StudySetsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StudySetsCubit, StudySetsState>(
      builder: (context, state) {
        // Trạng thái loading - chưa có dữ liệu
        if (state.status == StudySetsStatus.loading &&
            state.studySets.isEmpty) {
          return const QlzLoadingState(
            type: QlzLoadingType.circular,
            message: 'Đang tải học phần...',
          );
        }

        // Trạng thái lỗi
        if (state.status == StudySetsStatus.failure) {
          return QlzEmptyState.error(
            title: 'Không thể tải học phần',
            message: state.errorMessage ?? 'Đã xảy ra lỗi khi tải dữ liệu',
            onAction: () => context.read<StudySetsCubit>().refreshStudySets(),
          );
        }

        // Trạng thái trống - không có dữ liệu
        if (state.studySets.isEmpty) {
          return QlzEmptyState.noData(
            title: 'Chưa có học phần',
            message:
                'Bạn chưa có học phần nào. Hãy tạo học phần mới để bắt đầu.',
            actionLabel: 'Tạo học phần',
            onAction: () =>
                Navigator.pushNamed(context, AppRoutes.createStudyModule),
          );
        }

        // Trạng thái thành công - có dữ liệu
        return RefreshIndicator(
          onRefresh: () => context.read<StudySetsCubit>().refreshStudySets(),
          child: _buildStudySetsList(context, state),
        );
      },
    );
  }

  /// Xây dựng danh sách học phần
  Widget _buildStudySetsList(BuildContext context, StudySetsState state) {
    final filterOptions = ['Tất cả', 'Của tôi', 'Đã học', 'Đã tải xuống'];
    final selectedFilter = state.filter ?? filterOptions.first;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        const SizedBox(height: 16),
        // Dropdown lọc học phần
        FilterDropdown(
          options: filterOptions,
          selectedOption: selectedFilter,
          onSelected: (value) {
            context.read<StudySetsCubit>().applyFilter(value);
          },
        ),
        const SizedBox(height: 16),
        // Trường tìm kiếm
        QlzTextField.search(
          hintText: 'Tìm kiếm học phần...',
          onChanged: (value) {
            // Chức năng tìm kiếm sẽ được triển khai sau
          },
        ),
        const SizedBox(height: 16),
        // Tiêu đề phần
        const QlzSectionHeader(
          title: 'Gần đây',
        ),
        const SizedBox(height: 8),
        // Hiển thị loading nếu đang tải lại dữ liệu
        if (state.status == StudySetsStatus.loading &&
            state.studySets.isNotEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          ),
        // Danh sách học phần
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: state.studySets
              .map(
                (studySet) => StudySetItem(
                  studySet: studySet,
                  onTap: () => _navigateToStudySetDetail(context, studySet),
                ),
              )
              .toList(),
        ),
        // Khoảng trống dưới cùng để đảm bảo UX
        const SizedBox(height: 16),
      ],
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
