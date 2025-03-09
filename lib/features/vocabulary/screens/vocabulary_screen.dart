// lib/features/vocabulary/screens/vocabulary_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/core/routes/app_routes.dart';
import 'package:qlz_flash_cards_ui/features/vocabulary/cubit/vocabulary_cubit.dart';
import 'package:qlz_flash_cards_ui/features/vocabulary/cubit/vocabulary_state.dart';
import 'package:qlz_flash_cards_ui/features/vocabulary/widgets/module_user_info.dart';
import 'package:qlz_flash_cards_ui/features/vocabulary/widgets/study_options_list.dart';
import 'package:qlz_flash_cards_ui/features/vocabulary/widgets/study_progress.dart';
import 'package:qlz_flash_cards_ui/features/vocabulary/widgets/term_list.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/cards/qlz_flashcard_carousel.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_empty_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_error_view.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_loading_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/navigation/qlz_app_bar.dart';

final class VocabularyScreen extends StatelessWidget {
  final String moduleName;
  final String? moduleId;

  const VocabularyScreen({
    super.key,
    required this.moduleName,
    this.moduleId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VocabularyCubit()..loadFlashcards(moduleId),
      child: Builder(builder: (context) {
        return Scaffold(
          backgroundColor: AppColors.darkBackground,
          appBar: QlzAppBar(
            title: moduleName,
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  // TODO: Implement share functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Tính năng chia sẻ đang được phát triển')),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  _showOptionsMenu(context);
                },
              ),
            ],
          ),
          body: BlocBuilder<VocabularyCubit, VocabularyState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const QlzLoadingState(
                  message: 'Đang tải học phần...',
                  type: QlzLoadingType.circular,
                  color: AppColors.primary,
                );
              }

              if (state.error != null) {
                return QlzErrorView(
                  message: state.error!,
                  onRetry: () {
                    context.read<VocabularyCubit>().loadFlashcards(moduleId);
                  },
                );
              }

              final flashcards = state.flashcards;
              if (flashcards.isEmpty) {
                return QlzEmptyState.noData(
                  title: 'Chưa có thẻ nào',
                  message: 'Học phần này chưa có thẻ ghi nhớ nào',
                  actionLabel: 'Tạo thẻ mới',
                  onAction: () {
                    // TODO: Navigate to create flashcard screen
                  },
                );
              }

              // Scroll controller để quản lý việc scroll
              final scrollController = ScrollController();

              return Stack(
                children: [
                  // Nội dung chính có thể scrollable
                  SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.only(
                        bottom: 80), // Thêm padding để tránh che khuất nội dung
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        QlzFlashcardCarousel(flashcards: flashcards),
                        const SizedBox(height: 20),
                        const ModuleUserInfo(),
                        const SizedBox(height: 20),
                        StudyOptionsList(
                          onOptionSelected: (route) {
                            Navigator.pushNamed(
                              context,
                              route,
                              arguments: {
                                'moduleId': moduleId,
                                'moduleName': moduleName,
                                'flashcards': flashcards,
                                'initialIndex': 0,
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        const StudyProgress(),
                        const SizedBox(height: 24),
                        const TermList(),
                      ],
                    ),
                  ),

                  // Nút "Học bộ học phần này" cố định ở cuối màn hình
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.darkBackground,
                        // Thêm shadow để tạo hiệu ứng nổi lên trên nội dung
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.studyFlashcards,
                            arguments: {
                              'moduleId': moduleId,
                              'moduleName': moduleName,
                              'flashcards': flashcards,
                              'initialIndex': 0,
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Học bộ học phần này',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      }),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF12113A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.white),
                title: const Text('Chỉnh sửa học phần',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to edit module screen
                },
              ),
              ListTile(
                leading: const Icon(Icons.download, color: Colors.white),
                title: const Text('Tải xuống ngoại tuyến',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Download for offline use
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Xóa học phần',
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Show delete confirmation dialog
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
