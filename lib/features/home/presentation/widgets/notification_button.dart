import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';

class NotificationButton extends StatelessWidget {
  const NotificationButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        child: Icon(
          Icons.notifications_outlined,
          key: ValueKey('notification'),
          color: AppColors.darkTextSecondary,
        ),
      ),
      onPressed: () {
        // Xử lý sự kiện thông báo
      },
      tooltip: 'Thông báo',
    );
  }
}
