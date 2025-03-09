import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/features/module/data/models/study_module_model.dart';
import 'package:qlz_flash_cards_ui/features/module/data/repositories/module_repository.dart';
import 'package:qlz_flash_cards_ui/features/module/logic/cubit/study_module_cubit.dart';
import 'package:qlz_flash_cards_ui/features/module/logic/states/study_module_state.dart';
import 'package:qlz_flash_cards_ui/features/module/module_module.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/cards/qlz_card.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_empty_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_loading_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/navigation/qlz_app_bar.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/utils/qlz_chip.dart';

class ListStudyModuleOfFolderScreen extends StatefulWidget {
  final String folderName;
  final String folderId;
  const ListStudyModuleOfFolderScreen({
    super.key,
    required this.folderName,
    required this.folderId,
  });
  @override
  State<ListStudyModuleOfFolderScreen> createState() => 
      _ListStudyModuleOfFolderScreenState();
}

class _ListStudyModuleOfFolderScreenState extends State<ListStudyModuleOfFolderScreen> {
  late StudyModuleCubit _cubit;
  
  @override
  void initState() {
    super.initState();
    _cubit = StudyModuleCubit(context.read<ModuleRepository>());
    _cubit.loadStudyModulesByFolder(widget.folderId);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A092D),
        appBar: QlzAppBar(
          title: widget.folderName,
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {},
            ),
          ],
        ),
        body: BlocBuilder<StudyModuleCubit, StudyModuleState>(
          builder: (context, state) {
            if (state.status == StudyModuleStatus.loading && state.modules.isEmpty) {
               return const Center(
                child: QlzLoadingState(
                  message: 'Đang tải học phần...',
                  type: QlzLoadingType.circular,
                ),
              );
            }
            if (state.status == StudyModuleStatus.failure) {
              return QlzEmptyState.error(
                title: 'Không thể tải học phần',
                message: state.errorMessage ?? 'Đã xảy ra lỗi khi tải dữ liệu',
                onAction: () => _cubit.refreshFolderStudyModules(widget.folderId),
              );
            }
            if (state.modules.isEmpty) {
              return QlzEmptyState.noData(
                title: 'Chưa có học phần',
                message: 'Thư mục này chưa có học phần nào',
                actionLabel: 'Tạo học phần',
                onAction: () {
                  Navigator.pushNamed(
                    context,
                    '/create-study-module',
                  );
                },
              );
            }
            return SafeArea(
              child: RefreshIndicator(
                onRefresh: () => _cubit.refreshFolderStudyModules(widget.folderId),
                child: Padding(
                  padding: const EdgeInsets.all(20),
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
                            onTap: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          itemCount: state.modules.length,
                          itemBuilder: (context, index) {
                            final module = state.modules[index];
                            return _buildModuleItem(context, module);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildModuleItem(BuildContext context, StudyModule module) {
    return QlzCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      onTap: () {
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
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}