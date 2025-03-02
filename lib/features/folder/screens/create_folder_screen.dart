// lib/features/screens/folder/create_folder_screen.dart

import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/buttons/qlz_button.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/cards/qlz_card.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/inputs/qlz_text_field.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/layout/qlz_screen.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/navigation/qlz_app_bar.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_snackbar.dart';

final class CreateFolderScreen extends StatefulWidget {
  const CreateFolderScreen({super.key});

  @override
  State<CreateFolderScreen> createState() => _CreateFolderScreenState();
}

class _CreateFolderScreenState extends State<CreateFolderScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _titleError;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _titleError = _titleController.text.trim().isEmpty
          ? 'Tiêu đề không được để trống'
          : null;
    });
  }

  Future<void> _createFolder() async {
    _validateForm();

    if (_titleError != null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement folder creation logic with API call
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        Navigator.pop(context);
        QlzSnackbar.success(
          context: context,
          message: 'Thư mục đã được tạo thành công',
        );
      }
    } catch (e) {
      if (mounted) {
        QlzSnackbar.error(
          context: context,
          message: 'Không thể tạo thư mục. Vui lòng thử lại sau.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return QlzScreen(
      appBar: QlzAppBar(
        title: 'Thư mục mới',
        actions: [
          QlzButton.primary(
            label: 'Tạo',
            onPressed: _isLoading ? null : _createFolder,
            size: QlzButtonSize.small,
            isLoading: _isLoading,
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
                    error: _titleError,
                    onChanged: (_) => setState(() => _titleError = null),
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
                onPressed: _isLoading ? null : _createFolder,
                isFullWidth: true,
                icon: Icons.create_new_folder_outlined,
                size: QlzButtonSize.large,
                isLoading: _isLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
