import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/features/quiz/factory/quiz_factory.dart';
import 'package:qlz_flash_cards_ui/features/quiz/models/quiz_question.dart';
import 'package:qlz_flash_cards_ui/features/quiz/models/quiz_result.dart';
import 'package:qlz_flash_cards_ui/features/quiz/models/quiz_settings.dart';
import 'package:qlz_flash_cards_ui/features/quiz/screens/quiz_result_screen.dart';
import 'package:qlz_flash_cards_ui/features/vocabulary/data/flashcard.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/layout/qlz_modal.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/layout/qlz_screen.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/navigation/qlz_app_bar.dart';

class QuizScreen extends StatefulWidget {
  final Map<String, dynamic>? quizData;
  const QuizScreen({super.key, this.quizData});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late QuizSettings _settings;
  late List<Flashcard> _flashcards;
  late QuizFactory _quizFactory;
  late List<QuizQuestion> _questions;
  int _currentQuestionIndex = 0;
  int _correctAnswers = 0;
  bool _isAnswerSubmitted = false;
  bool _isQuizCompleted = false;
  dynamic _additionalData; // Giữ giá trị này cho đến khi chuyển câu
  DateTime? _quizStartTime;
  DateTime? _quizEndTime;

  @override
  void initState() {
    super.initState();
    _initializeQuiz();
    _quizStartTime = DateTime.now();
  }

  void _initializeQuiz() {
    final quizData = widget.quizData;
    if (quizData != null) {
      _settings = QuizSettings.fromMap(quizData);
      _flashcards = quizData['flashcards'] as List<Flashcard>;
    } else {
      _settings =
          QuizSettings.defaultSettings('sample_module', 'Bài kiểm tra mẫu');
      _flashcards = _generateSampleFlashcards();
    }
    _quizFactory = QuizFactory.createFromType(_settings.quizType,
        useSimplifiedWritten: true);
    if (_settings.shuffleQuestions) {
      _flashcards = List.from(_flashcards)..shuffle();
    }
    _questions =
        _quizFactory.createQuestions(_flashcards, _settings.questionCount);
  }

  List<Flashcard> _generateSampleFlashcards() {
    return List.generate(
      10,
      (index) => Flashcard(
        id: 'flashcard_$index',
        term: 'Thuật ngữ ${index + 1}',
        definition: 'Đây là định nghĩa của thuật ngữ ${index + 1}',
        example:
            index % 2 == 0 ? 'Đây là ví dụ cho thuật ngữ ${index + 1}' : null,
      ),
    );
  }

  void _handleQuestionAnswered(dynamic answer) {
    setState(() {
      _isAnswerSubmitted = true;
      _additionalData = answer; // Giữ giá trị này
      print("Handle: _additionalData=$_additionalData");
      switch (_settings.quizType) {
        case QuizType.multipleChoice:
          final selectedIndex = answer as int;
          final question =
              _questions[_currentQuestionIndex] as MultipleChoiceQuestion;
          final correctIndex =
              question.options.indexOf(question.flashcard.definition);
          if (selectedIndex == correctIndex) {
            _correctAnswers++;
          }
          break;
        case QuizType.trueFalse:
          final userAnswer = answer as bool;
          final question =
              _questions[_currentQuestionIndex] as TrueFalseQuestion;
          if (userAnswer == question.isCorrectPairing) {
            _correctAnswers++;
          }
          break;
        case QuizType.written:
          final writtenAnswer = answer as String;
          if (writtenAnswer.isEmpty) {
            break;
          }
          final question = _questions[_currentQuestionIndex] as WrittenQuestion;
          if (_quizFactory is WrittenQuizSimplifiedFactory) {
            final factory = _quizFactory as WrittenQuizSimplifiedFactory;
            if (factory.isAnswerCorrect(
                writtenAnswer, question.flashcard.term)) {
              _correctAnswers++;
            }
          }
          break;
        case QuizType.matching:
          final matchingResult = answer as Map<String, dynamic>;
          _correctAnswers = matchingResult['correctMatches'] as int;
          break;
      }
    });
  }

  void _moveToNextQuestion(int index) {
    if (index < _questions.length) {
      setState(() {
        _currentQuestionIndex = index;
        _additionalData = null; // Chỉ reset ở đây
        _isAnswerSubmitted = false;
      });
    } else {
      _completeQuiz();
    }
  }

  void _completeQuiz() {
    setState(() {
      _isQuizCompleted = true;
      _quizEndTime = DateTime.now();
    });
  }

  Future<bool> _showExitConfirmation() async {
    final bool shouldExit = await QlzModal.showConfirmation(
      context: context,
      title: 'Thoát bài kiểm tra',
      message:
          'Bạn có chắc chắn muốn thoát bài kiểm tra? Tiến trình của bạn sẽ không được lưu.',
      confirmText: 'Thoát',
      cancelText: 'Hủy',
      isDanger: true,
    );
    return shouldExit;
  }

  void _exitQuiz() {
    _showExitConfirmation().then((shouldExit) {
      if (shouldExit) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _isQuizCompleted,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        final bool shouldExit = await _showExitConfirmation();
        if (shouldExit && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: QlzScreen(
        appBar: _settings.quizType == QuizType.written && !_isQuizCompleted
            ? AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: _exitQuiz,
                ),
                title: null,
              )
            : QlzAppBar(
                title: _isQuizCompleted
                    ? 'Kết quả kiểm tra'
                    : _settings.moduleName,
                onBackPressed: _isQuizCompleted ? null : _exitQuiz,
                actions: [
                  if (!_isQuizCompleted &&
                      _settings.quizType != QuizType.matching &&
                      _settings.quizType != QuizType.written)
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Center(
                        child: Text(
                          '${_currentQuestionIndex + 1}/${_questions.length}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
        padding: EdgeInsets.zero,
        child: _isQuizCompleted ? _buildResultScreen() : _buildQuizContent(),
      ),
    );
  }

  Widget _buildQuizContent() {
    return _quizFactory.createQuizScreen(
      questions: _questions,
      showCorrectAnswers: _settings.showCorrectAnswers,
      onQuestionAnswered: _handleQuestionAnswered,
      onQuizCompleted: _completeQuiz,
      onMoveToQuestion: _moveToNextQuestion,
      currentQuestionIndex: _currentQuestionIndex,
      isAnswerSubmitted: _isAnswerSubmitted,
      additionalData: _additionalData, // Truyền giá trị hiện tại
    );
  }

  Widget _buildResultScreen() {
    final quizDuration = _quizEndTime!.difference(_quizStartTime!);
    final int totalQuestions = _settings.quizType == QuizType.matching
        ? _questions.first.flashcards.length
        : _questions.length;
    final quizResult = QuizResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      moduleId: _settings.moduleId,
      moduleName: _settings.moduleName,
      quizType: _settings.quizType,
      correctAnswers: _correctAnswers,
      totalQuestions: totalQuestions,
      completionTime: quizDuration,
      completionDate: DateTime.now(),
    );
    return QuizResultScreen(
      quizResult: quizResult,
      onRestart: () {
        setState(() {
          _currentQuestionIndex = 0;
          _correctAnswers = 0;
          _additionalData = null;
          _isAnswerSubmitted = false;
          _isQuizCompleted = false;
          _quizStartTime = DateTime.now();
          _quizEndTime = null;
          _initializeQuiz();
        });
      },
    );
  }
}
