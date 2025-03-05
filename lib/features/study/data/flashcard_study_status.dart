// C:/Users/ntgpt/OneDrive/workspace/qlz_flash_cards_ui/lib/features/study/data/flashcard_study_status.dart
import 'package:qlz_flash_cards_ui/features/vocabulary/data/flashcard.dart';

class FlashcardStudyStatus {
  final Flashcard flashcard; // Thẻ flashcard gốc
  bool isCorrectInMultipleChoice; // Đúng trong phần trắc nghiệm
  bool isCorrectInTyping; // Đúng trong phần gõ
  bool isDifficult; // Thẻ khó
  bool isCompleted; // Hoàn thành thẻ
  int errorCount; // Số lần sai
  bool needsReview; // Cần ôn lại
  DateTime? lastReviewTime; // Thời gian ôn lại cuối cùng

  FlashcardStudyStatus({
    required this.flashcard,
    this.isCorrectInMultipleChoice = false,
    this.isCorrectInTyping = false,
    this.isDifficult = false,
    this.isCompleted = false,
    this.errorCount = 0,
    this.needsReview = false,
    this.lastReviewTime,
  });

  FlashcardStudyStatus copyWith({
    Flashcard? flashcard,
    bool? isCorrectInMultipleChoice,
    bool? isCorrectInTyping,
    bool? isDifficult,
    bool? isCompleted,
    int? errorCount,
    bool? needsReview,
    DateTime? lastReviewTime,
  }) {
    return FlashcardStudyStatus(
      flashcard: flashcard ?? this.flashcard,
      isCorrectInMultipleChoice: isCorrectInMultipleChoice ?? this.isCorrectInMultipleChoice,
      isCorrectInTyping: isCorrectInTyping ?? this.isCorrectInTyping,
      isDifficult: isDifficult ?? this.isDifficult,
      isCompleted: isCompleted ?? this.isCompleted,
      errorCount: errorCount ?? this.errorCount,
      needsReview: needsReview ?? this.needsReview,
      lastReviewTime: lastReviewTime ?? this.lastReviewTime,
    );
  }

  FlashcardStudyStatus reset() {
    return FlashcardStudyStatus(flashcard: flashcard);
  }

  FlashcardStudyStatus markError() {
    return copyWith(
      errorCount: errorCount + 1,
      needsReview: true,
      isDifficult: true,
      lastReviewTime: DateTime.now(),
    );
  }

  bool get isFullyCompleted => isCorrectInMultipleChoice && isCorrectInTyping;
}