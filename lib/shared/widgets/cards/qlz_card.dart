// lib/shared/widgets/cards/qlz_card.dart

import 'package:flutter/material.dart';

/// Possible elevation levels for QlzCard
sealed class QlzCardElevation {
  const QlzCardElevation._();

  static const none = _QlzCardElevationNone();
  static const low = _QlzCardElevationLow();
  static const medium = _QlzCardElevationMedium();
  static const high = _QlzCardElevationHigh();
}

final class _QlzCardElevationNone extends QlzCardElevation {
  const _QlzCardElevationNone() : super._();
}

final class _QlzCardElevationLow extends QlzCardElevation {
  const _QlzCardElevationLow() : super._();
}

final class _QlzCardElevationMedium extends QlzCardElevation {
  const _QlzCardElevationMedium() : super._();
}

final class _QlzCardElevationHigh extends QlzCardElevation {
  const _QlzCardElevationHigh() : super._();
}

/// A customizable card component for the Quizlet-like application.
///
/// This card is designed to display flashcards, study items, and other
/// content that needs to be contained within a card-like surface.
final class QlzCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final QlzCardElevation elevation;
  final bool hasBorder;
  final BorderRadius? borderRadius;
  final bool isSelected;
  final bool isDisabled;
  final bool isLoading;
  final Widget? header;
  final Widget? footer;
  final CrossAxisAlignment crossAxisAlignment;
  final double? width;
  final double? height;

  const QlzCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.elevation = QlzCardElevation.none,
    this.hasBorder = true,
    this.borderRadius,
    this.isSelected = false,
    this.isDisabled = false,
    this.isLoading = false,
    this.header,
    this.footer,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultBorderRadius = BorderRadius.circular(12);

    final Widget cardContent = Padding(
      padding: padding ?? const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (header != null) ...[
            header!,
            const SizedBox(height: 12),
          ],
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            )
          else
            child,
          if (footer != null) ...[
            const SizedBox(height: 12),
            footer!,
          ],
        ],
      ),
    );

    final Widget cardWithInk = Material(
      color: backgroundColor ?? const Color(0xFF12113A),
      borderRadius: borderRadius ?? defaultBorderRadius,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: borderRadius ?? defaultBorderRadius,
        child: cardContent,
      ),
    );

    final Widget cardWithBorder = Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? defaultBorderRadius,
        border: hasBorder
            ? Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : Colors.white.withOpacity(0.1),
                width: isSelected ? 2.0 : 1.0,
              )
            : null,
      ),
      child: cardWithInk,
    );

    Widget finalCard = hasBorder ? cardWithBorder : cardWithInk;

    if (margin != null) {
      finalCard = Padding(
        padding: margin!,
        child: finalCard,
      );
    }

    if (width != null || height != null) {
      finalCard = SizedBox(
        width: width,
        height: height,
        child: finalCard,
      );
    }

    return finalCard;
  }
}
