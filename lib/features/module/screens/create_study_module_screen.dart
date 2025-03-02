// lib/features/module/screens/create_study_module_screen.dart

import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/core/routes/app_routes.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/buttons/qlz_button.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/cards/qlz_card.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/inputs/qlz_text_field.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/labels/qlz_label.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/layout/qlz_screen.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/navigation/qlz_app_bar.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_loading_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_snackbar.dart';

final class CreateStudyModuleScreen extends StatefulWidget {
  const CreateStudyModuleScreen({super.key});

  @override
  State<CreateStudyModuleScreen> createState() =>
      _CreateStudyModuleScreenState();
}

class _CreateStudyModuleScreenState extends State<CreateStudyModuleScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<TextEditingController> _termControllers = [];
  final List<TextEditingController> _definitionControllers = [];
  final List<int> _vocabularyCards = [0, 1];
  final _scrollController = ScrollController();

  String? _titleError;
  Map<int, String?> _termErrors = {};
  Map<int, String?> _definitionErrors = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers for existing cards
    for (int i = 0; i < _vocabularyCards.length; i++) {
      _termControllers.add(TextEditingController());
      _definitionControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (var controller in _termControllers) {
      controller.dispose();
    }
    for (var controller in _definitionControllers) {
      controller.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _addNewCard() {
    final newIndex = _vocabularyCards.length;
    setState(() {
      _vocabularyCards.add(newIndex);
      _termControllers.add(TextEditingController());
      _definitionControllers.add(TextEditingController());
    });

    // Scroll to new card after it's added
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  bool _validateForm() {
    bool isValid = true;
    final title = _titleController.text.trim();
    Map<int, String?> newTermErrors = {};
    Map<int, String?> newDefinitionErrors = {};

    // Validate title
    if (title.isEmpty) {
      setState(() {
        _titleError = 'Vui lòng nhập tiêu đề';
      });
      isValid = false;
    } else {
      setState(() {
        _titleError = null;
      });
    }

    // Validate at least the first two cards
    for (int i = 0; i < 2; i++) {
      if (_termControllers[i].text.trim().isEmpty) {
        newTermErrors[i] = 'Vui lòng nhập thuật ngữ';
        isValid = false;
      }

      if (_definitionControllers[i].text.trim().isEmpty) {
        newDefinitionErrors[i] = 'Vui lòng nhập định nghĩa';
        isValid = false;
      }
    }

    // Check remaining cards if they have content
    for (int i = 2; i < _vocabularyCards.length; i++) {
      final term = _termControllers[i].text.trim();
      final definition = _definitionControllers[i].text.trim();

      // If one has content, the other should too
      if (term.isNotEmpty && definition.isEmpty) {
        newDefinitionErrors[i] = 'Vui lòng nhập định nghĩa';
        isValid = false;
      } else if (term.isEmpty && definition.isNotEmpty) {
        newTermErrors[i] = 'Vui lòng nhập thuật ngữ';
        isValid = false;
      }
    }

    setState(() {
      _termErrors = newTermErrors;
      _definitionErrors = newDefinitionErrors;
    });

    return isValid;
  }

  Future<void> _handleSave() async {
    if (!_validateForm()) {
      QlzSnackbar.error(
        context: context,
        message: 'Vui lòng kiểm tra lại các trường bắt buộc',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      // Show success message and pop
      QlzSnackbar.success(
        context: context,
        message: 'Học phần đã được tạo thành công',
      );

      // Return to previous screen
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        QlzSnackbar.error(
          context: context,
          message: 'Có lỗi xảy ra. Vui lòng thử lại sau.',
        );
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return QlzScreen(
      appBar: QlzAppBar(
        title: 'Tạo học phần',
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.moduleSettings,
            ),
          ),
          _isSubmitting
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
                  onPressed: _handleSave,
                ),
        ],
      ),
      // floatingActionButton: null,
      child: _isSubmitting
          ? const Center(
              child: QlzLoadingState(
                message: 'Đang tạo học phần...',
                type: QlzLoadingType.circular,
              ),
            )
          : SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const QlzLabel.muted('Chủ đề, chương, đơn vị'),
                  const SizedBox(height: 16),
                  _buildModuleInfoCard(),
                  _buildVocabularyCardsList(),
                  const SizedBox(height: 20),
                  Center(
                    child: QlzButton.secondary(
                      label: 'Thêm thẻ',
                      icon: Icons.add,
                      onPressed: _addNewCard,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildModuleInfoCard() {
    return QlzCard(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const QlzLabel('TIÊU ĐỀ'),
          const SizedBox(height: 12),
          Row(
            children: [
              QlzButton.secondary(
                label: 'Quét tài liệu',
                icon: Icons.document_scanner_outlined,
                onPressed: () {
                  // TODO: Implement scan functionality
                },
                size: QlzButtonSize.small,
              ),
              const SizedBox(width: 8),
              QlzButton.ghost(
                label: 'Nhập',
                icon: Icons.upload_file_outlined,
                onPressed: () {},
                size: QlzButtonSize.small,
              ),
            ],
          ),
          const SizedBox(height: 16),
          QlzTextField(
            controller: _titleController,
            hintText: 'Học phần của bạn có chủ đề gì?',
            error: _titleError,
            onChanged: (_) => setState(() => _titleError = null),
          ),
          const SizedBox(height: 20),
          const QlzLabel('MÔ TẢ'),
          const SizedBox(height: 12),
          QlzTextField(
            controller: _descriptionController,
            hintText: 'Thêm mô tả...',
            isMultiline: true,
          ),
        ],
      ),
    );
  }

  Widget _buildVocabularyCardsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _vocabularyCards.length,
      itemBuilder: (context, index) => _buildVocabularyCard(index),
    );
  }

  Widget _buildVocabularyCard(int index) {
    final isRequired = index < 2;

    return QlzCard(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              QlzLabel('THUẬT NGỮ ${isRequired ? "*" : ""}'),
              const Spacer(),
              QlzLabel.secondary('${index + 1}'),
              const SizedBox(width: 8),
              if (index > 1)
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _vocabularyCards.removeAt(index);
                      final controller = _termControllers.removeAt(index);
                      controller.dispose();
                      final defController =
                          _definitionControllers.removeAt(index);
                      defController.dispose();

                      // Update errors
                      final newTermErrors = Map<int, String?>.from(_termErrors);
                      final newDefErrors =
                          Map<int, String?>.from(_definitionErrors);
                      newTermErrors.remove(index);
                      newDefErrors.remove(index);
                      _termErrors = newTermErrors;
                      _definitionErrors = newDefErrors;
                    });
                  },
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  padding: EdgeInsets.zero,
                  splashRadius: 20,
                ),
            ],
          ),
          const SizedBox(height: 12),
          QlzTextField(
            controller: _termControllers[index],
            hintText: 'Nhập thuật ngữ...',
            error: _termErrors[index],
            onChanged: (_) {
              if (_termErrors.containsKey(index)) {
                setState(() {
                  final newErrors = Map<int, String?>.from(_termErrors);
                  newErrors.remove(index);
                  _termErrors = newErrors;
                });
              }
            },
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              QlzLabel('ĐỊNH NGHĨA ${isRequired ? "*" : ""}'),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          QlzTextField(
            controller: _definitionControllers[index],
            hintText: 'Nhập định nghĩa...',
            isMultiline: true,
            error: _definitionErrors[index],
            onChanged: (_) {
              if (_definitionErrors.containsKey(index)) {
                setState(() {
                  final newErrors = Map<int, String?>.from(_definitionErrors);
                  newErrors.remove(index);
                  _definitionErrors = newErrors;
                });
              }
            },
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              QlzButton.ghost(
                label: 'Thêm ví dụ',
                icon: Icons.add,
                onPressed: () {},
                size: QlzButtonSize.small,
              ),
              const SizedBox(width: 8),
              QlzButton.ghost(
                label: 'Thêm hình ảnh',
                icon: Icons.image_outlined,
                onPressed: () {},
                size: QlzButtonSize.small,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
