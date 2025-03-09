import '../models/flashcard_model.dart';

class FlashcardRepository {
  // This is a placeholder for your data source, e.g., a database or API client.
  final List<Flashcard> _flashcards = [];

  // Fetch all flashcards
  Future<List<Flashcard>> getFlashcards() async {
    // Simulate a network or database call
    await Future.delayed(const Duration(seconds: 1));
    return _flashcards;
  }

  // Add a new flashcard
  Future<void> addFlashcard(Flashcard flashcard) async {
    // Simulate a network or database call
    await Future.delayed(const Duration(seconds: 1));
    _flashcards.add(flashcard);
  }

  // Update an existing flashcard
  Future<void> updateFlashcard(Flashcard flashcard) async {
    // Simulate a network or database call
    await Future.delayed(const Duration(seconds: 1));
    int index = _flashcards.indexWhere((f) => f.id == flashcard.id);
    if (index != -1) {
      _flashcards[index] = flashcard;
    }
  }

  // Delete a flashcard
  Future<void> deleteFlashcard(String id) async {
    // Simulate a network or database call
    await Future.delayed(const Duration(seconds: 1));
    _flashcards.removeWhere((f) => f.id == id);
  }
}