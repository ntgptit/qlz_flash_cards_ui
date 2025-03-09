import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/features/study/data/study_session_state.dart';
import 'package:qlz_flash_cards_ui/features/vocabulary/data/flashcard.dart';

abstract class StudyStrategy {
  Widget buildContent(
      BuildContext context, Flashcard flashcard, StudySessionState state);
  void checkAnswer(
      String userAnswer, Flashcard flashcard, StudySessionState state);
  void onNext(StudySessionState state);
  void onSkip(StudySessionState state);
}
