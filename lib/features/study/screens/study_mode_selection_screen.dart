import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/data/models/flashcard_model.dart';
import 'package:qlz_flash_cards_ui/features/study/screens/study_settings_screen.dart';

import '../enums/study_enums.dart';
import '../providers/study_modes_provider.dart';

class StudyModeSelectionScreen extends StatefulWidget {
  final List<Flashcard> flashcards;
  final String? moduleId;
  final String moduleName;

  const StudyModeSelectionScreen({
    super.key,
    required this.flashcards,
    this.moduleId,
    this.moduleName = '',
  });

  @override
  State<StudyModeSelectionScreen> createState() =>
      _StudyModeSelectionScreenState();
}

class _StudyModeSelectionScreenState extends State<StudyModeSelectionScreen> {
  StudyMode? _selectedMode;

  @override
  void initState() {
    super.initState();
    _selectedMode = StudyMode.multipleChoice;
  }

  void _selectMode(StudyMode mode) {
    setState(() => _selectedMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.moduleName.isNotEmpty
            ? 'Study ${widget.moduleName}'
            : 'Select Study Mode'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
                'Choose how you want to study ${widget.flashcards.length} terms'),
          ),
          Expanded(
            child: StudyModesProvider.buildStudyModeSelector(
              context: context,
              onModeSelected: _selectMode,
              selectedMode: _selectedMode,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudySettingsScreen(
                        moduleId: widget.moduleId,
                        moduleName: widget.moduleName,
                        flashcards: widget.flashcards,
                        selectedMode: _selectedMode,
                      ),
                    ),
                  ),
                  child: const Text('Continue'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => StudyModesProvider.startStudyMode(
                    context: context,
                    mode: _selectedMode!,
                    flashcards: widget.flashcards,
                    moduleId: widget.moduleId,
                    moduleName: widget.moduleName,
                  ),
                  child: const Text('Start Now'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
