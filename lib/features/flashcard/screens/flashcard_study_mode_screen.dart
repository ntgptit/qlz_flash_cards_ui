import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
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
  // Controllers
  final CardSwiperController _cardSwiperController = CardSwiperController();
  final Map<String, QlzFlashcardController> _flashcardControllers = {};

  // State variables
  bool _dialogShown = false;
  bool _isAutoPlayEnabled = false;
  Timer? _autoPlayTimer;
  bool _isAutoSwiping = false;

  // Ghi nhớ flashcard hiện tại
  Flashcard? _currentFlashcard;

  @override
  void dispose() {
    _stopAutoPlayMode();
    super.dispose();
  }

  // Tạo hoặc lấy controller cho một flashcard cụ thể
  QlzFlashcardController _getFlashcardController(String flashcardId) {
    if (!_flashcardControllers.containsKey(flashcardId)) {
      _flashcardControllers[flashcardId] = QlzFlashcardController();
    }
    return _flashcardControllers[flashcardId]!;
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
          _dialogShown = false;
        },
      ),
    ).then((_) => _dialogShown = false);
  }

  void _toggleAutoPlayMode(BuildContext context) {
    setState(() {
      _isAutoPlayEnabled = !_isAutoPlayEnabled;

      // Khi bật chế độ tự động, đánh dấu biến _isAutoSwiping
      _isAutoSwiping = _isAutoPlayEnabled;
    });

    if (_isAutoPlayEnabled) {
      // Khởi động chuỗi tự động với flashcard hiện tại
      final state = context.read<FlashcardCubit>().state;
      _currentFlashcard = state.currentFlashcard;
      _runAutoPlaySequence(context);
    } else {
      _stopAutoPlayMode();
    }
  }

  void _runAutoPlaySequence(BuildContext context) {
    if (!mounted || !_isAutoPlayEnabled) return;

    final cubit = context.read<FlashcardCubit>();
    final state = cubit.state;

    if (state.flashcards.isEmpty) {
      _stopAutoPlayMode();
      return;
    }

    // Lấy controller cho flashcard hiện tại
    final flashcardId = state.currentFlashcard?.id ?? '';
    final controller = _getFlashcardController(flashcardId);

    if (controller.isShowingFront) {
      // 1. Nếu đang ở mặt trước, lật thẻ để xem định nghĩa
      controller.flip();

      // 2. Đợi 5 giây để người dùng đọc định nghĩa
      _autoPlayTimer = Timer(const Duration(seconds: 5), () {
        if (!mounted || !_isAutoPlayEnabled) return;

        // 3. Kiểm tra nếu đây là thẻ cuối cùng
        if (state.currentIndex < state.flashcards.length - 1) {
          // 4. Nếu chưa phải thẻ cuối, chuyển sang thẻ kế tiếp (KHÔNG đánh dấu điểm)
          _cardSwiperController.swipe(CardSwiperDirection.right);

          // 5. Đợi animation chuyển thẻ hoàn tất
          _autoPlayTimer = Timer(const Duration(seconds: 1), () {
            if (mounted && _isAutoPlayEnabled) {
              // 6. Tiếp tục chuỗi với thẻ mới
              _runAutoPlaySequence(context);
            }
          });
        } else {
          // Nếu là thẻ cuối cùng
          _stopAutoPlayMode();
          if (!_dialogShown) {
            _showCompletionDialog(context);
          }
        }
      });
    } else {
      // Nếu đang ở mặt sau, chuyển thẻ luôn (không cần lật về mặt trước)
      if (state.currentIndex < state.flashcards.length - 1) {
        // Chuyển sang thẻ tiếp theo (KHÔNG đánh dấu điểm)
        _cardSwiperController.swipe(CardSwiperDirection.right);

        // Đợi animation chuyển thẻ hoàn tất
        _autoPlayTimer = Timer(const Duration(seconds: 1), () {
          if (mounted && _isAutoPlayEnabled) {
            _runAutoPlaySequence(context);
          }
        });
      } else {
        // Nếu là thẻ cuối cùng
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
        if (state.isSessionCompleted &&
            !state.hasMoreFlashcards &&
            !_dialogShown) {
          _showCompletionDialog(context);
        }

        // Cập nhật flashcard hiện tại khi thay đổi
        _currentFlashcard = state.currentFlashcard;
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
    // Tạo danh sách các thẻ để hiển thị trong swiper
    final flashcardWidgets = state.flashcards.map((flashcard) {
      // Tạo hoặc lấy controller cho flashcard
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
            // Implement audio playback logic
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
            // Counters for learned/not learned terms
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

            // Flashcard area with CardSwiper
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
                            // Vuốt trái - đánh dấu đang học (chưa thuộc)
                            context.read<FlashcardCubit>().markAsNotLearned();
                          } else if (direction == CardSwiperDirection.right) {
                            // Vuốt phải - đánh dấu đã thuộc
                            context.read<FlashcardCubit>().markAsLearned();
                          }
                        }

                        // Cập nhật index hiện tại
                        if (currentIndex != null &&
                            currentIndex != state.currentIndex) {
                          context
                              .read<FlashcardCubit>()
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
                        // Thêm hiệu ứng màu cho thẻ khi vuốt
                        Color overlayColor = Colors.transparent;
                        IconData? overlayIcon;

                        // Đảm bảo opacity nằm trong khoảng [0.0, 1.0]
                        double opacity = 0.0;

                        // Xác định màu overlay dựa vào hướng vuốt
                        if (percentThresholdX.abs() > 0.1) {
                          // Giới hạn giá trị opacity từ 0.0 đến 1.0
                          opacity =
                              (1.0 - percentThresholdX.abs()).clamp(0.3, 1.0);

                          if (percentThresholdX > 0) {
                            // Vuốt phải - đã thuộc (màu xanh)
                            if (!_isAutoSwiping) {
                              overlayColor = Colors.green;
                              overlayIcon = Icons.check;
                            }
                          } else {
                            // Vuốt trái - đang học (màu cam)
                            overlayColor = Colors.orange;
                            overlayIcon = Icons.refresh;
                          }
                        }

                        return Stack(
                          children: [
                            // Thẻ gốc
                            flashcardWidgets[index],

                            // Overlay màu khi vuốt
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

            // Navigation buttons
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
                  // Swipe guidance text
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
