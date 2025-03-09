// lib/features/module/data/models/study_module_model.dart
import 'package:equatable/equatable.dart';
import 'package:qlz_flash_cards_ui/features/vocabulary/data/flashcard.dart';

class StudyModule extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String creatorName;
  final bool hasPlusBadge;
  final int termCount;
  final List<Flashcard> flashcards;
  final DateTime createdAt;
  final DateTime? lastUpdatedAt;
  final String? language;
  final String? definitionLanguage;
  final bool isPublic;
  final bool isEditable;
  final bool autoSuggest;

  const StudyModule({
    required this.id,
    required this.title,
    this.description,
    required this.creatorName,
    this.hasPlusBadge = false,
    required this.termCount,
    required this.flashcards,
    required this.createdAt,
    this.lastUpdatedAt,
    this.language,
    this.definitionLanguage,
    this.isPublic = true,
    this.isEditable = false,
    this.autoSuggest = true,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        creatorName,
        hasPlusBadge,
        termCount,
        flashcards,
        createdAt,
        lastUpdatedAt,
        language,
        definitionLanguage,
        isPublic,
        isEditable,
        autoSuggest,
      ];

  StudyModule copyWith({
    String? id,
    String? title,
    String? description,
    String? creatorName,
    bool? hasPlusBadge,
    int? termCount,
    List<Flashcard>? flashcards,
    DateTime? createdAt,
    DateTime? lastUpdatedAt,
    String? language,
    String? definitionLanguage,
    bool? isPublic,
    bool? isEditable,
    bool? autoSuggest,
  }) {
    return StudyModule(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      creatorName: creatorName ?? this.creatorName,
      hasPlusBadge: hasPlusBadge ?? this.hasPlusBadge,
      termCount: termCount ?? this.termCount,
      flashcards: flashcards ?? this.flashcards,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      language: language ?? this.language,
      definitionLanguage: definitionLanguage ?? this.definitionLanguage,
      isPublic: isPublic ?? this.isPublic,
      isEditable: isEditable ?? this.isEditable,
      autoSuggest: autoSuggest ?? this.autoSuggest,
    );
  }

  factory StudyModule.fromJson(Map<String, dynamic> json) {
    return StudyModule(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      creatorName: json['creatorName'] as String,
      hasPlusBadge: json['hasPlusBadge'] as bool? ?? false,
      termCount: json['termCount'] as int,
      flashcards: (json['flashcards'] as List<dynamic>?)
              ?.map((e) => Flashcard.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUpdatedAt: json['lastUpdatedAt'] != null
          ? DateTime.parse(json['lastUpdatedAt'] as String)
          : null,
      language: json['language'] as String?,
      definitionLanguage: json['definitionLanguage'] as String?,
      isPublic: json['isPublic'] as bool? ?? true,
      isEditable: json['isEditable'] as bool? ?? false,
      autoSuggest: json['autoSuggest'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'creatorName': creatorName,
      'hasPlusBadge': hasPlusBadge,
      'termCount': termCount,
      'flashcards': flashcards.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'lastUpdatedAt': lastUpdatedAt?.toIso8601String(),
      'language': language,
      'definitionLanguage': definitionLanguage,
      'isPublic': isPublic,
      'isEditable': isEditable,
      'autoSuggest': autoSuggest,
    };
  }

  /// Create an empty module with default values
  factory StudyModule.empty() {
    return StudyModule(
      id: '',
      title: '',
      description: '',
      creatorName: 'giapnguyen1994',
      hasPlusBadge: false,
      termCount: 0,
      flashcards: const [],
      createdAt: DateTime.now(),
    );
  }
}