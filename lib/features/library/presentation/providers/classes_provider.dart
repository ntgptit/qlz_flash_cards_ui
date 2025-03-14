import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qlz_flash_cards_ui/core/providers/app_providers.dart';
import 'package:qlz_flash_cards_ui/features/library/data/models/class_model.dart';
import 'package:qlz_flash_cards_ui/features/library/data/repositories/library_repository.dart';

enum ClassesStatus { initial, loading, creating, success, failure }

/// State class for classes
class ClassesState {
  final List<ClassModel> classes;
  final ClassesStatus status;
  final String? errorMessage;
  final String? validationError;

  const ClassesState({
    this.classes = const [],
    this.status = ClassesStatus.initial,
    this.errorMessage,
    this.validationError,
  });

  ClassesState copyWith({
    List<ClassModel>? classes,
    ClassesStatus? status,
    String? errorMessage,
    String? validationError,
  }) {
    return ClassesState(
      classes: classes ?? this.classes,
      status: status ?? this.status,
      errorMessage: errorMessage,
      validationError: validationError,
    );
  }

  bool get isCreating => status == ClassesStatus.creating;
}

/// StateNotifier that manages classes state
class ClassesNotifier extends StateNotifier<ClassesState> {
  final LibraryRepository _repository;

  ClassesNotifier(this._repository) : super(const ClassesState());

  /// Loads all classes
  Future<void> loadClasses({bool forceRefresh = false}) async {
    state = state.copyWith(status: ClassesStatus.loading);

    try {
      final classes = await _repository.getClasses(forceRefresh: forceRefresh);

      state = state.copyWith(
        status: ClassesStatus.success,
        classes: classes,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: ClassesStatus.failure,
        errorMessage: e.toString(),
      );
    }
  }

  /// Refreshes the classes list
  Future<void> refreshClasses() async {
    await loadClasses(forceRefresh: true);
  }

  /// Creates a new class
  Future<bool> createClass({
    required String name,
    required String description,
    required bool allowMembersToAdd,
  }) async {
    if (name.trim().isEmpty) {
      state = state.copyWith(
        validationError: 'Vui lòng nhập tên lớp học',
      );
      return false;
    }

    state = state.copyWith(
      status: ClassesStatus.creating,
      validationError: null,
    );

    try {
      final newClass = await _repository.createClass(
        name: name,
        description: description,
        allowMembersToAdd: allowMembersToAdd,
      );

      final updatedClasses = List<ClassModel>.from(state.classes)
        ..add(newClass);

      state = state.copyWith(
        status: ClassesStatus.success,
        classes: updatedClasses,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        status: ClassesStatus.failure,
        errorMessage: e.toString(),
      );

      return false;
    }
  }

  /// Clears any error messages in the state
  void clearError() {
    state = state.copyWith(
      errorMessage: null,
      validationError: null,
    );
  }
}

/// Provider for classes
final classesProvider =
    StateNotifierProvider.autoDispose<ClassesNotifier, ClassesState>((ref) {
  final repository = ref.watch(libraryRepositoryProvider);
  final notifier = ClassesNotifier(repository);

  // Initialize by loading classes
  notifier.loadClasses();

  return notifier;
});
