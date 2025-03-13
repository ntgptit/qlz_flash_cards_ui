// C:/Users/ntgpt/OneDrive/workspace/qlz_flash_cards_ui/lib/features/module/logic/cubit/create_module_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/data/models/flashcard_model.dart';
import 'package:qlz_flash_cards_ui/features/module/data/models/module_settings_model.dart';
import 'package:qlz_flash_cards_ui/features/module/data/models/study_module_model.dart';
import 'package:qlz_flash_cards_ui/features/module/data/repositories/module_repository.dart';
import 'package:qlz_flash_cards_ui/features/module/logic/states/create_module_state.dart';

class CreateModuleCubit extends Cubit<CreateModuleState> {
  final ModuleRepository _repository;
  bool _isClosed = false;

  CreateModuleCubit(this._repository)
      : super(CreateModuleState(
          flashcards: [
            Flashcard.empty(order: 0),
            Flashcard.empty(order: 1),
          ],
        ));

  @override
  Future<void> close() {
    _isClosed = true;
    return super.close();
  }

  void _safeEmit(CreateModuleState newState) {
    if (!_isClosed) {
      emit(newState);
    }
  }

  void updateTitle(String title) {
    _safeEmit(state.copyWith(
      title: title,
      titleError: title.trim().isEmpty ? 'Vui lòng nhập tiêu đề' : null,
    ));
  }

  void updateDescription(String description) {
    _safeEmit(state.copyWith(description: description));
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

    _safeEmit(state.copyWith(
      flashcards: newFlashcards,
      termErrors: newTermErrors,
    ));
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

    _safeEmit(state.copyWith(
      flashcards: newFlashcards,
      definitionErrors: newDefErrors,
    ));
  }

  void addFlashcard() {
    final newFlashcards = List<Flashcard>.from(state.flashcards);
    newFlashcards.add(Flashcard.empty(order: newFlashcards.length));
    _safeEmit(state.copyWith(flashcards: newFlashcards));
  }

  void removeFlashcard(int index) {
    if (index < 2) return; // Don't remove the first two required flashcards

    final newFlashcards = List<Flashcard>.from(state.flashcards);
    if (index < newFlashcards.length) {
      newFlashcards.removeAt(index);

      // Cập nhật lại order cho các flashcard sau khi xóa
      for (int i = index; i < newFlashcards.length; i++) {
        newFlashcards[i] = newFlashcards[i].copyWith(order: i);
      }
    }

    final newTermErrors = Map<int, String?>.from(state.termErrors);
    final newDefErrors = Map<int, String?>.from(state.definitionErrors);

    // Xóa lỗi của flashcard bị xóa
    newTermErrors.remove(index);
    newDefErrors.remove(index);

    // Cập nhật lại key cho các lỗi của flashcard sau index
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

    _safeEmit(state.copyWith(
      flashcards: newFlashcards,
      termErrors: newTermErrors,
      definitionErrors: newDefErrors,
    ));
  }

  bool validateForm() {
    final title = state.title.trim();
    Map<int, String?> newTermErrors = {};
    Map<int, String?> newDefErrors = {};
    bool isValid = true;

    if (title.isEmpty) {
      _safeEmit(state.copyWith(titleError: 'Vui lòng nhập tiêu đề'));
      isValid = false;
    } else {
      _safeEmit(state.copyWith(titleError: null));
    }

    // Kiểm tra 2 flashcard đầu tiên (bắt buộc)
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

    // Kiểm tra các flashcard không bắt buộc
    for (int i = 2; i < state.flashcards.length; i++) {
      final term = state.flashcards[i].term.trim();
      final definition = state.flashcards[i].definition.trim();

      // Nếu có term nhưng không có definition hoặc ngược lại
      if (term.isNotEmpty && definition.isEmpty) {
        newDefErrors[i] = 'Vui lòng nhập định nghĩa';
        isValid = false;
      } else if (term.isEmpty && definition.isNotEmpty) {
        newTermErrors[i] = 'Vui lòng nhập thuật ngữ';
        isValid = false;
      }
    }

    _safeEmit(state.copyWith(
      termErrors: newTermErrors,
      definitionErrors: newDefErrors,
    ));

    return isValid;
  }

  Future<bool> submitModule() async {
    if (!validateForm()) return false;

    _safeEmit(state.copyWith(status: CreateModuleStatus.submitting));

    try {
      // Chỉ lấy các flashcard hợp lệ (có cả term và definition)
      final validFlashcards = state.flashcards.where((card) {
        return card.term.trim().isNotEmpty && card.definition.trim().isNotEmpty;
      }).toList();

      // Tạo StudyModule từ state hiện tại
      final module = StudyModule(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // ID tạm thời
        title: state.title,
        description: state.description,
        creatorName: 'giapnguyen1994', // Lấy từ user profile trong thực tế
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

      _safeEmit(state.copyWith(
        status: CreateModuleStatus.success,
      ));

      return true;
    } on NetworkTimeoutException catch (e) {
      _safeEmit(state.copyWith(
        status: CreateModuleStatus.failure,
        errorMessage: 'Không thể kết nối đến máy chủ: ${e.message}',
      ));
      return false;
    } on PermissionException catch (e) {
      _safeEmit(state.copyWith(
        status: CreateModuleStatus.failure,
        errorMessage: e.message,
      ));
      return false;
    } on ModuleException catch (e) {
      _safeEmit(state.copyWith(
        status: CreateModuleStatus.failure,
        errorMessage: e.message,
      ));
      return false;
    } catch (e) {
      _safeEmit(state.copyWith(
        status: CreateModuleStatus.failure,
        errorMessage: 'Đã xảy ra lỗi: $e',
      ));
      return false;
    }
  }

  void updateSettings(ModuleSettings settings) {
    _safeEmit(state.copyWith(settings: settings));
  }
}
