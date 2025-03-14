import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qlz_flash_cards_ui/core/routes/app_routes.dart';
import 'package:qlz_flash_cards_ui/features/library/data/models/class_model.dart';
import 'package:qlz_flash_cards_ui/features/library/presentation/providers/classes_provider.dart';
import 'package:qlz_flash_cards_ui/features/library/presentation/widgets/class_item.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_empty_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_loading_state.dart';

/// Tab to display classes in the library screen
class ClassesTab extends ConsumerWidget {
  const ClassesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(classesProvider);

    // Loading state
    if (state.status == ClassesStatus.loading && state.classes.isEmpty) {
      return const QlzLoadingState(
        type: QlzLoadingType.circular,
        message: 'Đang tải lớp học...',
      );
    }

    // Error state
    if (state.status == ClassesStatus.failure) {
      return QlzEmptyState.error(
        title: 'Không thể tải lớp học',
        message: state.errorMessage ?? 'Đã xảy ra lỗi khi tải dữ liệu',
        onAction: () => ref.read(classesProvider.notifier).refreshClasses(),
      );
    }

    // Empty state
    if (state.classes.isEmpty) {
      return QlzEmptyState.noData(
        title: 'Chưa có lớp học',
        message:
            'Bạn chưa tham gia lớp học nào. Hãy tạo hoặc tham gia lớp học.',
        actionLabel: 'Tạo lớp học',
        onAction: () => Navigator.pushNamed(context, AppRoutes.createClass),
      );
    }

    // Content state with refresh capability
    return RefreshIndicator(
      onRefresh: () => ref.read(classesProvider.notifier).refreshClasses(),
      child: _buildClassesList(context, state, ref),
    );
  }

  Widget _buildClassesList(
      BuildContext context, ClassesState state, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: [
        // Loading indicator for refresh
        if (state.status == ClassesStatus.loading && state.classes.isNotEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          ),
        // List of classes
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: state.classes
              .map(
                (classModel) => ClassItem(
                  classModel: classModel,
                  onTap: () => _onClassTap(context, classModel),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _onClassTap(BuildContext context, ClassModel classModel) {
    AppRoutes.navigateToClassDetail(
      context,
      classId: classModel.id,
      className: classModel.name,
    );
  }
}
