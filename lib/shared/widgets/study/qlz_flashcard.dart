import 'dart:math';

import 'package:flutter/material.dart';

/// Represents the side of a flashcard
sealed class QlzFlashcardSide {
  const QlzFlashcardSide._();
  static const front = _QlzFlashcardSideFront();
  static const back = _QlzFlashcardSideBack();
}

final class _QlzFlashcardSideFront extends QlzFlashcardSide {
  const _QlzFlashcardSideFront() : super._();
}

final class _QlzFlashcardSideBack extends QlzFlashcardSide {
  const _QlzFlashcardSideBack() : super._();
}

/// Controller for QlzFlashcard to allow external control of the card
final class QlzFlashcardController {
  _QlzFlashcardState? _state;

  /// Attach state to this controller
  void _attach(_QlzFlashcardState state) {
    _state = state;
  }

  /// Detach state from this controller
  void _detach() {
    _state = null;
  }

  /// Flip the card programmatically
  void flip() {
    _state?._flip();
  }

  /// Check if the card is currently showing the front side
  bool get isShowingFront => _state?._side == QlzFlashcardSide.front;

  /// Check if the card is currently being animated (during flip)
  bool get isAnimating => _state?._controller.isAnimating ?? false;
}

/// A flashcard component for displaying vocabulary terms and definitions.
final class QlzFlashcard extends StatefulWidget {
  /// The term displayed on the front of the card
  final String term;

  /// The definition displayed on the back of the card
  final String definition;

  /// Optional example sentence
  final String? example;

  /// Optional pronunciation guide
  final String? pronunciation;

  /// Optional image URL
  final String? imageUrl;

  /// Optional audio URL
  final String? audioUrl;

  /// Callback when the card is flipped
  final VoidCallback? onFlip;

  /// Callback when audio button is pressed
  final VoidCallback? onAudioPlay;

  /// Callback when the card is marked as difficult
  final VoidCallback? onMarkAsDifficult;

  /// Whether the card is marked as difficult
  final bool isDifficult;

  /// Optional child widget to overlay on the card
  final Widget? child;

  /// Optional controller to control the card externally
  final QlzFlashcardController? controller;

  const QlzFlashcard({
    super.key,
    required this.term,
    required this.definition,
    this.example,
    this.pronunciation,
    this.imageUrl,
    this.audioUrl,
    this.onFlip,
    this.onAudioPlay,
    this.onMarkAsDifficult,
    this.isDifficult = false,
    this.child,
    this.controller,
  });

  @override
  State<QlzFlashcard> createState() => _QlzFlashcardState();
}

class _QlzFlashcardState extends State<QlzFlashcard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  QlzFlashcardSide _side = QlzFlashcardSide.front;

  @override
  void initState() {
    super.initState();
    // Attach controller if provided
    widget.controller?._attach(this);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -pi / 2), weight: 50.0),
      TweenSequenceItem(tween: Tween(begin: pi / 2, end: 0.0), weight: 50.0),
    ]).animate(_controller);

    _animation.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        setState(() {
          _side = (_side == QlzFlashcardSide.front)
              ? QlzFlashcardSide.back
              : QlzFlashcardSide.front;
        });
        widget.onFlip?.call();
      }
    });
  }

  @override
  void dispose() {
    // Detach controller if provided
    widget.controller?._detach();
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    if (_controller.isAnimating) return;
    _controller.status == AnimationStatus.dismissed
        ? _controller.forward()
        : _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: _controller.isAnimating ? null : _flip,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(_animation.value);

          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: widget.isDifficult
                      ? theme.colorScheme.error
                      : Colors.transparent,
                ),
              ),
              child: _side == QlzFlashcardSide.front
                  ? _buildFrontSide(theme)
                  : _buildBackSide(theme),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFrontSide(ThemeData theme) {
    return Stack(
      children: [
        Container(
          constraints: const BoxConstraints(minHeight: 200, maxHeight: 400),
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.imageUrl != null) ...[
                  Image.network(
                    widget.imageUrl!,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image),
                  ),
                  const SizedBox(height: 16),
                ],
                Text(widget.term,
                    style: theme.textTheme.headlineMedium,
                    textAlign: TextAlign.center),
                if (widget.pronunciation != null) ...[
                  const SizedBox(height: 8),
                  Text(widget.pronunciation!,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center),
                ],
              ],
            ),
          ),
        ),

        // Audio button
        Positioned(
          left: 16,
          top: 16,
          child: IconButton(
            icon: const Icon(Icons.volume_up_outlined),
            onPressed: widget.onAudioPlay,
            color: Colors.white.withOpacity(0.7),
          ),
        ),

        // Star button
        Positioned(
          right: 16,
          top: 16,
          child: IconButton(
            icon: Icon(
              widget.isDifficult ? Icons.star : Icons.star_border_outlined,
              color: widget.isDifficult
                  ? Colors.amber
                  : Colors.white.withOpacity(0.7),
            ),
            onPressed: widget.onMarkAsDifficult,
          ),
        ),

        if (widget.child != null) widget.child!,
      ],
    );
  }

  Widget _buildBackSide(ThemeData theme) {
    return Container(
      constraints: const BoxConstraints(minHeight: 200, maxHeight: 400),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(widget.definition,
              style: theme.textTheme.bodyLarge, textAlign: TextAlign.center),
          if (widget.example != null) ...[
            const SizedBox(height: 16),
            Text('"${widget.example!}"',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontStyle: FontStyle.italic),
                textAlign: TextAlign.center),
          ],
          const SizedBox(height: 24),
          IconButton(
            onPressed: widget.onMarkAsDifficult,
            icon: Icon(
              widget.isDifficult ? Icons.flag : Icons.flag_outlined,
              color: widget.isDifficult ? theme.colorScheme.error : null,
            ),
          ),
        ],
      ),
    );
  }
}
