import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/buttons/qlz_button.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/cards/qlz_card.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_snackbar.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/inputs/qlz_text_field.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/layout/qlz_screen.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/navigation/qlz_app_bar.dart';

/// Screen for creating a new folder
class CreateFolderScreen extends ConsumerStatefulWidget {
  const CreateFolderScreen({super.key});

  @override
  ConsumerState<CreateFolderScreen> createState() => _CreateFolderScreenState();
}

class _CreateFolderScreenState extends ConsumerState<CreateFolderScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(foldersProvider);

    // Listen for errors or validation issues
    ref.listen(foldersProvider, (previous, current) {
      if (current.errorMessage != null) {
        QlzSnackbar.error(
          context: context,
          message: current.errorMessage!,
        );
        ref.read(foldersProvider.notifier).clearError();
      }
    });

    return QlzScreen(
      appBar: QlzAppBar(
        title: 'Thư mục mới',
        actions: [
          QlzButton.primary(
            label: 'Tạo',
            onPressed: state.isCreating ? null : _createFolder,
            size: QlzButtonSize.small,
            isLoading: state.isCreating,
          ),
        ],
      ),
      withScrollView: true,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            QlzCard(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thông tin thư mục',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  QlzTextField(
                    label: 'Tiêu đề',
                    controller: _titleController,
                    hintText: 'Nhập tiêu đề thư mục',
                    isRequired: true,
                    prefixIcon: Icons.folder_outlined,
                    error: state.validationError,
                    onChanged: (_) {
                      if (state.validationError != null) {
                        ref.read(foldersProvider.notifier).clearError();
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  QlzTextField(
                    label: 'Mô tả',
                    controller: _descriptionController,
                    hintText: 'Mô tả về thư mục này (tùy chọn)',
                    isMultiline: true,
                    prefixIcon: Icons.description_outlined,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: QlzButton.primary(
                label: 'Tạo thư mục',
                onPressed: state.isCreating ? null : _createFolder,
                isFullWidth: true,
                icon: Icons.create_new_folder_outlined,
                size: QlzButtonSize.large,
                isLoading: state.isCreating,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createFolder() async {
    final success = await ref.read(foldersProvider.notifier).createFolder(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
        );

    if (success && mounted) {
      QlzSnackbar.success(
        context: context,
        message: 'Thư mục đã được tạo thành công',
      );
      Navigator.pop(context);
    }
  }
}
