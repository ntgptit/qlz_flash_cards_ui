// lib/features/library/logic/states/folders_state.dart
import 'package:equatable/equatable.dart';

import '../../data/models/folder_model.dart';

enum FoldersStatus { initial, loading, success, failure }

class FoldersState extends Equatable {
  final List<Folder> folders;
  final FoldersStatus status;
  final String? errorMessage;

  const FoldersState({
    this.folders = const [],
    this.status = FoldersStatus.initial,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [folders, status, errorMessage];

  FoldersState copyWith({
    List<Folder>? folders,
    FoldersStatus? status,
    String? errorMessage,
  }) {
    return FoldersState(
      folders: folders ?? this.folders,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
