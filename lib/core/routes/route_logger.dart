import 'package:flutter/material.dart';

/// Quản lý logging cho navigation.
class RouteLogger {
  static BuildContext? _context;

  static BuildContext get context =>
      _context ?? (throw Exception('Context not set'));

  static void setContext(BuildContext context) {
    _context = context;
  }

  static void logNavigation(RouteSettings settings) {
    debugPrint('🧭 Navigating to route: ${settings.name}');
    if (settings.arguments != null) {
      debugPrint('  - Arguments: ${settings.arguments}');
    }
  }

  static void logError(
      String? routeName, dynamic error, StackTrace stackTrace) {
    debugPrint('❌ Error generating route $routeName: $error');
    debugPrint('Stack trace: $stackTrace');
  }
}
