import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';

class AppBarLeading extends StatelessWidget {
  const AppBarLeading({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => IconButton(
        icon: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.menu,
            color: AppColors.darkTextSecondary,
          ),
        ),
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
    );
  }
}
