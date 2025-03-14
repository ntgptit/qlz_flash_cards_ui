// lib/features/module/presentation/screens/list_study_module_of_folder_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/features/module/data/models/study_module_model.dart';
import 'package:qlz_flash_cards_ui/features/module/module_module.dart';
import 'package:qlz_flash_cards_ui/features/module/presentation/providers/study_module_provider.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/cards/qlz_card.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_empty_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_loading_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/navigation/qlz_app_bar.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/utils/qlz_chip.dart';

class ListStudyModuleOfFolderScreen extends ConsumerStatefulWidget {
  final String folderName;
  final String folderId;

  const ListStudyModuleOfFolderScreen({
    super.key,
    required this.folderName,
    required this.folderId,
  });

  @override
  ConsumerState<ListStudyModuleOfFolderScreen> createState() =>
      _ListStudyModuleOfFolderScreenState();
}

class _ListStudyModuleOfFolderScreenState
    extends ConsumerState<ListStudyModuleOfFolderScreen> {
  @override
  void initState() {
    super.initState();

    // Load study modules for this folder
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(studyModuleProvider.notifier)
          .loadStudyModulesByFolder(widget.folderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch the study module state
    final state = ref.watch(studyModuleProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A092D),
      appBar: QlzAppBar(
        title: widget.folderName,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
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
      body: _buildBody(state),
    );
  }

  Widget _buildBody(StudyModuleState state) {
    // Handle loading state
    if (state.status == StudyModuleStatus.loading && state.modules.isEmpty) {
      return const Center(
        child: QlzLoadingState(
          message: 'Đang tải học phần...',
          type: QlzLoadingType.circular,
        ),
      );
    }

    // Handle error state
    if (state.status == StudyModuleStatus.failure) {
      return QlzEmptyState.error(
        title: 'Không thể tải học phần',
        message: state.errorMessage ?? 'Đã xảy ra lỗi khi tải dữ liệu',
        onAction: () => ref
            .read(studyModuleProvider.notifier)
            .refreshFolderStudyModules(widget.folderId),
      );
    }

    // Handle empty state
    if (state.modules.isEmpty) {
      return QlzEmptyState.noData(
        title: 'Chưa có học phần',
        message: 'Thư mục này chưa có học phần nào',
        actionLabel: 'Tạo học phần',
        onAction: () {
          HapticFeedback.mediumImpact();
          Navigator.pushNamed(
            context,
            '/create-study-module',
          );
        },
      );
    }

    // Show the list of modules
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref
              .read(studyModuleProvider.notifier)
              .refreshFolderStudyModules(widget.folderId),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Gần đây',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  QlzChip(
                    label: 'Sắp xếp',
                    icon: Icons.sort,
                    type: QlzChipType.ghost,
                    onTap: () {
                      HapticFeedback.selectionClick();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: state.modules.length,
                  itemBuilder: (context, index) {
                    final module = state.modules[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildModuleItem(context, module),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModuleItem(BuildContext context, StudyModule module) {
    return QlzCard(
      padding: const EdgeInsets.all(16),
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ModuleModule.provideDetailScreen(
              moduleId: module.id,
              moduleName: module.title,
            ),
          ),
        );
      },
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.style_outlined,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  module.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Học phần • ${module.termCount} thuật ngữ • Tác giả: ${module.creatorName}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.more_horiz,
              color: Colors.white70,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
            },
          ),
        ],
      ),
    );
  }
}
