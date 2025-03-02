// lib/shared/widgets/feedback/qlz_loading_state.dart

import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';

/// Types of loading indicators
enum QlzLoadingType {
  circular,
  linear,
  pulse,
  skeleton,
}

/// A widget for displaying various loading states
/// including circular, linear, pulse, and skeleton loading.
final class QlzLoadingState extends StatelessWidget {
  /// The type of loading indicator to display.
  final QlzLoadingType type;

  /// The color of the loading indicator.
  final Color? color;

  /// The size of the loading indicator.
  final double size;

  /// The message to display.
  final String? message;

  /// The style of the message text.
  final TextStyle? messageStyle;

  /// Whether to show the message above the indicator.
  final bool messageOnTop;

  /// The spacing between the message and the indicator.
  final double spacing;

  /// The padding around the loading state.
  final EdgeInsetsGeometry padding;

  /// Whether to show the overlay.
  final bool overlay;

  /// The color of the overlay.
  final Color? overlayColor;

  /// The width of the skeleton (for skeleton type).
  final double? skeletonWidth;

  /// The height of the skeleton (for skeleton type).
  final double? skeletonHeight;

  /// The border radius of the skeleton (for skeleton type).
  final BorderRadius? skeletonBorderRadius;

  const QlzLoadingState({
    super.key,
    this.type = QlzLoadingType.circular,
    this.color,
    this.size = 48,
    this.message,
    this.messageStyle,
    this.messageOnTop = false,
    this.spacing = 16,
    this.padding = const EdgeInsets.all(24),
    this.overlay = false,
    this.overlayColor,
    this.skeletonWidth,
    this.skeletonHeight,
    this.skeletonBorderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final effectiveColor = color ?? AppColors.primary;
    final effectiveOverlayColor = overlayColor ??
        (isDarkMode
            ? Colors.black.withOpacity(0.7)
            : Colors.white.withOpacity(0.7));

    // Build the loading indicator
    Widget loadingIndicator = _buildLoadingIndicator(context, effectiveColor);

    // Add message if provided
    if (message != null) {
      final messageText = Text(
        message!,
        style: messageStyle ??
            theme.textTheme.bodyMedium?.copyWith(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
        textAlign: TextAlign.center,
      );

      loadingIndicator = messageOnTop
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                messageText,
                SizedBox(height: spacing),
                loadingIndicator,
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                loadingIndicator,
                SizedBox(height: spacing),
                messageText,
              ],
            );
    }

    // Add padding
    loadingIndicator = Padding(
      padding: padding,
      child: loadingIndicator,
    );

    // Center the indicator
    loadingIndicator = Center(child: loadingIndicator);

    // Add overlay if needed
    if (overlay) {
      return Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: effectiveOverlayColor,
            ),
          ),
          loadingIndicator,
        ],
      );
    }

    return loadingIndicator;
  }

  Widget _buildLoadingIndicator(BuildContext context, Color color) {
    switch (type) {
      case QlzLoadingType.circular:
        return SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        );

      case QlzLoadingType.linear:
        return SizedBox(
          width: size * 5,
          height: size / 4,
          child: LinearProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(color),
            backgroundColor: color.withOpacity(0.3),
          ),
        );

      case QlzLoadingType.pulse:
        return _PulseLoadingIndicator(
          size: size,
          color: color,
        );

      case QlzLoadingType.skeleton:
        return _SkeletonLoadingIndicator(
          width: skeletonWidth,
          height: skeletonHeight,
          borderRadius: skeletonBorderRadius,
        );
    }
  }
}

/// A pulsing loading animation
class _PulseLoadingIndicator extends StatefulWidget {
  final double size;
  final Color color;

  const _PulseLoadingIndicator({
    required this.size,
    required this.color,
  });

  @override
  State<_PulseLoadingIndicator> createState() => _PulseLoadingIndicatorState();
}

class _PulseLoadingIndicatorState extends State<_PulseLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withOpacity(0.3),
          ),
          child: Center(
            child: Container(
              width: widget.size * _animation.value,
              height: widget.size * _animation.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withOpacity(_animation.value),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A skeleton loading placeholder
class _SkeletonLoadingIndicator extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const _SkeletonLoadingIndicator({
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  State<_SkeletonLoadingIndicator> createState() =>
      _SkeletonLoadingIndicatorState();
}

class _SkeletonLoadingIndicatorState extends State<_SkeletonLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width ?? 200,
          height: widget.height ?? 20,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
              colors: [
                isDarkMode ? const Color(0xFF1A1D3D) : Colors.grey.shade300,
                isDarkMode ? const Color(0xFF2C2D4A) : Colors.grey.shade100,
                isDarkMode ? const Color(0xFF1A1D3D) : Colors.grey.shade300,
              ],
            ),
          ),
        );
      },
    );
  }
}
