// lib/features/vocabulary/cubit/vocabulary_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qlz_flash_cards_ui/features/vocabulary/cubit/vocabulary_state.dart';
import 'package:qlz_flash_cards_ui/features/vocabulary/data/flashcard.dart';

// Sample flashcards data (typically would come from a repository)
final List<Flashcard> sampleFlashcards = [
  const Flashcard(
    term: '과일',
    definition: 'Trái cây',
    example: '저는 과일을 많이 먹어요.',
    pronunciation: 'gwail',
    isDifficult: false,
  ),
  const Flashcard(
    term: '야채',
    definition: 'Rau củ',
    example: '야채를 먹으면 건강에 좋습니다.',
    pronunciation: 'yachae',
    isDifficult: false,
  ),
  const Flashcard(
    term: '고기',
    definition: 'Thịt',
    example: '저는 고기를 좋아해요.',
    pronunciation: 'gogi',
    isDifficult: true,
  ),
  const Flashcard(
    term: '음료',
    definition: 'Đồ uống',
    example: '음료를 마시고 싶어요.',
    pronunciation: 'eumryo',
    isDifficult: false,
  ),
  const Flashcard(
    term: '빵',
    definition: 'Bánh mì',
    example: '아침에 빵을 먹었어요.',
    pronunciation: 'ppang',
    isDifficult: false,
  ),
  const Flashcard(
    term: '생선',
    definition: 'Cá',
    example: '생선을 구워서 먹어요.',
    pronunciation: 'saengseon',
    isDifficult: true,
  ),
  const Flashcard(
    term: '밥',
    definition: 'Cơm',
    example: '저녁에 밥을 먹었어요.',
    pronunciation: 'bap',
    isDifficult: false,
  ),
  const Flashcard(
    term: '국',
    definition: 'Canh',
    example: '뜨거운 국을 조심하세요.',
    pronunciation: 'guk',
    isDifficult: false,
  ),
  const Flashcard(
    term: '치즈',
    definition: 'Phô mai',
    example: '치즈가 많이 들어간 피자를 좋아해요.',
    pronunciation: 'chijeu',
    isDifficult: false,
  ),
  const Flashcard(
    term: '달걀',
    definition: 'Trứng',
    example: '달걀을 삶아서 먹었어요.',
    pronunciation: 'dalgyal',
    isDifficult: false,
  ),
  const Flashcard(
    term: '우유',
    definition: 'Sữa',
    example: '우유를 매일 마셔요.',
    pronunciation: 'uyu',
    isDifficult: false,
  ),
  const Flashcard(
    term: '커피',
    definition: 'Cà phê',
    example: '아침마다 커피를 마셔요.',
    pronunciation: 'keopi',
    isDifficult: false,
  ),
  const Flashcard(
    term: '과자',
    definition: 'Bánh kẹo',
    example: '과자를 너무 많이 먹지 마세요.',
    pronunciation: 'gwaja',
    isDifficult: false,
  ),
  const Flashcard(
    term: '설탕',
    definition: 'Đường',
    example: '설탕을 넣으면 맛이 달아요.',
    pronunciation: 'seoltang',
    isDifficult: true,
  ),
  const Flashcard(
    term: '소금',
    definition: 'Muối',
    example: '소금을 조금 넣으세요.',
    pronunciation: 'sogeum',
    isDifficult: false,
  ),
  const Flashcard(
    term: '후추',
    definition: 'Tiêu',
    example: '후추를 뿌려서 먹어요.',
    pronunciation: 'huchu',
    isDifficult: true,
  ),
  const Flashcard(
    term: '면',
    definition: 'Mì',
    example: '면을 삶아서 국수로 만들어요.',
    pronunciation: 'myeon',
    isDifficult: false,
  ),
  const Flashcard(
    term: '김치',
    definition: 'Kimchi',
    example: '한국 사람들은 김치를 많이 먹어요.',
    pronunciation: 'gimchi',
    isDifficult: false,
  ),
  const Flashcard(
    term: '햄버거',
    definition: 'Hamburger',
    example: '햄버거를 먹으러 가자!',
    pronunciation: 'haembeogeo',
    isDifficult: false,
  ),
];

final class VocabularyCubit extends Cubit<VocabularyState> {
  // Trong thực tế, bạn sẽ inject repository vào đây
  // final VocabularyRepository repository;

  VocabularyCubit() : super(const VocabularyInitial());

  Future<void> loadFlashcards([String? moduleId]) async {
    try {
      emit(VocabularyLoading(
        flashcards: state.flashcards,
        currentPage: state.currentPage,
      ));

      // Trong thực tế, bạn sẽ lấy dữ liệu từ repository:
      // final flashcards = await repository.getFlashcards(moduleId);

      // Giả lập API call
      await Future.delayed(const Duration(seconds: 1));

      // Sử dụng dữ liệu mẫu cho demo
      final flashcards = moduleId == null ? sampleFlashcards : sampleFlashcards;

      emit(VocabularyLoaded(
        flashcards: flashcards,
        currentPage: state.currentPage,
      ));
    } catch (e) {
      emit(VocabularyError(
        flashcards: state.flashcards,
        currentPage: state.currentPage,
        error: e.toString(),
      ));
    }
  }

  void updateCurrentPage(int page) {
    emit(state.copyWith(currentPage: page));
  }

  Future<void> toggleFlashcardDifficulty(int index) async {
    if (index < 0 || index >= state.flashcards.length) return;

    try {
      final currentFlashcards = List<Flashcard>.from(state.flashcards);
      final flashcard = currentFlashcards[index];

      // Trong thực tế sẽ gọi API để cập nhật
      // await repository.updateFlashcardDifficulty(flashcard.id, !flashcard.isDifficult);

      // Giả lập API call
      await Future.delayed(const Duration(milliseconds: 300));

      currentFlashcards[index] = Flashcard(
        term: flashcard.term,
        definition: flashcard.definition,
        example: flashcard.example,
        pronunciation: flashcard.pronunciation,
        imageUrl: flashcard.imageUrl,
        audioUrl: flashcard.audioUrl,
        isDifficult: !flashcard.isDifficult,
      );

      emit(state.copyWith(flashcards: currentFlashcards));
    } catch (e) {
      emit(VocabularyError(
        flashcards: state.flashcards,
        currentPage: state.currentPage,
        error: e.toString(),
      ));
    }
  }

  Future<void> playAudio(int index) async {
    if (index < 0 || index >= state.flashcards.length) return;

    try {
      // Trong thực tế sẽ phát audio từ URL
      // if (flashcard.audioUrl != null) {
      //   await audioService.playAudio(flashcard.audioUrl!);
      // }

      // Giả lập phát audio
      await Future.delayed(const Duration(milliseconds: 300));

      // Không cần cập nhật state khi phát audio
    } catch (e) {
      // Xử lý lỗi, có thể không cần emit error state khi chỉ phát audio
      print('Error playing audio: $e');
    }
  }

  Future<void> markAsDifficult(int index) async {
    if (index < 0 || index >= state.flashcards.length) return;
    try {
      final currentFlashcards = List<Flashcard>.from(state.flashcards);
      final flashcard = currentFlashcards[index];

      // Chỉ đánh dấu nếu chưa được đánh dấu
      if (!flashcard.isDifficult) {
        // Trong thực tế sẽ gọi API
        // await repository.markFlashcardAsDifficult(flashcard.id);

        // Giả lập API call
        await Future.delayed(const Duration(milliseconds: 300));

        currentFlashcards[index] = Flashcard(
          term: flashcard.term,
          definition: flashcard.definition,
          example: flashcard.example,
          pronunciation: flashcard.pronunciation,
          imageUrl: flashcard.imageUrl,
          audioUrl: flashcard.audioUrl,
          isDifficult: true,
        );

        emit(state.copyWith(flashcards: currentFlashcards));
      }
    } catch (e) {
      emit(VocabularyError(
        flashcards: state.flashcards,
        currentPage: state.currentPage,
        error: e.toString(),
      ));
    }
  }

  // Các chức năng bổ sung tiềm năng

  Future<void> createFlashcard(Flashcard flashcard) async {
    try {
      final currentFlashcards = List<Flashcard>.from(state.flashcards);

      // Trong thực tế sẽ gọi API
      // final newFlashcard = await repository.createFlashcard(flashcard);

      // Giả lập API call
      await Future.delayed(const Duration(milliseconds: 500));

      currentFlashcards.add(flashcard);

      emit(state.copyWith(flashcards: currentFlashcards));
    } catch (e) {
      emit(VocabularyError(
        flashcards: state.flashcards,
        currentPage: state.currentPage,
        error: e.toString(),
      ));
    }
  }

  Future<void> updateFlashcard(int index, Flashcard flashcard) async {
    if (index < 0 || index >= state.flashcards.length) return;

    try {
      final currentFlashcards = List<Flashcard>.from(state.flashcards);

      // Trong thực tế sẽ gọi API
      // await repository.updateFlashcard(flashcard.id, flashcard);

      // Giả lập API call
      await Future.delayed(const Duration(milliseconds: 500));

      currentFlashcards[index] = flashcard;

      emit(state.copyWith(flashcards: currentFlashcards));
    } catch (e) {
      emit(VocabularyError(
        flashcards: state.flashcards,
        currentPage: state.currentPage,
        error: e.toString(),
      ));
    }
  }

  Future<void> deleteFlashcard(int index) async {
    if (index < 0 || index >= state.flashcards.length) return;

    try {
      final currentFlashcards = List<Flashcard>.from(state.flashcards);

      // Trong thực tế sẽ gọi API
      // await repository.deleteFlashcard(flashcard.id);

      // Giả lập API call
      await Future.delayed(const Duration(milliseconds: 500));

      currentFlashcards.removeAt(index);

      emit(state.copyWith(flashcards: currentFlashcards));
    } catch (e) {
      emit(VocabularyError(
        flashcards: state.flashcards,
        currentPage: state.currentPage,
        error: e.toString(),
      ));
    }
  }
}
