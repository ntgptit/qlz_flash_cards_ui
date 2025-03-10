// lib/features/library/logic/states/folders_state.dart
import 'package:equatable/equatable.dart';

import '../../data/models/folder_model.dart';

/// Trạng thái có thể của folders
enum FoldersStatus { initial, loading, success, failure }

/// Lớp state quản lý trạng thái của folders
class FoldersState extends Equatable {
  /// Danh sách các thư mục
  final List<Folder> folders;

  /// Trạng thái hiện tại
  final FoldersStatus status;

  /// Thông báo lỗi (nếu có)
  final String? errorMessage;

  const FoldersState({
    this.folders = const [],
    this.status = FoldersStatus.initial,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [folders, status, errorMessage];

  /// Tạo bản sao của state với các thuộc tính được thay đổi
  FoldersState copyWith({
    List<Folder>? folders,
    FoldersStatus? status,
    String? errorMessage,
  }) {
    return FoldersState(
      folders: folders ?? this.folders,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }
}
