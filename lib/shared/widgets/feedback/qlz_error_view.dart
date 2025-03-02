// // lib/shared/widgets/feedback/qlz_error_view.dart

// import 'package:flutter/material.dart';
// import 'package:qlz_flash_cards_ui/config/app_colors.dart';

// final class QlzErrorView extends StatelessWidget {
//   final String? title;
//   final String message;
//   final VoidCallback? onRetry;
//   final String retryText;
//   final IconData icon;

//   const QlzErrorView({
//     super.key,
//     this.title = 'Đã xảy ra lỗi',
//     required this.message,
//     this.onRetry,
//     this.retryText = 'Thử lại',
//     this.icon = Icons.error_outline,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               icon,
//               color: AppColors.error,
//               size: 48,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               title!,
//               style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               message,
//               style: const TextStyle(color: Color.fromRGBO(255, 255, 255, 0.7)),
//               textAlign: TextAlign.center,
//             ),
//             if (onRetry != null) ...[
//               const SizedBox(height: 24),
//               ElevatedButton(
//                 onPressed: onRetry,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primary,
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 24,
//                     vertical: 12,
//                   ),
//                 ),
//                 child: Text(retryText),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
// lib/shared/widgets/feedback/qlz_error_view.dart

import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';

/// A widget to display error messages with retry functionality.
final class QlzErrorView extends StatelessWidget {
  /// The error message to display.
  final String message;

  /// The callback when the retry button is pressed.
  final VoidCallback? onRetry;

  /// The icon to display.
  final IconData icon;

  /// The color of the icon.
  final Color? iconColor;

  /// The size of the icon.
  final double iconSize;

  /// The style of the error message.
  final TextStyle? messageStyle;

  /// The label for the retry button.
  final String retryLabel;

  /// Whether to show the retry button.
  final bool showRetryButton;

  /// Additional padding around the error view.
  final EdgeInsetsGeometry padding;

  const QlzErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
    this.iconColor,
    this.iconSize = 72,
    this.messageStyle,
    this.retryLabel = 'Thử lại',
    this.showRetryButton = true,
    this.padding = const EdgeInsets.all(24),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final effectiveIconColor =
        iconColor ?? (isDarkMode ? AppColors.error : AppColors.error);

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
              color: effectiveIconColor,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: messageStyle ??
                  theme.textTheme.bodyLarge?.copyWith(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
              textAlign: TextAlign.center,
            ),
            if (showRetryButton && onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryLabel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
