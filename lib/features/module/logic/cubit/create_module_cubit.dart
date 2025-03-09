// lib/features/module/logic/cubit/create_module_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qlz_flash_cards_ui/features/vocabulary/data/flashcard.dart';

import '../../data/models/module_settings_model.dart';
import '../../data/models/study_module_model.dart';
import '../../data/repositories/module_repository.dart';
import '../states/create_module_state.dart';

class CreateModuleCubit extends Cubit<CreateModuleState> {
  final ModuleRepository _repository;

  CreateModuleCubit(this._repository) : super(CreateModuleState(
    // Initialize with 2 empty flashcards
    flashcards: [
      Flashcard.empty(order: 0),
      Flashcard.empty(order: 1),
    ],
  ));

  // Update title
  void updateTitle(String title) {
    emit(state.copyWith(
      title: title,
      titleError: title.trim().isEmpty ? 'Vui lòng nhập tiêu đề' : null,
    ));
  }

  // Update description
  void updateDescription(String description) {
    emit(state.copyWith(description: description));
  }

  // Update flashcard term
  void updateFlashcardTerm(int index, String term) {
    final newFlashcards = List<Flashcard>.from(state.flashcards);
    if (index < newFlashcards.length) {
      newFlashcards[index] = newFlashcards[index].copyWith(term: term);
    }

    // Update term errors
    final newTermErrors = Map<int, String?>.from(state.termErrors);
    // Clear error if term is not empty
    if (term.trim().isNotEmpty) {
      newTermErrors.remove(index);
    }

    emit(state.copyWith(
      flashcards: newFlashcards,
      termErrors: newTermErrors,
    ));
  }

  // Update flashcard definition
  void updateFlashcardDefinition(int index, String definition) {
    final newFlashcards = List<Flashcard>.from(state.flashcards);
    if (index < newFlashcards.length) {
      newFlashcards[index] = newFlashcards[index].copyWith(definition: definition);
    }

    // Update definition errors
    final newDefErrors = Map<int, String?>.from(state.definitionErrors);
    // Clear error if definition is not empty
    if (definition.trim().isNotEmpty) {
      newDefErrors.remove(index);
    }

    emit(state.copyWith(
      flashcards: newFlashcards,
      definitionErrors: newDefErrors,
    ));
  }

  // Add a new flashcard
  void addFlashcard() {
    final newFlashcards = List<Flashcard>.from(state.flashcards);
    newFlashcards.add(Flashcard.empty(order: newFlashcards.length));
    emit(state.copyWith(flashcards: newFlashcards));
  }

  // Remove flashcard
  void removeFlashcard(int index) {
    if (index < 2) return; // Don't remove the first two required flashcards
    
    final newFlashcards = List<Flashcard>.from(state.flashcards);
    if (index < newFlashcards.length) {
      newFlashcards.removeAt(index);
    }
    
    // Update errors maps
    final newTermErrors = Map<int, String?>.from(state.termErrors);
    final newDefErrors = Map<int, String?>.from(state.definitionErrors);
    newTermErrors.remove(index);
    newDefErrors.remove(index);
    
    emit(state.copyWith(
      flashcards: newFlashcards,
      termErrors: newTermErrors,
      definitionErrors: newDefErrors,
    ));
  }

  // Validate form
  bool validateForm() {
    final title = state.title.trim();
    Map<int, String?> newTermErrors = {};
    Map<int, String?> newDefErrors = {};
    bool isValid = true;
    
    if (title.isEmpty) {
      emit(state.copyWith(titleError: 'Vui lòng nhập tiêu đề'));
      isValid = false;
    } else {
      emit(state.copyWith(titleError: null));
    }
    
    // First two flashcards are required
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
    
    // Optional flashcards - if one field is filled, the other must be too
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
    
    emit(state.copyWith(
      termErrors: newTermErrors,
      definitionErrors: newDefErrors,
    ));
    
    return isValid;
  }

  // Submit form to create module
  Future<bool> submitModule() async {
    if (!validateForm()) return false;
    
    emit(state.copyWith(status: CreateModuleStatus.submitting));
    
    try {
      // Filter out empty flashcards
      final validFlashcards = state.flashcards.where((card) {
        return card.term.trim().isNotEmpty && card.definition.trim().isNotEmpty;
      }).toList();
      
      final module = StudyModule(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Temporary ID
        title: state.title,
        description: state.description,
        creatorName: 'giapnguyen1994', // Should come from user profile
        termCount: validFlashcards.length,
        flashcards: validFlashcards,
        createdAt: DateTime.now(),
        language: state.settings.termLanguage,
        definitionLanguage: state.settings.definitionLanguage,
        isPublic: state.settings.viewPermission == 'Mọi người',
        isEditable: state.settings.editPermission == 'Mọi người',
        autoSuggest: state.settings.autoSuggest,
      );
      
      final createdModule = await _repository.createStudyModule(module);
      
      emit(state.copyWith(
        status: CreateModuleStatus.success,
      ));
      
      return true;
    } catch (e) {
      emit(state.copyWith(
        status: CreateModuleStatus.failure,
        errorMessage: e.toString(),
      ));
      return false;
    }
  }

  // Update module settings
  void updateSettings(ModuleSettings settings) {
    emit(state.copyWith(settings: settings));
  }
}