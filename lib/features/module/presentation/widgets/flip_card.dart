import 'dart:math';

import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/cards/qlz_card.dart';

class FlipCard extends StatelessWidget {
  final bool isFlipped;
  final Widget frontWidget;
  final Widget backWidget;
  final Duration animationDuration;

  const FlipCard({
    super.key,
    required this.isFlipped,
    required this.frontWidget,
    required this.backWidget,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(
        begin: 0,
        end: isFlipped ? pi : 0,
      ),
      duration: animationDuration,
      builder: (context, double value, child) {
        // Front face disappears at 90 degrees, back face appears after 90 degrees
        final showFrontFace = value < (pi / 2);

        return QlzCard(
          margin: const EdgeInsets.all(20),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(value),
            child: showFrontFace
                ? frontWidget
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi),
                    child: backWidget,
                  ),
          ),
        );
      },
    );
  }
}
