// lib/shared/widgets/quiz/qlz_quiz_option.dart

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';

/// Represents the state of a quiz option
sealed class QlzQuizOptionState {
  const QlzQuizOptionState._();

  static const idle = _QlzQuizOptionStateIdle();
  static const selected = _QlzQuizOptionStateSelected();
  static const correct = _QlzQuizOptionStateCorrect();
  static const incorrect = _QlzQuizOptionStateIncorrect();
}

final class _QlzQuizOptionStateIdle extends QlzQuizOptionState {
  const _QlzQuizOptionStateIdle() : super._();
}

final class _QlzQuizOptionStateSelected extends QlzQuizOptionState {
  const _QlzQuizOptionStateSelected() : super._();
}

final class _QlzQuizOptionStateCorrect extends QlzQuizOptionState {
  const _QlzQuizOptionStateCorrect() : super._();
}

final class _QlzQuizOptionStateIncorrect extends QlzQuizOptionState {
  const _QlzQuizOptionStateIncorrect() : super._();
}

/// A quiz option component for multiple choice questions.
///
/// This component represents a single option in a multiple choice quiz,
/// supporting different states (idle, selected, correct, incorrect) and
/// customizable appearance.
final class QlzQuizOption extends StatelessWidget {
  final String text;
  final String? subtext;
  final QlzQuizOptionState state;
  final VoidCallback? onTap;
  final bool isDisabled;

  const QlzQuizOption({
    super.key,
    required this.text,
    this.subtext,
    this.state = QlzQuizOptionState.idle,
    this.onTap,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getBorderColor(theme),
              width: _getBorderWidth(),
            ),
            color: _getBackgroundColor(theme),
          ),
          child: Row(
            children: [
              _buildLeadingIcon(theme),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: _getTextColor(theme),
                      ),
                    ),
                    if (subtext != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtext!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _getSubtextColor(theme),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBorderColor(ThemeData theme) => switch (state) {
        QlzQuizOptionState.idle => AppColors.darkBorder, // Sử dụng darkBorder cho trạng thái mặc định
        QlzQuizOptionState.selected => AppColors.primary, // Màu xanh chính cho lựa chọn
        QlzQuizOptionState.correct => AppColors.success, // Xanh lá cho đúng
        QlzQuizOptionState.incorrect => AppColors.error, // Đỏ cho sai
        _ => throw UnimplementedError(),
      };

  double _getBorderWidth() => switch (state) {
        QlzQuizOptionState.idle => 1.0,
        QlzQuizOptionState.selected => 2.0,
        QlzQuizOptionState.correct => 2.0,
        QlzQuizOptionState.incorrect => 2.0,
        _ => throw UnimplementedError(),
      };

  Color _getBackgroundColor(ThemeData theme) => switch (state) {
        QlzQuizOptionState.idle => AppColors.darkCard, // Màu nền thẻ tối
        QlzQuizOptionState.selected => AppColors.primary.withOpacity(0.1), // Nhẹ nhàng khi chọn
        QlzQuizOptionState.correct => AppColors.success.withOpacity(0.1), // Nhẹ nhàng khi đúng
        QlzQuizOptionState.incorrect => AppColors.error.withOpacity(0.1), // Nhẹ nhàng khi sai
        _ => throw UnimplementedError(),
      };

  Color _getTextColor(ThemeData theme) => switch (state) {
        QlzQuizOptionState.idle => AppColors.darkText, // Màu chữ trắng cho trạng thái mặc định
        QlzQuizOptionState.selected => AppColors.primary, // Xanh chính khi chọn
        QlzQuizOptionState.correct => AppColors.success, // Xanh lá khi đúng
        QlzQuizOptionState.incorrect => AppColors.error, // Đỏ khi sai
        _ => throw UnimplementedError(),
      };

  Color _getSubtextColor(ThemeData theme) => switch (state) {
        QlzQuizOptionState.idle => AppColors.darkTextSecondary, // Màu phụ cho trạng thái mặc định
        QlzQuizOptionState.selected => AppColors.primary.withOpacity(0.8), // Nhẹ hơn khi chọn
        QlzQuizOptionState.correct => AppColors.success.withOpacity(0.8), // Nhẹ hơn khi đúng
        QlzQuizOptionState.incorrect => AppColors.error.withOpacity(0.8), // Nhẹ hơn khi sai
        _ => throw UnimplementedError(),
      };

  Widget _buildLeadingIcon(ThemeData theme) => switch (state) {
        QlzQuizOptionState.idle => const SizedBox.shrink(),
        QlzQuizOptionState.selected => const Icon(
            Icons.check_circle_outline,
            color: AppColors.primary, // Icon xanh khi chọn
          ),
        QlzQuizOptionState.correct => const Icon(
            Icons.check_circle,
            color: AppColors.success, // Icon xanh lá khi đúng
          ),
        QlzQuizOptionState.incorrect => const Icon(
            Icons.cancel,
            color: AppColors.error, // Icon đỏ khi sai
          ),
        _ => throw UnimplementedError(),
      };
}