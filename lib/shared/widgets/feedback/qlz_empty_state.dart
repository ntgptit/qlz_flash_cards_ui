// lib/shared/widgets/feedback/qlz_empty_state.dart

import 'package:flutter/material.dart';

/// A widget for displaying empty state with icon, title, message, and optional action.
final class QlzEmptyState extends StatelessWidget {
  /// The title displayed in the empty state.
  final String title;

  /// The message displayed in the empty state.
  final String message;

  /// The icon displayed in the empty state.
  final IconData icon;

  /// The size of the icon.
  final double iconSize;

  /// The color of the icon.
  final Color? iconColor;

  /// The action button's label.
  final String? actionLabel;

  /// The callback when the action button is pressed.
  final VoidCallback? onAction;

  /// The spacing between elements.
  final double spacing;

  /// The style of the title text.
  final TextStyle? titleStyle;

  /// The style of the message text.
  final TextStyle? messageStyle;

  /// The color of the action button.
  final Color? actionColor;

  /// Custom widget to display instead of the default elements.
  final Widget? customContent;

  /// Additional padding around the empty state.
  final EdgeInsetsGeometry padding;

  const QlzEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.hourglass_empty,
    this.iconSize = 72,
    this.iconColor,
    this.actionLabel,
    this.onAction,
    this.spacing = 16,
    this.titleStyle,
    this.messageStyle,
    this.actionColor,
    this.customContent,
    this.padding = const EdgeInsets.all(24),
  });

  /// Creates an empty state for items not found.
  factory QlzEmptyState.notFound({
    String title = 'No Results Found',
    String message = 'We couldn\'t find what you\'re looking for',
    String? actionLabel,
    VoidCallback? onAction,
    EdgeInsetsGeometry padding = const EdgeInsets.all(24),
  }) {
    return QlzEmptyState(
      title: title,
      message: message,
      icon: Icons.search_off,
      actionLabel: actionLabel,
      onAction: onAction,
      padding: padding,
    );
  }

  /// Creates an empty state for an error.
  factory QlzEmptyState.error({
    String title = 'Something Went Wrong',
    String message = 'An error occurred while trying to load data',
    String? actionLabel = 'Try Again',
    VoidCallback? onAction,
    EdgeInsetsGeometry padding = const EdgeInsets.all(24),
  }) {
    return QlzEmptyState(
      title: title,
      message: message,
      icon: Icons.error_outline,
      actionLabel: actionLabel,
      onAction: onAction,
      padding: padding,
    );
  }

  /// Creates an empty state for no data.
  factory QlzEmptyState.noData({
    String title = 'No Data Yet',
    String message = 'Create your first item to get started',
    String? actionLabel = 'Create',
    VoidCallback? onAction,
    EdgeInsetsGeometry padding = const EdgeInsets.all(24),
  }) {
    return QlzEmptyState(
      title: title,
      message: message,
      icon: Icons.note_add_outlined,
      actionLabel: actionLabel,
      onAction: onAction,
      padding: padding,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    if (customContent != null) {
      return Center(
        child: Padding(
          padding: padding,
          child: customContent,
        ),
      );
    }

    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: iconColor ??
                  (isDarkMode
                      ? Colors.white.withOpacity(0.5)
                      : Colors.black.withOpacity(0.5)),
            ),
            SizedBox(height: spacing),
            Text(
              title,
              style: titleStyle ??
                  theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacing / 2),
            Text(
              message,
              style: messageStyle ??
                  theme.textTheme.bodyMedium?.copyWith(
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.7)
                        : Colors.black.withOpacity(0.7),
                  ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: spacing),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: actionColor ?? theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
