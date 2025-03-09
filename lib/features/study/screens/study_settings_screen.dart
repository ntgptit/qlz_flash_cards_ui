import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/data/models/flashcard_model.dart';
import '../enums/study_enums.dart';
import '../providers/study_modes_provider.dart';

/// A screen that allows users to configure their study settings
/// Follows SOLID principles with single responsibility for setting configuration
class StudySettingsScreen extends StatefulWidget {
  final String? moduleId;
  final String moduleName;
  final List<Flashcard> flashcards;
  final StudyMode? selectedMode;

  const StudySettingsScreen({
    super.key,
    this.moduleId,
    required this.moduleName,
    required this.flashcards,
    this.selectedMode,
  });

  @override
  State<StudySettingsScreen> createState() => _StudySettingsScreenState();
}

class _StudySettingsScreenState extends State<StudySettingsScreen> {
  StudyGoal _selectedGoal = StudyGoal.quickStudy;
  KnowledgeLevel _selectedKnowledgeLevel = KnowledgeLevel.allNew;
  late final StudyMode _selectedMode;

  // Theme constants for better maintainability
  static const _backgroundColor = Color(0xFF0A0A29);
  static const _accentColor = Color(0xFF3D4EF5);
  static const _itemBackgroundColor = Color(0xFF1D1D54);
  static const _standardBorderRadius = 16.0;

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.selectedMode ?? StudyMode.multipleChoice;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildBody() {
    // Using CustomScrollView for better scrolling performance
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildSectionTitle(),
              _buildMainQuestion(),
              _buildDivider(),
              _buildGoalSectionTitle(),
              const SizedBox(height: 24),
            ]),
          ),
        ),
        // Goal options as separate sliver items for better performance
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final goal = StudyGoal.values[index];

                return Column(
                  children: [
                    _buildGoalOption(
                      title: _getLocalizedGoalTitle(goal),
                      icon: _getGoalIcon(goal),
                      iconColor: _getGoalIconColor(goal),
                      goalType: goal,
                    ),
                    if (index < StudyGoal.values.length - 1)
                      const SizedBox(height: 16),
                    if (index == StudyGoal.values.length - 1)
                      const SizedBox(height: 32),
                  ],
                );
              },
              childCount: StudyGoal.values.length,
            ),
          ),
        ),
        // Knowledge level options
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildKnowledgeLevelTitle(),
              const SizedBox(height: 24),
            ]),
          ),
        ),

        // Knowledge level options list
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final level = KnowledgeLevel.values[index];

                return _buildKnowledgeLevelOption(
                  title: _getLocalizedKnowledgeLevelTitle(level),
                  level: level,
                );
              },
              childCount: KnowledgeLevel.values.length,
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 32),
            ]),
          ),
        ),
        // Action buttons
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildPrimaryButton(
                label: 'Bắt đầu chế độ Học',
                onPressed: _startStudySession,
              ),
              const SizedBox(height: 16),
              _buildSecondaryButton(
                label: 'Bỏ qua cá nhân hóa',
                onPressed: _skipPersonalization,
              ),
              const SizedBox(height: 32),
              _buildBottomIndicator(),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Text(
        'Section 4: 병원',
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }

  Widget _buildMainQuestion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'Bạn muốn ôn luyện như thế nào?',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              width: 60,
              height: 60,
              child: _buildLoadingSpinner(),
            ),
          ],
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildLoadingSpinner() {
    return Stack(
      children: [
        CircularProgressIndicator(
          value: 0.75,
          strokeWidth: 8,
          backgroundColor: Colors.blue.withOpacity(0.2),
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
        Center(
          child: Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Column(
      children: [
        Container(
          height: 1,
          color: Colors.white.withOpacity(0.2),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildGoalSectionTitle() {
    return const Text(
      'Mục tiêu của bạn cho học phần này là gì?',
      style: TextStyle(
          color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildGoalOption({
    required String title,
    required IconData icon,
    required Color iconColor,
    required StudyGoal goalType,
  }) {
    final isSelected = _selectedGoal == goalType;

    return InkWell(
      onTap: () => setState(() => _selectedGoal = goalType),
      borderRadius: BorderRadius.circular(_standardBorderRadius),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(_standardBorderRadius),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
              Container(
                decoration: BoxDecoration(
                  color: _itemBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKnowledgeLevelTitle() {
    return const Text(
      'Bạn nắm được tài liệu này ở mức nào?',
      style: TextStyle(
          color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildKnowledgeLevelOption({
    required String title,
    required KnowledgeLevel level,
  }) {
    return RadioListTile<KnowledgeLevel>(
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 15),
      ),
      value: level,
      groupValue: _selectedKnowledgeLevel,
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedKnowledgeLevel = value);
        }
      },
      contentPadding: EdgeInsets.zero,
      activeColor: Colors.white,
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: _accentColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_standardBorderRadius),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white30),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_standardBorderRadius),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildBottomIndicator() {
    return Center(
      child: Container(
        width: 80,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.5),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  // Business logic separated from UI following separation of concerns

  void _startStudySession() {
    _validateAndLaunchSession(includePreferences: true);
  }

  void _skipPersonalization() {
    _validateAndLaunchSession(includePreferences: false);
  }

  void _validateAndLaunchSession({required bool includePreferences}) {
    // Validation to handle empty flashcard list
    if (widget.flashcards.isEmpty) {
      _showEmptyFlashcardsWarning();
      return;
    }

    StudyModesProvider.startStudyMode(
      context: context,
      mode: _selectedMode,
      flashcards: widget.flashcards,
      moduleId: widget.moduleId,
      moduleName: widget.moduleName,
      studyGoal: includePreferences ? _selectedGoal : null,
      knowledgeLevel: includePreferences ? _selectedKnowledgeLevel : null,
    );
  }

  // Get localized title for study goal - directly using the viLabel property
  String _getLocalizedGoalTitle(StudyGoal goal) {
    return goal.viLabel;
  }

  // Get icon for study goal - directly use the enum property
  IconData _getGoalIcon(StudyGoal goal) {
    return goal.icon;
  }

  // Get color for study goal icon - directly use the enum property
  Color _getGoalIconColor(StudyGoal goal) {
    return goal.iconColor;
  }

  // Get localized title for knowledge level - directly using the viLabel property
  String _getLocalizedKnowledgeLevelTitle(KnowledgeLevel level) {
    return level.viLabel;
  }

  // Display warning dialog when flashcard list is empty
  void _showEmptyFlashcardsWarning() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Không có Flashcards'),
        content: const Text(
            'Không thể bắt đầu phiên học vì không có flashcards nào. Vui lòng thêm flashcards vào học phần này trước.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đã hiểu'),
          ),
        ],
      ),
    );
  }
}
