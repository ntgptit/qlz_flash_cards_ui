// lib/features/library/presentation/tabs/classes_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qlz_flash_cards_ui/core/routes/app_routes.dart';
import 'package:qlz_flash_cards_ui/features/library/logic/cubit/classes_cubit.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_empty_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_loading_state.dart';

import '../../data/models/class_model.dart';
import '../../logic/states/classes_state.dart';
import '../widgets/class_item.dart';

/// Tab hiển thị danh sách lớp học
class ClassesTab extends StatelessWidget {
  const ClassesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClassesCubit, ClassesState>(
      builder: (context, state) {
        // Trạng thái loading - chưa có dữ liệu
        if (state.status == ClassesStatus.loading && state.classes.isEmpty) {
          return const QlzLoadingState(
            type: QlzLoadingType.circular,
            message: 'Đang tải lớp học...',
          );
        }

        // Trạng thái lỗi
        if (state.status == ClassesStatus.failure) {
          return QlzEmptyState.error(
            title: 'Không thể tải lớp học',
            message: state.errorMessage ?? 'Đã xảy ra lỗi khi tải dữ liệu',
            onAction: () => context.read<ClassesCubit>().refreshClasses(),
          );
        }

        // Trạng thái trống - không có dữ liệu
        if (state.classes.isEmpty) {
          return QlzEmptyState.noData(
            title: 'Chưa có lớp học',
            message:
                'Bạn chưa tham gia lớp học nào. Hãy tạo hoặc tham gia lớp học.',
            actionLabel: 'Tạo lớp học',
            onAction: () => Navigator.pushNamed(context, AppRoutes.createClass),
          );
        }

        // Trạng thái thành công - có dữ liệu
        return RefreshIndicator(
          onRefresh: () => context.read<ClassesCubit>().refreshClasses(),
          child: _buildClassesList(context, state),
        );
      },
    );
  }

  /// Xây dựng danh sách lớp học
  Widget _buildClassesList(BuildContext context, ClassesState state) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: [
        // Hiển thị loading nếu đang tải lại dữ liệu
        if (state.status == ClassesStatus.loading && state.classes.isNotEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          ),
        // Danh sách lớp học
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
        // Khoảng trống dưới cùng để đảm bảo UX
        const SizedBox(height: 16),
      ],
    );
  }

  /// Điều hướng đến màn hình chi tiết lớp học
  void _onClassTap(BuildContext context, ClassModel classModel) {
    // Navigate to class detail screen
    // Hiện chưa có màn hình chi tiết lớp học nên tạm thời chỉ in log
    debugPrint('Navigating to class ${classModel.name}');

    AppRoutes.navigateToClassDetail(
      context,
      classId: classModel.id,
      className: classModel.name,
    );
  }
}
