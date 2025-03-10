import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/features/dashboard/dashboard_module.dart';
import 'package:qlz_flash_cards_ui/features/library/presentation/screens/library_screen.dart';
import 'package:qlz_flash_cards_ui/features/profile/profile_screen.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/labels/qlz_label.dart';

/// Main home screen with bottom navigation
final class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardModule.create(),
      const SolutionsTab(),
      const Center(child: Icon(Icons.add, size: 40, color: AppColors.darkText)),
      const LibraryScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.darkSurface,
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          if (index == 2) {
            _showCreateModal(context);
          } else {
            setState(() => _currentIndex = index);
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
            icon: Icon(Icons.lightbulb_outline,
                color: AppColors.darkTextSecondary),
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
            icon:
                Icon(Icons.folder_outlined, color: AppColors.darkTextSecondary),
            selectedIcon: Icon(Icons.folder, color: AppColors.primary),
            label: 'Thư viện',
          ),
          NavigationDestination(
            icon:
                Icon(Icons.person_outline, color: AppColors.darkTextSecondary),
            selectedIcon: Icon(Icons.person, color: AppColors.primary),
            label: 'Hồ sơ',
          ),
        ],
      ),
    );
  }

  void _showCreateModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCreateOption(
              context,
              icon: Icons.style_outlined,
              title: 'Học phần',
              subtitle: 'Tạo bộ thẻ ghi nhớ mới',
              color: AppColors.primary,
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/create-study-module');
              },
            ),
            const SizedBox(height: 12),
            _buildCreateOption(
              context,
              icon: Icons.folder_outlined,
              title: 'Thư mục',
              subtitle: 'Tổ chức học phần của bạn',
              color: AppColors.warning,
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/create-folder');
              },
            ),
            const SizedBox(height: 12),
            _buildCreateOption(
              context,
              icon: Icons.school_outlined,
              title: 'Lớp học',
              subtitle: 'Tạo không gian học tập chung',
              color: AppColors.secondary,
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/create-class');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
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
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.darkText,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    subtitle,
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
