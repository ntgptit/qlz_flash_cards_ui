// lib/shared/widgets/feedback/qlz_snackbar.dart

import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';

/// Snackbar types for different contexts
enum QlzSnackbarType {
  info,
  success,
  error,
  warning,
}

/// A custom snackbar with various types (success, error, info)
/// and animation support.
sealed class QlzSnackbar {
  const QlzSnackbar._();

  /// Shows a snackbar with the provided message.
  static void show({
    required BuildContext context,
    required String message,
    QlzSnackbarType type = QlzSnackbarType.info,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onPressed,
    String? actionLabel,
    bool dismissible = true,
    Color? backgroundColor,
    TextStyle? messageStyle,
    EdgeInsetsGeometry? margin,
    double? elevation,
    bool showIcon = true,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Determine colors and icons based on type
    final (typeColor, typeIcon) = switch (type) {
      QlzSnackbarType.info => (AppColors.primary, Icons.info_outline),
      QlzSnackbarType.success => (
          AppColors.success,
          Icons.check_circle_outline
        ),
      QlzSnackbarType.error => (AppColors.error, Icons.error_outline),
      QlzSnackbarType.warning => (
          AppColors.warning,
          Icons.warning_amber_outlined
        ),
    };

    final bgColor = backgroundColor ??
        (isDarkMode ? const Color(0xFF1A1D3D) : theme.colorScheme.surface);

    final snackBar = SnackBar(
      content: Row(
        children: [
          if (showIcon) ...[
            Icon(
              typeIcon,
              color: typeColor,
              size: 24,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              message,
              style: messageStyle ??
                  TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
            ),
          ),
        ],
      ),
      duration: duration,
      backgroundColor: bgColor,
      margin: margin ?? const EdgeInsets.all(8),
      behavior: SnackBarBehavior.floating,
      elevation: elevation ?? 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: typeColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      action: (actionLabel != null || dismissible)
          ? SnackBarAction(
              label: actionLabel ?? 'Dismiss',
              textColor: typeColor,
              onPressed: onPressed ??
                  () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
            )
          : null,
    );

    // Show the snackbar
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Shows a success snackbar.
  static void success({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onPressed,
    String? actionLabel,
  }) {
    show(
      context: context,
      message: message,
      type: QlzSnackbarType.success,
      duration: duration,
      onPressed: onPressed,
      actionLabel: actionLabel,
    );
  }

  /// Shows an error snackbar.
  static void error({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onPressed,
    String? actionLabel,
  }) {
    show(
      context: context,
      message: message,
      type: QlzSnackbarType.error,
      duration: duration,
      onPressed: onPressed,
      actionLabel: actionLabel,
    );
  }

  /// Shows an info snackbar.
  static void info({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onPressed,
    String? actionLabel,
  }) {
    show(
      context: context,
      message: message,
      type: QlzSnackbarType.info,
      duration: duration,
      onPressed: onPressed,
      actionLabel: actionLabel,
    );
  }

  /// Shows a warning snackbar.
  static void warning({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onPressed,
    String? actionLabel,
  }) {
    show(
      context: context,
      message: message,
      type: QlzSnackbarType.warning,
      duration: duration,
      onPressed: onPressed,
      actionLabel: actionLabel,
    );
  }
}
