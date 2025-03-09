// lib/features/library/logic/cubit/study_sets_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/library_repository.dart';
import '../states/study_sets_state.dart';

class StudySetsCubit extends Cubit<StudySetsState> {
  final LibraryRepository _repository;

  StudySetsCubit(this._repository) : super(const StudySetsState());

  // Load study sets with optional filter
  Future<void> loadStudySets({String? filter, bool forceRefresh = false}) async {
    emit(state.copyWith(status: StudySetsStatus.loading));

    try {
      final studySets = await _repository.getStudySets(filter: filter, forceRefresh: forceRefresh);
      emit(state.copyWith(
        status: StudySetsStatus.success,
        studySets: studySets,
        filter: filter,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: StudySetsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  // Apply filter to study sets
  void applyFilter(String filter) {
    if (filter == state.filter) return;
    loadStudySets(filter: filter);
  }

  // Refresh study sets
  Future<void> refreshStudySets() async {
    await loadStudySets(filter: state.filter, forceRefresh: true);
  }
}