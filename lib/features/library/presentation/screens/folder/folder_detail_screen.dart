// lib/features/library/presentation/screens/folder_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qlz_flash_cards_ui/core/routes/app_routes.dart';
import 'package:qlz_flash_cards_ui/features/library/data/models/study_set_model.dart';
import 'package:qlz_flash_cards_ui/features/library/logic/cubit/study_sets_cubit.dart';
import 'package:qlz_flash_cards_ui/features/library/logic/states/study_sets_state.dart';
import 'package:qlz_flash_cards_ui/features/library/presentation/widgets/study_set_item.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_empty_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_loading_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/navigation/qlz_app_bar.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/utils/qlz_chip.dart';

/// Màn hình hiển thị chi tiết thư mục và danh sách học phần trong thư mục
class FolderDetailScreen extends StatefulWidget {
  final String folderId;
  final String folderName;

  const FolderDetailScreen({
    super.key,
    required this.folderId,
    required this.folderName,
  });

  @override
  State<FolderDetailScreen> createState() => _FolderDetailScreenState();
}

class _FolderDetailScreenState extends State<FolderDetailScreen> {
  bool _loadingTimedOut = false;

  @override
  void initState() {
    super.initState();

    // Tải dữ liệu khi màn hình được tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("DEBUG: Loading study sets for folder ID: ${widget.folderId}");
      context.read<StudySetsCubit>().loadStudySetsByFolder(widget.folderId);

      // Thêm timeout để tránh trạng thái loading vô hạn
      Future.delayed(const Duration(seconds: 15), () {
        if (mounted && !_loadingTimedOut) {
          print("DEBUG: Loading timed out for folder screen");
          setState(() {
            _loadingTimedOut = true;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A092D),
      appBar: QlzAppBar(
        title: widget.folderName,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              HapticFeedback.lightImpact();
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              HapticFeedback.lightImpact();
            },
          ),
        ],
      ),
      body: BlocConsumer<StudySetsCubit, StudySetsState>(
        listener: (context, state) {
          print("DEBUG-Listener: State changed to ${state.status}");
        },
        builder: (context, state) {
          print(
              "DEBUG-Builder: Current state: ${state.status}, studySets: ${state.studySets.length}");

          // Thêm xử lý timeout
          if (_loadingTimedOut && state.status == StudySetsStatus.loading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.amber, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Tải dữ liệu quá lâu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Có thể có vấn đề với kết nối mạng hoặc máy chủ',
                    style: TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _loadingTimedOut = false;
                      });
                      context.read<StudySetsCubit>().loadStudySetsByFolder(
                          widget.folderId,
                          forceRefresh: true);
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          // Trạng thái loading - chưa có dữ liệu
          if (state.status == StudySetsStatus.loading &&
              state.studySets.isEmpty) {
            return const Center(
              child: QlzLoadingState(
                message: 'Đang tải học phần...',
                type: QlzLoadingType.circular,
              ),
            );
          }

          // Trạng thái lỗi
          if (state.status == StudySetsStatus.failure) {
            return QlzEmptyState.error(
              title: 'Không thể tải học phần',
              message: state.errorMessage ?? 'Đã xảy ra lỗi khi tải dữ liệu',
              onAction: () => context
                  .read<StudySetsCubit>()
                  .loadStudySetsByFolder(widget.folderId, forceRefresh: true),
            );
          }

          // Trạng thái trống - không có dữ liệu
          if (state.studySets.isEmpty) {
            return QlzEmptyState.noData(
              title: 'Chưa có học phần',
              message: 'Thư mục này chưa có học phần nào',
              actionLabel: 'Tạo học phần',
              onAction: () {
                HapticFeedback.mediumImpact();
                Navigator.pushNamed(
                  context,
                  '/create-study-module',
                );
              },
            );
          }

          // Trạng thái thành công - có dữ liệu
          return RefreshIndicator(
            onRefresh: () => context
                .read<StudySetsCubit>()
                .loadStudySetsByFolder(widget.folderId, forceRefresh: true),
            child: _buildStudySetsList(context, state),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          Navigator.pushNamed(
            context,
            '/create-study-module',
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  /// Xây dựng danh sách học phần trong thư mục
  Widget _buildStudySetsList(BuildContext context, StudySetsState state) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tất cả học phần',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                QlzChip(
                  label: 'Sắp xếp',
                  icon: Icons.sort,
                  type: QlzChipType.ghost,
                  onTap: () {
                    HapticFeedback.lightImpact();
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: state.status == StudySetsStatus.loading &&
                      state.studySets.isNotEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _buildStudySetsListView(context, state.studySets),
            ),
          ],
        ),
      ),
    );
  }

  /// Xây dựng ListView cho danh sách học phần
  Widget _buildStudySetsListView(
      BuildContext context, List<StudySet> studySets) {
    return ListView.builder(
      itemCount: studySets.length,
      itemBuilder: (context, index) {
        final studySet = studySets[index];
        return StudySetItem(
          studySet: studySet,
          onTap: () => _navigateToStudySetDetail(context, studySet),
        );
      },
    );
  }

  /// Điều hướng đến màn hình chi tiết học phần
  void _navigateToStudySetDetail(BuildContext context, StudySet studySet) {
    HapticFeedback.selectionClick();
    AppRoutes.navigateToModuleDetail(
      context,
      moduleId: studySet.id,
      moduleName: studySet.title,
    );
  }
}
