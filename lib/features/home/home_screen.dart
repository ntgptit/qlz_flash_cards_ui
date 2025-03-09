import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/features/home/tabs/home_tab.dart';
import 'package:qlz_flash_cards_ui/features/home/tabs/solutions_tab.dart';
import 'package:qlz_flash_cards_ui/features/library/presentation/screens/library_screen.dart';
import 'package:qlz_flash_cards_ui/features/profile/profile_screen.dart';

final class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeTab(),
    const SolutionsTab(),
    const Center(child: Icon(Icons.add, size: 40, color: Colors.white)),
    const LibraryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A092D),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF12113A),
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          if (index == 2) {
            _showCreateModal(context);
          } else {
            setState(() => _currentIndex = index);
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: Icon(Icons.lightbulb_outline),
            selectedIcon: Icon(Icons.lightbulb),
            label: 'Lời giải',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Tạo',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder),
            label: 'Thư viện',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Hồ sơ',
          ),
        ],
      ),
    );
  }

  void _showCreateModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF12113A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildCreateOption(
              context,
              icon: Icons.folder_outlined,
              title: 'Thư mục',
              subtitle: 'Tổ chức học phần của bạn',
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildCreateOption(
              context,
              icon: Icons.school_outlined,
              title: 'Lớp học',
              subtitle: 'Tạo không gian học tập chung',
              color: Colors.purple,
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
  }) {
    return InkWell(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1D3D),
          borderRadius: BorderRadius.circular(12),
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color.fromARGB(180, 255, 255, 255), // Updated
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color.fromARGB(180, 255, 255, 255), // Updated
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
