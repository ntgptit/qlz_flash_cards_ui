// lib/shared/widgets/data_display/qlz_progress.dart

import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';

/// Types of progress indicators available
enum QlzProgressType {
  linear,
  circular,
  segmented,
}

/// A customized progress indicator widget for showing progress
/// in different formats (linear, circular, segmented).
final class QlzProgress extends StatelessWidget {
  /// The current progress value between 0.0 and 1.0.
  final double value;

  /// The type of progress indicator to display.
  final QlzProgressType type;

  /// The height of the progress bar (for linear type).
  final double height;

  /// The width of the progress bar (for linear type).
  final double? width;

  /// The size of the progress indicator (for circular type).
  final double size;

  /// The color of the progress indicator.
  final Color? color;

  /// The background color of the progress indicator.
  final Color? backgroundColor;

  /// Optional label to display.
  final String? label;

  /// The style of the label.
  final TextStyle? labelStyle;

  /// The position of the label (inside or outside the progress bar).
  final bool showLabelInside;

  /// Whether to animate changes in the progress value.
  final bool animate;

  /// The duration of the animation.
  final Duration animationDuration;

  /// The number of segments (for segmented type).
  final int segments;

  /// The spacing between segments (for segmented type).
  final double segmentSpacing;

  const QlzProgress({
    super.key,
    required this.value,
    this.type = QlzProgressType.linear,
    this.height = 8,
    this.width,
    this.size = 48,
    this.color,
    this.backgroundColor,
    this.label,
    this.labelStyle,
    this.showLabelInside = false,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.segments = 10,
    this.segmentSpacing = 4,
  }) : assert(
            value >= 0.0 && value <= 1.0, 'Value must be between 0.0 and 1.0');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? AppColors.primary;
    final effectiveBackgroundColor = backgroundColor ??
        (theme.brightness == Brightness.dark
            ? const Color(0xFF1A1D3D)
            : theme.colorScheme.surfaceContainerHighest);

    switch (type) {
      case QlzProgressType.linear:
        return _buildLinearProgress(
          context,
          effectiveColor,
          effectiveBackgroundColor,
        );
      case QlzProgressType.circular:
        return _buildCircularProgress(
          context,
          effectiveColor,
          effectiveBackgroundColor,
        );
      case QlzProgressType.segmented:
        return _buildSegmentedProgress(
          context,
          effectiveColor,
          effectiveBackgroundColor,
        );
    }
  }

  Widget _buildLinearProgress(
    BuildContext context,
    Color effectiveColor,
    Color effectiveBackgroundColor,
  ) {
    final progressBar = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: Stack(
        children: [
          AnimatedContainer(
            duration: animate ? animationDuration : Duration.zero,
            width: width != null ? width! * value : null,
            decoration: BoxDecoration(
              color: effectiveColor,
              borderRadius: BorderRadius.circular(height / 2),
            ),
          ),
          if (showLabelInside && label != null)
            Center(
              child: Text(
                label!,
                style: labelStyle ??
                    Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
              ),
            ),
        ],
      ),
    );

    if (!showLabelInside && label != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label!,
            style: labelStyle ?? Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          progressBar,
        ],
      );
    }

    return progressBar;
  }

  Widget _buildCircularProgress(
    BuildContext context,
    Color effectiveColor,
    Color effectiveBackgroundColor,
  ) {
    final progressCircle = SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          CircularProgressIndicator(
            value: 1.0,
            strokeWidth: height,
            valueColor: AlwaysStoppedAnimation<Color>(effectiveBackgroundColor),
          ),
          // Progress circle
          AnimatedContainer(
            duration: animate ? animationDuration : Duration.zero,
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: height,
              valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
            ),
          ),
          // Center label if needed
          if (showLabelInside && label != null)
            Text(
              label!,
              style: labelStyle ??
                  Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
            ),
        ],
      ),
    );

    if (!showLabelInside && label != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          progressCircle,
          const SizedBox(height: 8),
          Text(
            label!,
            style: labelStyle ?? Theme.of(context).textTheme.bodySmall,
          ),
        ],
      );
    }

    return progressCircle;
  }

  Widget _buildSegmentedProgress(
    BuildContext context,
    Color effectiveColor,
    Color effectiveBackgroundColor,
  ) {
    final completedSegments = (value * segments).floor();
    final partialSegment = value * segments - completedSegments;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              label!,
              style: labelStyle ?? Theme.of(context).textTheme.bodySmall,
            ),
          ),
        SizedBox(
          width: width,
          height: height,
          child: Row(
            children: List.generate(segments, (index) {
              Color segmentColor;
              double segmentValue = 1.0;

              if (index < completedSegments) {
                // Fully completed segment
                segmentColor = effectiveColor;
              } else if (index == completedSegments) {
                // Partially completed segment
                segmentColor = effectiveColor;
                segmentValue = partialSegment;
              } else {
                // Not started segment
                segmentColor = effectiveBackgroundColor;
              }

              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    right: index < segments - 1 ? segmentSpacing : 0,
                  ),
                  height: height,
                  decoration: BoxDecoration(
                    color: effectiveBackgroundColor,
                    borderRadius: BorderRadius.circular(height / 2),
                  ),
                  child: index <= completedSegments
                      ? AnimatedContainer(
                          duration: animate ? animationDuration : Duration.zero,
                          width: segmentValue * double.infinity,
                          decoration: BoxDecoration(
                            color: segmentColor,
                            borderRadius: BorderRadius.circular(height / 2),
                          ),
                        )
                      : null,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
