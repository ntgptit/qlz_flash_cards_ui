import 'package:equatable/equatable.dart';

import '../../data/models/flashcard_model.dart';

// Define the states
enum FlashcardStatus { initial, loading, success, failure }

class FlashcardState extends Equatable {
  final List<Flashcard> flashcards;
  final FlashcardStatus status;
  final String? errorMessage;
  final int currentIndex;
  final int learnedCount;
  final int notLearnedCount;

  const FlashcardState({
    this.flashcards = const [],
    this.status = FlashcardStatus.initial,
    this.errorMessage,
    this.currentIndex = 0,
    this.learnedCount = 0,
    this.notLearnedCount = 0,
  });

  @override
  List<Object?> get props => [flashcards, status, errorMessage, currentIndex, learnedCount, notLearnedCount];

  FlashcardState copyWith({
    List<Flashcard>? flashcards,
    FlashcardStatus? status,
    String? errorMessage,
    int? currentIndex,
    int? learnedCount,
    int? notLearnedCount,
  }) {
    return FlashcardState(
      flashcards: flashcards ?? this.flashcards,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      currentIndex: currentIndex ?? this.currentIndex,
      learnedCount: learnedCount ?? this.learnedCount,
      notLearnedCount: notLearnedCount ?? this.notLearnedCount,
    );
  }
}

// Define the Cubit
