import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';

class SettingsMenu extends StatelessWidget {
  const SettingsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(
        Icons.settings_outlined,
        color: AppColors.darkTextSecondary,
      ),
      onSelected: (value) {
        if (value == 'settings') {
          // Điều hướng đến màn hình cài đặt
        } else if (value == 'logout') {
          // Xử lý đăng xuất
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'settings',
          child: Text('Cài đặt'),
        ),
        const PopupMenuItem(
          value: 'logout',
          child: Text('Đăng xuất'),
        ),
      ],
      color: AppColors.darkCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
