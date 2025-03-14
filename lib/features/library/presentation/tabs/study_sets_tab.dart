import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qlz_flash_cards_ui/core/routes/app_routes.dart';
import 'package:qlz_flash_cards_ui/features/library/data/models/study_set_model.dart';
import 'package:qlz_flash_cards_ui/features/library/presentation/providers/study_sets_provider.dart';
import 'package:qlz_flash_cards_ui/features/library/presentation/widgets/filter_dropdown.dart';
import 'package:qlz_flash_cards_ui/features/library/presentation/widgets/study_set_item.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_empty_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_loading_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/header/qlz_section_header.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/inputs/qlz_text_field.dart';

/// Tab to display study sets in the library screen
class StudySetsTab extends ConsumerWidget {
  const StudySetsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studySetsProvider);

    // Loading state
    if (state.status == StudySetsStatus.loading && state.studySets.isEmpty) {
      return const QlzLoadingState(
        type: QlzLoadingType.circular,
        message: 'Đang tải học phần...',
      );
    }

    // Error state
    if (state.status == StudySetsStatus.failure) {
      return QlzEmptyState.error(
        title: 'Không thể tải học phần',
        message: state.errorMessage ?? 'Đã xảy ra lỗi khi tải dữ liệu',
        onAction: () => ref.read(studySetsProvider.notifier).refreshStudySets(),
      );
    }

    // Empty state
    if (state.studySets.isEmpty) {
      return QlzEmptyState.noData(
        title: 'Chưa có học phần',
        message: 'Bạn chưa có học phần nào. Hãy tạo học phần mới để bắt đầu.',
        actionLabel: 'Tạo học phần',
        onAction: () =>
            Navigator.pushNamed(context, AppRoutes.createStudyModule),
      );
    }

    // Content state with refresh capability
    return RefreshIndicator(
      onRefresh: () => ref.read(studySetsProvider.notifier).refreshStudySets(),
      child: _buildStudySetsList(context, state, ref),
    );
  }

  Widget _buildStudySetsList(
      BuildContext context, StudySetsState state, WidgetRef ref) {
    final filterOptions = ['Tất cả', 'Của tôi', 'Đã học', 'Đã tải xuống'];
    final selectedFilter = state.filter ?? filterOptions.first;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        const SizedBox(height: 16),
        // Filter dropdown
        FilterDropdown(
          options: filterOptions,
          selectedOption: selectedFilter,
          onSelected: (value) {
            ref.read(studySetsProvider.notifier).applyFilter(value);
          },
        ),
        const SizedBox(height: 16),
        // Search field
        QlzTextField.search(
          hintText: 'Tìm kiếm học phần...',
          onChanged: (value) {
            // TODO: Implement search functionality
          },
        ),
        const SizedBox(height: 16),
        // Section header
        const QlzSectionHeader(
          title: 'Gần đây',
        ),
        const SizedBox(height: 8),
        // Loading indicator for refresh
        if (state.status == StudySetsStatus.loading &&
            state.studySets.isNotEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          ),
        // List of study sets
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
        const SizedBox(height: 16),
      ],
    );
  }

  void _navigateToStudySetDetail(BuildContext context, StudySet studySet) {
    AppRoutes.navigateToModuleDetail(
      context,
      moduleId: studySet.id,
      moduleName: studySet.title,
    );
  }
}
