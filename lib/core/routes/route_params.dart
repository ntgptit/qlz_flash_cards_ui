import 'package:flutter/material.dart';

import '../../features/flashcard/data/models/flashcard_model.dart';

/// Quản lý tham số route một cách type-safe.
class RouteParams {
  final String routeName;
  final Map<String, dynamic> params;

  RouteParams({required this.routeName, this.params = const {}});

  factory RouteParams.fromSettings(RouteSettings settings) {
    final args = settings.arguments;
    if (args is Map<String, dynamic>) {
      return RouteParams(routeName: settings.name ?? '', params: args);
    }
    return RouteParams(routeName: settings.name ?? '');
  }

  Map<String, dynamic> toMap() => params;

  String getString(String key, [String defaultValue = '']) {
    final value = params[key];
    return value is String ? value : (value?.toString() ?? defaultValue);
  }

  int getInt(String key, [int defaultValue = 0]) {
    final value = params[key];
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  bool getBool(String key, [bool defaultValue = false]) {
    final value = params[key];
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    if (value is num) return value != 0;
    return defaultValue;
  }

  List<Flashcard> getFlashcards(String key) {
    final value = params[key];
    if (value is List<Flashcard>) return value;
    if (value is List) return value.whereType<Flashcard>().toList();
    return [];
  }

  T getEnum<T>(String key, List<T> values, T defaultValue) {
    final value = params[key];
    if (value is T) return value;
    if (value is int && value >= 0 && value < values.length) {
      return values[value];
    }
    if (value is String) {
      final index = values.indexWhere((e) =>
          e.toString().split('.').last.toLowerCase() == value.toLowerCase());
      if (index >= 0) return values[index];
    }
    return defaultValue;
  }
}
