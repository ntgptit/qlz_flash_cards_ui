import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/features/quiz/models/quiz_question.dart';

class WrittenQuizSimplified extends StatefulWidget {
  final List<WrittenQuestion> questions;
  final Function(String) onAnswerSubmitted;
  final VoidCallback onQuizCompleted;
  final Function(int) onMoveToQuestion;
  final int currentQuestionIndex;
  final bool isAnswerSubmitted;
  final int totalQuestions;
  final bool showAnswerImmediately;
  final String? submittedAnswer;

  const WrittenQuizSimplified({
    super.key,
    required this.questions,
    required this.onAnswerSubmitted,
    required this.onQuizCompleted,
    required this.onMoveToQuestion,
    required this.currentQuestionIndex,
    required this.isAnswerSubmitted,
    required this.totalQuestions,
    this.showAnswerImmediately = true,
    this.submittedAnswer,
  });

  @override
  State<WrittenQuizSimplified> createState() => _WrittenQuizSimplifiedState();
}

class _WrittenQuizSimplifiedState extends State<WrittenQuizSimplified> {
  late TextEditingController _answerController;
  final FocusNode _answerFocusNode = FocusNode();
  bool _localIsAnswerSubmitted = false;
  String? _localSubmittedAnswer;

  @override
  void initState() {
    super.initState();
    _answerController = TextEditingController();
    _localIsAnswerSubmitted = widget.isAnswerSubmitted;
    _localSubmittedAnswer = widget.submittedAnswer;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _answerFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _answerController.dispose();
    _answerFocusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(WrittenQuizSimplified oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentQuestionIndex != widget.currentQuestionIndex) {
      _answerController.clear();
      _localIsAnswerSubmitted = widget.isAnswerSubmitted;
      _localSubmittedAnswer = widget.submittedAnswer;
      _answerFocusNode.requestFocus();
      print(
          "didUpdateWidget: Reset for new question, _localSubmittedAnswer=$_localSubmittedAnswer");
    }
  }

  void _submitAnswer() {
    if (!_localIsAnswerSubmitted) {
      final answer = _answerController.text.trim();
      if (answer.isNotEmpty) {
        setState(() {
          _localIsAnswerSubmitted = true;
          _localSubmittedAnswer = answer;
          print("Submit: _localSubmittedAnswer=$_localSubmittedAnswer");
        });
        widget.onAnswerSubmitted(answer);
        _answerController.clear();

        // Kiểm tra nếu trả lời đúng thì tự động chuyển sau 1.5 giây
        final currentQuestion = widget.questions[widget.currentQuestionIndex];
        final flashcard = currentQuestion.flashcard;
        if (_checkAnswer(flashcard.term, answer)) {
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (!mounted) return;
            if (widget.currentQuestionIndex < widget.totalQuestions - 1) {
              widget.onMoveToQuestion(widget.currentQuestionIndex + 1);
            } else {
              widget.onQuizCompleted();
            }
          });
        }
      }
    }
  }

  void _skipQuestion() {
    if (!_localIsAnswerSubmitted) {
      setState(() {
        _localIsAnswerSubmitted = true;
        _localSubmittedAnswer = '';
        print("Skip: _localSubmittedAnswer=$_localSubmittedAnswer");
      });
      widget.onAnswerSubmitted('');
      _answerController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = widget.questions[widget.currentQuestionIndex];
    final flashcard = currentQuestion.flashcard;

    final bool showResult =
        _localIsAnswerSubmitted && widget.showAnswerImmediately;
    final bool isSkipped = _localSubmittedAnswer?.isEmpty ?? false;
    final bool isAnswerCorrect = _localSubmittedAnswer != null &&
        !isSkipped &&
        _checkAnswer(flashcard.term, _localSubmittedAnswer!);

    print(
        "Build: showResult=$showResult, isSkipped=$isSkipped, _localSubmittedAnswer=$_localSubmittedAnswer");

    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 40,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFF252850), width: 1),
            ),
          ),
          child: Text(
            '${widget.currentQuestionIndex + 1}/${widget.totalQuestions}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 15),
                Text(
                  flashcard.definition,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (showResult) ...[
                  const SizedBox(height: 20),
                  if (isAnswerCorrect) ...[
                    const Text(
                      'Tuyệt vời! Bạn đã trả lời đúng!',
                      style: TextStyle(
                        color: Color(0xFF4AE290),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildAnswerContainer(
                      text: _localSubmittedAnswer ?? "",
                      color: const Color(0xFF4AE290),
                      icon: Icons.check_circle,
                    ),
                  ] else if (isSkipped) ...[
                    const Text(
                      'Thử lại câu hỏi này sau!',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildAnswerContainer(
                      text: 'Đã bỏ qua',
                      color: Colors.grey,
                      icon: Icons.help_outline,
                    ),
                  ] else ...[
                    const Text(
                      'Đừng nản chí, học là một quá trình!',
                      style: TextStyle(
                        color: Color(0xFFFF6B6B),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildAnswerContainer(
                      text: _localSubmittedAnswer ?? "",
                      color: const Color(0xFFFF6B6B),
                      icon: Icons.close,
                    ),
                  ],
                  if (!isAnswerCorrect) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Câu trả lời đúng',
                      style: TextStyle(color: Color(0xFF4AE290), fontSize: 18),
                    ),
                    const SizedBox(height: 12),
                    _buildAnswerContainer(
                      text: flashcard.term,
                      color: const Color(0xFF4AE290),
                      icon: Icons.check,
                    ),
                  ],
                  const Spacer(),
                ] else ...[
                  const Spacer(),
                  Container(
                    width: double.infinity,
                    height: 60,
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Color(0xFF252850), width: 1),
                        bottom: BorderSide(color: Color(0xFF252850), width: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _answerController,
                            focusNode: _answerFocusNode,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Nhập từ vựng tiếng Hàn',
                              hintStyle: TextStyle(
                                  color: Colors.white38, fontSize: 16),
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 16),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (_) => _submitAnswer(),
                            enabled: !_localIsAnswerSubmitted,
                          ),
                        ),
                        TextButton(
                          onPressed:
                              _localIsAnswerSubmitted ? null : _skipQuestion,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child: const Text(
                            'Không biết',
                            style: TextStyle(
                              color: Color(0xFF5C5FA6),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ],
            ),
          ),
        ),
        // Chỉ hiển thị nút "Tiếp tục" khi không trả lời đúng
        if (showResult && !isAnswerCorrect) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0xFF1C1C36),
              border:
                  Border(top: BorderSide(color: Color(0xFF252850), width: 1)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (widget.currentQuestionIndex < widget.totalQuestions - 1) {
                    widget.onMoveToQuestion(widget.currentQuestionIndex + 1);
                  } else {
                    widget.onQuizCompleted();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4255FF),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Tiếp tục', style: TextStyle(fontSize: 18)),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAnswerContainer(
      {required String text, required Color color, required IconData icon}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
    );
  }

  bool _checkAnswer(String correctAnswer, String userAnswer) {
    return correctAnswer.trim().toLowerCase() ==
        userAnswer.trim().toLowerCase();
  }
}
