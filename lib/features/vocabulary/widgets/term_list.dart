// lib/features/vocabulary/widgets/term_list.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qlz_flash_cards_ui/features/vocabulary/cubit/vocabulary_cubit.dart';
import 'package:qlz_flash_cards_ui/features/vocabulary/cubit/vocabulary_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/cards/qlz_card.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/header/qlz_section_header.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/study/qlz_flashcard_term_item.dart';

final class TermList extends StatelessWidget {
  const TermList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VocabularyCubit, VocabularyState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const QlzSectionHeader(
                title: 'Thẻ',
                trailing: Row(
                  children: [
                    Text(
                      'Thứ tự gốc',
                      style: TextStyle(
                        color: Color.fromRGBO(255, 255, 255, 0.6),
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.sort,
                      color: Color.fromRGBO(255, 255, 255, 0.6),
                      size: 20,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (state.flashcards.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Không có thẻ nào để hiển thị',
                      style:
                          TextStyle(color: Color.fromRGBO(255, 255, 255, 0.6)),
                    ),
                  ),
                )
              else
                QlzCard(
                  backgroundColor: const Color(0xFF12113A),
                  padding: EdgeInsets.zero,
                  hasBorder: false,
                  child: Column(
                    children: state.flashcards.asMap().entries.map((entry) {
                      final index = entry.key;
                      final flashcard = entry.value;

                      return QlzFlashcardTermItem(
                        flashcard: flashcard,
                        onToggleDifficult: () {
                          context
                              .read<VocabularyCubit>()
                              .toggleFlashcardDifficulty(index);
                        },
                        onPlayAudio: () {
                          context.read<VocabularyCubit>().playAudio(index);
                        },
                        onTap: () {
                          // TODO: Navigate to flashcard detail
                        },
                        showDivider: index < state.flashcards.length - 1,
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
