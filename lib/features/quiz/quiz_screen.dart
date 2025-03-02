// lib/presentation/screens/quiz/quiz_screen.dart

import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/navigation/qlz_app_bar.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/quiz/qlz_quiz_option.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/utils/qlz_chip.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/buttons/qlz_button.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/data_display/qlz_progress.dart';

final class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A092D),
      appBar: QlzAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        titleWidget: QlzChip(
          label: '1/20',
          type: QlzChipType.ghost,
          isOutlined: true,
          borderColor: Colors.white.withOpacity(0.3),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: QlzProgress(
              value: 0.05,
              type: QlzProgressType.linear,
              height: 6,
              color: AppColors.primary,
              backgroundColor: Color(0xFF12113A),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chọn nghĩa đúng cho:',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '과일',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'gwail',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 32),
                  QlzQuizOption(
                    text: 'Trái cây',
                    subtext: '과일: Trái cây, hoa quả',
                    state: QlzQuizOptionState.selected,
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  QlzQuizOption(
                    text: 'Rau củ',
                    subtext: '채소: Rau củ, rau xanh',
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  QlzQuizOption(
                    text: 'Đồ uống',
                    subtext: '음료: Đồ uống, thức uống',
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  QlzQuizOption(
                    text: 'Bánh kẹo',
                    subtext: '과자: Bánh kẹo, đồ ăn vặt',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: QlzButton.primary(
                label: 'Kiểm tra',
                onPressed: () {},
                isFullWidth: true,
                size: QlzButtonSize.large,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
