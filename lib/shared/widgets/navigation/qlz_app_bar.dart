// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:qlz_flash_cards_ui/config/app_colors.dart';

// /// A custom app bar with consistent styling for the app.
// final class QlzAppBar extends StatelessWidget implements PreferredSizeWidget {
//   /// The title of the app bar.
//   final String? title;

//   /// A widget to display as the title.
//   final Widget? titleWidget;

//   /// The leading widget (usually a back button).
//   final Widget? leading;

//   /// The list of actions to display at the right side.
//   final List<Widget>? actions;

//   /// The background color of the app bar.
//   final Color? backgroundColor;

//   /// The color of the app bar text and icons.
//   final Color? foregroundColor;

//   /// The elevation of the app bar.
//   final double elevation;

//   /// Whether to center the title.
//   final bool centerTitle;

//   /// The bottom widget of the app bar (e.g., TabBar).
//   final PreferredSizeWidget? bottom;

//   /// The system UI overlay style to apply.
//   final SystemUiOverlayStyle? systemOverlayStyle;

//   /// Whether to automatically add a back button.
//   final bool automaticallyImplyLeading;

//   /// The height of the app bar.
//   final double height;

//   /// Whether to show a border at the bottom.
//   final bool showBottomBorder;

//   /// The color of the bottom border.
//   final Color? bottomBorderColor;

//   /// Callback for when the back button is pressed.
//   final VoidCallback? onBackPressed;

//   const QlzAppBar({
//     super.key,
//     this.title,
//     this.titleWidget,
//     this.leading,
//     this.actions,
//     this.backgroundColor,
//     this.foregroundColor,
//     this.elevation = 0,
//     this.centerTitle = true,
//     this.bottom,
//     this.systemOverlayStyle,
//     this.automaticallyImplyLeading = true,
//     this.height = kToolbarHeight,
//     this.showBottomBorder = false,
//     this.bottomBorderColor,
//     this.onBackPressed,
//   }) : assert(title == null || titleWidget == null,
//             'Cannot provide both title and titleWidget');

//   /// Preferred size of the AppBar.
//   @override
//   Size get preferredSize => Size.fromHeight(
//         height +
//             (bottom?.preferredSize.height ?? 0) +
//             (showBottomBorder ? 1 : 0),
//       );

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDarkMode = theme.brightness == Brightness.dark;

//     final effectiveBackgroundColor = backgroundColor ??
//         (isDarkMode ? AppColors.darkBackground : AppColors.lightBackground);

//     final effectiveForegroundColor =
//         foregroundColor ?? (isDarkMode ? Colors.white : Colors.black);

//     final effectiveBottom = _buildBottomWidget(isDarkMode);

//     return AppBar(
//       title: titleWidget ??
//           (title != null
//               ? Text(title!, style: _titleTextStyle(effectiveForegroundColor))
//               : null),
//       leading: _buildLeadingWidget(context, effectiveForegroundColor),
//       actions: actions,
//       backgroundColor: effectiveBackgroundColor,
//       foregroundColor: effectiveForegroundColor,
//       elevation: elevation,
//       centerTitle: centerTitle,
//       bottom: effectiveBottom,
//       systemOverlayStyle:
//           systemOverlayStyle ?? _defaultSystemOverlayStyle(isDarkMode),
//       automaticallyImplyLeading: automaticallyImplyLeading,
//       toolbarHeight: height,
//     );
//   }

//   /// Builds the bottom widget if applicable.
//   PreferredSizeWidget? _buildBottomWidget(bool isDarkMode) {
//     if (bottom != null || showBottomBorder) {
//       return PreferredSize(
//         preferredSize: Size.fromHeight(
//             (bottom?.preferredSize.height ?? 0) + (showBottomBorder ? 1 : 0)),
//         child: Column(
//           children: [
//             if (bottom != null) bottom!,
//             if (showBottomBorder)
//               Divider(
//                 height: 1,
//                 thickness: 1,
//                 color: bottomBorderColor ??
//                     (isDarkMode ? AppColors.darkBorder : AppColors.lightBorder),
//               ),
//           ],
//         ),
//       );
//     }
//     return bottom;
//   }

//   /// Builds the leading widget.
//   Widget? _buildLeadingWidget(BuildContext context, Color foregroundColor) {
//     return switch (leading) {
//       Widget widget => widget,
//       _ when automaticallyImplyLeading && Navigator.of(context).canPop() =>
//         IconButton(
//           icon: Icon(Icons.arrow_back, color: foregroundColor),
//           onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
//         ),
//       _ => null,
//     };
//   }

//   /// Defines the title text style.
//   TextStyle _titleTextStyle(Color color) => TextStyle(
//         color: color,
//         fontWeight: FontWeight.bold,
//       );

//   /// Defines the default system overlay style.
//   SystemUiOverlayStyle _defaultSystemOverlayStyle(bool isDarkMode) =>
//       SystemUiOverlayStyle(
//         statusBarColor: Colors.transparent,
//         statusBarIconBrightness:
//             isDarkMode ? Brightness.light : Brightness.dark,
//       );
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';

/// A custom app bar with consistent styling for the app.
final class QlzAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// The title of the app bar.
  final String? title;

  /// A widget to display as the title.
  final Widget? titleWidget;

  /// The leading widget (usually a back button).
  final Widget? leading;

  /// The list of actions to display at the right side.
  final List<Widget>? actions;

  /// The background color of the app bar.
  final Color? backgroundColor;

  /// The color of the app bar text and icons.
  final Color? foregroundColor;

  /// The elevation of the app bar.
  final double elevation;

  /// Whether to center the title.
  final bool centerTitle;

  /// The bottom widget of the app bar (e.g., TabBar).
  final PreferredSizeWidget? bottom;

  /// The system UI overlay style to apply.
  final SystemUiOverlayStyle? systemOverlayStyle;

  /// Whether to automatically add a back button.
  final bool automaticallyImplyLeading;

  /// The height of the app bar.
  final double height;

  /// Whether to show a border at the bottom.
  final bool showBottomBorder;

  /// The color of the bottom border.
  final Color? bottomBorderColor;

  /// Callback for when the back button is pressed.
  final VoidCallback? onBackPressed;

  const QlzAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.centerTitle = true,
    this.bottom,
    this.systemOverlayStyle,
    this.automaticallyImplyLeading = true,
    this.height = kToolbarHeight,
    this.showBottomBorder = false,
    this.bottomBorderColor,
    this.onBackPressed,
  }) : assert(title == null || titleWidget == null,
            'Cannot provide both title and titleWidget');

  /// Preferred size of the AppBar.
  @override
  Size get preferredSize => Size.fromHeight(
        height +
            (bottom?.preferredSize.height ?? 0) +
            (showBottomBorder ? 1 : 0),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final effectiveBackgroundColor = backgroundColor ??
        (isDarkMode ? AppColors.darkBackground : AppColors.lightBackground);

    final effectiveForegroundColor =
        foregroundColor ?? (isDarkMode ? Colors.white : Colors.black);

    final effectiveBottom = _buildBottomWidget(isDarkMode);

    return AppBar(
      title: titleWidget ??
          (title != null
              ? AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                  child: Text(
                    title!,
                    key: ValueKey<String>(title!),
                    style: _titleTextStyle(effectiveForegroundColor),
                  ),
                )
              : null),
      leading: _buildLeadingWidget(context, effectiveForegroundColor),
      actions: actions,
      backgroundColor: effectiveBackgroundColor,
      foregroundColor: effectiveForegroundColor,
      elevation: elevation,
      centerTitle: centerTitle,
      bottom: effectiveBottom,
      systemOverlayStyle:
          systemOverlayStyle ?? _defaultSystemOverlayStyle(isDarkMode),
      automaticallyImplyLeading: automaticallyImplyLeading,
      toolbarHeight: height,
    );
  }

  /// Builds the bottom widget if applicable.
  PreferredSizeWidget? _buildBottomWidget(bool isDarkMode) {
    if (bottom != null || showBottomBorder) {
      return PreferredSize(
        preferredSize: Size.fromHeight(
            (bottom?.preferredSize.height ?? 0) + (showBottomBorder ? 1 : 0)),
        child: Column(
          children: [
            if (bottom != null) bottom!,
            if (showBottomBorder)
              Divider(
                height: 1,
                thickness: 1,
                color: bottomBorderColor ??
                    (isDarkMode ? AppColors.darkBorder : AppColors.lightBorder),
              ),
          ],
        ),
      );
    }
    return bottom;
  }

  /// Builds the leading widget.
  Widget? _buildLeadingWidget(BuildContext context, Color foregroundColor) {
    return switch (leading) {
      Widget widget => widget,
      _ when automaticallyImplyLeading && Navigator.of(context).canPop() =>
        IconButton(
          icon: Icon(Icons.arrow_back, color: foregroundColor),
          onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
        ),
      _ => null,
    };
  }

  /// Defines the title text style.
  TextStyle _titleTextStyle(Color color) => TextStyle(
        color: color,
        fontWeight: FontWeight.bold,
      );

  /// Defines the default system overlay style.
  SystemUiOverlayStyle _defaultSystemOverlayStyle(bool isDarkMode) =>
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            isDarkMode ? Brightness.light : Brightness.dark,
      );
}
