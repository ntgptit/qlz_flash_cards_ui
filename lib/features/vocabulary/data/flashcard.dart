// lib/features/vocabulary/data/flashcard.dart

import 'package:equatable/equatable.dart';

/// Represents a flashcard vocabulary entry
final class Flashcard extends Equatable {
  /// Unique identifier for the flashcard
  final String? id;

  /// The term to be learned (front side of the card)
  final String term;

  /// The definition of the term (back side of the card)
  final String definition;

  /// Optional example sentence using the term
  final String? example;

  /// Optional phonetic pronunciation guide
  final String? pronunciation;

  /// Optional URL to an image illustrating the term
  final String? imageUrl;

  /// Optional URL to an audio file with pronunciation
  final String? audioUrl;

  /// Whether this flashcard is marked as difficult by the user
  final bool isDifficult;

  /// The number of times the user got this flashcard correct
  final int correctCount;

  /// The number of times the user got this flashcard wrong
  final int incorrectCount;

  /// The timestamp of when this flashcard was last reviewed
  final DateTime? lastReviewedAt;

  const Flashcard({
    this.id,
    required this.term,
    required this.definition,
    this.example,
    this.pronunciation,
    this.imageUrl,
    this.audioUrl,
    this.isDifficult = false,
    this.correctCount = 0,
    this.incorrectCount = 0,
    this.lastReviewedAt,
  });

  /// Create a copy of this flashcard with modified properties
  Flashcard copyWith({
    String? id,
    String? term,
    String? definition,
    String? example,
    String? pronunciation,
    String? imageUrl,
    String? audioUrl,
    bool? isDifficult,
    int? correctCount,
    int? incorrectCount,
    DateTime? lastReviewedAt,
  }) {
    return Flashcard(
      id: id ?? this.id,
      term: term ?? this.term,
      definition: definition ?? this.definition,
      example: example ?? this.example,
      pronunciation: pronunciation ?? this.pronunciation,
      imageUrl: imageUrl ?? this.imageUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      isDifficult: isDifficult ?? this.isDifficult,
      correctCount: correctCount ?? this.correctCount,
      incorrectCount: incorrectCount ?? this.incorrectCount,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
    );
  }

  /// Create flashcard from JSON map
  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'],
      term: json['term'],
      definition: json['definition'],
      example: json['example'],
      pronunciation: json['pronunciation'],
      imageUrl: json['imageUrl'],
      audioUrl: json['audioUrl'],
      isDifficult: json['isDifficult'] ?? false,
      correctCount: json['correctCount'] ?? 0,
      incorrectCount: json['incorrectCount'] ?? 0,
      lastReviewedAt: json['lastReviewedAt'] != null
          ? DateTime.parse(json['lastReviewedAt'])
          : null,
    );
  }

  /// Convert flashcard to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'term': term,
      'definition': definition,
      'example': example,
      'pronunciation': pronunciation,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'isDifficult': isDifficult,
      'correctCount': correctCount,
      'incorrectCount': incorrectCount,
      'lastReviewedAt': lastReviewedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        term,
        definition,
        example,
        pronunciation,
        imageUrl,
        audioUrl,
        isDifficult,
        correctCount,
        incorrectCount,
        lastReviewedAt,
      ];
}
