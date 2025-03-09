// lib/shared/widgets/study/qlz_flashcard_carousel.dart

import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/data/models/flashcard_model.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/screens/flashcard_study_mode_screen.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/buttons/qlz_icon_button.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_empty_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/study/qlz_flashcard.dart';

final class QlzFlashcardCarousel extends StatefulWidget {
  /// Danh sách flashcards để hiển thị trong carousel
  final List<Flashcard> flashcards;
  
  /// Chiều cao của carousel
  final double height;
  
  /// Callback khi một trang mới được hiển thị
  final void Function(int)? onPageChanged;
  
  /// Trang ban đầu để hiển thị
  final int initialPage;
  
  /// Callback khi thẻ được lật
  final VoidCallback? onFlip;
  
  /// Callback khi người dùng muốn phát audio
  final void Function(int)? onAudioPlay;
  
  /// Callback khi người dùng đánh dấu một flashcard là khó
  final void Function(int)? onMarkAsDifficult;
  
  /// Callback khi người dùng nhấn vào nút xem toàn màn hình
  final void Function(int)? onFullscreen;
  
  /// Widget hiển thị khi không có flashcard nào
  final Widget? emptyWidget;
  
  /// Tiêu đề hiển thị khi không có flashcard
  final String emptyTitle;
  
  /// Thông báo hiển thị khi không có flashcard
  final String emptyMessage;
  
  /// Nhãn nút hành động khi không có flashcard
  final String? emptyActionLabel;
  
  /// Callback khi nút hành động được nhấn trong trạng thái trống
  final VoidCallback? onEmptyAction;
  
  /// Hiển thị tối đa bao nhiêu chỉ báo trang
  final int maxPageIndicators;

  const QlzFlashcardCarousel({
    super.key, 
    required this.flashcards,
    this.height = 220,
    this.onPageChanged,
    this.initialPage = 0,
    this.onFlip,
    this.onAudioPlay,
    this.onMarkAsDifficult,
    this.onFullscreen,
    this.emptyWidget,
    this.emptyTitle = 'Không có thẻ nào!',
    this.emptyMessage = 'Chưa có thẻ ghi nhớ nào trong học phần này',
    this.emptyActionLabel = 'Tạo thẻ ghi nhớ',
    this.onEmptyAction,
    this.maxPageIndicators = 10,
  });

  @override
  State<QlzFlashcardCarousel> createState() => _QlzFlashcardCarouselState();
}

class _QlzFlashcardCarouselState extends State<QlzFlashcardCarousel> {
  late final PageController _pageController;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _pageController = PageController(
      viewportFraction: 0.9, 
      initialPage: widget.initialPage,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    widget.onPageChanged?.call(page);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.flashcards.isEmpty) {
      if (widget.emptyWidget != null) {
        return widget.emptyWidget!;
      }
      
      return QlzEmptyState.noData(
        title: widget.emptyTitle,
        message: widget.emptyMessage,
        actionLabel: widget.emptyActionLabel,
        onAction: widget.onEmptyAction,
      );
    }

    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: _onPageChanged,
            itemCount: widget.flashcards.length,
            itemBuilder: (context, index) {
              final flashcard = widget.flashcards[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: QlzFlashcard(
                  term: flashcard.term,
                  definition: flashcard.definition,
                  example: flashcard.example,
                  pronunciation: flashcard.pronunciation,
                  isDifficult: flashcard.isDifficult,
                  onFlip: widget.onFlip,
                  onAudioPlay: () {
                    widget.onAudioPlay?.call(index);
                  },
                  onMarkAsDifficult: () {
                    widget.onMarkAsDifficult?.call(index);
                  },
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: QlzIconButton.ghost(
                            icon: Icons.open_in_full,
                            tooltip: 'Xem toàn màn hình',
                            onPressed: () {
                              if (widget.onFullscreen != null) {
                                widget.onFullscreen!.call(index);
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        FlashcardStudyModeScreen(
                                      flashcards: widget.flashcards,
                                      initialIndex: _currentPage,
                                    ),
                                  ),
                                );
                              }
                            },
                            size: QlzIconButtonSize.small,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        _buildPageIndicators(),
      ],
    );
  }
  
  Widget _buildPageIndicators() {
    final int totalCards = widget.flashcards.length;
    final int visibleIndicators = totalCards > widget.maxPageIndicators 
      ? widget.maxPageIndicators 
      : totalCards;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            visibleIndicators,
            (index) {
              // Adjust index if we have more cards than visible indicators
              final int adjustedIndex = totalCards > widget.maxPageIndicators
                  ? (_currentPage < widget.maxPageIndicators / 2 
                      ? index 
                      : (_currentPage > totalCards - widget.maxPageIndicators / 2
                          ? (totalCards - widget.maxPageIndicators) + index
                          : _currentPage - (widget.maxPageIndicators ~/ 2) + index))
                  : index;
                  
              final bool isCurrent = adjustedIndex == _currentPage;
              
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isCurrent ? 12 : 8,
                height: isCurrent ? 12 : 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCurrent
                      ? AppColors.primary
                      : const Color.fromRGBO(255, 255, 255, 0.3),
                ),
              );
            },
          ),
        ),
        if (totalCards > widget.maxPageIndicators)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '${_currentPage + 1}/$totalCards',
              style: const TextStyle(
                color: Color.fromRGBO(255, 255, 255, 0.6),
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
  
  /// Chuyển đến trang cụ thể trong carousel
  void goToPage(int page) {
    if (page >= 0 && page < widget.flashcards.length) {
      _pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }
  
  /// Chuyển đến trang kế tiếp
  void nextPage() {
    if (_currentPage < widget.flashcards.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }
  
  /// Chuyển đến trang trước đó
  void previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }
}