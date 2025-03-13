import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';

/// A customizable progress bar for flashcard study sessions
class FlashcardProgressBar extends StatelessWidget {
  /// The progress value between 0.0 and 1.0
  final double progress;

  /// The height of the progress bar
  final double height;

  /// The background color of the progress bar
  final Color? backgroundColor;

  /// The color of the progress indicator
  final Color? progressColor;

  /// Whether to animate changes in progress
  final bool animate;

  /// The duration of the animation
  final Duration animationDuration;

  const FlashcardProgressBar({
    super.key,
    required this.progress,
    this.height = 4.0,
    this.backgroundColor,
    this.progressColor,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 300),
  }) : assert(progress >= 0.0 && progress <= 1.0,
            'Progress must be between 0.0 and 1.0');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine colors based on theme if not explicitly provided
    final effectiveBackgroundColor = backgroundColor ??
        (theme.brightness == Brightness.dark
            ? const Color(0xFF1A1D3D)
            : theme.colorScheme.surfaceContainerHighest);

    final effectiveProgressColor = progressColor ?? AppColors.primary;

    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;

          return Stack(
            children: [
              // Background
              Container(
                width: maxWidth,
                decoration: BoxDecoration(
                  color: effectiveBackgroundColor,
                ),
              ),

              // Progress indicator
              animate
                  ? AnimatedContainer(
                      duration: animationDuration,
                      curve: Curves.easeInOut,
                      width: maxWidth * progress,
                      decoration: BoxDecoration(
                        color: effectiveProgressColor,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(2.0),
                          bottomRight: Radius.circular(2.0),
                        ),
                      ),
                    )
                  : Container(
                      width: maxWidth * progress,
                      decoration: BoxDecoration(
                        color: effectiveProgressColor,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(2.0),
                          bottomRight: Radius.circular(2.0),
                        ),
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }
}
