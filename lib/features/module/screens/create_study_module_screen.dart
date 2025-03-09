import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/core/routes/app_routes.dart';
import 'package:qlz_flash_cards_ui/features/module/data/repositories/module_repository.dart';
import 'package:qlz_flash_cards_ui/features/module/logic/cubit/create_module_cubit.dart';
import 'package:qlz_flash_cards_ui/features/module/logic/states/create_module_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/buttons/qlz_button.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/cards/qlz_card.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_loading_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_snackbar.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/inputs/qlz_text_field.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/labels/qlz_label.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/layout/qlz_screen.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/navigation/qlz_app_bar.dart';

class CreateStudyModuleScreen extends StatefulWidget {
  const CreateStudyModuleScreen({super.key});
  @override
  State<CreateStudyModuleScreen> createState() => _CreateStudyModuleScreenState();
}

class _CreateStudyModuleScreenState extends State<CreateStudyModuleScreen> {
  final _scrollController = ScrollController();
  late CreateModuleCubit _cubit;
  
  @override
  void initState() {
    super.initState();
    _cubit = CreateModuleCubit(context.read<ModuleRepository>());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _addNewCard() {
    _cubit.addFlashcard();
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

  Future<void> _handleSave() async {
    final result = await _cubit.submitModule();
    if (!mounted) return;
    if (result) {
      QlzSnackbar.success(
        context: context,
        message: 'Học phần đã được tạo thành công',
      );
      Navigator.pop(context);
    } else {
      QlzSnackbar.error(
        context: context,
        message: 'Vui lòng kiểm tra lại các trường bắt buộc',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<CreateModuleCubit, CreateModuleState>(
        builder: (context, state) {
          final isSubmitting = state.status == CreateModuleStatus.submitting;
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
                isSubmitting
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
            child: isSubmitting
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
                        _buildModuleInfoCard(state),
                        _buildVocabularyCardsList(state),
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
        },
      ),
    );
  }

  Widget _buildModuleInfoCard(CreateModuleState state) {
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
                onPressed: () {},
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
            hintText: 'Học phần của bạn có chủ đề gì?',
            error: state.titleError,
            onChanged: (value) => _cubit.updateTitle(value),
          ),
          const SizedBox(height: 20),
          const QlzLabel('MÔ TẢ'),
          const SizedBox(height: 12),
          QlzTextField(
            hintText: 'Thêm mô tả...',
            isMultiline: true,
            onChanged: (value) => _cubit.updateDescription(value),
          ),
        ],
      ),
    );
  }

  Widget _buildVocabularyCardsList(CreateModuleState state) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.flashcards.length,
      itemBuilder: (context, index) => _buildVocabularyCard(context, index, state),
    );
  }

  Widget _buildVocabularyCard(BuildContext context, int index, CreateModuleState state) {
    final isRequired = index < 2;
    final flashcard = state.flashcards[index];
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
                  onPressed: () => _cubit.removeFlashcard(index),
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
            hintText: 'Nhập thuật ngữ...',
            error: state.termErrors[index],
            onChanged: (value) => _cubit.updateFlashcardTerm(index, value),
            controller: TextEditingController(text: flashcard.term),
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
            hintText: 'Nhập định nghĩa...',
            isMultiline: true,
            error: state.definitionErrors[index],
            onChanged: (value) => _cubit.updateFlashcardDefinition(index, value),
            controller: TextEditingController(text: flashcard.definition),
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