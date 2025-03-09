// // lib/features/library/presentation/screens/library_screen.dart
// import 'package:flutter/material.dart';
// import 'package:qlz_flash_cards_ui/features/class/create_class_screen.dart';
// import 'package:qlz_flash_cards_ui/features/folder/screens/create_folder_screen.dart';
// import 'package:qlz_flash_cards_ui/features/module/screens/create_study_module_screen.dart';
// import 'package:qlz_flash_cards_ui/shared/widgets/navigation/qlz_app_bar.dart';

// import '../tabs/classes_tab.dart';
// import '../tabs/folders_tab.dart';
// import '../tabs/study_sets_tab.dart';

// /// The main screen of the Library feature, displaying tabs for study sets, folders, and classes
// class LibraryScreen extends StatefulWidget {
//   const LibraryScreen({super.key});

//   @override
//   State<LibraryScreen> createState() => _LibraryScreenState();
// }

// class _LibraryScreenState extends State<LibraryScreen> with SingleTickerProviderStateMixin {
//   late final TabController _tabController;
  
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//   }
  
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
  
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0A092D),
//       appBar: QlzAppBar(
//         title: '라이브러리', // "Library" in Korean
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.add, color: Colors.white),
//             onPressed: _handleAddAction,
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           TabBar(
//             controller: _tabController,
//             indicatorColor: Colors.white,
//             labelColor: Colors.white,
//             unselectedLabelColor: Colors.white60,
//             tabs: const [
//               Tab(text: '날말카드 세트'), // "Flashcard Sets"
//               Tab(text: '폴더'), // "Folders"
//               Tab(text: '클래스'), // "Classes"
//             ],
//           ),
//           Expanded(
//             child: TabBarView(
//               controller: _tabController,
//               children: const [
//                 StudySetsTab(),
//                 FoldersTab(),
//                 ClassesTab(),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
  
//   void _handleAddAction() {
//     final currentTabIndex = _tabController.index;
//     switch (currentTabIndex) {
//       case 0: // Tab Study Sets
//         Navigator.of(context).push(
//           MaterialPageRoute(
//             builder: (context) => const CreateStudyModuleScreen(),
//           ),
//         );
//         break;
//       case 1: // Tab Folders
//         Navigator.of(context).push(
//           MaterialPageRoute(
//             builder: (context) => const CreateFolderScreen(),
//           ),
//         );
//         break;
//       case 2: // Tab Classes
//         Navigator.of(context).push(
//           MaterialPageRoute(
//             builder: (context) => const CreateClassScreen(),
//           ),
//         );
//         break;
//     }
//   }
// }

// lib/features/library/presentation/screens/library_screen.dart
import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/features/class/create_class_screen.dart';
import 'package:qlz_flash_cards_ui/features/folder/screens/create_folder_screen.dart';
import 'package:qlz_flash_cards_ui/features/module/screens/create_study_module_screen.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/navigation/qlz_app_bar.dart';

import '../tabs/classes_tab.dart';
import '../tabs/folders_tab.dart';
import '../tabs/study_sets_tab.dart';

/// The main screen of the Library feature, displaying tabs for study sets, folders, and classes
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> with SingleTickerProviderStateMixin {
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
        title: '라이브러리', // "Library" in Korean
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
              Tab(text: '날말카드 세트'), // "Flashcard Sets"
              Tab(text: '폴더'), // "Folders"
              Tab(text: '클래스'), // "Classes"
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
  
  void _handleAddAction() {
    final currentTabIndex = _tabController.index;
    switch (currentTabIndex) {
      case 0: // Tab Study Sets
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const CreateStudyModuleScreen(),
          ),
        );
        break;
      case 1: // Tab Folders
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const CreateFolderScreen(),
          ),
        );
        break;
      case 2: // Tab Classes
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const CreateClassScreen(),
          ),
        );
        break;
    }
  }
}