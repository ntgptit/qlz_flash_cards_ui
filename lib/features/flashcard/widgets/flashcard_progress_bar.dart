import 'package:flutter/material.dart';

import '../../../config/app_colors.dart';

/// A custom progress bar widget for flashcard study sessions
class FlashcardProgressBar extends StatelessWidget {
  /// The progress value (0.0 to 1.0)
  final double progress;
  
  /// Height of the progress bar
  final double height;
  
  /// Background color of the progress bar
  final Color? backgroundColor;
  
  /// Color of the progress indicator
  final Color? progressColor;
  
  /// Whether to animate changes in the progress value
  final bool animate;
  
  /// Duration of the animation
  final Duration animationDuration;

  /// Creates a FlashcardProgressBar instance
  const FlashcardProgressBar({
    super.key,
    required this.progress,
    this.height = 4.0,
    this.backgroundColor,
    this.progressColor,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 300),
  });

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
      child: Stack(
        children: [
          // Background
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: effectiveBackgroundColor,
            ),
          ),
          
          // Progress indicator
          animate
              ? AnimatedContainer(
                  duration: animationDuration,
                  width: MediaQuery.of(context).size.width * progress,
                  decoration: BoxDecoration(
                    color: effectiveProgressColor,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(2.0),
                      bottomRight: Radius.circular(2.0),
                    ),
                  ),
                )
              : Container(
                  width: MediaQuery.of(context).size.width * progress,
                  decoration: BoxDecoration(
                    color: effectiveProgressColor,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(2.0),
                      bottomRight: Radius.circular(2.0),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}