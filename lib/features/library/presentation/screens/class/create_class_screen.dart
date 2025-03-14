import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/features/library/presentation/providers/classes_provider.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/buttons/qlz_button.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/cards/qlz_card.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_loading_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_snackbar.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/inputs/qlz_text_field.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/labels/qlz_label.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/layout/qlz_screen.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/navigation/qlz_app_bar.dart';

/// Screen for creating a new class
class CreateClassScreen extends ConsumerStatefulWidget {
  const CreateClassScreen({super.key});

  @override
  ConsumerState<CreateClassScreen> createState() => _CreateClassScreenState();
}

class _CreateClassScreenState extends ConsumerState<CreateClassScreen> {
  final _classNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _allowMembersToAdd = true;

  @override
  void dispose() {
    _classNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(classesProvider);

    // Listen for errors
    ref.listen(classesProvider, (previous, current) {
      if (current.errorMessage != null) {
        QlzSnackbar.error(
          context: context,
          message: current.errorMessage!,
        );
        ref.read(classesProvider.notifier).clearError();
      }
    });

    return QlzScreen(
      appBar: QlzAppBar(
        title: 'Lớp học mới',
        actions: [
          state.isCreating
              ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: _createClass,
                ),
        ],
      ),
      child: state.isCreating
          ? const Center(
              child: QlzLoadingState(
                message: 'Đang tạo lớp học...',
                type: QlzLoadingType.circular,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildClassInfoCard(),
                  _buildClassSettingsCard(),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: QlzButton.primary(
                      label: 'Tạo lớp học',
                      onPressed: _createClass,
                      isFullWidth: true,
                      icon: Icons.add_circle_outline,
                      size: QlzButtonSize.large,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildClassInfoCard() {
    final state = ref.watch(classesProvider);

    return QlzCard(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const QlzLabel(
            'THÔNG TIN LỚP HỌC',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          QlzTextField(
            label: 'Tên lớp *',
            controller: _classNameController,
            hintText: 'Nhập tên lớp học',
            isRequired: true,
            prefixIcon: Icons.class_outlined,
            error: state.validationError,
            onChanged: (_) {
              if (state.validationError != null) {
                ref.read(classesProvider.notifier).clearError();
              }
            },
          ),
          const SizedBox(height: 20),
          QlzTextField(
            label: 'Mô tả',
            controller: _descriptionController,
            hintText: 'Mô tả về lớp học này (tùy chọn)',
            isMultiline: true,
            prefixIcon: Icons.description_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildClassSettingsCard() {
    return QlzCard(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const QlzLabel(
            'CÀI ĐẶT LỚP HỌC',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quyền truy cập cho thành viên',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cho phép thành viên thêm học phần và mời thành viên mới',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Switch(
                value: _allowMembersToAdd,
                onChanged: (value) {
                  setState(() {
                    _allowMembersToAdd = value;
                  });
                },
                activeColor: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white12),
          const SizedBox(height: 12),
          QlzButton.ghost(
            label: 'Thêm cài đặt nâng cao',
            icon: Icons.settings_outlined,
            onPressed: () {
              // TODO: Implement advanced settings
            },
            size: QlzButtonSize.small,
          ),
        ],
      ),
    );
  }

  Future<void> _createClass() async {
    if (_classNameController.text.trim().isEmpty) {
      QlzSnackbar.error(
        context: context,
        message: 'Vui lòng nhập tên lớp học',
      );
      return;
    }

    final success = await ref.read(classesProvider.notifier).createClass(
          name: _classNameController.text.trim(),
          description: _descriptionController.text.trim(),
          allowMembersToAdd: _allowMembersToAdd,
        );

    if (success && mounted) {
      QlzSnackbar.success(
        context: context,
        message: 'Lớp học đã được tạo thành công',
      );
      Navigator.pop(context);
    }
  }
}
