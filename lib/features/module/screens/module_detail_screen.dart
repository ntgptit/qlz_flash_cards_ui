import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qlz_flash_cards_ui/core/routes/app_routes.dart';
import 'package:qlz_flash_cards_ui/features/module/data/models/study_module_model.dart';
import 'package:qlz_flash_cards_ui/features/module/data/repositories/module_repository.dart';
import 'package:qlz_flash_cards_ui/features/module/logic/cubit/module_detail_cubit.dart';
import 'package:qlz_flash_cards_ui/features/module/logic/states/module_detail_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/buttons/qlz_button.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/cards/qlz_card.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/cards/qlz_flashcard_carousel.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_empty_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_loading_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/navigation/qlz_app_bar.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/utils/qlz_avatar.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/utils/qlz_chip.dart';

class ModuleDetailScreen extends StatefulWidget {
  final String id;
  final String name;
  const ModuleDetailScreen({
    super.key,
    required this.id,
    required this.name,
  });
  @override
  State<ModuleDetailScreen> createState() => _ModuleDetailScreenState();
}

class _ModuleDetailScreenState extends State<ModuleDetailScreen> {
  late ModuleDetailCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = ModuleDetailCubit(context.read<ModuleRepository>());
    _cubit.loadModuleDetails(widget.id);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _navigateToBlastMode(StudyModule module) {
    if (module.flashcards.isEmpty) return;

    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => BlastModeScreen(
    //       moduleId: module.id,
    //       moduleName: module.title,
    //       flashcards: module.flashcards,
    //     ),
    //   ),
    // );
  }

  void _navigateToFlashcardsMode(StudyModule module) {
    if (module.flashcards.isEmpty) return;

    AppRoutes.navigateToStudyFlashcards(
      context,
      flashcards: module.flashcards,
    );
  }

  void _navigateToLearningMode(StudyModule module) {
    if (module.flashcards.isEmpty) return;

    AppRoutes.navigateToLearn(
      context,
      flashcards: module.flashcards,
      moduleName: module.title,
      moduleId: module.id,
    );
  }

  void _navigateToQuizMode(StudyModule module) {
    if (module.flashcards.isEmpty) return;

    AppRoutes.navigateToQuizSettings(
      context,
      flashcards: module.flashcards,
      moduleName: module.title,
      moduleId: module.id,
    );
  }

  void _navigateToMatchMode(StudyModule module) {
    if (module.flashcards.isEmpty) return;

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
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<ModuleDetailCubit, ModuleDetailState>(
        builder: (context, state) {
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
          if (state.status == ModuleDetailStatus.failure) {
            return Scaffold(
              backgroundColor: const Color(0xFF0A092D),
              appBar: const QlzAppBar(
                backgroundColor: Colors.transparent,
              ),
              body: QlzEmptyState.error(
                title: 'Không thể tải học phần',
                message: state.errorMessage ?? 'Đã xảy ra lỗi khi tải học phần',
                onAction: () =>
                    _cubit.loadModuleDetails(widget.id, forceRefresh: true),
              ),
            );
          }
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

          final module = state.module!;
          final hasFlashcards = module.flashcards.isNotEmpty;

          return Scaffold(
            backgroundColor: const Color(0xFF0A092D),
            appBar: QlzAppBar(
              backgroundColor: Colors.transparent,
              actions: [
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {},
                ),
              ],
            ),
            body: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // Flashcard carousel
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
                          margin: EdgeInsets.all(20),
                          height: 240,
                          child: Center(
                            child: Text(
                              'No flashcards available',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),

                      // Module title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          module.title,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      // Author info and chips
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            QlzAvatar(
                              size: 32,
                              name: module.creatorName,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              module.creatorName,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
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
                      ),

                      const Divider(color: Colors.white24, height: 1),
                    ],
                  ),
                ),

                // Study options
                SliverList(
                  delegate: SliverChildListDelegate([
                    _buildStudyOption(
                      icon: Icons.style_outlined,
                      color: Colors.blue,
                      label: 'Thẻ ghi nhớ',
                      onTap: () => _navigateToFlashcardsMode(module),
                    ),
                    _buildStudyOption(
                      icon: Icons.refresh,
                      color: Colors.purple,
                      label: 'Học',
                      onTap: () => _navigateToLearningMode(module),
                    ),
                    _buildStudyOption(
                      icon: Icons.quiz_outlined,
                      color: Colors.green,
                      label: 'Kiểm tra',
                      onTap: () => _navigateToQuizMode(module),
                    ),
                    _buildStudyOption(
                      icon: Icons.compare_arrows,
                      color: Colors.orange,
                      label: 'Ghép thẻ',
                      onTap: () => _navigateToMatchMode(module),
                    ),
                    _buildStudyOption(
                      icon: Icons.rocket_launch,
                      color: Colors.blue,
                      label: 'Blast',
                      onTap: () => _navigateToBlastMode(module),
                    ),

                    // Action buttons
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Expanded(
                            child: QlzButton.secondary(
                              label: 'Chỉnh sửa',
                              icon: Icons.edit_outlined,
                              onPressed: () {},
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: QlzButton.ghost(
                              label: 'Tải xuống',
                              icon: Icons.download_outlined,
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Add extra space at the bottom for safer scrolling
                    const SizedBox(height: 40),
                  ]),
                ),
              ],
            ),
          );
        },
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
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
