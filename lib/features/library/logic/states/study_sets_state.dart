// lib/features/library/logic/states/study_sets_state.dart
import 'package:equatable/equatable.dart';

import '../../data/models/study_set_model.dart';

enum StudySetsStatus { initial, loading, success, failure }

class StudySetsState extends Equatable {
  final List<StudySet> studySets;
  final StudySetsStatus status;
  final String? errorMessage;
  final String? filter;

  const StudySetsState({
    this.studySets = const [],
    this.status = StudySetsStatus.initial,
    this.errorMessage,
    this.filter,
  });

  @override
  List<Object?> get props => [studySets, status, errorMessage, filter];

  StudySetsState copyWith({
    List<StudySet>? studySets,
    StudySetsStatus? status,
    String? errorMessage,
    String? filter,
  }) {
    return StudySetsState(
      studySets: studySets ?? this.studySets,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      filter: filter ?? this.filter,
    );
  }
}