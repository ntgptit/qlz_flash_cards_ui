import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qlz_flash_cards_ui/core/routes/app_routes.dart';
import 'package:qlz_flash_cards_ui/features/library/presentation/tabs/classes_tab.dart';
import 'package:qlz_flash_cards_ui/features/library/presentation/tabs/folders_tab.dart';
import 'package:qlz_flash_cards_ui/features/library/presentation/tabs/study_sets_tab.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/navigation/qlz_app_bar.dart';

/// Main screen for the library section, displaying study sets, folders, and classes
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Add listener to handle tab changes
    _tabController.addListener(() {
      // This will trigger a rebuild when the tab changes
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });
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
                // Use separate tab widgets for better code organization
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

  /// Handle the add button press based on the current tab
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
