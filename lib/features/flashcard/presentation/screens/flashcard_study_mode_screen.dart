import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/data/models/flashcard_model.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/domain/states/flashcard_state.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/presentation/providers/flashcard_provider.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/presentation/widgets/flashcard_progress_bar.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/presentation/widgets/flashcard_result_dialog.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_empty_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_loading_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_snackbar.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/layout/qlz_modal.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/navigation/qlz_app_bar.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/study/qlz_flashcard.dart';

class FlashcardStudyModeScreen extends ConsumerWidget {
  final List<Flashcard> flashcards;
  final int initialIndex;

  const FlashcardStudyModeScreen({
    super.key,
    required this.flashcards,
    this.initialIndex = 0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize flashcards when the screen is first built
    ref.read(flashcardProvider.notifier).initializeFlashcards(
          flashcards,
          initialIndex.clamp(0, flashcards.isEmpty ? 0 : flashcards.length - 1),
        );

    return const FlashcardStudyModeView();
  }
}

class FlashcardStudyModeView extends ConsumerStatefulWidget {
  const FlashcardStudyModeView({super.key});

  @override
  ConsumerState<FlashcardStudyModeView> createState() =>
      _FlashcardStudyModeViewState();
}

class _FlashcardStudyModeViewState
    extends ConsumerState<FlashcardStudyModeView> {
  final CardSwiperController _cardSwiperController = CardSwiperController();
  final Map<String, QlzFlashcardController> _flashcardControllers = {};
  bool _dialogShown = false;
  bool _isAutoPlayEnabled = false;
  Timer? _autoPlayTimer;
  bool _isAutoSwiping = false;
  Flashcard? _currentFlashcard;

  @override
  void dispose() {
    _stopAutoPlayMode();
    super.dispose();
  }

  QlzFlashcardController _getFlashcardController(String flashcardId) {
    if (!_flashcardControllers.containsKey(flashcardId)) {
      _flashcardControllers[flashcardId] = QlzFlashcardController();
    }
    return _flashcardControllers[flashcardId]!;
  }

  void _showCompletionDialog(BuildContext context) {
    final state = ref.read(flashcardProvider);
    _dialogShown = true;

    QlzModal.showDialog(
      context: context,
      title: "Hoàn thành!",
      child: FlashcardResultDialog(
        learnedCount: state.learnedCount,
        notLearnedCount: state.notLearnedCount,
        totalFlashcards: state.totalFlashcards,
        onRestart: () {
          ref.read(flashcardProvider.notifier).resetStudySession();
          _dialogShown = false;
        },
      ),
    ).then((_) => _dialogShown = false);
  }

  void _toggleAutoPlayMode(BuildContext context) {
    setState(() {
      _isAutoPlayEnabled = !_isAutoPlayEnabled;
      _isAutoSwiping = _isAutoPlayEnabled;
    });

    if (_isAutoPlayEnabled) {
      final state = ref.read(flashcardProvider);
      _currentFlashcard = state.currentFlashcard;
      _runAutoPlaySequence(context);
    } else {
      _stopAutoPlayMode();
    }
  }

  void _runAutoPlaySequence(BuildContext context) {
    if (!mounted || !_isAutoPlayEnabled) return;

    final state = ref.read(flashcardProvider);

    if (state.flashcards.isEmpty) {
      _stopAutoPlayMode();
      return;
    }

    final flashcardId = state.currentFlashcard?.id ?? '';
    final controller = _getFlashcardController(flashcardId);

    if (controller.isShowingFront) {
      controller.flip();
      _autoPlayTimer = Timer(const Duration(seconds: 5), () {
        if (!mounted || !_isAutoPlayEnabled) return;

        if (state.currentIndex < state.flashcards.length - 1) {
          _cardSwiperController.swipe(CardSwiperDirection.right);
          _autoPlayTimer = Timer(const Duration(seconds: 1), () {
            if (mounted && _isAutoPlayEnabled) {
              _runAutoPlaySequence(context);
            }
          });
        } else {
          _stopAutoPlayMode();
          if (!_dialogShown) {
            _showCompletionDialog(context);
          }
        }
      });
    } else {
      if (state.currentIndex < state.flashcards.length - 1) {
        _cardSwiperController.swipe(CardSwiperDirection.right);
        _autoPlayTimer = Timer(const Duration(seconds: 1), () {
          if (mounted && _isAutoPlayEnabled) {
            _runAutoPlaySequence(context);
          }
        });
      } else {
        _stopAutoPlayMode();
        if (!_dialogShown) {
          _showCompletionDialog(context);
        }
      }
    }
  }

  void _stopAutoPlayMode() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
    setState(() {
      _isAutoPlayEnabled = false;
    });
  }

  Future<void> _toggleFlashcardDifficulty(Flashcard flashcard) async {
    await ref.read(flashcardProvider.notifier).toggleDifficulty(flashcard.id);

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
    final state = ref.watch(flashcardProvider);

    // Listen for state changes to show completion dialog
    ref.listen<FlashcardState>(flashcardProvider, (previous, current) {
      if (current.isSessionCompleted &&
          !current.hasMoreFlashcards &&
          !_dialogShown) {
        _showCompletionDialog(context);
      }
      _currentFlashcard = current.currentFlashcard;
    });

    switch (state.status) {
      case FlashcardStatus.loading:
        return _buildLoadingState();
      case FlashcardStatus.failure:
        return _buildErrorState(state);
      case FlashcardStatus.success:
      case FlashcardStatus.initial:
        return _buildStudyInterface(context, state);
    }
  }

  // Các phương thức build khác giữ nguyên, chỉ thay đổi context.read<FlashcardCubit>()
  // thành ref.read(flashcardProvider.notifier)
  // ...

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
    final flashcardWidgets = state.flashcards.map((flashcard) {
      final controller = _getFlashcardController(flashcard.id);
      return Container(
        margin: const EdgeInsets.all(20),
        child: QlzFlashcard(
          key: ValueKey(flashcard.id),
          controller: controller,
          term: flashcard.term,
          definition: flashcard.definition,
          example: flashcard.example,
          pronunciation: flashcard.pronunciation,
          isDifficult: flashcard.isDifficult,
          onAudioPlay: () {
            // Audio functionality
          },
          onMarkAsDifficult: () => _toggleFlashcardDifficulty(flashcard),
        ),
      );
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0A092D),
      appBar: QlzAppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Đóng',
        ),
        title: '${state.currentIndex + 1}/${state.totalFlashcards}',
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: FlashcardProgressBar(progress: state.progressFraction),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _buildCounter(
                    count: state.notLearnedCount,
                    color: Colors.orange,
                    isLeftSide: true,
                  ),
                  const Spacer(),
                  _buildCounter(
                    count: state.learnedCount,
                    color: Colors.green,
                    isLeftSide: false,
                  ),
                ],
              ),
            ),
            Expanded(
              child: flashcardWidgets.isEmpty
                  ? const Center(
                      child: Text('Không có thẻ nào',
                          style: TextStyle(color: Colors.white)))
                  : CardSwiper(
                      controller: _cardSwiperController,
                      cardsCount: flashcardWidgets.length,
                      initialIndex: state.currentIndex,
                      isLoop: false,
                      allowedSwipeDirection: _isAutoPlayEnabled
                          ? const AllowedSwipeDirection.none()
                          : const AllowedSwipeDirection.all(),
                      onSwipe: (previousIndex, currentIndex, direction) {
                        if (!_isAutoSwiping) {
                          if (direction == CardSwiperDirection.left) {
                            ref
                                .read(flashcardProvider.notifier)
                                .markAsNotLearned();
                          } else if (direction == CardSwiperDirection.right) {
                            ref
                                .read(flashcardProvider.notifier)
                                .markAsLearned();
                          }
                        }
                        if (currentIndex != null &&
                            currentIndex != state.currentIndex) {
                          ref
                              .read(flashcardProvider.notifier)
                              .onPageChanged(currentIndex);
                        }
                        return true;
                      },
                      onEnd: () {
                        if (!_dialogShown) {
                          _showCompletionDialog(context);
                        }
                      },
                      numberOfCardsDisplayed: 1,
                      backCardOffset: const Offset(0, 0),
                      padding: const EdgeInsets.all(0),
                      cardBuilder: (context, index, percentThresholdX,
                          percentThresholdY) {
                        Color overlayColor = Colors.transparent;
                        IconData? overlayIcon;
                        double opacity = 0.0;
                        if (percentThresholdX.abs() > 0.1) {
                          opacity =
                              (1.0 - percentThresholdX.abs()).clamp(0.3, 1.0);
                          if (percentThresholdX > 0) {
                            if (!_isAutoSwiping) {
                              overlayColor = Colors.green;
                              overlayIcon = Icons.check;
                            }
                          } else {
                            overlayColor = Colors.orange;
                            overlayIcon = Icons.refresh;
                          }
                        }
                        return Stack(
                          children: [
                            flashcardWidgets[index],
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: overlayColor.withOpacity(opacity),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: opacity > 0.2
                                    ? Center(
                                        child: Icon(
                                          overlayIcon,
                                          color: Colors.white,
                                          size: 100,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.arrow_back,
                    color: Colors.grey,
                    onPressed: _isAutoPlayEnabled
                        ? null
                        : () {
                            if (state.currentIndex > 0) {
                              _cardSwiperController
                                  .swipe(CardSwiperDirection.bottom);
                            }
                          },
                    tooltip: 'Quay lại',
                    isDisabled: _isAutoPlayEnabled || state.currentIndex == 0,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: [
                        const Text(
                          'Chạm vào thẻ để lật',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Vuốt phải: Đã biết | Vuốt trái: Đang học',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  _buildActionButton(
                    icon: _isAutoPlayEnabled ? Icons.pause : Icons.play_arrow,
                    color: AppColors.primary,
                    onPressed: () => _toggleAutoPlayMode(context),
                    tooltip: _isAutoPlayEnabled ? 'Tạm dừng' : 'Tự động phát',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounter({
    required int count,
    required Color color,
    required bool isLeftSide,
  }) {
    return Container(
      width: 70,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.horizontal(
          left: isLeftSide ? const Radius.circular(20) : Radius.zero,
          right: !isLeftSide ? const Radius.circular(20) : Radius.zero,
        ),
        border: Border.all(color: color, width: 1),
      ),
      alignment: Alignment.center,
      child: Text(
        '$count',
        style: TextStyle(
          color: color,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
    String? tooltip,
    bool isDisabled = false,
  }) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: IconButton.filledTonal(
        onPressed: isDisabled ? null : onPressed,
        icon: Icon(icon),
        tooltip: tooltip,
        iconSize: 32,
        style: IconButton.styleFrom(
          backgroundColor: isDisabled
              ? Colors.grey.withOpacity(0.1)
              : color.withOpacity(0.2),
          foregroundColor: isDisabled ? Colors.grey : color,
          minimumSize: const Size(56, 56),
        ),
      ),
    );
  }
}
