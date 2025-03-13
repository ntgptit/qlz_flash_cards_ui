// C:/Users/ntgpt/OneDrive/workspace/qlz_flash_cards_ui/lib/features/module/screens/create_study_module_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/core/routes/app_routes.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/data/models/flashcard_model.dart';
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
  State<CreateStudyModuleScreen> createState() =>
      _CreateStudyModuleScreenState();
}

class _CreateStudyModuleScreenState extends State<CreateStudyModuleScreen> {
  final _scrollController = ScrollController();

  // Quản lý TextEditingController với Maps
  final Map<int, TextEditingController> _termControllers = {};
  final Map<int, TextEditingController> _definitionControllers = {};
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Lắng nghe thay đổi trong state để cập nhật controllers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeControllers();
    });
  }

  void _initializeControllers() {
    final state = context.read<CreateModuleCubit>().state;
    _titleController.text = state.title;
    _descriptionController.text = state.description;

    for (int i = 0; i < state.flashcards.length; i++) {
      _getTermController(i, state.flashcards[i].term);
      _getDefinitionController(i, state.flashcards[i].definition);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();

    // Giải phóng tất cả controllers
    _termControllers.forEach((_, controller) => controller.dispose());
    _definitionControllers.forEach((_, controller) => controller.dispose());

    super.dispose();
  }

  // Lấy hoặc tạo TextEditingController cho term
  TextEditingController _getTermController(int index, String initialText) {
    if (!_termControllers.containsKey(index)) {
      _termControllers[index] = TextEditingController(text: initialText);
      _termControllers[index]!.addListener(() {
        context
            .read<CreateModuleCubit>()
            .updateFlashcardTerm(index, _termControllers[index]!.text);
      });
    }
    return _termControllers[index]!;
  }

  // Lấy hoặc tạo TextEditingController cho definition
  TextEditingController _getDefinitionController(
      int index, String initialText) {
    if (!_definitionControllers.containsKey(index)) {
      _definitionControllers[index] = TextEditingController(text: initialText);
      _definitionControllers[index]!.addListener(() {
        context.read<CreateModuleCubit>().updateFlashcardDefinition(
            index, _definitionControllers[index]!.text);
      });
    }
    return _definitionControllers[index]!;
  }

  void _addNewCard() {
    HapticFeedback.selectionClick();
    context.read<CreateModuleCubit>().addFlashcard();

    // Scroll xuống sau khi thêm thẻ mới
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

  // Cập nhật controllers khi flashcards thay đổi
  void _updateControllersFromState(List<Flashcard> flashcards) {
    for (int i = 0; i < flashcards.length; i++) {
      final flashcard = flashcards[i];

      if (_termControllers.containsKey(i) &&
          _termControllers[i]!.text != flashcard.term) {
        _termControllers[i]!.text = flashcard.term;
      }

      if (_definitionControllers.containsKey(i) &&
          _definitionControllers[i]!.text != flashcard.definition) {
        _definitionControllers[i]!.text = flashcard.definition;
      }
    }
  }

  Future<void> _handleSave() async {
    HapticFeedback.mediumImpact();

    final result = await context.read<CreateModuleCubit>().submitModule();
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
    return BlocConsumer<CreateModuleCubit, CreateModuleState>(
      listener: (context, state) {
        // Cập nhật controllers khi state thay đổi
        _updateControllersFromState(state.flashcards);
      },
      builder: (context, state) {
        final isSubmitting = state.status == CreateModuleStatus.submitting;

        return QlzScreen(
          appBar: QlzAppBar(
            title: 'Tạo học phần',
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pushNamed(
                    context,
                    AppRoutes.moduleSettings,
                  );
                },
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
                onPressed: () {
                  HapticFeedback.lightImpact();
                },
                size: QlzButtonSize.small,
              ),
              const SizedBox(width: 8),
              QlzButton.ghost(
                label: 'Nhập',
                icon: Icons.upload_file_outlined,
                onPressed: () {
                  HapticFeedback.lightImpact();
                },
                size: QlzButtonSize.small,
              ),
            ],
          ),
          const SizedBox(height: 16),
          QlzTextField(
            hintText: 'Học phần của bạn có chủ đề gì?',
            error: state.titleError,
            controller: _titleController,
            onChanged: (value) =>
                context.read<CreateModuleCubit>().updateTitle(value),
          ),
          const SizedBox(height: 20),
          const QlzLabel('MÔ TẢ'),
          const SizedBox(height: 12),
          QlzTextField(
            hintText: 'Thêm mô tả...',
            isMultiline: true,
            controller: _descriptionController,
            onChanged: (value) =>
                context.read<CreateModuleCubit>().updateDescription(value),
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
      itemBuilder: (context, index) =>
          _buildVocabularyCard(context, index, state),
    );
  }

  Widget _buildVocabularyCard(
      BuildContext context, int index, CreateModuleState state) {
    final isRequired = index < 2;
    final flashcard = state.flashcards[index];

    // Sử dụng controller đã tạo
    final termController = _getTermController(index, flashcard.term);
    final definitionController =
        _getDefinitionController(index, flashcard.definition);

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
                    HapticFeedback.mediumImpact();
                    context.read<CreateModuleCubit>().removeFlashcard(index);

                    // Xóa controllers khi xóa flashcard
                    _termControllers.remove(index)?.dispose();
                    _definitionControllers.remove(index)?.dispose();
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
            hintText: 'Nhập thuật ngữ...',
            error: state.termErrors[index],
            controller: termController,
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
            controller: definitionController,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              QlzButton.ghost(
                label: 'Thêm ví dụ',
                icon: Icons.add,
                onPressed: () {
                  HapticFeedback.lightImpact();
                },
                size: QlzButtonSize.small,
              ),
              const SizedBox(width: 8),
              QlzButton.ghost(
                label: 'Thêm hình ảnh',
                icon: Icons.image_outlined,
                onPressed: () {
                  HapticFeedback.lightImpact();
                },
                size: QlzButtonSize.small,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
