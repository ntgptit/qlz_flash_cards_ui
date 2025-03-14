// lib/features/module/presentation/providers/create_module_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qlz_flash_cards_ui/core/providers/app_providers.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/data/models/flashcard_model.dart';
import 'package:qlz_flash_cards_ui/features/module/data/models/module_settings_model.dart';
import 'package:qlz_flash_cards_ui/features/module/data/models/study_module_model.dart';
import 'package:qlz_flash_cards_ui/features/module/data/repositories/module_repository.dart';

// State definition for creating module
enum CreateModuleStatus { initial, submitting, success, failure }

class CreateModuleState {
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

  bool get isValid {
    if (title.trim().isEmpty || titleError != null) return false;
    if (flashcards.length < 2) return false;
    for (int i = 0; i < 2; i++) {
      if (i >= flashcards.length) return false;
      if (flashcards[i].term.trim().isEmpty ||
          flashcards[i].definition.trim().isEmpty) {
        return false;
      }
    }
    if (termErrors.isNotEmpty || definitionErrors.isNotEmpty) return false;
    return true;
  }
}

// StateNotifier for module creation
class CreateModuleNotifier extends StateNotifier<CreateModuleState> {
  final ModuleRepository _repository;

  CreateModuleNotifier(this._repository)
      : super(CreateModuleState(
          flashcards: [
            Flashcard.empty(order: 0),
            Flashcard.empty(order: 1),
          ],
        ));

  void updateTitle(String title) {
    state = state.copyWith(
      title: title,
      titleError: title.trim().isEmpty ? 'Vui lòng nhập tiêu đề' : null,
    );
  }

  void updateDescription(String description) {
    state = state.copyWith(description: description);
  }

  void updateFlashcardTerm(int index, String term) {
    final newFlashcards = List<Flashcard>.from(state.flashcards);
    if (index < newFlashcards.length) {
      newFlashcards[index] = newFlashcards[index].copyWith(term: term);
    }

    final newTermErrors = Map<int, String?>.from(state.termErrors);
    if (term.trim().isNotEmpty) {
      newTermErrors.remove(index);
    }

    state = state.copyWith(
      flashcards: newFlashcards,
      termErrors: newTermErrors,
    );
  }

  void updateFlashcardDefinition(int index, String definition) {
    final newFlashcards = List<Flashcard>.from(state.flashcards);
    if (index < newFlashcards.length) {
      newFlashcards[index] =
          newFlashcards[index].copyWith(definition: definition);
    }

    final newDefErrors = Map<int, String?>.from(state.definitionErrors);
    if (definition.trim().isNotEmpty) {
      newDefErrors.remove(index);
    }

    state = state.copyWith(
      flashcards: newFlashcards,
      definitionErrors: newDefErrors,
    );
  }

  void addFlashcard() {
    final newFlashcards = List<Flashcard>.from(state.flashcards);
    newFlashcards.add(Flashcard.empty(order: newFlashcards.length));
    state = state.copyWith(flashcards: newFlashcards);
  }

  void removeFlashcard(int index) {
    if (index < 2) return; // Don't remove the first two required flashcards

    final newFlashcards = List<Flashcard>.from(state.flashcards);
    if (index < newFlashcards.length) {
      newFlashcards.removeAt(index);

      // Update order values for remaining flashcards
      for (int i = index; i < newFlashcards.length; i++) {
        newFlashcards[i] = newFlashcards[i].copyWith(order: i);
      }
    }

    // Clean up error maps
    final newTermErrors = Map<int, String?>.from(state.termErrors);
    final newDefErrors = Map<int, String?>.from(state.definitionErrors);

    newTermErrors.remove(index);
    newDefErrors.remove(index);

    // Adjust error indices for remaining errors
    for (int i = index + 1; i < state.flashcards.length; i++) {
      if (newTermErrors.containsKey(i)) {
        final error = newTermErrors.remove(i);
        if (error != null) {
          newTermErrors[i - 1] = error;
        }
      }

      if (newDefErrors.containsKey(i)) {
        final error = newDefErrors.remove(i);
        if (error != null) {
          newDefErrors[i - 1] = error;
        }
      }
    }

    state = state.copyWith(
      flashcards: newFlashcards,
      termErrors: newTermErrors,
      definitionErrors: newDefErrors,
    );
  }

  bool validateForm() {
    final title = state.title.trim();
    Map<int, String?> newTermErrors = {};
    Map<int, String?> newDefErrors = {};
    bool isValid = true;

    // Validate title
    if (title.isEmpty) {
      state = state.copyWith(titleError: 'Vui lòng nhập tiêu đề');
      isValid = false;
    } else {
      state = state.copyWith(titleError: null);
    }

    // Validate required first two flashcards
    for (int i = 0; i < 2; i++) {
      if (i < state.flashcards.length) {
        if (state.flashcards[i].term.trim().isEmpty) {
          newTermErrors[i] = 'Vui lòng nhập thuật ngữ';
          isValid = false;
        }
        if (state.flashcards[i].definition.trim().isEmpty) {
          newDefErrors[i] = 'Vui lòng nhập định nghĩa';
          isValid = false;
        }
      }
    }

    // Validate optional additional flashcards - if term is filled, definition must be filled too and vice versa
    for (int i = 2; i < state.flashcards.length; i++) {
      final term = state.flashcards[i].term.trim();
      final definition = state.flashcards[i].definition.trim();

      if (term.isNotEmpty && definition.isEmpty) {
        newDefErrors[i] = 'Vui lòng nhập định nghĩa';
        isValid = false;
      } else if (term.isEmpty && definition.isNotEmpty) {
        newTermErrors[i] = 'Vui lòng nhập thuật ngữ';
        isValid = false;
      }
    }

    state = state.copyWith(
      termErrors: newTermErrors,
      definitionErrors: newDefErrors,
    );

    return isValid;
  }

  Future<bool> submitModule() async {
    if (!validateForm()) return false;

    state = state.copyWith(status: CreateModuleStatus.submitting);

    try {
      final validFlashcards = state.flashcards.where((card) {
        return card.term.trim().isNotEmpty && card.definition.trim().isNotEmpty;
      }).toList();

      final module = StudyModule(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Temporary ID
        title: state.title,
        description: state.description,
        creatorName: 'giapnguyen1994', // Should be taken from user profile
        termCount: validFlashcards.length,
        flashcards: validFlashcards,
        createdAt: DateTime.now(),
        language: state.settings.termLanguage,
        definitionLanguage: state.settings.definitionLanguage,
        isPublic: state.settings.viewPermission == 'Mọi người',
        isEditable: state.settings.editPermission == 'Mọi người',
        autoSuggest: state.settings.autoSuggest,
      );

      await _repository.createStudyModule(module);

      state = state.copyWith(status: CreateModuleStatus.success);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: CreateModuleStatus.failure,
        errorMessage: 'Đã xảy ra lỗi: $e',
      );
      return false;
    }
  }

  void updateSettings(ModuleSettings settings) {
    state = state.copyWith(settings: settings);
  }
}

// Provider for the CreateModuleNotifier
final createModuleProvider =
    StateNotifierProvider<CreateModuleNotifier, CreateModuleState>(
  (ref) {
    final repository = ref.watch(moduleRepositoryProvider);
    return CreateModuleNotifier(repository);
  },
);
