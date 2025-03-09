import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/data/repositories/flashcard_repository.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/logic/states/flashcard_state.dart';

class FlashcardCubit extends Cubit<FlashcardState> {
  final FlashcardRepository _flashcardRepository;

  FlashcardCubit(this._flashcardRepository) : super(const FlashcardState());

  Future<void> fetchFlashcards() async {
    try {
      emit(state.copyWith(status: FlashcardStatus.loading));
      final flashcards = await _flashcardRepository.getFlashcards();
      emit(state.copyWith(status: FlashcardStatus.success, flashcards: flashcards));
    } catch (e) {
      emit(state.copyWith(status: FlashcardStatus.failure, errorMessage: e.toString()));
    }
  }

  void markAsLearned() {
    emit(state.copyWith(
      learnedCount: state.learnedCount + 1,
      currentIndex: state.currentIndex + 1,
    ));
  }

  void markAsNotLearned() {
    emit(state.copyWith(
      notLearnedCount: state.notLearnedCount + 1,
      currentIndex: state.currentIndex + 1,
    ));
  }

  void resetStudySession() {
    emit(state.copyWith(
      currentIndex: 0,
      learnedCount: 0,
      notLearnedCount: 0,
    ));
  }
}