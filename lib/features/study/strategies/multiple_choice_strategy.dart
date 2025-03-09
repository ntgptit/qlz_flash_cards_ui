import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/data/models/flashcard_model.dart';
import 'package:qlz_flash_cards_ui/features/study/data/study_session_state.dart';
import 'package:qlz_flash_cards_ui/features/study/widgets/option_list.dart';

import '../strategies/study_strategy.dart';

class MultipleChoiceStrategy implements StudyStrategy {
  @override
  Widget buildContent(
      BuildContext context, Flashcard flashcard, StudySessionState state) {
    return OptionList(
      flashcards: state.flashcards,
      flashcard: flashcard,
      onCorrectAnswer: () => checkAnswer(flashcard.term, flashcard, state),
      onWrongAnswer: () => checkAnswer('', flashcard, state),
      onContinue: () => onNext(state),
    );
  }

  @override
  void checkAnswer(
      String userAnswer, Flashcard flashcard, StudySessionState state) {
    state.isAnswered[state.currentIndex] = true;
    state.userAnswers[state.currentIndex] = userAnswer;
    if (userAnswer.toLowerCase() == flashcard.term.toLowerCase()) {
      state.correctAnswers++;
      state.isCorrect[state.currentIndex] = true;
    }
  }

  @override
  void onNext(StudySessionState state) {
    if (state.currentIndex < state.flashcards.length - 1) {
      state.currentIndex++;
    } else {
      state.isSessionComplete = true;
    }
  }

  @override
  void onSkip(StudySessionState state) {
    state.isAnswered[state.currentIndex] = true;
    state.userAnswers[state.currentIndex] = '';
  }
}
