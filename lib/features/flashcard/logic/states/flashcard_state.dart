import 'package:equatable/equatable.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/data/models/flashcard_model.dart';

/// Possible statuses for flashcard operations
enum FlashcardStatus { initial, loading, success, failure }

/// State management class for flashcard operations
class FlashcardState extends Equatable {
  /// List of flashcards in the current study session
  final List<Flashcard> flashcards;

  /// Current status of flashcard operations
  final FlashcardStatus status;

  /// Error message if operation failed
  final String? errorMessage;

  /// Current index in the flashcards list being studied
  final int currentIndex;

  /// Number of flashcards marked as learned
  final int learnedCount;

  /// IDs of the flashcards marked as learned
  final List<String> learnedIds;

  /// Number of flashcards marked as not learned
  final int notLearnedCount;

  /// IDs of the flashcards marked as not learned
  final List<String> notLearnedIds;

  /// Is the current session completed
  final bool isSessionCompleted;

  /// Creates a FlashcardState instance
  const FlashcardState({
    this.flashcards = const [],
    this.status = FlashcardStatus.initial,
    this.errorMessage,
    this.currentIndex = 0,
    this.learnedCount = 0,
    this.learnedIds = const [],
    this.notLearnedCount = 0,
    this.notLearnedIds = const [],
    this.isSessionCompleted = false,
  });

  @override
  List<Object?> get props => [
        flashcards,
        status,
        errorMessage,
        currentIndex,
        learnedCount,
        learnedIds,
        notLearnedCount,
        notLearnedIds,
        isSessionCompleted,
      ];

  /// Creates a copy of this state with specified fields replaced
  FlashcardState copyWith({
    List<Flashcard>? flashcards,
    FlashcardStatus? status,
    String? errorMessage,
    int? currentIndex,
    int? learnedCount,
    List<String>? learnedIds,
    int? notLearnedCount,
    List<String>? notLearnedIds,
    bool? isSessionCompleted,
  }) {
    final newCurrentIndex = currentIndex ?? this.currentIndex;
    final newFlashcards = flashcards ?? this.flashcards;
    final autoCompleted =
        newCurrentIndex >= newFlashcards.length - 1; // Đổi thành >= length - 1
    return FlashcardState(
      flashcards: newFlashcards,
      status: status ?? this.status,
      errorMessage: errorMessage,
      currentIndex: newCurrentIndex,
      learnedCount: learnedCount ?? this.learnedCount,
      learnedIds: learnedIds ?? this.learnedIds,
      notLearnedCount: notLearnedCount ?? this.notLearnedCount,
      notLearnedIds: notLearnedIds ?? this.notLearnedIds,
      isSessionCompleted: isSessionCompleted ??
          (autoCompleted ? true : this.isSessionCompleted),
    );
  }

  /// Gets the current flashcard, or null if none available
  Flashcard? get currentFlashcard {
    if (flashcards.isEmpty || currentIndex >= flashcards.length) {
      return null;
    }
    return flashcards[currentIndex];
  }

  /// Gets the completion percentage of the study session
  double get completionPercentage {
    if (flashcards.isEmpty) return 0.0;
    return ((learnedCount + notLearnedCount) / flashcards.length) * 100;
  }

  /// Gets the total number of flashcards
  int get totalFlashcards => flashcards.length;

  /// Checks if there are more flashcards to study
  bool get hasMoreFlashcards => currentIndex < flashcards.length;

  /// Gets the progress as a fraction (0.0 - 1.0)
  double get progressFraction {
    if (flashcards.isEmpty) return 0.0;
    return (currentIndex / flashcards.length).clamp(0.0, 1.0);
  }
}
