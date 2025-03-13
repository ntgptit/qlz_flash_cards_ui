import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';

class FlashcardProgressBar extends StatelessWidget {
  final double progress;
  final double height;
  final Color? backgroundColor;
  final Color? progressColor;
  final bool animate;
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
              Container(
                width: maxWidth,
                decoration: BoxDecoration(
                  color: effectiveBackgroundColor,
                ),
              ),
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
