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

/// A flashcard component for displaying vocabulary terms and definitions.
final class QlzFlashcard extends StatefulWidget {
  final String term;
  final String definition;
  final String? example;
  final String? pronunciation;
  final String? imageUrl;
  final String? audioUrl;
  final VoidCallback? onFlip;
  final VoidCallback? onAudioPlay;
  final VoidCallback? onMarkAsDifficult;
  final bool isDifficult;
  final Widget? child;

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
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      constraints:
                          const BoxConstraints(minHeight: 200, maxHeight: 400),
                      padding: const EdgeInsets.all(24),
                      child: _side == QlzFlashcardSide.front
                          ? _buildFrontSide(theme)
                          : _buildBackSide(theme),
                    ),
                  ),
                  if (widget.child != null) widget.child!,
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFrontSide(ThemeData theme) {
    return Column(
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
            style: theme.textTheme.headlineMedium, textAlign: TextAlign.center),
        if (widget.pronunciation != null) ...[
          const SizedBox(height: 8),
          Text(widget.pronunciation!,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontStyle: FontStyle.italic),
              textAlign: TextAlign.center),
        ],
        if (widget.audioUrl != null) ...[
          const SizedBox(height: 16),
          IconButton(
              onPressed: widget.onAudioPlay, icon: const Icon(Icons.volume_up)),
        ],
      ],
    );
  }

  Widget _buildBackSide(ThemeData theme) {
    return Column(
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
    );
  }
}
