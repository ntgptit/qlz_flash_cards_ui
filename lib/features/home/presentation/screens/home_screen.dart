import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/core/routes/app_routes.dart';
import 'package:qlz_flash_cards_ui/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:qlz_flash_cards_ui/features/home/presentation/widgets/solutions_tab.dart';
import 'package:qlz_flash_cards_ui/features/library/library_module.dart';
import 'package:qlz_flash_cards_ui/features/profile/profile_screen.dart';

import '../../data/models/home_menu_item.dart';
import '../providers/home_providers.dart';

final class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeStateProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: _buildBody(context, state.selectedTabIndex, ref),
      bottomNavigationBar:
          _buildNavigationBar(context, state.selectedTabIndex, ref),
    );
  }

  Widget _buildBody(BuildContext context, int tabIndex, WidgetRef ref) {
    return switch (tabIndex) {
      0 => const DashboardScreen(),
      1 => const SolutionsTab(),
      2 => const SizedBox.shrink(), // This tab opens a modal instead
      3 => LibraryModule.provideRiverpodScreen(),
      4 => const ProfileScreen(),
      _ => const DashboardScreen() // Fallback case
    };
  }

  Widget _buildNavigationBar(
      BuildContext context, int currentIndex, WidgetRef ref) {
    final homeNotifier = ref.read(homeStateProvider.notifier);

    return NavigationBar(
      backgroundColor: AppColors.darkSurface,
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        if (index == 2) {
          _showCreateModal(context);
        } else {
          homeNotifier.changeTab(index);
        }
      },
      indicatorColor: AppColors.primary.withOpacity(0.2),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined, color: AppColors.darkTextSecondary),
          selectedIcon: Icon(Icons.home, color: AppColors.primary),
          label: 'Trang chủ',
        ),
        NavigationDestination(
          icon:
              Icon(Icons.lightbulb_outline, color: AppColors.darkTextSecondary),
          selectedIcon: Icon(Icons.lightbulb, color: AppColors.primary),
          label: 'Lời giải',
        ),
        NavigationDestination(
          icon: Icon(Icons.add_circle_outline,
              color: AppColors.darkTextSecondary),
          selectedIcon: Icon(Icons.add_circle, color: AppColors.primary),
          label: 'Tạo',
        ),
        NavigationDestination(
          icon: Icon(Icons.folder_outlined, color: AppColors.darkTextSecondary),
          selectedIcon: Icon(Icons.folder, color: AppColors.primary),
          label: 'Thư viện',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline, color: AppColors.darkTextSecondary),
          selectedIcon: Icon(Icons.person, color: AppColors.primary),
          label: 'Hồ sơ',
        ),
      ],
    );
  }

  void _showCreateModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) => const _CreateOptionsModal(),
    );
  }
}

class _CreateOptionsModal extends StatelessWidget {
  const _CreateOptionsModal();

  @override
  Widget build(BuildContext context) {
    final createOptions = [
      const HomeMenuItem(
        icon: Icons.style_outlined,
        title: 'Học phần',
        subtitle: 'Tạo bộ thẻ ghi nhớ mới',
        color: AppColors.primary,
        route: AppRoutes.createStudyModule,
      ),
      const HomeMenuItem(
        icon: Icons.folder_outlined,
        title: 'Thư mục',
        subtitle: 'Tổ chức học phần của bạn',
        color: AppColors.warning,
        route: AppRoutes.createFolder,
      ),
      const HomeMenuItem(
        icon: Icons.school_outlined,
        title: 'Lớp học',
        subtitle: 'Tạo không gian học tập chung',
        color: AppColors.secondary,
        route: AppRoutes.createClass,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < createOptions.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            _CreateOptionItem(menuItem: createOptions[i]),
          ],
        ],
      ),
    );
  }
}

class _CreateOptionItem extends StatelessWidget {
  final HomeMenuItem menuItem;

  const _CreateOptionItem({required this.menuItem});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _navigate(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.darkBorder),
        ),
        child: Row(
          children: [
            Icon(menuItem.icon, color: menuItem.color, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menuItem.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.darkText,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    menuItem.subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.darkTextSecondary,
                        ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.darkTextSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _navigate(BuildContext context) {
    Navigator.pop(context);
    Navigator.pushNamed(context, menuItem.route);
  }
}
