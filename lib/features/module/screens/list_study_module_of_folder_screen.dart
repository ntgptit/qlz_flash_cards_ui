// lib/features/screens/folder/list_study_module_of_folder_screen.dart

import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/features/vocabulary/screens/vocabulary_screen.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_empty_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/navigation/qlz_app_bar.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/cards/qlz_card.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/utils/qlz_chip.dart';

final class ListStudyModuleOfFolderScreen extends StatelessWidget {
  final String folderName;

  const ListStudyModuleOfFolderScreen({super.key, required this.folderName});

  @override
  Widget build(BuildContext context) {
    final studyModules = _getDummyModules();

    return Scaffold(
      backgroundColor: const Color(0xFF0A092D),
      appBar: QlzAppBar(
        title: folderName,
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
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: AppColors.primary,
      //   onPressed: () {},
      //   child: const Icon(Icons.add),
      // ),
      body: SafeArea(
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
                child: studyModules.isEmpty
                    ? QlzEmptyState.noData(
                        title: 'Chưa có học phần',
                        message: 'Thư mục này chưa có học phần nào',
                        actionLabel: 'Tạo học phần',
                        onAction: () {},
                      )
                    : ListView.builder(
                        itemCount: studyModules.length,
                        itemBuilder: (context, index) {
                          final module = studyModules[index];
                          return _buildModuleItem(context, module);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModuleItem(BuildContext context, Map<String, dynamic> module) {
    return QlzCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VocabularyScreen(
              moduleName: module['title'],
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
                  module['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Học phần • ${module['terms']} thuật ngữ • Tác giả: ${module['author']}',
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

  List<Map<String, dynamic>> _getDummyModules() {
    return List.generate(
      4,
      (index) => {
        'title': 'Section ${index + 1}: Chủ đề ${index + 1}',
        'terms': 50 + index,
        'author': 'bạn',
      },
    );
  }
}
