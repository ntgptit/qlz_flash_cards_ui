// lib/features/library/presentation/screens/library_screen.dart
import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/core/routes/app_routes.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/navigation/qlz_app_bar.dart';

import '../tabs/classes_tab.dart';
import '../tabs/folders_tab.dart';
import '../tabs/study_sets_tab.dart';

/// Màn hình chính của module Library, hiển thị các tab cho study sets, folders và classes
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A092D),
      appBar: QlzAppBar(
        title: 'Thư viện',
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _handleAddAction,
          ),
        ],
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            tabs: const [
              Tab(text: 'Học phần'),
              Tab(text: 'Thư mục'),
              Tab(text: 'Lớp học'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                StudySetsTab(),
                FoldersTab(),
                ClassesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Xử lý hành động thêm mới dựa trên tab hiện tại
  void _handleAddAction() {
    final currentTabIndex = _tabController.index;
    switch (currentTabIndex) {
      case 0: // Tab Study Sets
        Navigator.pushNamed(context, AppRoutes.createStudyModule);
        break;
      case 1: // Tab Folders
        Navigator.pushNamed(context, AppRoutes.createFolder);
        break;
      case 2: // Tab Classes
        Navigator.pushNamed(context, AppRoutes.createClass);
        break;
    }
  }
}
