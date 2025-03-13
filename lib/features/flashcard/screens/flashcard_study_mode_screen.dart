import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/data/models/flashcard_model.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/logic/cubit/flashcard_cubit.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/logic/states/flashcard_state.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/widgets/flashcard_progress_bar.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/widgets/flashcard_result_dialog.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_empty_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_loading_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_snackbar.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/layout/qlz_modal.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/navigation/qlz_app_bar.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/study/qlz_flashcard.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/utils/qlz_chip.dart';

class FlashcardStudyModeScreen extends StatelessWidget {
  final List<Flashcard> flashcards;
  final int initialIndex;

  const FlashcardStudyModeScreen({
    super.key,
    required this.flashcards,
    this.initialIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FlashcardCubit(
        context.read(),
      )..initializeFlashcards(
          flashcards,
          initialIndex.clamp(
              0, flashcards.isEmpty ? 0 : flashcards.length - 1)),
      child: const FlashcardStudyModeView(),
    );
  }
}

class FlashcardStudyModeView extends StatefulWidget {
  const FlashcardStudyModeView({super.key});

  @override
  State<FlashcardStudyModeView> createState() => _FlashcardStudyModeViewState();
}

class _FlashcardStudyModeViewState extends State<FlashcardStudyModeView> {
  late final PageController _pageController;
  double _prevDragDx = 0.0;
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: 0,
      viewportFraction: 0.9, // Improves UX by showing part of next/prev cards
      keepPage: true,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateCard(BuildContext context, {required bool isNext}) {
    final cubit = context.read<FlashcardCubit>();
    final state = cubit.state;

    // Check boundary conditions
    if (isNext && state.currentIndex >= state.flashcards.length - 1) {
      if (!_dialogShown) {
        _showCompletionDialog(context);
      }
      return;
    }

    if (isNext && state.hasMoreFlashcards) {
      final nextPage =
          (state.currentIndex + 1).clamp(0, state.flashcards.length - 1);
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: kIsWeb ? 150 : 300),
        curve: Curves.easeInOut,
      );
    } else if (!isNext && state.currentIndex > 0) {
      final prevPage =
          (state.currentIndex - 1).clamp(0, state.flashcards.length - 1);
      _pageController.animateToPage(
        prevPage,
        duration: const Duration(milliseconds: kIsWeb ? 150 : 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showCompletionDialog(BuildContext context) {
    final cubit = context.read<FlashcardCubit>();
    final state = cubit.state;

    _dialogShown = true;

    QlzModal.showDialog(
      context: context,
      title: "Hoàn thành!",
      child: FlashcardResultDialog(
        learnedCount: state.learnedCount,
        notLearnedCount: state.notLearnedCount,
        totalFlashcards: state.totalFlashcards,
        onRestart: () {
          cubit.resetStudySession();
          if (_pageController.hasClients) {
            _pageController.jumpToPage(0);
          }
          _dialogShown = false;
        },
      ),
    ).then((_) => _dialogShown = false);
  }

  Future<void> _toggleFlashcardDifficulty(Flashcard flashcard) async {
    await context.read<FlashcardCubit>().toggleDifficulty(flashcard.id);
    if (mounted) {
      QlzSnackbar.info(
        context: context,
        message: flashcard.isDifficult
            ? 'Đã bỏ đánh dấu là từ khó'
            : 'Đã đánh dấu là từ khó',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FlashcardCubit, FlashcardState>(
      listener: (context, state) {
        // Ensure PageController is synchronized with state
        if (_pageController.hasClients &&
            state.status == FlashcardStatus.success &&
            _pageController.page?.round() != state.currentIndex) {
          _pageController.animateToPage(
            state.currentIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }

        // Show completion dialog when session is complete
        if (state.isSessionCompleted &&
            !state.hasMoreFlashcards &&
            !_dialogShown) {
          _showCompletionDialog(context);
        }
      },
      builder: (context, state) {
        switch (state.status) {
          case FlashcardStatus.loading:
            return _buildLoadingState();
          case FlashcardStatus.failure:
            return _buildErrorState(state);
          case FlashcardStatus.success:
          case FlashcardStatus.initial:
            return _buildStudyInterface(context, state);
        }
      },
    );
  }

  Widget _buildLoadingState() {
    return const Scaffold(
      backgroundColor: Color(0xFF0A092D),
      appBar: QlzAppBar(title: 'Đang tải...'),
      body: Center(
        child: QlzLoadingState(message: 'Đang tải thẻ ghi nhớ...'),
      ),
    );
  }

  Widget _buildErrorState(FlashcardState state) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A092D),
      appBar: const QlzAppBar(),
      body: QlzEmptyState.error(
        title: 'Không thể tải thẻ ghi nhớ',
        message: state.errorMessage ?? 'Đã xảy ra lỗi khi tải dữ liệu',
        onAction: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildStudyInterface(BuildContext context, FlashcardState state) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A092D),
      appBar: QlzAppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Đóng',
        ),
        title: '${state.currentIndex + 1}/${state.totalFlashcards}',
        actions: [
          IconButton(
            icon: Icon(
              state.currentFlashcard?.isDifficult ?? false
                  ? Icons.star
                  : Icons.star_border,
            ),
            tooltip: "Đánh dấu khó",
            onPressed: state.currentFlashcard != null
                ? () => _toggleFlashcardDifficulty(state.currentFlashcard!)
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Bắt đầu lại",
            onPressed: () {
              context.read<FlashcardCubit>().resetStudySession();
              if (_pageController.hasClients) {
                _pageController.jumpToPage(0);
              }
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: FlashcardProgressBar(progress: state.progressFraction),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWideScreen = constraints.maxWidth > 600;
            return Row(
              children: [
                if (isWideScreen)
                  Expanded(
                    flex: 2,
                    child: _buildSidePanel(context, state),
                  ),
                Expanded(
                  flex: isWideScreen ? 5 : 1,
                  child: _buildMainContent(context, state),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSidePanel(BuildContext context, FlashcardState state) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          QlzChip(
            label: 'Chưa thuộc: ${state.notLearnedCount}',
            type: QlzChipType.warning,
            icon: Icons.access_time,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          const SizedBox(height: 20),
          QlzChip(
            label: 'Đã thuộc: ${state.learnedCount}',
            type: QlzChipType.success,
            icon: Icons.check_circle_outline,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          const SizedBox(height: 40),
          OutlinedButton.icon(
            onPressed: () {
              context.read<FlashcardCubit>().resetStudySession();
              if (_pageController.hasClients) {
                _pageController.jumpToPage(0);
              }
            },
            icon: const Icon(Icons.refresh, size: 20),
            label: const Text("Bắt đầu lại"),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white30),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, FlashcardState state) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            itemCount: state.flashcards.length,
            onPageChanged: (index) {
              // Use the dedicated method in the cubit to handle page changes
              context.read<FlashcardCubit>().onPageChanged(index);
            },
            itemBuilder: (_, index) {
              final flashcard = state.flashcards[index];
              return GestureDetector(
                onHorizontalDragStart: (details) =>
                    _prevDragDx = details.globalPosition.dx,
                onHorizontalDragEnd: (details) {
                  // Skip custom drag handling on web
                  if (kIsWeb) return;

                  // Threshold for considering it a swipe
                  final dragDistance = _prevDragDx - details.globalPosition.dx;
                  if (dragDistance.abs() > 60) {
                    final isSwipeRight = dragDistance > 0;

                    // Use PageController to animate instead of directly setting state
                    if (isSwipeRight && index < state.flashcards.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else if (!isSwipeRight && index > 0) {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: QlzFlashcard(
                    key: ValueKey(flashcard.id), // Optimize rebuilds
                    term: flashcard.term,
                    definition: flashcard.definition,
                    example: flashcard.example,
                    pronunciation: flashcard.pronunciation,
                    isDifficult: flashcard.isDifficult,
                    onMarkAsDifficult: () =>
                        _toggleFlashcardDifficulty(flashcard),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.arrow_back,
                color: Colors.grey,
                onPressed: () => _navigateCard(context, isNext: false),
                tooltip: 'Quay lại',
              ),
              _buildActionButton(
                icon: Icons.close,
                color: AppColors.warning,
                onPressed: () {
                  final cubit = context.read<FlashcardCubit>();
                  cubit.markAsNotLearned();

                  // Navigate to next card after marking
                  if (state.currentIndex < state.flashcards.length - 1) {
                    _navigateCard(context, isNext: true);
                  } else if (!_dialogShown) {
                    _showCompletionDialog(context);
                  }
                },
                tooltip: 'Chưa thuộc',
              ),
              _buildActionButton(
                icon: Icons.check,
                color: AppColors.success,
                onPressed: () {
                  final cubit = context.read<FlashcardCubit>();
                  cubit.markAsLearned();

                  // Navigate to next card after marking
                  if (state.currentIndex < state.flashcards.length - 1) {
                    _navigateCard(context, isNext: true);
                  } else if (!_dialogShown) {
                    _showCompletionDialog(context);
                  }
                },
                tooltip: 'Đã thuộc',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    String? tooltip,
  }) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: IconButton.filledTonal(
        onPressed: onPressed,
        icon: Icon(icon),
        tooltip: tooltip,
        iconSize: 32,
        style: IconButton.styleFrom(
          backgroundColor: color.withOpacity(0.2),
          foregroundColor: color,
          minimumSize: const Size(56, 56),
        ),
      ),
    );
  }
}
