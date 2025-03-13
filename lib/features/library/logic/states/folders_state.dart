// lib/features/library/logic/states/folders_state.dart
import 'package:equatable/equatable.dart';

import '../../data/models/folder_model.dart';

/// Trạng thái có thể của folders
enum FoldersStatus { initial, loading, creating, success, failure }

/// Lớp state quản lý trạng thái của folders
class FoldersState extends Equatable {
  /// Danh sách các thư mục
  final List<Folder> folders;

  /// Trạng thái hiện tại
  final FoldersStatus status;

  /// Thông báo lỗi (nếu có)
  final String? errorMessage;

  /// Lỗi validation khi tạo thư mục (nếu có)
  final String? validationError;

  const FoldersState({
    this.folders = const [],
    this.status = FoldersStatus.initial,
    this.errorMessage,
    this.validationError,
  });

  @override
  List<Object?> get props => [folders, status, errorMessage, validationError];

  /// Tạo bản sao của state với các thuộc tính được thay đổi
  FoldersState copyWith({
    List<Folder>? folders,
    FoldersStatus? status,
    String? errorMessage,
    String? validationError,
  }) {
    return FoldersState(
      folders: folders ?? this.folders,
      status: status ?? this.status,
      errorMessage: errorMessage,
      validationError: validationError,
    );
  }

  /// Kiểm tra trạng thái đang tạo thư mục
  bool get isCreating => status == FoldersStatus.creating;
}
