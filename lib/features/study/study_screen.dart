import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/features/study/data/study_enums.dart';
import 'package:qlz_flash_cards_ui/features/vocabulary/data/flashcard.dart';
import 'package:qlz_flash_cards_ui/features/vocabulary/screens/vocabulary_screen.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_empty_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/layout/qlz_screen.dart';

class StudyScreen extends StatefulWidget {
  final List<Flashcard> flashcards;
  final String moduleName;
  final StudyGoal goal;
  final KnowledgeLevel knowledgeLevel;

  const StudyScreen({
    super.key,
    required this.flashcards,
    required this.moduleName,
    required this.goal,
    required this.knowledgeLevel,
  });

  factory StudyScreen.fromArguments(Map<String, dynamic> arguments) {
    final flashcards =
        (arguments['flashcards'] as List?)?.cast<Flashcard>() ?? [];
    final moduleName = arguments['moduleName'] as String? ?? 'Học phần';
    final goal = arguments['goal'] != null
        ? StudyGoal.values.byName(arguments['goal'])
        : StudyGoal.quickStudy;
    final knowledgeLevel = arguments['knowledgeLevel'] != null
        ? KnowledgeLevel.values.byName(arguments['knowledgeLevel'])
        : KnowledgeLevel.allNew;

    return StudyScreen(
      flashcards: flashcards,
      moduleName: moduleName,
      goal: goal,
      knowledgeLevel: knowledgeLevel,
    );
  }

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  int _currentIndex = 0;
  int _correctAnswers = 0;
  int _totalAnswered = 0;
  double _progress = 0.0;
  String? _selectedAnswer;
  bool _isAnswerSubmitted = false;
  bool _isAnswerCorrect = false;
  List<String> _options = [];
  Timer? _autoNextTimer;

  @override
  void initState() {
    super.initState();
    if (widget.flashcards.isNotEmpty) {
      _setupQuestion();
    }
  }

  @override
  void dispose() {
    _autoNextTimer?.cancel();
    super.dispose();
  }

  void _setupQuestion() {
    _selectedAnswer = null;
    _isAnswerSubmitted = false;
    _isAnswerCorrect = false;

    final correctAnswer = widget.flashcards[_currentIndex].term;
    _options = [correctAnswer];

    final otherFlashcards =
        widget.flashcards.where((f) => f.term != correctAnswer).toList();
    otherFlashcards.shuffle();
    _options.addAll(otherFlashcards.take(3).map((f) => f.term));
    _options.shuffle();

    _progress = (_currentIndex / widget.flashcards.length);
  }

  void _checkAnswer(String answer) {
    if (_isAnswerSubmitted) return;

    final isCorrect = answer == widget.flashcards[_currentIndex].term;

    setState(() {
      _selectedAnswer = answer;
      _isAnswerSubmitted = true;
      _isAnswerCorrect = isCorrect;

      if (isCorrect) {
        _correctAnswers++;
        // Tự động chuyển sang từ vựng tiếp theo sau 1 giây nếu trả lời đúng
        _autoNextTimer = Timer(const Duration(seconds: 1), () {
          if (mounted) {
            _nextQuestion();
          }
        });
      }
      _totalAnswered++;
    });
  }

  void _nextQuestion() {
    // Hủy Timer nếu còn tồn tại
    _autoNextTimer?.cancel();

    if (_currentIndex < widget.flashcards.length - 1) {
      setState(() {
        _currentIndex++;
        _setupQuestion();
      });
    } else {
      _showResultsDialog();
    }
  }

  void _showResultsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        title: const Text(
          'Kết quả học tập',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Bạn trả lời đúng $_correctAnswers/${widget.flashcards.length} câu',
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tỷ lệ chính xác: ${(_correctAnswers / widget.flashcards.length * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                color: _correctAnswers > widget.flashcards.length / 2
                    ? Colors.green
                    : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Đầu tiên đóng dialog
              Navigator.of(context).pop();

              // Sau đó điều hướng đến màn hình Vocabulary
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VocabularyScreen(
                    moduleName: '',
                  ), // Thay bằng màn hình Vocabulary thực tế
                ),
              );
            },
            child:
                const Text('Kết thúc', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem(
      String option, bool isSelected, bool isCorrectAnswer) {
    Color backgroundColor = const Color(0xFF12113A);
    Color borderColor = Colors.transparent;
    Color textColor = Colors.white;

    Widget? leadingIcon;

    if (_isAnswerSubmitted) {
      if (isCorrectAnswer) {
        // Đáp án đúng luôn có viền xanh và icon check
        borderColor = const Color(0xFF63E48D);
        leadingIcon = const Icon(
          Icons.check_circle,
          color: Color(0xFF63E48D),
          size: 24,
        );
      } else if (isSelected) {
        // Đáp án đã chọn nhưng sai
        borderColor = const Color(0xFFFF4D4F);
        leadingIcon = const Icon(
          Icons.close,
          color: Color(0xFFFF4D4F),
          size: 24,
        );
      }
    } else if (isSelected) {
      // Đáp án đang được chọn
      borderColor = AppColors.primary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor,
          width: borderColor != Colors.transparent ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isAnswerSubmitted ? null : () => _checkAnswer(option),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Row(
              children: [
                if (leadingIcon != null) ...[
                  SizedBox(width: 24, child: leadingIcon),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    option,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight:
                          isSelected || isCorrectAnswer && _isAnswerSubmitted
                              ? FontWeight.bold
                              : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.flashcards.isEmpty) {
      return QlzScreen(
        appBar: AppBar(title: const Text('Học tập')),
        child: QlzEmptyState.noData(
          title: 'Không có thẻ ghi nhớ',
          message: 'Học phần này chưa có thẻ ghi nhớ nào để học.',
          actionLabel: 'Quay lại',
          onAction: () => Navigator.pop(context),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A092D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 48,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              // TODO: Implement settings
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Correct answers counter
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _correctAnswers > 0
                          ? const Color(0xFF12113A)
                          : const Color(0xFF12113A),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _correctAnswers > 0
                            ? const Color(0xFF63E48D)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      '$_correctAnswers',
                      style: TextStyle(
                        color: _correctAnswers > 0
                            ? const Color(0xFF63E48D)
                            : Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Progress bar
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _progress,
                          backgroundColor: const Color(0xFF282A4A),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF63E48D),
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ),
                  ),

                  // Total flashcards counter
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF12113A),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${widget.flashcards.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Definition section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                widget.flashcards[_currentIndex].definition,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Feedback section - show only after answering
            if (_isAnswerSubmitted)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _isAnswerCorrect ? "잘했어요!" : "조금만 더요, 아직 배우고 있잖아요!",
                  style: TextStyle(
                    color: _isAnswerCorrect
                        ? const Color(0xFF63E48D)
                        : const Color(0xFFFF4D4F),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Options section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Only show this label when not answered yet
                  if (!_isAnswerSubmitted)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Text(
                        'Chọn câu trả lời',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  // Options list
                  ...List.generate(_options.length, (index) {
                    final option = _options[index];
                    final isSelected = _selectedAnswer == option;
                    final isCorrectAnswer =
                        option == widget.flashcards[_currentIndex].term;

                    return _buildOptionItem(
                        option, isSelected, isCorrectAnswer);
                  }),
                ],
              ),
            ),

            const Spacer(),

            // Continue button - only show for incorrect answers
            if (_isAnswerSubmitted && !_isAnswerCorrect)
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _nextQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '계속하기',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
