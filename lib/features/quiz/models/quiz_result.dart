// lib/features/quiz/models/quiz_result.dart

import 'package:qlz_flash_cards_ui/features/quiz/models/quiz_settings.dart';

/// Model lưu trữ kết quả bài kiểm tra
class QuizResult {
  final String id;
  final String moduleId;
  final String moduleName;
  final QuizType quizType;
  final int correctAnswers;
  final int totalQuestions;
  final Duration completionTime;
  final DateTime completionDate;

  /// Tỷ lệ chính xác (tính theo phần trăm)
  double get successRate =>
      totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0.0;

  const QuizResult({
    required this.id,
    required this.moduleId,
    required this.moduleName,
    required this.quizType,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.completionTime,
    required this.completionDate,
  });

  /// Tạo đối tượng từ Map
  factory QuizResult.fromMap(Map<String, dynamic> map) {
    return QuizResult(
      id: map['id'] as String,
      moduleId: map['moduleId'] as String,
      moduleName: map['moduleName'] as String,
      quizType: map['quizType'] as QuizType,
      correctAnswers: map['correctAnswers'] as int,
      totalQuestions: map['totalQuestions'] as int,
      completionTime: Duration(seconds: map['completionTimeSec'] as int),
      completionDate: DateTime.parse(map['completionDate'] as String),
    );
  }

  /// Chuyển đối tượng thành Map để lưu trữ
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'moduleId': moduleId,
      'moduleName': moduleName,
      'quizType': quizType.index,
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'completionTimeSec': completionTime.inSeconds,
      'completionDate': completionDate.toIso8601String(),
      'successRate': successRate,
    };
  }

  /// Định dạng thời gian hoàn thành thành chuỗi mm:ss
  String get formattedTime {
    final minutes = completionTime.inMinutes;
    final seconds = completionTime.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Đánh giá kết quả dựa trên tỷ lệ chính xác
  String get evaluation {
    if (successRate >= 80) {
      return 'Rất tốt! Bạn đã thành thạo phần lớn các thuật ngữ.';
    } else if (successRate >= 60) {
      return 'Không tệ! Hãy tiếp tục luyện tập thêm.';
    } else {
      return 'Bạn cần luyện tập thêm với những thuật ngữ này.';
    }
  }
}
