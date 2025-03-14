// lib/features/folder/screens/create_folder_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qlz_flash_cards_ui/features/library/logic/cubit/folders_cubit.dart';
import 'package:qlz_flash_cards_ui/features/library/logic/states/folders_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/buttons/qlz_button.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/cards/qlz_card.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_snackbar.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/inputs/qlz_text_field.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/layout/qlz_screen.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/navigation/qlz_app_bar.dart';

final class CreateFolderScreen extends StatefulWidget {
  const CreateFolderScreen({super.key});

  @override
  State<CreateFolderScreen> createState() => _CreateFolderScreenState();
}

class _CreateFolderScreenState extends State<CreateFolderScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createFolder() async {
    final cubit = context.read<FoldersCubit>();

    final success = await cubit.createFolder(
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FoldersCubit, FoldersState>(
      listener: (context, state) {
        // Hiển thị lỗi nếu có
        if (state.errorMessage != null) {
          QlzSnackbar.error(
            context: context,
            message: state.errorMessage!,
          );
          // Xóa lỗi sau khi hiển thị
          context.read<FoldersCubit>().clearError();
        }
      },
      builder: (context, state) {
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
                          // Xóa lỗi validation khi người dùng nhập
                          if (state.validationError != null) {
                            context.read<FoldersCubit>().clearError();
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
      },
    );
  }
}
