// lib/presentation/screens/folder/folder_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_empty_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/navigation/qlz_app_bar.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/cards/qlz_card.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/utils/qlz_icon_badge.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/buttons/qlz_button.dart';

final class FolderDetailScreen extends StatelessWidget {
  const FolderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A092D),
      appBar: QlzAppBar(
        title: 'VitaminB2',
        actions: [
          QlzIconBadge(
            icon: Icons.search,
            onTap: () {},
          ),
          QlzIconBadge(
            icon: Icons.more_vert,
            onTap: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                const Icon(
                  Icons.history,
                  color: Colors.white70,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Sửa ngày 4/2/25',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Gần đây',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                QlzButton.ghost(
                  label: 'Xem tất cả',
                  onPressed: () {},
                  size: QlzButtonSize.small,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _buildStudyModuleList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStudyModuleList() {
    final List<Map<String, dynamic>> studyModules = List.generate(
      8,
      (index) => {
        'title': 'Vitamin_Book2_Chapter${index + 1}-2: Vocabulary',
        'terms': 55 + index,
        'author': 'bạn',
      },
    );

    if (studyModules.isEmpty) {
      return QlzEmptyState.noData(
        title: 'Chưa có học phần',
        message: 'Tạo học phần đầu tiên để bắt đầu học',
        actionLabel: 'Tạo học phần',
        onAction: () {},
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: studyModules.length,
      itemBuilder: (context, index) {
        final module = studyModules[index];

        return QlzCard(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          onTap: () {},
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
                      '${module['terms']} thuật ngữ • Tác giả: ${module['author']}',
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
      },
    );
  }
}
