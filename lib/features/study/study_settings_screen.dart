import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/features/study/data/study_enums.dart';
import 'package:qlz_flash_cards_ui/features/study/study_screen.dart';
import 'package:qlz_flash_cards_ui/features/vocabulary/data/flashcard.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/layout/qlz_screen.dart';

class StudySettingsScreen extends StatefulWidget {
  final List<Flashcard> flashcards;
  final String moduleName;
  final String? moduleId;

  const StudySettingsScreen({
    super.key,
    required this.flashcards,
    required this.moduleName,
    this.moduleId,
  });

  @override
  State<StudySettingsScreen> createState() => _StudySettingsScreenState();
}

class _StudySettingsScreenState extends State<StudySettingsScreen> {
  StudyGoal _selectedGoal = StudyGoal.quickStudy;
  KnowledgeLevel _selectedLevel = KnowledgeLevel.allNew;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return QlzScreen(
      padding: EdgeInsets.zero,
      // Disable withScrollView as we'll handle scrolling ourselves
      withScrollView: false,
      backgroundColor: const Color(0xFF0A092D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ),
      ),
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Use minimum vertical space
                children: [
                  // Tiêu đề Section
                  Text(
                    'Section ${widget.moduleId ?? '4'}: ${widget.moduleName}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14, // Giảm kích thước
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8), // Giảm khoảng cách

                  // Tiêu đề chính
                  const Text(
                    'Bạn muốn ôn luyện như thế nào?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26, // Giảm kích thước
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16), // Giảm khoảng cách
                  const Divider(height: 1, color: Color(0xFF2C2D4A)),
                  const SizedBox(height: 20), // Giảm khoảng cách

                  // Mục tiêu học tập
                  const Text(
                    'Mục tiêu của bạn cho học phần này là gì?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18, // Giảm kích thước
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14), // Giảm khoảng cách

                  _buildGoalOption(
                    StudyGoal.quickStudy,
                    'Nhanh chóng học tập',
                    Icons.bolt,
                  ),
                  const SizedBox(height: 10), // Giảm khoảng cách
                  _buildGoalOption(
                    StudyGoal.memorizeAll,
                    'Ghi nhớ tất cả',
                    Icons.description,
                  ),

                  const SizedBox(height: 30), // Giảm khoảng cách

                  // Mức độ kiến thức
                  const Text(
                    'Bạn nắm được tài liệu này ở mức nào?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18, // Giảm kích thước
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12), // Giảm khoảng cách

                  _buildKnowledgeOption(
                      KnowledgeLevel.allNew, 'Tất cả đều mới'),
                  _buildKnowledgeOption(
                      KnowledgeLevel.someFamiliar, 'Tôi biết một phần'),
                  _buildKnowledgeOption(
                      KnowledgeLevel.mostlyKnown, 'Tôi biết hầu hết'),

                  const SizedBox(height: 30), // Giảm khoảng cách

                  // Nút Bắt đầu chế độ học
                  ElevatedButton(
                    onPressed: _isLoading ? null : _startStudyMode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4255FF),
                      disabledBackgroundColor:
                          const Color(0xFF4255FF).withOpacity(0.5),
                      padding: const EdgeInsets.symmetric(
                          vertical: 14), // Giảm padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Center(
                      child: _isLoading
                          ? const SizedBox(
                              width: 20, // Giảm kích thước
                              height: 20, // Giảm kích thước
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ))
                          : const Text(
                              'Bắt đầu chế độ Học',
                              style: TextStyle(
                                fontSize: 16, // Giảm kích thước
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 12), // Giảm khoảng cách

                  // Nút Bỏ qua cá nhân hóa
                  OutlinedButton(
                    onPressed: _isLoading ? null : _skipPersonalization,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14), // Giảm padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: BorderSide(
                        color: _isLoading
                            ? Colors.white.withOpacity(0.5)
                            : Colors.white,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Bỏ qua cá nhân hóa',
                        style: TextStyle(
                          fontSize: 16, // Giảm kích thước
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20), // Giảm khoảng cách
                ],
              ),
            ),
          ),

          // Loading progress indicator
          if (_isLoading)
            Positioned(
              top: 10,
              right: 20,
              child: SizedBox(
                width: 32, // Giảm kích thước
                height: 32, // Giảm kích thước
                child: CircularProgressIndicator(
                  value: null,
                  strokeWidth: 3, // Giảm độ dày
                  color: Colors.blue[300],
                  backgroundColor: Colors.blue[700],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGoalOption(StudyGoal goal, String label, IconData icon) {
    final isSelected = _selectedGoal == goal;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedGoal = goal;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF12113A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14), // Giảm padding
        child: Row(
          children: [
            Container(
              width: 40, // Giảm kích thước
              height: 40, // Giảm kích thước
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF4255FF).withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: goal == StudyGoal.quickStudy
                    ? const Color(0xFF4255FF)
                    : const Color(0xFF5BE9FA),
                size: 24, // Giảm kích thước
              ),
            ),
            const SizedBox(width: 12), // Giảm khoảng cách
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16, // Giảm kích thước
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (isSelected)
              Container(
                width: 20, // Giảm kích thước
                height: 20, // Giảm kích thước
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF4255FF),
                ),
                child: const Center(
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 14, // Giảm kích thước
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildKnowledgeOption(KnowledgeLevel level, String label) {
    final isSelected = _selectedLevel == level;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedLevel = level;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8), // Giảm padding
        child: Row(
          children: [
            Container(
              width: 24, // Giảm kích thước
              height: 24, // Giảm kích thước
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF4255FF)
                      : Colors.white.withOpacity(0.7),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Container(
                      margin: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF4255FF),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12), // Giảm khoảng cách
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16, // Giảm kích thước
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startStudyMode() {
    setState(() {
      _isLoading = true;
    });

    // Simulate loading for a better UX
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StudyScreen(
            flashcards: widget.flashcards,
            moduleName: widget.moduleName,
            goal: _selectedGoal,
            knowledgeLevel: _selectedLevel,
          ),
        ),
      ).then((_) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    });
  }

  void _skipPersonalization() {
    setState(() {
      _isLoading = true;
    });

    // Simulate loading for a better UX
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StudyScreen(
            flashcards: widget.flashcards,
            moduleName: widget.moduleName,
            goal: StudyGoal.quickStudy,
            knowledgeLevel: KnowledgeLevel.allNew,
          ),
        ),
      ).then((_) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    });
  }
}
