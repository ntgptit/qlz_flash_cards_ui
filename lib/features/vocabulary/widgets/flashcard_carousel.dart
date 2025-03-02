// lib/features/vocabulary/widgets/flashcard_carousel.dart

import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/screens/flashcard_study_mode_screen.dart';
import 'package:qlz_flash_cards_ui/features/vocabulary/data/flashcard.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_empty_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/study/qlz_flashcard.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/buttons/qlz_icon_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qlz_flash_cards_ui/features/vocabulary/cubit/vocabulary_cubit.dart';

final class FlashcardCarousel extends StatefulWidget {
  final List<Flashcard> flashcards;

  const FlashcardCarousel({super.key, required this.flashcards});

  @override
  State<FlashcardCarousel> createState() => _FlashcardCarouselState();
}

class _FlashcardCarouselState extends State<FlashcardCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9, initialPage: 0);
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
    // Thông báo cho Cubit về thay đổi trang
    context.read<VocabularyCubit>().updateCurrentPage(page);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.flashcards.isEmpty) {
      return QlzEmptyState.noData(
        title: 'Không có thẻ nào!',
        message: 'Chưa có thẻ ghi nhớ nào trong học phần này',
        actionLabel: 'Tạo thẻ ghi nhớ',
        onAction: () {
          // TODO: Implement create flashcard feature
        },
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 220,
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
                  onFlip: () {
                    // TODO: Track flip analytics
                  },
                  onAudioPlay: () {
                    context.read<VocabularyCubit>().playAudio(index);
                  },
                  onMarkAsDifficult: () {
                    context.read<VocabularyCubit>().markAsDifficult(index);
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.flashcards.length > 10 ? 10 : widget.flashcards.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 12 : 8,
              height: _currentPage == index ? 12 : 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index
                    ? AppColors.primary
                    : const Color.fromRGBO(255, 255, 255, 0.3),
              ),
            ),
          ),
        ),
        if (widget.flashcards.length > 10)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '${_currentPage + 1}/${widget.flashcards.length}',
              style: const TextStyle(
                color: Color.fromRGBO(255, 255, 255, 0.6),
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}
