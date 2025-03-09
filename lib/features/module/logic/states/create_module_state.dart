// lib/features/module/logic/states/create_module_state.dart
import 'package:equatable/equatable.dart';
import 'package:qlz_flash_cards_ui/features/vocabulary/data/flashcard.dart';

import '../../data/models/module_settings_model.dart';

enum CreateModuleStatus { initial, submitting, success, failure }

class CreateModuleState extends Equatable {
  final String title;
  final String description;
  final List<Flashcard> flashcards;
  final Map<int, String?> termErrors;
  final Map<int, String?> definitionErrors;
  final String? titleError;
  final CreateModuleStatus status;
  final String? errorMessage;
  final ModuleSettings settings;

  const CreateModuleState({
    this.title = '',
    this.description = '',
    this.flashcards = const [],
    this.termErrors = const {},
    this.definitionErrors = const {},
    this.titleError,
    this.status = CreateModuleStatus.initial,
    this.errorMessage,
    this.settings = const ModuleSettings(),
  });

  @override
  List<Object?> get props => [
        title,
        description,
        flashcards,
        termErrors,
        definitionErrors,
        titleError,
        status,
        errorMessage,
        settings,
      ];

  CreateModuleState copyWith({
    String? title,
    String? description,
    List<Flashcard>? flashcards,
    Map<int, String?>? termErrors,
    Map<int, String?>? definitionErrors,
    String? titleError,
    CreateModuleStatus? status,
    String? errorMessage,
    ModuleSettings? settings,
  }) {
    return CreateModuleState(
      title: title ?? this.title,
      description: description ?? this.description,
      flashcards: flashcards ?? this.flashcards,
      termErrors: termErrors ?? this.termErrors,
      definitionErrors: definitionErrors ?? this.definitionErrors,
      titleError: titleError,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      settings: settings ?? this.settings,
    );
  }

  // Check if form is valid
  bool get isValid {
    if (title.trim().isEmpty || titleError != null) return false;
    
    // At least 2 flashcards are required with term and definition
    if (flashcards.length < 2) return false;
    
    for (int i = 0; i < 2; i++) {
      if (i >= flashcards.length) return false;
      if (flashcards[i].term.trim().isEmpty || flashcards[i].definition.trim().isEmpty) {
        return false;
      }
    }
    
    // Check if there are any errors in the form
    if (termErrors.isNotEmpty || definitionErrors.isNotEmpty) return false;
    
    return true;
  }
}