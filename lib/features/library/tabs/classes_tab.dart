import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_empty_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_loading_state.dart';

final class ClassesTab extends StatefulWidget {
  const ClassesTab({super.key});

  @override
  State<ClassesTab> createState() => _ClassesTabState();
}

final class _ClassesTabState extends State<ClassesTab> {
  bool _isLoading = true;
  final List<Map<String, dynamic>> _classes = [];

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      setState(() {
        // Để test trạng thái empty, bạn có thể comment/uncomment dòng bên dưới
        _classes.addAll([
          {
            'name': 'Korean_Multicampus',
            'studyModulesCount': 80,
          },
          {
            'name': 'Korean_Online_Class_2024',
            'studyModulesCount': 45,
          },
          {
            'name': 'TOPIK 중급 스터디',
            'studyModulesCount': 68,
          },
          {
            'name': 'Lớp học tiếng Hàn cơ bản',
            'studyModulesCount': 32,
          }
        ]);
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshClasses() async {
    setState(() {
      _isLoading = true;
      _classes.clear();
    });
    await _loadClasses();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const QlzLoadingState(
        type: QlzLoadingType.circular,
        message: '로딩 중...', // "Loading..." in Korean
      );
    }

    if (_classes.isEmpty) {
      return QlzEmptyState(
        title: '수업이 없습니다', // "No classes" in Korean
        message:
            '아직 참여한 수업이 없습니다. 수업을 만들거나 참여해보세요.', // "You haven't joined any classes yet. Create or join a class."
        icon: Icons.people_outlined,
        actionLabel: '수업 만들기', // "Create class" in Korean
        onAction: () {
          // Navigate to create class screen
          debugPrint('Navigate to create class screen');
        },
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshClasses,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _classes.length,
        itemBuilder: (context, index) {
          final classItem = _classes[index];
          return _ClassItem(
            name: classItem['name'],
            studyModulesCount: classItem['studyModulesCount'],
            onTap: () {
              debugPrint('Tapped on class: ${classItem['name']}');
            },
          );
        },
      ),
    );
  }
}

final class _ClassItem extends StatelessWidget {
  final String name;
  final int studyModulesCount;
  final VoidCallback? onTap;

  const _ClassItem({
    required this.name,
    required this.studyModulesCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF12113A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Class icon and name
            Row(
              children: [
                const Icon(
                  Icons.people_outline,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Study modules count
            Text(
              '$studyModulesCount học phần', // "X study modules" in Vietnamese
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
