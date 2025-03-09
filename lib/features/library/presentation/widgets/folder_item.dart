// lib/features/library/presentation/widgets/folder_item.dart
import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/cards/qlz_card.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/utils/qlz_avatar.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/utils/qlz_chip.dart';

import '../../data/models/folder_model.dart';

class FolderItem extends StatelessWidget {
  final Folder folder;
  final VoidCallback? onTap;

  const FolderItem({
    required this.folder,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return QlzCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      backgroundColor: AppColors.darkCard,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.folder_outlined,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  folder.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              QlzChip(
                label: '${folder.moduleCount} học phần',
                type: QlzChipType.ghost,
                isOutlined: true,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              QlzAvatar(
                name: folder.creatorName,
                size: 32,
              ),
              const SizedBox(width: 8),
              Text(
                folder.creatorName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              if (folder.hasPlusBadge)
                const QlzChip(
                  label: 'Plus',
                  type: QlzChipType.primary,
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                ),
            ],
          ),
        ],
      ),
    );
  }
}