import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/core/routes/app_routes.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_empty_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_loading_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/utils/qlz_avatar.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/utils/qlz_chip.dart';

final class FoldersTab extends StatefulWidget {
  const FoldersTab({super.key});

  @override
  State<FoldersTab> createState() => _FoldersTabState();
}

final class _FoldersTabState extends State<FoldersTab> {
  bool _isLoading = true;
  final List<Map<String, dynamic>> _folders = [];

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      setState(() {
        // Để test trạng thái empty, bạn có thể comment/uncomment dòng bên dưới
        _folders.addAll([
          {
            'name': 'Grammar',
            'creator': 'giapnguyen1994',
            'hasPlusBadge': true,
            'moduleCount': 5,
          },
          {
            'name': 'OJT_Korea_2024',
            'creator': 'giapnguyen1994',
            'hasPlusBadge': true,
            'moduleCount': 65,
          },
          {
            'name': 'Tiếng Hàn tổng hợp 2',
            'creator': 'giapnguyen1994',
            'hasPlusBadge': true,
            'moduleCount': 55,
          },
          {
            'name': 'Duyen선생님_중급1',
            'creator': 'giapnguyen1994',
            'hasPlusBadge': true,
            'moduleCount': 45,
          },
          {
            'name': 'Ngữ pháp nâng cao',
            'creator': 'korean_teacher',
            'hasPlusBadge': true,
            'moduleCount': 35,
          },
          {
            'name': 'Luyện thi TOPIK II',
            'creator': 'hangul_study',
            'hasPlusBadge': false,
            'moduleCount': 25,
          },
          {
            'name': 'Khóa học EPS',
            'creator': 'eps_study',
            'hasPlusBadge': true,
            'moduleCount': 15,
          }
        ]);
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshFolders() async {
    setState(() {
      _isLoading = true;
      _folders.clear();
    });
    await _loadFolders();
  }

  void _navigateToFolderDetail(Map<String, dynamic> folder) {
    Navigator.pushNamed(
      context,
      AppRoutes.folderDetail,
      arguments: {
        'folderId': folder['id'],
        'folderName': folder['name'],
        'creatorName': folder['creator'],
        'moduleCount': folder['moduleCount'],
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const QlzLoadingState(
        type: QlzLoadingType.circular,
        message: '로딩 중...', // "Loading..." in Korean
      );
    }

    if (_folders.isEmpty) {
      return QlzEmptyState.noData(
        title: 'Chưa có thư mục nào',
        message: 'Tạo thư mục đầu tiên để tổ chức học phần của bạn',
        actionLabel: 'Tạo thư mục',
        onAction: () => Navigator.pushNamed(context, AppRoutes.createFolder),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshFolders,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _folders.length,
        itemBuilder: (context, index) {
          final folder = _folders[index];
          return _FolderItem(
            name: folder['name'],
            creatorName: folder['creator'],
            hasPlusBadge: folder['hasPlusBadge'],
            moduleCount: folder['moduleCount'],
            onTap: () => _navigateToFolderDetail(folder),
          );
        },
      ),
    );
  }
}

final class _FolderItem extends StatelessWidget {
  final String name;
  final String creatorName;
  final bool hasPlusBadge;
  final int moduleCount;
  final VoidCallback? onTap;

  const _FolderItem({
    required this.name,
    required this.creatorName,
    required this.hasPlusBadge,
    this.moduleCount = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
            // Folder icon and name
            Row(
              children: [
                const Icon(
                  Icons.folder_outlined,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
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
                QlzChip(
                  label: '$moduleCount học phần',
                  type: QlzChipType.ghost,
                  isOutlined: true,
                ),
              ],
            ),

            const SizedBox(height: 20),

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
