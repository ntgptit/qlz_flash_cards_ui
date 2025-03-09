// lib/presentation/screens/module/module_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/buttons/qlz_button.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/cards/qlz_card.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/navigation/qlz_app_bar.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/utils/qlz_avatar.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/utils/qlz_chip.dart';

final class ModuleDetailScreen extends StatelessWidget {
  const ModuleDetailScreen({super.key, required String id, required String name});

  @override
  Widget build(BuildContext context) {
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            const QlzCard(
              height: 200,
              width: double.infinity,
              margin: EdgeInsets.all(20),
              child: Center(
                child: Text(
                  '과일',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Vitamin_Book2_Chapter4-2: Vocabulary',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const QlzAvatar(
                    size: 32,
                    assetPath: 'assets/images/user_avatar.jpg',
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'giapnguyen1994',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                  const SizedBox(width: 8),
                  const QlzChip(
                    label: 'Plus',
                    type: QlzChipType.primary,
                    padding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                  ),
                  const Spacer(),
                  const QlzChip(
                    label: '55 thuật ngữ',
                    type: QlzChipType.ghost,
                    icon: Icons.style_outlined,
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24, height: 1),
            _buildActionButton(
              context: context,
              icon: Icons.style_outlined,
              label: 'Thẻ ghi nhớ',
              color: Colors.blue,
            ),
            _buildActionButton(
              context: context,
              icon: Icons.refresh,
              label: 'Học',
              color: Colors.purple,
            ),
            _buildActionButton(
              context: context,
              icon: Icons.quiz_outlined,
              label: 'Kiểm tra',
              color: Colors.green,
            ),
            _buildActionButton(
              context: context,
              icon: Icons.compare_arrows,
              label: 'Ghép thẻ',
              color: Colors.orange,
            ),
            _buildActionButton(
              context: context,
              icon: Icons.rocket_launch,
              label: 'Blast',
              color: Colors.red,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return QlzCard(
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 6,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      onTap: () {},
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
