import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/features/library/widgets/filter_dropdown.dart';
import 'package:qlz_flash_cards_ui/features/vocabulary/screens/vocabulary_screen.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_empty_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_loading_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/inputs/qlz_text_field.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/utils/qlz_avatar.dart';

final class StudySetsTab extends StatefulWidget {
  const StudySetsTab({super.key});

  @override
  State<StudySetsTab> createState() => _StudySetsTabState();
}

final class _StudySetsTabState extends State<StudySetsTab> {
  bool _isLoading = true;
  final List<Map<String, dynamic>> _studySets = [];
  final List<String> _filterOptions = ['모두', '내가 만든 세트', '학습함', '다운로드됨'];
  String _selectedFilter = '모두';

  @override
  void initState() {
    super.initState();
    _loadStudySets();
  }

  Future<void> _loadStudySets() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      setState(() {
        // Để test trạng thái empty, bạn có thể comment/uncomment dòng bên dưới
        _studySets.addAll([
          {
            'title': 'Section 4: 병원',
            'wordCount': 88,
            'creator': 'giapnguyen1994',
            'hasPlusBadge': true,
          },
          {
            'title': 'Vitamin_Book2_Chapter4-2: Vocabulary',
            'wordCount': 55,
            'creator': 'giapnguyen1994',
            'hasPlusBadge': true,
          },
          {
            'title': 'Vitamin_Book2_Chapter1-1: Vocabulary',
            'wordCount': 74,
            'creator': 'giapnguyen1994',
            'hasPlusBadge': false,
          },
          {
            'title': 'TOPIK I - Luyện nghe cấp độ 1-2',
            'wordCount': 120,
            'creator': 'korean_teacher',
            'hasPlusBadge': true,
          },
          {
            'title': 'Từ vựng tiếng Hàn chủ đề Ẩm thực',
            'wordCount': 45,
            'creator': 'hangul_study',
            'hasPlusBadge': false,
          },
          {
            'title': 'Động từ bất quy tắc - 불규칙 동사',
            'wordCount': 32,
            'creator': 'koreanwithme',
            'hasPlusBadge': true,
          },
          {
            'title': 'EPS-TOPIK 60일 완성',
            'wordCount': 210,
            'creator': 'eps_study',
            'hasPlusBadge': true,
          }
        ]);
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshStudySets() async {
    setState(() {
      _isLoading = true;
      _studySets.clear();
    });
    await _loadStudySets();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const QlzLoadingState(
        type: QlzLoadingType.circular,
        message: '로딩 중...', // "Loading..." in Korean
      );
    }

    if (_studySets.isEmpty) {
      return QlzEmptyState(
        title: '학습 세트가 없습니다', // "No study sets" in Korean
        message:
            '학습 세트를 만들어 단어를 공부해보세요.', // "Create a study set to study vocabulary" in Korean
        icon: Icons.book_outlined,
        actionLabel: '세트 만들기', // "Create set" in Korean
        onAction: () {
          // Navigate to create study set screen
          debugPrint('Navigate to create study set screen');
        },
      );
    }

    // Sử dụng RefreshIndicator bọc toàn bộ nội dung có thể cuộn
    return RefreshIndicator(
      onRefresh: _refreshStudySets,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // === Phần Filter cũng sẽ cuộn theo ===
          const SizedBox(height: 15),

          // Filter dropdown
          FilterDropdown(
            options: _filterOptions,
            selectedOption: _selectedFilter,
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
          ),

          const SizedBox(height: 16),

          // Search text field
          QlzTextField.search(
            hintText: '검색어를 입력하세요...',
            onChanged: (value) {
              setState(() {});
            },
          ),

          const SizedBox(height: 16),

          // Section title
          const Text(
            '이번 주', // "This week" in Korean
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),

          // === Danh sách Study Sets ===
          ...List.generate(_studySets.length, (index) {
            final studySet = _studySets[index];
            return _StudySetItem(
              title: studySet['title'],
              wordCount: studySet['wordCount'],
              creatorName: studySet['creator'],
              hasPlusBadge: studySet['hasPlusBadge'],
              onTap: () {
                // Navigate to study set detail
                debugPrint('Tapped on study set: ${studySet['title']}');
              },
            );
          }),
        ],
      ),
    );
  }
}

// StudySetItem được tích hợp trực tiếp trong file này
// và được đổi tên thành _StudySetItem để thể hiện nó là private
final class _StudySetItem extends StatelessWidget {
  final String title;
  final int wordCount;
  final String creatorName;
  final bool hasPlusBadge;
  final VoidCallback? onTap;

  const _StudySetItem({
    required this.title,
    required this.wordCount,
    required this.creatorName,
    required this.hasPlusBadge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VocabularyScreen(
              moduleName: title,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF12113A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // Word count
            Text(
              '$wordCount 단어', // "X terms" in Korean
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 12),

            // Creator info row
            Row(
              children: [
                // Creator avatar
                QlzAvatar(
                  name: creatorName,
                  size: 32,
                  imageUrl: 'assets/images/user_avatar.jpg',
                ),

                const SizedBox(width: 8),

                // Creator name
                Text(
                  creatorName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),

                // Plus badge
                if (hasPlusBadge)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1D3D),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: const Text(
                      'Plus',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
