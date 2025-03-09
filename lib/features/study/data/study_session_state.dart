import 'package:qlz_flash_cards_ui/features/flashcard/data/models/flashcard_model.dart';

class StudySessionState {
  int currentIndex = 0;
  int correctAnswers = 0;
  bool isSessionComplete = false;
  final List<Flashcard> flashcards;
  final List<String> userAnswers = [];
  final List<bool> isAnswered = [];
  final List<bool> isCorrect = [];

  StudySessionState(this.flashcards) {
    for (int i = 0; i < flashcards.length; i++) {
      userAnswers.add('');
      isAnswered.add(false);
      isCorrect.add(false);
    }
  }

  double get successRate =>
      flashcards.isEmpty ? 0.0 : correctAnswers / flashcards.length;
}
