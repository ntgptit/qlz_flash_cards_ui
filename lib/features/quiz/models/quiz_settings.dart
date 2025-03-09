// lib/features/quiz/models/quiz_settings.dart

import 'package:flutter/material.dart';

/// Các loại bài kiểm tra có sẵn
enum QuizType {
  multipleChoice('Trắc nghiệm', Icons.check_circle_outline,
      'Chọn đáp án đúng từ các lựa chọn'),
  trueFalse('Đúng / Sai', Icons.thumbs_up_down_outlined,
      'Xác định xem phát biểu đúng hay sai'),
  written(
      'Tự luận', Icons.edit_note, 'Viết câu trả lời đầy đủ cho các câu hỏi'),
  matching('Nối cặp', Icons.compare_arrows,
      'Nối các thuật ngữ với định nghĩa tương ứng');

  final String label;
  final IconData icon;
  final String description;

  const QuizType(this.label, this.icon, this.description);
}

/// Các tuỳ chọn độ khó
enum QuizDifficulty {
  easy('Dễ', 'Tập trung vào các thuật ngữ bạn đã thành thạo'),
  medium('Trung bình', 'Cân bằng giữa các thuật ngữ dễ và khó'),
  hard('Khó', 'Tập trung vào các thuật ngữ khó');

  final String label;
  final String description;

  const QuizDifficulty(this.label, this.description);
}

/// Model lưu trữ các cài đặt bài kiểm tra
class QuizSettings {
  final String moduleId;
  final String moduleName;
  final QuizType quizType;
  final int questionCount;
  final QuizDifficulty difficulty;
  final bool shuffleQuestions;
  final bool showCorrectAnswers;

  const QuizSettings({
    required this.moduleId,
    required this.moduleName,
    required this.quizType,
    required this.questionCount,
    required this.difficulty,
    required this.shuffleQuestions,
    required this.showCorrectAnswers,
  });

  /// Tạo bản sao có thể chỉnh sửa của đối tượng cài đặt
  QuizSettings copyWith({
    String? moduleId,
    String? moduleName,
    QuizType? quizType,
    int? questionCount,
    QuizDifficulty? difficulty,
    bool? shuffleQuestions,
    bool? showCorrectAnswers,
  }) {
    return QuizSettings(
      moduleId: moduleId ?? this.moduleId,
      moduleName: moduleName ?? this.moduleName,
      quizType: quizType ?? this.quizType,
      questionCount: questionCount ?? this.questionCount,
      difficulty: difficulty ?? this.difficulty,
      shuffleQuestions: shuffleQuestions ?? this.shuffleQuestions,
      showCorrectAnswers: showCorrectAnswers ?? this.showCorrectAnswers,
    );
  }

  /// Chuyển đối tượng thành Map để truyền dữ liệu giữa các màn hình
  Map<String, dynamic> toMap() {
    return {
      'moduleId': moduleId,
      'moduleName': moduleName,
      'quizType': quizType.index, // Lưu index của enum
      'questionCount': questionCount,
      'difficulty': difficulty.index, // Lưu index của enum
      'shuffleQuestions': shuffleQuestions,
      'showCorrectAnswers': showCorrectAnswers,
    };
  }

  /// Tạo đối tượng từ Map
  factory QuizSettings.fromMap(Map<String, dynamic> map) {
    QuizType quizType;
    QuizDifficulty difficulty;

    // Xử lý chuyển đổi quizType
    var quizTypeData = map['quizType'];
    if (quizTypeData is QuizType) {
      quizType = quizTypeData;
    } else if (quizTypeData is int) {
      quizType = QuizType.values[quizTypeData];
    } else {
      quizType = QuizType.written; // Giá trị mặc định
    }

    // Xử lý chuyển đổi difficulty
    var difficultyData = map['difficulty'];
    if (difficultyData is QuizDifficulty) {
      difficulty = difficultyData;
    } else if (difficultyData is int) {
      difficulty = QuizDifficulty.values[difficultyData];
    } else {
      difficulty = QuizDifficulty.medium; // Giá trị mặc định
    }

    return QuizSettings(
      moduleId: map['moduleId'] as String,
      moduleName: map['moduleName'] as String,
      quizType: quizType,
      questionCount: map['questionCount'] as int,
      difficulty: difficulty,
      shuffleQuestions: map['shuffleQuestions'] as bool,
      showCorrectAnswers: map['showCorrectAnswers'] as bool,
    );
  }

  /// Cài đặt mặc định
  factory QuizSettings.defaultSettings(String moduleId, String moduleName) {
    return QuizSettings(
      moduleId: moduleId,
      moduleName: moduleName,
      quizType: QuizType.multipleChoice,
      questionCount: 10,
      difficulty: QuizDifficulty.medium,
      shuffleQuestions: true,
      showCorrectAnswers: true,
    );
  }
}
