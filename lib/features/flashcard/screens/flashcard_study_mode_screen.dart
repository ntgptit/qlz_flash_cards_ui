import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/data/models/flashcard_model.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/data/repositories/flashcard_repository.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/logic/cubit/flashcard_cubit.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/logic/states/flashcard_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/buttons/qlz_button.dart';
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
        RepositoryProvider.of<FlashcardRepository>(context), 
      )..fetchFlashcards(),
      child: const FlashcardStudyModeView(),
    );
  }
}

class FlashcardStudyModeView extends StatefulWidget {
  const FlashcardStudyModeView({super.key});

  @override
  _FlashcardStudyModeViewState createState() => _FlashcardStudyModeViewState();
}

class _FlashcardStudyModeViewState extends State<FlashcardStudyModeView> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _moveToNextCard(BuildContext context) {
    final cubit = context.read<FlashcardCubit>();
    final state = cubit.state;

    if (state.currentIndex < state.flashcards.length - 1) {
      final newIndex = state.currentIndex + 1;
      _pageController.animateToPage(
        newIndex,
        duration: const Duration(milliseconds: kIsWeb ? 150 : 300),
        curve: Curves.easeInOut,
      ).then((_) {
        cubit.emit(state.copyWith(currentIndex: newIndex));
      });
    } else {
      _showCompletionDialog(context);
    }
  }

  void _showCompletionDialog(BuildContext context) {
    final state = context.read<FlashcardCubit>().state;
    final learnedCards = state.learnedCount;
    final notLearnedCards = state.notLearnedCount;
    final percentLearned = (learnedCards / (learnedCards + notLearnedCards) * 100).toStringAsFixed(1);

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
              context.read<FlashcardCubit>().resetStudySession();
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
    return BlocBuilder<FlashcardCubit, FlashcardState>(
      builder: (context, state) {
        if (state.status == FlashcardStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state.status == FlashcardStatus.failure) {
          return Center(child: Text('Error: ${state.errorMessage}'));
        }

        return Scaffold(
          backgroundColor: const Color(0xFF0A092D),
          appBar: QlzAppBar(
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
            title: '${state.currentIndex + 1}/${state.flashcards.length}',
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: "Bắt đầu lại",
                onPressed: () => context.read<FlashcardCubit>().resetStudySession(),
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {},
              ),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isWideScreen = constraints.maxWidth > 600;

              return isWideScreen
                  ? Row(
                      children: [
                        Expanded(flex: 2, child: _buildSidePanel(context)),
                        Expanded(flex: 5, child: _buildMainContent(context)),
                      ],
                    )
                  : _buildMainContent(context);
            },
          ),
        );
      },
    );
  }

  Widget _buildSidePanel(BuildContext context) {
    final state = context.read<FlashcardCubit>().state;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          QlzChip(
            label: '${state.notLearnedCount}',
            type: QlzChipType.warning,
            icon: Icons.access_time,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          const SizedBox(height: 20),
          QlzChip(
            label: '${state.learnedCount}',
            type: QlzChipType.success,
            icon: Icons.check_circle_outline,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          const SizedBox(height: 40),
          QlzButton(
            label: "Bắt đầu lại",
            icon: Icons.refresh,
            variant: QlzButtonVariant.secondary,
            onPressed: () => context.read<FlashcardCubit>().resetStudySession(),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    final state = context.read<FlashcardCubit>().state;

    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              context.read<FlashcardCubit>().emit(context.read<FlashcardCubit>().state.copyWith(currentIndex: index));
            },
            itemCount: state.flashcards.length,
            itemBuilder: (_, index) {
              final flashcard = state.flashcards[index]; 

              return GestureDetector(
                onTap: kIsWeb ? () => context.read<FlashcardCubit>().markAsLearned() : null,
                onHorizontalDragEnd: (details) {
                  if (!kIsWeb) {
                    final dragDistance = details.primaryVelocity ?? 0;
                    if (dragDistance > 300) {
                      context.read<FlashcardCubit>().markAsLearned();
                    } else if (dragDistance < -300) {
                      context.read<FlashcardCubit>().markAsNotLearned();
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
                onPressed: () => context.read<FlashcardCubit>().markAsNotLearned(),
                icon: const Icon(Icons.close, color: AppColors.warning, size: 32),
              ),
              Column(
                children: [
                  const Text(
                    'Chạm vào để lật thẻ',
                    style: TextStyle(color: Color.fromRGBO(255, 255, 255, 0.7)),
                  ),
                  if (!kIsWeb && state.currentIndex > 0)
                    TextButton.icon(
                      onPressed: () => context.read<FlashcardCubit>().resetStudySession(),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      icon: const Icon(Icons.refresh, size: 18, color: AppColors.secondary),
                      label: const Text(
                        'Bắt đầu lại',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              IconButton(
                onPressed: () => context.read<FlashcardCubit>().markAsLearned(),
                icon: const Icon(Icons.check, color: AppColors.success, size: 32),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
