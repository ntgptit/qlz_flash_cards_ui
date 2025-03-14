// Loại quiz
enum QuizType {
  flashcards,
  multipleChoice,
  trueFalse,
  fillInBlank,
  matching,
}

// Độ khó quiz
enum QuizDifficulty {
  easy,
  medium,
  hard,
}

/// Model chứa cài đặt cho bài kiểm tra
class QuizSettings {
  /// Loại bài kiểm tra
  final QuizType quizType;

  /// Độ khó của bài kiểm tra
  final QuizDifficulty difficulty;

  /// Số lượng câu hỏi
  final int questionCount;

  /// Có trộn câu hỏi hay không
  final bool shuffleQuestions;

  /// Có hiển thị đáp án đúng hay không
  final bool showCorrectAnswers;

  /// Có bật bộ đếm thời gian hay không
  final bool enableTimer;

  /// Thời gian cho mỗi câu hỏi (tính bằng giây)
  final int timePerQuestion;

  /// Constructor với các giá trị mặc định
  const QuizSettings({
    this.quizType = QuizType.multipleChoice,
    this.difficulty = QuizDifficulty.medium,
    this.questionCount = 10,
    this.shuffleQuestions = true,
    this.showCorrectAnswers = true,
    this.enableTimer = false,
    this.timePerQuestion = 30,
  });

  /// Tạo bản sao với các giá trị được cập nhật
  QuizSettings copyWith({
    QuizType? quizType,
    QuizDifficulty? difficulty,
    int? questionCount,
    bool? shuffleQuestions,
    bool? showCorrectAnswers,
    bool? enableTimer,
    int? timePerQuestion,
  }) {
    return QuizSettings(
      quizType: quizType ?? this.quizType,
      difficulty: difficulty ?? this.difficulty,
      questionCount: questionCount ?? this.questionCount,
      shuffleQuestions: shuffleQuestions ?? this.shuffleQuestions,
      showCorrectAnswers: showCorrectAnswers ?? this.showCorrectAnswers,
      enableTimer: enableTimer ?? this.enableTimer,
      timePerQuestion: timePerQuestion ?? this.timePerQuestion,
    );
  }

  /// Tạo đối tượng QuizSettings từ Map
  factory QuizSettings.fromJson(Map<String, dynamic> json) {
    return QuizSettings(
      quizType: QuizType.values[json['quizType'] as int? ?? 1],
      difficulty: QuizDifficulty.values[json['difficulty'] as int? ?? 1],
      questionCount: json['questionCount'] as int? ?? 10,
      shuffleQuestions: json['shuffleQuestions'] as bool? ?? true,
      showCorrectAnswers: json['showCorrectAnswers'] as bool? ?? true,
      enableTimer: json['enableTimer'] as bool? ?? false,
      timePerQuestion: json['timePerQuestion'] as int? ?? 30,
    );
  }

  /// Chuyển đổi đối tượng thành Map
  Map<String, dynamic> toJson() {
    return {
      'quizType': quizType.index,
      'difficulty': difficulty.index,
      'questionCount': questionCount,
      'shuffleQuestions': shuffleQuestions,
      'showCorrectAnswers': showCorrectAnswers,
      'enableTimer': enableTimer,
      'timePerQuestion': timePerQuestion,
    };
  }
}
