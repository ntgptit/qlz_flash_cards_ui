// C:/Users/ntgpt/OneDrive/workspace/qlz_flash_cards_ui/lib/features/study/services/study_queue_manager.dart
import 'dart:math';

import 'package:qlz_flash_cards_ui/features/study/data/flashcard_study_status.dart';
import 'package:qlz_flash_cards_ui/features/vocabulary/data/flashcard.dart' show Flashcard;

enum StudyPhase { multipleChoice, typing, review }

class StudyQueueManager {
  static const int cardsPerGroup = 7;
  static const int spacingBetweenReviews = 3;
  static const int maxErrorsBeforeNewGroup = 3;

  final List<FlashcardStudyStatus> activeQueue = [];
  final List<FlashcardStudyStatus> reviewQueue = [];
  final List<FlashcardStudyStatus> completedCards = [];
  final List<FlashcardStudyStatus> allAvailableCards = [];
  final Set<String> usedCardIds = {};

  StudyPhase currentPhase = StudyPhase.multipleChoice;
  int multipleChoiceIndex = 0;
  int typingIndex = 0;
  int reviewIndex = 0;
  int totalErrors = 0;
  int cardsStudied = 0;

  void initialize(List<Flashcard> flashcards) {
    _resetState();
    for (var card in flashcards) {
      allAvailableCards.add(FlashcardStudyStatus(flashcard: card));
    }
    allAvailableCards.shuffle();
    addNewCardsToQueue();
  }

  void _resetState() {
    activeQueue.clear();
    reviewQueue.clear();
    completedCards.clear();
    usedCardIds.clear();
    allAvailableCards.clear();
    totalErrors = 0;
    cardsStudied = 0;
    multipleChoiceIndex = 0;
    typingIndex = 0;
    reviewIndex = 0;
    currentPhase = StudyPhase.multipleChoice;
  }

  FlashcardStudyStatus? getCurrentCard() {
    if (activeQueue.isEmpty) return null;
    switch (currentPhase) {
      case StudyPhase.multipleChoice:
        return multipleChoiceIndex < activeQueue.length ? activeQueue[multipleChoiceIndex] : null;
      case StudyPhase.typing:
        return typingIndex < activeQueue.length ? activeQueue[typingIndex] : null;
      case StudyPhase.review:
        return reviewIndex < reviewQueue.length ? reviewQueue[reviewIndex] : null;
    }
  }

  int getCurrentPhaseCardIndex() {
    switch (currentPhase) {
      case StudyPhase.multipleChoice:
        return multipleChoiceIndex;
      case StudyPhase.typing:
        return typingIndex;
      case StudyPhase.review:
        return reviewIndex;
    }
  }

  int getCurrentPhaseCardCount() {
    switch (currentPhase) {
      case StudyPhase.multipleChoice:
      case StudyPhase.typing:
        return activeQueue.length;
      case StudyPhase.review:
        return reviewQueue.length;
    }
  }

  void addNewCardsToQueue() {
    if (activeQueue.length >= cardsPerGroup) return;
    final cardsToAdd = cardsPerGroup - activeQueue.length;
    final unusedCards = allAvailableCards.where((card) => !usedCardIds.contains(card.flashcard.id ?? '')).toList();
    if (unusedCards.isEmpty) return;
    final cardsToTake = min(cardsToAdd, unusedCards.length);
    final newCards = unusedCards.take(cardsToTake).toList();
    for (var card in newCards) {
      activeQueue.add(card);
      if (card.flashcard.id != null) usedCardIds.add(card.flashcard.id!);
    }
  }

  void registerMultipleChoiceCorrect() {
    final currentCard = getCurrentCard();
    if (currentCard == null) return;
    currentCard.isCorrectInMultipleChoice = true;
  }

  void registerTypingCorrect() {
    final currentCard = getCurrentCard();
    if (currentCard == null) return;
    currentCard.isCorrectInTyping = true;
    if (currentCard.isCorrectInMultipleChoice) currentCard.isCompleted = true;
  }

  void registerIncorrectAnswer() {
    final currentCard = getCurrentCard();
    if (currentCard == null) return;
    currentCard.markError();
    totalErrors++;
  }

  void scheduleCardForReview(FlashcardStudyStatus card) {
    if (!reviewQueue.contains(card)) {
      final insertPosition = min(reviewQueue.length, spacingBetweenReviews);
      if (insertPosition >= reviewQueue.length) {
        reviewQueue.add(card);
      } else {
        reviewQueue.insert(insertPosition, card);
      }
    }
  }

  void moveToNextMultipleChoiceCard() {
    multipleChoiceIndex++;
    if (multipleChoiceIndex >= activeQueue.length) multipleChoiceIndex = 0;
  }

  void moveToNextTypingCard() {
    final currentCard = getCurrentCard();
    if (currentCard == null) return;
    if (currentCard.isCompleted) {
      if (!completedCards.contains(currentCard)) completedCards.add(currentCard);
      activeQueue.removeAt(typingIndex);
    } else if (currentCard.needsReview) {
      scheduleCardForReview(currentCard);
      activeQueue.removeAt(typingIndex);
    } else {
      typingIndex++;
    }
    if (typingIndex >= activeQueue.length) typingIndex = 0;
    cardsStudied++;
  }

  bool isMultipleChoicePhaseCompleted() {
    return activeQueue.every((card) => card.isCorrectInMultipleChoice || card.needsReview);
  }

  bool isTypingPhaseCompleted() => activeQueue.isEmpty;

  void prepareTypingPhase() {
    currentPhase = StudyPhase.typing;
    typingIndex = 0;
    activeQueue.removeWhere((card) {
      if (card.needsReview) {
        scheduleCardForReview(card);
        return true;
      }
      return false;
    });
  }

  void prepareReviewPhase() {
    currentPhase = StudyPhase.review;
    reviewIndex = 0;
    activeQueue.addAll(reviewQueue);
    reviewQueue.clear();
  }

  bool hasCardsForReview() => reviewQueue.isNotEmpty;

  int getCardsNeedingReviewCount() => reviewQueue.length;

  void prepareNewCardGroup() {
    totalErrors = 0;
    addNewCardsToQueue();
    currentPhase = StudyPhase.multipleChoice;
    multipleChoiceIndex = 0;
  }

  bool isCurrentGroupCompleted() => activeQueue.isEmpty && cardsStudied >= cardsPerGroup;

  bool canAddNewCards() => totalErrors < maxErrorsBeforeNewGroup;

  bool isModuleCompleted() => activeQueue.isEmpty && reviewQueue.isEmpty && completedCards.length == allAvailableCards.length;

  void resetForNewSession() {
    _resetState();
    for (var card in allAvailableCards) {
      card.reset();
    }
    allAvailableCards.shuffle();
    addNewCardsToQueue();
  }

  double getOverallProgress() => allAvailableCards.isEmpty ? 0.0 : completedCards.length / allAvailableCards.length;
}