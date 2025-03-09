import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/data/models/flashcard_model.dart';
import 'package:qlz_flash_cards_ui/features/study/data/study_session_state.dart';

import '../strategies/study_strategy.dart';
import '../widgets/writing_area.dart';

class WritingStrategy implements StudyStrategy {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  Widget buildContent(
      BuildContext context, Flashcard flashcard, StudySessionState state) {
    return WritingArea(
      answerController: _controller,
      focusNode: _focusNode,
      isAnswerChecked: state.isAnswered[state.currentIndex],
      isAnswerCorrect: state.isCorrect[state.currentIndex],
      correctAnswer:
          state.isCorrect[state.currentIndex] ? null : flashcard.term,
      onCheck: () => checkAnswer(_controller.text, flashcard, state),
      onNext: () => onNext(state),
      onDontKnow: () => onSkip(state),
    );
  }

  @override
  void checkAnswer(
      String userAnswer, Flashcard flashcard, StudySessionState state) {
    state.isAnswered[state.currentIndex] = true;
    state.userAnswers[state.currentIndex] = userAnswer;
    if (userAnswer.trim().toLowerCase() == flashcard.term.toLowerCase()) {
      state.correctAnswers++;
      state.isCorrect[state.currentIndex] = true;
    }
    _controller.clear();
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
