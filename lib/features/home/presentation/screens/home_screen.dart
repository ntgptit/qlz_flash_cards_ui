import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/core/managers/cubit_manager.dart';
import 'package:qlz_flash_cards_ui/core/routes/app_routes.dart';
import 'package:qlz_flash_cards_ui/features/dashboard/dashboard_module.dart';
import 'package:qlz_flash_cards_ui/features/home/data/models/home_menu_item.dart';
import 'package:qlz_flash_cards_ui/features/home/logic/cubit/home_cubit.dart'
    show HomeCubit;
import 'package:qlz_flash_cards_ui/features/home/logic/states/home_state.dart';
import 'package:qlz_flash_cards_ui/features/library/library_module.dart';
import 'package:qlz_flash_cards_ui/features/profile/profile_screen.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/labels/qlz_label.dart';

/// Main home screen with bottom navigation
final class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Wrap with BlocProvider from CubitManager's global providers
    // This ensures the HomeCubit is accessible throughout the home screen
    return MultiBlocProvider(
      providers: CubitManager().getHomeProviders(),
      child: const _HomeScreenContent(),
    );
  }
}

/// The main content of the home screen that uses the HomeCubit
class _HomeScreenContent extends StatelessWidget {
  const _HomeScreenContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.darkBackground,
          body: _buildBody(state.selectedTabIndex),
          bottomNavigationBar:
              _buildNavigationBar(context, state.selectedTabIndex),
        );
      },
    );
  }

  Widget _buildBody(int tabIndex) {
    // Return appropriate screen based on the selected tab
    return switch (tabIndex) {
      0 => DashboardModule.create(),
      1 => const SolutionsTab(),
      2 => const SizedBox.shrink(), // This tab opens a modal instead
      3 => LibraryModule.provideLibraryScreen(),
      4 => const ProfileScreen(),
      _ => DashboardModule.create() // Fallback case
    };
  }

  Widget _buildNavigationBar(BuildContext context, int currentIndex) {
    final homeCubit = context.read<HomeCubit>();

    return NavigationBar(
      backgroundColor: AppColors.darkSurface,
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        if (index == 2) {
          _showCreateModal(context);
        } else {
          homeCubit.changeTab(index);
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

/// Modal sheet showing create options
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

/// Individual option item in the create modal
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

/// Solutions tab with placeholder for future feature
class SolutionsTab extends StatelessWidget {
  const SolutionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.lightbulb_outline,
            color: AppColors.warning,
            size: 48,
          ),
          const SizedBox(height: 16),
          QlzLabel(
            'Lời giải',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.darkText,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Đang phát triển tính năng giúp bạn giải đáp các bài tập',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.darkTextSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
