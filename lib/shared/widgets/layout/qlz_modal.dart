// lib/shared/widgets/layout/qlz_modal.dart

import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';

/// A class that provides customized modal dialogs and bottom sheets.
sealed class QlzModal {
  const QlzModal._();

  /// Shows a bottom sheet with the given content.
  static Future<T?> showBottomSheet<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    bool isDismissible = true,
    bool enableDrag = true,
    bool showCloseButton = true,
    Color? backgroundColor,
    double? height,
    EdgeInsets padding = const EdgeInsets.all(16),
    ShapeBorder? shape,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      backgroundColor: backgroundColor ??
          (isDarkMode ? const Color(0xFF12113A) : Colors.white),
      shape: shape ??
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
      builder: (context) {
        return Container(
          padding: padding,
          constraints: BoxConstraints(
            maxHeight: height ?? MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bottom sheet handle
              Center(
                child: Container(
                  height: 4,
                  width: 40,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: isDarkMode
                        ? const Color.fromRGBO(255, 255, 255, 0.2)
                        : const Color.fromRGBO(0, 0, 0, 0.2),
                  ),
                ),
              ),

              // Title and close button
              if (title != null || showCloseButton)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (title != null)
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                color: isDarkMode ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    if (showCloseButton)
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                  ],
                ),

              if (title != null || showCloseButton) const SizedBox(height: 16),

              // Content
              Flexible(child: child),
            ],
          ),
        );
      },
    );
  }

  /// Shows a dialog with the given content.
  static Future<T?> showDialog<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    bool isDismissible = true,
    bool showCloseButton = true,
    Color? backgroundColor,
    EdgeInsets padding = const EdgeInsets.all(24),
    List<Widget>? actions,
    ShapeBorder? shape,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: isDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      pageBuilder: (context, animation, secondaryAnimation) {
        return AlertDialog(
          backgroundColor: backgroundColor ??
              (isDarkMode ? const Color(0xFF12113A) : Colors.white),
          shape: shape ??
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
          title: title != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (showCloseButton)
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                )
              : null,
          contentPadding: padding,
          content: child,
          actions: actions,
        );
      },
      transitionDuration: const Duration(milliseconds: 250),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
            child: child,
          ),
        );
      },
    );
  }

  /// Shows a confirmation dialog with the given content.
  static Future<bool> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmColor,
    bool isDanger = false,
    Color? confirmTextColor,
  }) async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Xác định màu chữ cho button
    final effectiveConfirmTextColor = confirmTextColor ?? Colors.white;

    // Xác định màu nền cho button
    final effectiveConfirmColor =
        isDanger ? AppColors.error : (confirmColor ?? AppColors.primary);

    final result = await showDialog<bool>(
      context: context,
      isDismissible: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
      title: title,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            cancelText,
            style: TextStyle(
              color: isDarkMode
                  ? const Color.fromRGBO(255, 255, 255, 0.7)
                  : const Color.fromRGBO(0, 0, 0, 0.7),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: effectiveConfirmColor,
            foregroundColor: effectiveConfirmTextColor, // Ensure good contrast
          ),
          child: Text(confirmText),
        ),
      ],
    );

    return result ?? false;
  }

  /// Shows a confirmation dialog with custom styling for better visibility.
  /// This can be used as an alternative to showConfirmation when text contrast is an issue.
  static Future<bool> showContrastConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDanger = false,
  }) async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? const Color(0xFF12113A) : Colors.white;

    // Choose high contrast colors
    final confirmColor = isDanger ? AppColors.error : AppColors.primary;
    final confirmTextColor = _getReadableTextColor(confirmColor);

    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      pageBuilder: (context, _, __) {
        return AlertDialog(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                cancelText,
                style: TextStyle(
                  color: isDarkMode
                      ? const Color.fromRGBO(255, 255, 255, 0.7)
                      : const Color.fromRGBO(0, 0, 0, 0.7),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: confirmColor,
                foregroundColor: confirmTextColor,
              ),
              child: Text(confirmText),
            ),
          ],
        );
      },
      transitionDuration: const Duration(milliseconds: 250),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
            child: child,
          ),
        );
      },
    );

    return result ?? false;
  }

  /// Calculates a text color that will be readable against the given background color
  static Color _getReadableTextColor(Color backgroundColor) {
    // Calculate the perceptive luminance (perceived brightness)
    // This formula gives us a value between 0 and 1
    final luminance = (0.299 * backgroundColor.r +
            0.587 * backgroundColor.g + // Sử dụng .g thay vì .green
            0.114 * backgroundColor.b) /
        255;

    // Use white text on dark backgrounds and black text on light backgrounds
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
