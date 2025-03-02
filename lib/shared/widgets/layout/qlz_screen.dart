// lib/shared/widgets/layout/qlz_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';

/// A wrapper widget for screens with consistent padding and background.
/// Handles safe area and ensures compatibility with multiple devices.
final class QlzScreen extends StatelessWidget {
  /// The body content of the screen.
  final Widget child;

  /// Optional app bar to display at the top of the screen.
  final PreferredSizeWidget? appBar;

  /// Optional bottom navigation bar.
  final Widget? bottomNavigationBar;

  /// Optional floating action button.
  final Widget? floatingActionButton;

  /// The background color of the screen.
  final Color? backgroundColor;

  /// The padding to apply around the screen content.
  final EdgeInsetsGeometry padding;

  /// Whether to wrap the child with a ScrollView.
  final bool withScrollView;

  /// The system UI overlay style.
  final SystemUiOverlayStyle? systemUiOverlayStyle;

  /// Whether to apply safe area insets.
  final bool useSafeArea;

  /// Whether to apply safe area at the top.
  final bool safeAreaTop;

  /// Whether to apply safe area at the bottom.
  final bool safeAreaBottom;

  /// Whether to resize to avoid the keyboard.
  final bool resizeToAvoidBottomInset;

  const QlzScreen({
    super.key,
    required this.child,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(16),
    this.withScrollView = false,
    this.systemUiOverlayStyle,
    this.useSafeArea = true,
    this.safeAreaTop = true,
    this.safeAreaBottom = true,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = withScrollView
        ? SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: padding,
              child: child,
            ),
          )
        : Padding(
            padding: padding,
            child: child,
          );

    final body = useSafeArea
        ? SafeArea(
            top: safeAreaTop,
            bottom: safeAreaBottom,
            child: content,
          )
        : content;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemUiOverlayStyle ??
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                Theme.of(context).brightness == Brightness.dark
                    ? Brightness.light
                    : Brightness.dark,
            systemNavigationBarColor:
                Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkBackground
                    : AppColors.lightBackground,
            systemNavigationBarIconBrightness:
                Theme.of(context).brightness == Brightness.dark
                    ? Brightness.light
                    : Brightness.dark,
          ),
      child: Scaffold(
        appBar: appBar,
        body: body,
        backgroundColor: backgroundColor ??
            (Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkBackground
                : AppColors.lightBackground),
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: floatingActionButton,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      ),
    );
  }
}
