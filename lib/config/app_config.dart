// lib/config/app_config.dart

import 'package:flutter/material.dart';

sealed class ApiConfig {
  static const baseUrl = 'https://api.example.com';
  static const version = 'v1';

  static const timeouts = (
    connection: Duration(seconds: 30),
    receive: Duration(seconds: 30),
  );

  static const endpoints = _ApiEndpoints();
}

final class _ApiEndpoints {
  const _ApiEndpoints();

  final auth = '/auth';
  final users = '/users';
  final folders = '/folders';
  final modules = '/study-modules';
  final vocabularies = '/vocabularies';
  final quiz = '/quiz-tests';
}

sealed class AppConfig {
  // App Info
  static const appName = 'Flash Cards App';
  static const packageName = 'com.example.flashcards';

  // Features Flags
  static const features = (
    enableLogging: true,
    enableCache: true,
    enableAnalytics: true,
  );

  // App Settings
  static const defaultLanguage = 'en';
  static const supportedLanguages = ['en', 'vi'];

  static const defaultThemeMode = ThemeMode.system;

  // Cache Settings
  static const cache = (
    maxAge: Duration(days: 7),
    maxSize: 50 * 1024 * 1024, // 50MB
  );

  // Pagination
  static const pagination = (
    defaultSize: 20,
    maxSize: 50,
    loadMoreThreshold: 3,
  );

  // Study Settings
  static const study = (
    minWordsPerSession: 5,
    maxWordsPerSession: 20,
    defaultSessionDuration: Duration(minutes: 15),
  );
}

enum Environment {
  development,
  staging,
  production;

  bool get isDevelopment => this == Environment.development;
  bool get isStaging => this == Environment.staging;
  bool get isProduction => this == Environment.production;
}

final class BuildConfig {
  const BuildConfig._();

  static const environment = Environment.development;

  static String get apiUrl => switch (environment) {
        Environment.development =>
          'http://localhost:8080/api/${ApiConfig.version}',
        Environment.staging =>
          'https://staging-api.example.com/api/${ApiConfig.version}',
        Environment.production =>
          'https://api.example.com/api/${ApiConfig.version}',
      };

  static Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'x-api-version': ApiConfig.version,
      };
}

sealed class HttpStatus {
  // Success Responses
  static const ok = 200;
  static const created = 201;
  static const accepted = 202;
  static const noContent = 204;

  // Client Errors
  static const badRequest = 400;
  static const unauthorized = 401;
  static const forbidden = 403;
  static const notFound = 404;

  // Server Errors
  static const serverError = 500;
}

sealed class StorageKeys {
  static const auth = _AuthStorageKeys();
  static const settings = _SettingsStorageKeys();
  static const cache = _CacheStorageKeys();
}

final class _AuthStorageKeys {
  const _AuthStorageKeys();

  final token = 'auth_token';
  final userId = 'user_id';
  final userEmail = 'user_email';
}

final class _SettingsStorageKeys {
  const _SettingsStorageKeys();

  final darkMode = 'dark_mode';
  final language = 'language';
}

final class _CacheStorageKeys {
  const _CacheStorageKeys();

  final lastSync = 'last_sync';
  final userCache = 'user_cache';
}

sealed class ApiResponseKeys {
  // Response Structure
  static const data = 'data';
  static const message = 'message';
  static const error = 'error';
  static const status = 'status';

  // Auth
  static const token = 'token';

  // Pagination
  static const pagination = (
    items: 'total_items',
    page: 'current_page',
    pages: 'total_pages',
  );
}
