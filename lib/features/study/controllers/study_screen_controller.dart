// C:/Users/ntgpt/OneDrive/workspace/qlz_flash_cards_ui/lib/features/study/controllers/study_screen_controller.dart
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/features/study/data/flashcard_study_status.dart';
import 'package:qlz_flash_cards_ui/features/study/data/study_enums.dart';
import 'package:qlz_flash_cards_ui/features/study/services/study_queue_manager.dart';
import 'package:qlz_flash_cards_ui/features/vocabulary/data/flashcard.dart';

class StudyScreenController {
  final StudyQueueManager queueManager = StudyQueueManager();
  StudyMode currentMode = StudyMode.multipleChoice;
  String? selectedAnswer;
  String typedAnswer = '';
  bool isAnswerSubmitted = false;
  bool isAnswerCorrect = false;
  List<String> options = [];
  final TextEditingController answerController = TextEditingController();
  Timer? autoNextTimer;
  static const Duration autoNextDuration = Duration(seconds: 1);
  int multipleChoiceCorrect = 0;
  int typingCorrect = 0;

  // Khởi tạo và hủy
  void initialize(List<Flashcard> flashcards) {
    queueManager.initialize(flashcards);
    setupMultipleChoiceQuestion();
  }

  void dispose() {
    autoNextTimer?.cancel();
    answerController.dispose();
  }

  // Thiết lập câu hỏi
  void setupMultipleChoiceQuestion() {
    selectedAnswer = null;
    isAnswerSubmitted = false;
    isAnswerCorrect = false;
    currentMode = StudyMode.multipleChoice;
    final currentCard = queueManager.getCurrentCard();
    if (currentCard == null) return;
    final correctAnswer = currentCard.flashcard.term;
    options = [correctAnswer];
    final allTerms = queueManager.allAvailableCards
        .where((card) => card.flashcard.term != correctAnswer)
        .map((card) => card.flashcard.term)
        .toList();
    if (allTerms.isNotEmpty) {
      allTerms.shuffle();
      options.addAll(allTerms.take(math.min(3, allTerms.length)));
    }
    options.shuffle();
  }

  void setupTypingQuestion() {
    typedAnswer = '';
    answerController.clear();
    isAnswerSubmitted = false;
    isAnswerCorrect = false;
    currentMode = StudyMode.typing;
  }

  // Kiểm tra câu trả lời
  void checkMultipleChoiceAnswer(String answer) {
    if (isAnswerSubmitted) return;
    final currentCard = queueManager.getCurrentCard();
    if (currentCard == null) return;
    final isCorrect = answer == currentCard.flashcard.term;
    selectedAnswer = answer;
    isAnswerSubmitted = true;
    isAnswerCorrect = isCorrect;
    if (isCorrect) {
      queueManager.registerMultipleChoiceCorrect();
      multipleChoiceCorrect++;
    } else {
      queueManager.registerIncorrectAnswer();
    }
  }

  void checkTypingAnswer() {
    if (isAnswerSubmitted) return;
    final currentCard = queueManager.getCurrentCard();
    if (currentCard == null) return;
    final normalizedInput = answerController.text.trim().toLowerCase();
    final normalizedTerm = currentCard.flashcard.term.trim().toLowerCase();
    final isCorrect = normalizedInput == normalizedTerm;
    typedAnswer = answerController.text;
    isAnswerSubmitted = true;
    isAnswerCorrect = isCorrect;
    if (isCorrect) {
      queueManager.registerTypingCorrect();
      typingCorrect++;
      if (currentCard.isFullyCompleted) queueManager.cardsStudied++;
    } else {
      queueManager.registerIncorrectAnswer();
    }
  }

  // Điều hướng
  void nextStep(VoidCallback onUpdate) {
    autoNextTimer?.cancel();
    if (currentMode == StudyMode.multipleChoice) {
      queueManager.moveToNextMultipleChoiceCard();
      if (queueManager.isMultipleChoicePhaseCompleted()) {
        queueManager.prepareTypingPhase();
        currentMode = StudyMode.typing;
        setupTypingQuestion();
      } else {
        setupMultipleChoiceQuestion();
      }
      onUpdate();
    } else {
      queueManager.moveToNextTypingCard();
      if (queueManager.isTypingPhaseCompleted()) {
        if (queueManager.hasCardsForReview()) {
          queueManager.prepareReviewPhase();
          currentMode = StudyMode.multipleChoice;
          setupMultipleChoiceQuestion();
        } else if (queueManager.canAddNewCards()) {
          queueManager.prepareNewCardGroup();
          currentMode = StudyMode.multipleChoice;
          setupMultipleChoiceQuestion();
        }
      } else {
        setupTypingQuestion();
      }
      onUpdate();
    }
  }

  void autoAdvanceAfterDelay(VoidCallback onUpdate) {
    autoNextTimer = Timer(autoNextDuration, () => nextStep(onUpdate));
  }

  // Truy vấn thông tin
  FlashcardStudyStatus? getCurrentCard() => queueManager.getCurrentCard();

  double getProgress() => queueManager.getOverallProgress();

  Map<String, dynamic> getStudyStatistics() {
    final totalCards = queueManager.allAvailableCards.length;
    final completedCards = queueManager.completedCards.length;
    final totalAttempts = multipleChoiceCorrect + typingCorrect + queueManager.totalErrors;
    return {
      'totalCards': totalCards,
      'completedCards': completedCards,
      'cardsStudied': queueManager.cardsStudied,
      'multipleChoiceCorrect': multipleChoiceCorrect,
      'typingCorrect': typingCorrect,
      'totalErrors': queueManager.totalErrors,
      'completionRate': totalCards > 0 ? completedCards / totalCards * 100 : 0,
      'accuracyRate': totalAttempts > 0 ? (multipleChoiceCorrect + typingCorrect) / totalAttempts * 100 : 0,
      'cardsNeedingReview': queueManager.getCardsNeedingReviewCount(),
    };
  }

  String getCurrentPhase() => currentMode == StudyMode.multipleChoice ? "Multiple Choice" : "Typing";

  int getCurrentPhaseCardCount() => queueManager.getCurrentPhaseCardCount();

  int getCurrentPhaseCardIndex() => queueManager.getCurrentPhaseCardIndex();

  // Trạng thái module
  bool isModuleCompleted() => queueManager.isModuleCompleted();

  void resetForNewSession() {
    queueManager.resetForNewSession();
    multipleChoiceCorrect = 0;
    typingCorrect = 0;
    currentMode = StudyMode.multipleChoice;
    setupMultipleChoiceQuestion();
  }
}