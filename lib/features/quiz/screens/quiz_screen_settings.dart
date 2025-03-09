// lib/features/quiz/screens/quiz_screen_settings.dart

import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/core/routes/app_routes.dart';
import 'package:qlz_flash_cards_ui/features/quiz/models/quiz_settings.dart';
import 'package:qlz_flash_cards_ui/features/vocabulary/data/flashcard.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/layout/qlz_screen.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/navigation/qlz_app_bar.dart';

/// Màn hình cài đặt bài kiểm tra để cấu hình trước khi bắt đầu
class QuizScreenSettings extends StatefulWidget {
  final String moduleId;
  final String moduleName;
  final List<Flashcard> flashcards;

  const QuizScreenSettings({
    super.key,
    required this.moduleId,
    required this.moduleName,
    required this.flashcards,
  });

  @override
  State<QuizScreenSettings> createState() => _QuizScreenSettingsState();
}

class _QuizScreenSettingsState extends State<QuizScreenSettings> {
  late QuizSettings _settings;
  bool _isLoading = false;

  // Cài đặt tùy chọn kiểm tra
  int _questionCount = 88; // Mặc định với giá trị như trong ảnh
  bool _showAnswerImmediately = true;
  String _responseLanguage = 'Tiếng Hàn';
  bool _trueFalseMode = false;
  bool _multipleChoiceMode = false;
  bool _writtenMode = true;

  @override
  void initState() {
    super.initState();

    // Số câu hỏi mặc định hoặc tối đa là số lượng flashcard
    _questionCount =
        widget.flashcards.length < 88 ? widget.flashcards.length : 88;

    // Khởi tạo với cài đặt mặc định
    _settings = QuizSettings(
      moduleId: widget.moduleId,
      moduleName: widget.moduleName,
      quizType: QuizType.written, // Mặc định là tự luận theo ảnh
      questionCount: _questionCount,
      difficulty: QuizDifficulty.medium,
      shuffleQuestions: true,
      showCorrectAnswers: true,
    );
  }

  void _startQuiz() {
    setState(() {
      _isLoading = true;
    });

    QuizType selectedType;
    if (_trueFalseMode) {
      selectedType = QuizType.trueFalse;
    } else if (_multipleChoiceMode) {
      selectedType = QuizType.multipleChoice;
    } else if (_writtenMode) {
      selectedType = QuizType.written;
    } else {
      selectedType = QuizType.written; // Mặc định là tự luận
    }

    final updatedSettings = _settings.copyWith(
      questionCount: _questionCount,
      quizType: selectedType, // Cập nhật chế độ thi
      showCorrectAnswers: _showAnswerImmediately,
    );

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      final quizData = Map<String, dynamic>.from(updatedSettings.toMap());
      quizData['flashcards'] = widget.flashcards;

      Navigator.pushNamed(
        context,
        AppRoutes.quiz,
        arguments: quizData, // Truyền dữ liệu vào QuizScreen
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return QlzScreen(
      appBar: QlzAppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title:
            '', // Không hiển thị tiêu đề trong AppBar vì đã có tiêu đề bên trong
      ),
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section title
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text(
                          'Section 4: ',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '병원',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.checklist,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),
                    const Text(
                      'Thiết lập bài kiểm tra',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Số câu hỏi
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Số câu hỏi',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '(tối đa ${widget.flashcards.length})',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 70,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2A3252),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '$_questionCount',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Slider cho số câu hỏi
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: AppColors.primary,
                        inactiveTrackColor: Colors.white.withOpacity(0.2),
                        thumbColor: Colors.white,
                        trackHeight: 4,
                        thumbShape:
                            const RoundSliderThumbShape(enabledThumbRadius: 8),
                      ),
                      child: Slider(
                        value: _questionCount.toDouble(),
                        min: 5,
                        max: widget.flashcards.length.toDouble(),
                        onChanged: (value) {
                          setState(() {
                            _questionCount = value.round();
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Hiển thị đáp án ngay
                    _buildSwitchRow(
                      'Hiển thị đáp án ngay',
                      _showAnswerImmediately,
                      (value) {
                        setState(() {
                          _showAnswerImmediately = value;
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    // Trả lời bằng
                    _buildSelectionRow(
                      'Trả lời bằng:',
                      _responseLanguage,
                      () {
                        _showLanguageOptionsDialog();
                      },
                    ),

                    const SizedBox(height: 20),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 20),

                    // Đúng / Sai
                    _buildSwitchRow(
                      'Đúng / Sai',
                      _trueFalseMode,
                      (value) {
                        setState(() {
                          _trueFalseMode = value;
                          // Nếu bật chế độ này, tắt các chế độ khác
                          if (value) {
                            _multipleChoiceMode = false;
                            _writtenMode = false;
                          } else if (!_multipleChoiceMode && !_writtenMode) {
                            // Đảm bảo luôn có ít nhất một chế độ được chọn
                            _writtenMode = true;
                          }
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    // Nhiều lựa chọn
                    _buildSwitchRow(
                      'Nhiều lựa chọn',
                      _multipleChoiceMode,
                      (value) {
                        setState(() {
                          _multipleChoiceMode = value;
                          // Nếu bật chế độ này, tắt các chế độ khác
                          if (value) {
                            _trueFalseMode = false;
                            _writtenMode = false;
                          } else if (!_trueFalseMode && !_writtenMode) {
                            // Đảm bảo luôn có ít nhất một chế độ được chọn
                            _writtenMode = true;
                          }
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    _buildSwitchRow(
                      'Tự luận',
                      _writtenMode,
                      (value) {
                        setState(() {
                          _writtenMode = value;
                          // Nếu bật chế độ này, tắt các chế độ khác
                          if (value) {
                            _trueFalseMode = false;
                            _multipleChoiceMode = false;
                          } else if (!_trueFalseMode && !_multipleChoiceMode) {
                            // Đảm bảo luôn có ít nhất một chế độ được chọn
                            _multipleChoiceMode = true;
                          }
                        });
                      },
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),

          // Nút bắt đầu kiểm tra
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _startQuiz,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Bắt đầu làm kiểm tra',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Hàng với switch toggle
  Widget _buildSwitchRow(
      String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
          activeTrackColor: AppColors.primary.withOpacity(0.4),
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: Colors.white.withOpacity(0.3),
        ),
      ],
    );
  }

  // Hàng với dropdown selection
  Widget _buildSelectionRow(String label, String value, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Row(
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Dialog chọn ngôn ngữ trả lời
  void _showLanguageOptionsDialog() {
    final options = ['Tiếng Hàn', 'Tiếng Việt', 'Tiếng Anh'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF12113A),
        title: const Text(
          'Chọn ngôn ngữ trả lời',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options
              .map((option) => ListTile(
                    title: Text(
                      option,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: option == _responseLanguage
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: option == _responseLanguage
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () {
                      setState(() {
                        _responseLanguage = option;
                      });
                      Navigator.pop(context);
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }
}
