// lib/shared/widgets/quiz/qlz_quiz_option.dart

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

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
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
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
        QlzQuizOptionState.idle => theme.dividerColor,
        QlzQuizOptionState.selected => theme.colorScheme.primary,
        QlzQuizOptionState.correct => theme.colorScheme.secondary,
        QlzQuizOptionState.incorrect => theme.colorScheme.error,
        _QlzQuizOptionStateIdle() => throw UnimplementedError(),
        _QlzQuizOptionStateSelected() => throw UnimplementedError(),
        _QlzQuizOptionStateCorrect() => throw UnimplementedError(),
        _QlzQuizOptionStateIncorrect() => throw UnimplementedError(),
      };

  double _getBorderWidth() => switch (state) {
        QlzQuizOptionState.idle => 1.0,
        QlzQuizOptionState.selected => 2.0,
        QlzQuizOptionState.correct => 2.0,
        QlzQuizOptionState.incorrect => 2.0,
        _QlzQuizOptionStateIdle() => throw UnimplementedError(),
        _QlzQuizOptionStateSelected() => throw UnimplementedError(),
        _QlzQuizOptionStateCorrect() => throw UnimplementedError(),
        _QlzQuizOptionStateIncorrect() => throw UnimplementedError(),
      };

  Color _getBackgroundColor(ThemeData theme) => switch (state) {
        QlzQuizOptionState.idle => theme.cardColor,
        QlzQuizOptionState.selected =>
          theme.colorScheme.primary.withOpacity(0.1),
        QlzQuizOptionState.correct =>
          theme.colorScheme.secondary.withOpacity(0.1),
        QlzQuizOptionState.incorrect =>
          theme.colorScheme.error.withOpacity(0.1),
        _QlzQuizOptionStateIdle() => throw UnimplementedError(),
        _QlzQuizOptionStateSelected() => throw UnimplementedError(),
        _QlzQuizOptionStateCorrect() => throw UnimplementedError(),
        _QlzQuizOptionStateIncorrect() => throw UnimplementedError(),
      };

  Color _getTextColor(ThemeData theme) => switch (state) {
        QlzQuizOptionState.idle =>
          theme.textTheme.bodyLarge?.color ?? theme.colorScheme.onBackground,
        QlzQuizOptionState.selected => theme.colorScheme.primary,
        QlzQuizOptionState.correct => theme.colorScheme.secondary,
        QlzQuizOptionState.incorrect => theme.colorScheme.error,
        _QlzQuizOptionStateIdle() => throw UnimplementedError(),
        _QlzQuizOptionStateSelected() => throw UnimplementedError(),
        _QlzQuizOptionStateCorrect() => throw UnimplementedError(),
        _QlzQuizOptionStateIncorrect() => throw UnimplementedError(),
      };

  Color _getSubtextColor(ThemeData theme) => switch (state) {
        QlzQuizOptionState.idle => theme.textTheme.bodySmall?.color ??
            theme.colorScheme.onBackground.withOpacity(0.6),
        QlzQuizOptionState.selected =>
          theme.colorScheme.primary.withOpacity(0.8),
        QlzQuizOptionState.correct =>
          theme.colorScheme.secondary.withOpacity(0.8),
        QlzQuizOptionState.incorrect =>
          theme.colorScheme.error.withOpacity(0.8),
        _QlzQuizOptionStateIdle() => throw UnimplementedError(),
        _QlzQuizOptionStateSelected() => throw UnimplementedError(),
        _QlzQuizOptionStateCorrect() => throw UnimplementedError(),
        _QlzQuizOptionStateIncorrect() => throw UnimplementedError(),
      };

  Widget _buildLeadingIcon(ThemeData theme) => switch (state) {
        QlzQuizOptionState.idle => const SizedBox.shrink(),
        QlzQuizOptionState.selected => Icon(
            Icons.check_circle_outline,
            color: theme.colorScheme.primary,
          ),
        QlzQuizOptionState.correct => Icon(
            Icons.check_circle,
            color: theme.colorScheme.secondary,
          ),
        QlzQuizOptionState.incorrect => Icon(
            Icons.cancel,
            color: theme.colorScheme.error,
          ),
        _QlzQuizOptionStateIdle() => throw UnimplementedError(),
        _QlzQuizOptionStateSelected() => throw UnimplementedError(),
        _QlzQuizOptionStateCorrect() => throw UnimplementedError(),
        _QlzQuizOptionStateIncorrect() => throw UnimplementedError(),
      };
}
