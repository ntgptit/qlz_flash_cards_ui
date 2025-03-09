import 'package:flutter/material.dart';

enum StudyGoal {
  quickStudy,
  rememberAll;

  String get label => switch (this) {
        StudyGoal.quickStudy => 'Quick Study',
        StudyGoal.rememberAll => 'Remember All',
      };

  String get description => switch (this) {
        StudyGoal.quickStudy => 'Quickly learn the terms',
        StudyGoal.rememberAll => 'Memorize all terms long-term',
      };

  IconData get icon => switch (this) {
        StudyGoal.quickStudy => Icons.bolt,
        StudyGoal.rememberAll => Icons.checklist,
      };

  /// Vietnamese label for the UI
  String get viLabel => switch (this) {
        StudyGoal.quickStudy => 'Nhanh chóng học tập',
        StudyGoal.rememberAll => 'Ghi nhớ tất cả',
      };

  /// Vietnamese description for the UI
  String get viDescription => switch (this) {
        StudyGoal.quickStudy => 'Học nhanh các thuật ngữ',
        StudyGoal.rememberAll => 'Ghi nhớ tất cả các thuật ngữ lâu dài',
      };

  /// Get color for the icon
  Color get iconColor => switch (this) {
        StudyGoal.quickStudy => Colors.yellow,
        StudyGoal.rememberAll => Colors.lightBlue,
      };
}

enum KnowledgeLevel {
  allNew,
  partiallyKnown,
  mostlyKnown;

  String get label => switch (this) {
        KnowledgeLevel.allNew => 'All New',
        KnowledgeLevel.partiallyKnown => 'Partially Known',
        KnowledgeLevel.mostlyKnown => 'Mostly Known',
      };

  /// Vietnamese label for the UI
  String get viLabel => switch (this) {
        KnowledgeLevel.allNew => 'Tất cả đều mới',
        KnowledgeLevel.partiallyKnown => 'Tôi biết một phần',
        KnowledgeLevel.mostlyKnown => 'Tôi biết hầu hết',
      };
}

enum StudyMode {
  multipleChoice,
  writing,
  typingTest;

  String get label => switch (this) {
        StudyMode.multipleChoice => 'Multiple Choice',
        StudyMode.writing => 'Writing',
        StudyMode.typingTest => 'Typing Test',
      };

  String get description => switch (this) {
        StudyMode.multipleChoice => 'Choose the correct term from options',
        StudyMode.writing => 'Type your answer',
        StudyMode.typingTest => 'Test your typing skills',
      };

  IconData get icon => switch (this) {
        StudyMode.multipleChoice => Icons.check_circle_outline,
        StudyMode.writing => Icons.edit_note,
        StudyMode.typingTest => Icons.keyboard,
      };

  /// Vietnamese label for the UI
  String get viLabel => switch (this) {
        StudyMode.multipleChoice => 'Trắc nghiệm',
        StudyMode.writing => 'Viết',
        StudyMode.typingTest => 'Kiểm tra gõ',
      };

  /// Vietnamese description for the UI
  String get viDescription => switch (this) {
        StudyMode.multipleChoice => 'Chọn thuật ngữ đúng từ các tùy chọn',
        StudyMode.writing => 'Nhập câu trả lời của bạn',
        StudyMode.typingTest => 'Kiểm tra kỹ năng gõ của bạn',
      };
}
