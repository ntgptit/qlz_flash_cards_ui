import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/data/models/flashcard_model.dart';

import '../enums/study_enums.dart';
import '../screens/unified_study_screen.dart';
import '../strategies/multiple_choice_strategy.dart';
import '../strategies/study_strategy.dart';
import '../strategies/typing_test_strategy.dart';
import '../strategies/writing_strategy.dart';

class StudyModesProvider {
  static List<StudyModeInfo> getAllModes() {
    return [
      const StudyModeInfo(
        mode: StudyMode.multipleChoice,
        title: 'Multiple Choice',
        description: 'Choose the correct term from options',
        icon: Icons.check_circle_outline,
      ),
      const StudyModeInfo(
        mode: StudyMode.writing,
        title: 'Writing',
        description: 'Type your answer',
        icon: Icons.edit_note,
      ),
      const StudyModeInfo(
        mode: StudyMode.typingTest,
        title: 'Typing Test',
        description: 'Test your typing skills',
        icon: Icons.keyboard,
      ),
    ];
  }

  static void startStudyMode({
    required BuildContext context,
    required StudyMode mode,
    required List<Flashcard> flashcards,
    String? moduleId,
    String moduleName = '',
    StudyGoal? studyGoal,
    KnowledgeLevel? knowledgeLevel,
  }) {
    final strategy = _createStrategy(mode);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UnifiedStudyScreen(
          flashcards: flashcards,
          strategy: strategy,
        ),
      ),
    );
  }

  static StudyStrategy _createStrategy(StudyMode mode) {
    switch (mode) {
      case StudyMode.multipleChoice:
        return MultipleChoiceStrategy();
      case StudyMode.writing:
        return WritingStrategy();
      case StudyMode.typingTest:
        return TypingTestStrategy();
    }
  }

  static Widget buildStudyModeSelector({
    required BuildContext context,
    required Function(StudyMode) onModeSelected,
    StudyMode? selectedMode,
  }) {
    final modes = getAllModes();
    return Column(
      children: modes
          .map((modeInfo) => ListTile(
                title: Text(modeInfo.title),
                subtitle: Text(modeInfo.description),
                leading: Icon(modeInfo.icon),
                selected: selectedMode == modeInfo.mode,
                onTap: () => onModeSelected(modeInfo.mode),
              ))
          .toList(),
    );
  }
}

class StudyModeInfo {
  final StudyMode mode;
  final String title;
  final String description;
  final IconData icon;

  const StudyModeInfo({
    required this.mode,
    required this.title,
    required this.description,
    required this.icon,
  });
}
