import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qlz_flash_cards_ui/features/vocabulary/data/flashcard.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/layout/qlz_modal.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/navigation/qlz_app_bar.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/study/qlz_flashcard.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/utils/qlz_chip.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/buttons/qlz_button.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';

final class FlashcardStudyModeScreen extends StatefulWidget {
  final List<Flashcard> flashcards;
  final int initialIndex;

  const FlashcardStudyModeScreen({
    super.key,
    required this.flashcards,
    this.initialIndex = 0,
  });

  /// Factory constructor to create instance from route arguments
  factory FlashcardStudyModeScreen.fromArguments(
      Map<String, dynamic> arguments) {
    final flashcards = arguments['flashcards'] as List<Flashcard>;
    final initialIndex = arguments['initialIndex'] as int? ?? 0;

    return FlashcardStudyModeScreen(
      flashcards: flashcards,
      initialIndex: initialIndex,
    );
  }

  @override
  State<FlashcardStudyModeScreen> createState() =>
      _FlashcardStudyModeScreenState();
}

class _FlashcardStudyModeScreenState extends State<FlashcardStudyModeScreen> {
  late final PageController _pageController;
  int _currentIndex = 0;
  final ValueNotifier<int> _notLearnedCount = ValueNotifier<int>(0);
  final ValueNotifier<int> _learnedCount = ValueNotifier<int>(0);

  @override
  void initState() {
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    if (kIsWeb) {
      try {
        HardwareKeyboard.instance.addHandler(_handleKeyEvent);
      } catch (e) {
        debugPrint("Không thể đăng ký bàn phím: $e");
      }
    }
    super.initState();
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowRight:
          _markAsLearned();
          break;
        case LogicalKeyboardKey.arrowLeft:
          _markAsNotLearned();
          break;
        case LogicalKeyboardKey.keyR:
          _resetStudySession();
          break;
      }
    }
    return false;
  }

  @override
  void dispose() {
    if (kIsWeb) {
      HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    }
    _pageController.dispose();
    _notLearnedCount.dispose();
    _learnedCount.dispose();
    super.dispose();
  }

  void _markAsLearned() {
    _learnedCount.value++;
    _moveToNextCard();
  }

  void _markAsNotLearned() {
    _notLearnedCount.value++;
    _moveToNextCard();
  }

  void _moveToNextCard() {
    if (_currentIndex < widget.flashcards.length - 1) {
      final newIndex = _currentIndex + 1;
      _pageController
          .animateToPage(
        newIndex,
        duration: const Duration(milliseconds: kIsWeb ? 150 : 300),
        curve: Curves.easeInOut,
      )
          .then((_) {
        setState(() {
          _currentIndex = newIndex;
        });
      });
    } else {
      _showCompletionDialog();
    }
  }

  void _resetStudySession() {
    QlzModal.showConfirmation(
      context: context,
      title: "Bắt đầu lại",
      message: "Bạn có chắc muốn bắt đầu lại từ đầu không?",
      confirmText: "Bắt đầu lại",
      cancelText: "Hủy",
    ).then((confirmed) {
      if (confirmed) {
        setState(() {
          _currentIndex = 0;
          _notLearnedCount.value = 0;
          _learnedCount.value = 0;
        });
        _pageController.jumpToPage(0); // Thêm dòng này để reset nhanh
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _showCompletionDialog() {
    // final totalCards = widget.flashcards.length;
    final learnedCards = _learnedCount.value;
    final notLearnedCards = _notLearnedCount.value;
    final percentLearned =
        (learnedCards / (learnedCards + notLearnedCards) * 100)
            .toStringAsFixed(1);

    QlzModal.showDialog(
      context: context,
      title: "Chúc mừng!",
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Bạn đã học xong tất cả các flashcards!"),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text(
                    "$learnedCards",
                    style: const TextStyle(
                      color: AppColors.success,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text("Đã thuộc", style: TextStyle(fontSize: 12)),
                ],
              ),
              Column(
                children: [
                  Text(
                    "$notLearnedCards",
                    style: const TextStyle(
                      color: AppColors.warning,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text("Chưa thuộc", style: TextStyle(fontSize: 12)),
                ],
              ),
              Column(
                children: [
                  Text(
                    "$percentLearned%",
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text("Hoàn thành", style: TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          QlzButton(
            label: "Bắt đầu lại",
            icon: Icons.refresh,
            onPressed: () {
              Navigator.pop(context);
              _resetStudySession();
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Đóng"),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pop(context);
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWideScreen = constraints.maxWidth > 600;

          return Scaffold(
            backgroundColor: const Color(0xFF0A092D),
            appBar: QlzAppBar(
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
              title:
                  '${_currentIndex + 1}/${widget.flashcards.length}', // AnimatedSwitcher sẽ tự động được áp dụng
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: "Bắt đầu lại",
                  onPressed: _resetStudySession,
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {},
                ),
              ],
            ),
            body: isWideScreen
                ? Row(
                    children: [
                      Expanded(flex: 2, child: _buildSidePanel()),
                      Expanded(flex: 5, child: _buildMainContent()),
                    ],
                  )
                : _buildMainContent(),
          );
        },
      ),
    );
  }

  Widget _buildSidePanel() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ValueListenableBuilder<int>(
            valueListenable: _notLearnedCount,
            builder: (_, value, __) => QlzChip(
              label: '$value',
              type: QlzChipType.warning,
              icon: Icons.access_time,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
          const SizedBox(height: 20),
          ValueListenableBuilder<int>(
            valueListenable: _learnedCount,
            builder: (_, value, __) => QlzChip(
              label: '$value',
              type: QlzChipType.success,
              icon: Icons.check_circle_outline,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
          const SizedBox(height: 40),
          QlzButton(
            label: "Bắt đầu lại",
            icon: Icons.refresh,
            variant: QlzButtonVariant.secondary,
            onPressed: _resetStudySession,
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.flashcards.length,
            itemBuilder: (_, index) {
              final flashcard = widget.flashcards[index];

              return GestureDetector(
                onTap: kIsWeb ? _markAsLearned : null,
                onHorizontalDragEnd: (details) {
                  if (!kIsWeb) {
                    final dragDistance = details.primaryVelocity ?? 0;
                    if (dragDistance > 300) {
                      _markAsLearned();
                    } else if (dragDistance < -300) {
                      _markAsNotLearned();
                    }
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: QlzFlashcard(
                    term: flashcard.term,
                    definition: flashcard.definition,
                    example: flashcard.example,
                    pronunciation: flashcard.pronunciation,
                    onFlip: () {},
                    onAudioPlay: () {},
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
              IconButton(
                onPressed: _markAsNotLearned,
                icon:
                    const Icon(Icons.close, color: AppColors.warning, size: 32),
              ),
              Column(
                children: [
                  const Text(
                    'Chạm vào để lật thẻ',
                    style: TextStyle(color: Color.fromRGBO(255, 255, 255, 0.7)),
                  ),
                  if (!kIsWeb && _currentIndex > 0)
                    TextButton.icon(
                      onPressed: _resetStudySession,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      icon: const Icon(Icons.refresh,
                          size: 18, // Tăng nhẹ kích thước icon
                          color: AppColors.secondary),
                      label: const Text(
                        'Bắt đầu lại',
                        style: TextStyle(
                          fontSize: 13, // Tăng nhẹ kích thước chữ
                          fontWeight:
                              FontWeight.bold, // Làm chữ đậm hơn để dễ đọc
                          color: Colors.white, // Màu trắng để nổi bật hơn
                        ),
                      ),
                    ),
                ],
              ),
              IconButton(
                onPressed: _markAsLearned,
                icon:
                    const Icon(Icons.check, color: AppColors.success, size: 32),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
