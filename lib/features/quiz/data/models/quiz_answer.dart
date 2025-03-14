// lib/features/quiz/models/quiz_answer.dart

import 'package:equatable/equatable.dart';

/// Model cho đáp án của câu hỏi
class QuizAnswer extends Equatable {
  /// Định danh duy nhất của đáp án
  final String id;

  /// Nội dung đáp án
  final String text;

  /// Đáp án có đúng không
  final bool isCorrect;

  /// Dữ liệu bổ sung tùy chọn, có thể cần cho một số loại câu hỏi
  final Map<String, dynamic>? metadata;

  /// Constructor
  const QuizAnswer({
    required this.id,
    required this.text,
    required this.isCorrect,
    this.metadata,
  });

  /// Tạo bản sao với các giá trị được cập nhật
  QuizAnswer copyWith({
    String? id,
    String? text,
    bool? isCorrect,
    Map<String, dynamic>? metadata,
  }) {
    return QuizAnswer(
      id: id ?? this.id,
      text: text ?? this.text,
      isCorrect: isCorrect ?? this.isCorrect,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [id, text, isCorrect, metadata];
}
