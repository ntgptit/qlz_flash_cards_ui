// lib/features/module/presentation/screens/module_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qlz_flash_cards_ui/core/routes/app_routes.dart';
import 'package:qlz_flash_cards_ui/features/module/data/models/study_module_model.dart';
import 'package:qlz_flash_cards_ui/features/module/presentation/providers/module_detail_provider.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/buttons/qlz_button.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/cards/qlz_card.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/cards/qlz_flashcard_carousel.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_empty_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_loading_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/navigation/qlz_app_bar.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/utils/qlz_avatar.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/utils/qlz_chip.dart';

class ModuleDetailScreen extends ConsumerStatefulWidget {
  final String id;
  final String name;

  const ModuleDetailScreen({
    super.key,
    required this.id,
    required this.name,
  });

  @override
  ConsumerState<ModuleDetailScreen> createState() => _ModuleDetailScreenState();
}

class _ModuleDetailScreenState extends ConsumerState<ModuleDetailScreen> {
  @override
  void initState() {
    super.initState();

    // Tạo timer để kiểm tra timeout
    Future.delayed(const Duration(seconds: 15), () {
      if (mounted) {
        final provider = moduleDetailProvider(widget.id);
        final state = ref.read(provider);

        if (state.status == ModuleDetailStatus.loading) {
          ref.read(provider.notifier).setLoadingTimedOut(true);
        }
      }
    });

    // Sau khi widget được tải xong, load module details
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(moduleDetailProvider(widget.id).notifier)
          .loadModuleDetails(widget.id);
    });
  }

  void _navigateToBlastMode(StudyModule module) {
    if (module.flashcards.isEmpty) return;
    HapticFeedback.selectionClick();
  }

  void _navigateToFlashcardsMode(StudyModule module) {
    if (module.flashcards.isEmpty) return;
    HapticFeedback.selectionClick();
    AppRoutes.navigateToStudyFlashcards(
      context,
      flashcards: module.flashcards,
    );
  }

  void _navigateToLearningMode(StudyModule module) {
    if (module.flashcards.isEmpty) return;
    HapticFeedback.selectionClick();
    AppRoutes.navigateToLearn(
      context,
      flashcards: module.flashcards,
      moduleName: module.title,
      moduleId: module.id,
    );
  }

  void _navigateToQuizMode(StudyModule module) {
    if (module.flashcards.isEmpty) return;
    HapticFeedback.selectionClick();
    AppRoutes.navigateToQuizSettings(
      context,
      flashcards: module.flashcards,
      moduleName: module.title,
      moduleId: module.id,
    );
  }

  void _navigateToMatchMode(StudyModule module) {
    if (module.flashcards.isEmpty) return;
    HapticFeedback.selectionClick();
    Navigator.pushNamed(
      context,
      AppRoutes.match,
      arguments: {
        'flashcards': module.flashcards,
        'moduleName': module.title,
        'moduleId': module.id,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Sử dụng ref.watch để theo dõi state của provider
    final state = ref.watch(moduleDetailProvider(widget.id));

    // Xử lý timeout
    if (state.loadingTimedOut && state.status == ModuleDetailStatus.loading) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A092D),
        appBar: const QlzAppBar(
          backgroundColor: Colors.transparent,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.amber, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Tải dữ liệu quá lâu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Có thể có vấn đề với kết nối mạng hoặc máy chủ',
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              QlzButton(
                label: 'Thử lại',
                onPressed: () {
                  ref.read(moduleDetailProvider(widget.id).notifier)
                    ..setLoadingTimedOut(false)
                    ..loadModuleDetails(widget.id, forceRefresh: true);
                },
              ),
            ],
          ),
        ),
      );
    }

    // Xử lý trạng thái loading
    if (state.status == ModuleDetailStatus.loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A092D),
        appBar: QlzAppBar(
          backgroundColor: Colors.transparent,
        ),
        body: Center(
          child: QlzLoadingState(
            message: 'Đang tải học phần...',
          ),
        ),
      );
    }

    // Xử lý trạng thái lỗi
    if (state.status == ModuleDetailStatus.failure) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A092D),
        appBar: const QlzAppBar(
          backgroundColor: Colors.transparent,
        ),
        body: QlzEmptyState.error(
          title: 'Không thể tải học phần',
          message: state.errorMessage ?? 'Đã xảy ra lỗi khi tải học phần',
          onAction: () => ref
              .read(moduleDetailProvider(widget.id).notifier)
              .loadModuleDetails(widget.id, forceRefresh: true),
        ),
      );
    }

    // Xử lý trường hợp không tìm thấy module
    if (state.module == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A092D),
        appBar: const QlzAppBar(
          backgroundColor: Colors.transparent,
        ),
        body: QlzEmptyState.notFound(
          title: 'Không tìm thấy học phần',
          message: 'Học phần này không tồn tại hoặc đã bị xóa',
          onAction: () => Navigator.pop(context),
          actionLabel: 'Quay lại',
        ),
      );
    }

    // Hiển thị nội dung của module
    final module = state.module!;
    final hasFlashcards = module.flashcards.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF0A092D),
      appBar: QlzAppBar(
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              HapticFeedback.lightImpact();
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              HapticFeedback.lightImpact();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  if (hasFlashcards)
                    QlzFlashcardCarousel(
                      flashcards: module.flashcards,
                      height: 240,
                      initialPage: 0,
                      onFullscreen: (index) {
                        _navigateToFlashcardsMode(module);
                      },
                    )
                  else
                    const QlzCard(
                      height: 240,
                      child: Center(
                        child: Text(
                          'Chưa có thẻ ghi nhớ nào',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    module.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      QlzAvatar(
                        size: 32,
                        name: module.creatorName,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        module.creatorName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
                      ),
                      const SizedBox(width: 8),
                      if (module.hasPlusBadge)
                        const QlzChip(
                          label: 'Plus',
                          type: QlzChipType.primary,
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                        ),
                      const Spacer(),
                      QlzChip(
                        label: '${module.termCount} thuật ngữ',
                        type: QlzChipType.ghost,
                        icon: Icons.style_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white24, height: 1),
                ],
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 16),
                _buildStudyOption(
                  icon: Icons.style_outlined,
                  color: Colors.blue,
                  label: 'Thẻ ghi nhớ',
                  onTap: () => _navigateToFlashcardsMode(module),
                ),
                const SizedBox(height: 8),
                _buildStudyOption(
                  icon: Icons.refresh,
                  color: Colors.purple,
                  label: 'Học',
                  onTap: () => _navigateToLearningMode(module),
                ),
                const SizedBox(height: 8),
                _buildStudyOption(
                  icon: Icons.quiz_outlined,
                  color: Colors.green,
                  label: 'Kiểm tra',
                  onTap: () => _navigateToQuizMode(module),
                ),
                const SizedBox(height: 8),
                _buildStudyOption(
                  icon: Icons.compare_arrows,
                  color: Colors.orange,
                  label: 'Ghép thẻ',
                  onTap: () => _navigateToMatchMode(module),
                ),
                const SizedBox(height: 8),
                _buildStudyOption(
                  icon: Icons.rocket_launch,
                  color: Colors.blue,
                  label: 'Blast',
                  onTap: () => _navigateToBlastMode(module),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: QlzButton.secondary(
                        label: 'Chỉnh sửa',
                        icon: Icons.edit_outlined,
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: QlzButton.ghost(
                        label: 'Tải xuống',
                        icon: Icons.download_outlined,
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudyOption({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return QlzCard(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const Spacer(),
          const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white70,
            size: 16,
          ),
        ],
      ),
    );
  }
}
