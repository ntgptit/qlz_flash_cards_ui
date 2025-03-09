// // lib/features/vocabulary/cubit/vocabulary_state.dart

// import 'package:equatable/equatable.dart';
// import 'package:qlz_flash_cards_ui/features/vocabulary/data/flashcard.dart';

// sealed class VocabularyState extends Equatable {
//   final List<Flashcard> flashcards;
//   final int currentPage;
//   final bool isLoading;
//   final String? error;

//   const VocabularyState({
//     required this.flashcards,
//     required this.currentPage,
//     required this.isLoading,
//     this.error,
//   });

//   @override
//   List<Object?> get props => [flashcards, currentPage, isLoading, error];

//   VocabularyState copyWith({
//     List<Flashcard>? flashcards,
//     int? currentPage,
//     bool? isLoading,
//     String? error,
//   }) {
//     if (this is VocabularyLoading) {
//       return VocabularyLoading(
//         flashcards: flashcards ?? this.flashcards,
//         currentPage: currentPage ?? this.currentPage,
//       );
//     } else if (this is VocabularyLoaded) {
//       return VocabularyLoaded(
//         flashcards: flashcards ?? this.flashcards,
//         currentPage: currentPage ?? this.currentPage,
//       );
//     } else if (this is VocabularyError) {
//       return VocabularyError(
//         flashcards: flashcards ?? this.flashcards,
//         currentPage: currentPage ?? this.currentPage,
//         error: error ?? this.error ?? 'Unknown error',
//       );
//     }
//     return this;
//   }
// }

// final class VocabularyInitial extends VocabularyState {
//   const VocabularyInitial()
//       : super(
//           flashcards: const [],
//           currentPage: 0,
//           isLoading: false,
//         );
// }

// final class VocabularyLoading extends VocabularyState {
//   const VocabularyLoading({
//     required super.flashcards,
//     required super.currentPage,
//   }) : super(
//           isLoading: true,
//         );
// }

// final class VocabularyLoaded extends VocabularyState {
//   const VocabularyLoaded({
//     required super.flashcards,
//     required super.currentPage,
//   }) : super(
//           isLoading: false,
//         );
// }

// final class VocabularyError extends VocabularyState {
//   const VocabularyError({
//     required super.flashcards,
//     required super.currentPage,
//     required String error,
//   }) : super(
//           isLoading: false,
//           error: error,
//         );
// }
