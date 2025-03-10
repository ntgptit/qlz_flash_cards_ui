// lib/features/library/logic/states/study_sets_state.dart
import 'package:equatable/equatable.dart';

import '../../data/models/study_set_model.dart';

/// Trạng thái có thể của study sets
enum StudySetsStatus { initial, loading, success, failure }

/// Lớp state quản lý trạng thái của study sets
class StudySetsState extends Equatable {
  /// Danh sách các study sets
  final List<StudySet> studySets;

  /// Trạng thái hiện tại
  final StudySetsStatus status;

  /// Thông báo lỗi (nếu có)
  final String? errorMessage;

  /// Bộ lọc hiện tại (nếu có)
  final String? filter;

  /// ID thư mục hiện tại (nếu đang xem study sets của một thư mục)
  final String? folderId;

  const StudySetsState({
    this.studySets = const [],
    this.status = StudySetsStatus.initial,
    this.errorMessage,
    this.filter,
    this.folderId,
  });

  @override
  List<Object?> get props =>
      [studySets, status, errorMessage, filter, folderId];

  /// Tạo bản sao của state với các thuộc tính được thay đổi
  StudySetsState copyWith({
    List<StudySet>? studySets,
    StudySetsStatus? status,
    String? errorMessage,
    String? filter,
    String? folderId,
  }) {
    return StudySetsState(
      studySets: studySets ?? this.studySets,
      status: status ?? this.status,
      errorMessage: errorMessage,
      filter: filter ?? this.filter,
      folderId: folderId ?? this.folderId,
    );
  }
}
