// lib/features/dashboard/data/repositories/dashboard_repository.dart

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../features/module/data/models/study_module_model.dart';
import '../models/study_history_model.dart';
import '../models/study_stats_model.dart';

/// Repository for dashboard data, handling user study statistics and history
class DashboardRepository {
  final Dio _dio;
  final SharedPreferences _prefs;

  // Cache keys
  static const String _statsKey = 'dashboard_study_stats';
  static const String _historyKey = 'dashboard_study_history';
  static const String _recommendationsKey = 'dashboard_recommendations';
  static const String _lastSyncKey = 'dashboard_last_sync';

  // Flag for mock data (for development)
  final bool _useMockData = true;

  DashboardRepository(this._dio, this._prefs);

  /// Get user's study statistics
  Future<StudyStatsModel> getStudyStats({bool forceRefresh = false}) async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 800));
      return _getMockStudyStats();
    }

    try {
      // Use cache if available and not forcing refresh
      if (!forceRefresh && _isCacheValid()) {
        final cachedData = _prefs.getString(_statsKey);
        if (cachedData != null) {
          try {
            return StudyStatsModel.fromJson(
                jsonDecode(cachedData) as Map<String, dynamic>);
          } catch (e) {
            debugPrint('Error decoding cached stats: $e');
          }
        }
      }

      // Fetch from API
      final response = await _dio.get('/api/user/study-stats');

      if (response.statusCode == 200) {
        final stats =
            StudyStatsModel.fromJson(response.data as Map<String, dynamic>);

        // Cache the result
        await _prefs.setString(_statsKey, jsonEncode(stats.toJson()));
        await _prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());

        return stats;
      } else {
        throw Exception('Failed to load study stats: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching study stats: $e');

      // Try to use cached data if available
      final cachedData = _prefs.getString(_statsKey);
      if (cachedData != null) {
        try {
          return StudyStatsModel.fromJson(
              jsonDecode(cachedData) as Map<String, dynamic>);
        } catch (e) {
          debugPrint('Error using cached stats: $e');
        }
      }

      // Return empty stats if all else fails
      return StudyStatsModel.empty();
    }
  }

  /// Get user's study history
  Future<StudyHistoryModel> getStudyHistory({bool forceRefresh = false}) async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 800));
      return _getMockStudyHistory();
    }

    try {
      // Use cache if available and not forcing refresh
      if (!forceRefresh && _isCacheValid()) {
        final cachedData = _prefs.getString(_historyKey);
        if (cachedData != null) {
          try {
            return StudyHistoryModel.fromJson(
                jsonDecode(cachedData) as Map<String, dynamic>);
          } catch (e) {
            debugPrint('Error decoding cached history: $e');
          }
        }
      }

      // Fetch from API
      final response = await _dio.get('/api/user/study-history');

      if (response.statusCode == 200) {
        final history =
            StudyHistoryModel.fromJson(response.data as Map<String, dynamic>);

        // Cache the result
        await _prefs.setString(_historyKey, jsonEncode(history.toJson()));
        await _prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());

        return history;
      } else {
        throw Exception('Failed to load study history: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching study history: $e');

      // Try to use cached data if available
      final cachedData = _prefs.getString(_historyKey);
      if (cachedData != null) {
        try {
          return StudyHistoryModel.fromJson(
              jsonDecode(cachedData) as Map<String, dynamic>);
        } catch (e) {
          debugPrint('Error using cached history: $e');
        }
      }

      // Return empty history if all else fails
      return StudyHistoryModel.empty();
    }
  }

  /// Get recommended study modules
  Future<List<StudyModule>> getRecommendedModules(
      {bool forceRefresh = false}) async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 800));
      return _getMockRecommendedModules();
    }

    try {
      // Use cache if available and not forcing refresh
      if (!forceRefresh && _isCacheValid()) {
        final cachedData = _prefs.getString(_recommendationsKey);
        if (cachedData != null) {
          try {
            final List<dynamic> decoded =
                jsonDecode(cachedData) as List<dynamic>;
            return decoded
                .map((e) => StudyModule.fromJson(e as Map<String, dynamic>))
                .toList();
          } catch (e) {
            debugPrint('Error decoding cached recommendations: $e');
          }
        }
      }

      // Fetch from API
      final response = await _dio.get('/api/user/recommendations');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        final modules = data
            .map((e) => StudyModule.fromJson(e as Map<String, dynamic>))
            .toList();

        // Cache the result
        await _prefs.setString(_recommendationsKey,
            jsonEncode(modules.map((e) => e.toJson()).toList()));
        await _prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());

        return modules;
      } else {
        throw Exception(
            'Failed to load recommendations: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching recommendations: $e');

      // Try to use cached data if available
      final cachedData = _prefs.getString(_recommendationsKey);
      if (cachedData != null) {
        try {
          final List<dynamic> decoded = jsonDecode(cachedData) as List<dynamic>;
          return decoded
              .map((e) => StudyModule.fromJson(e as Map<String, dynamic>))
              .toList();
        } catch (e) {
          debugPrint('Error using cached recommendations: $e');
        }
      }

      // Return empty list if all else fails
      return [];
    }
  }

  /// Record a completed study session
  Future<bool> recordStudySession(StudySessionEntry session) async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));

      try {
        // Update local history with the new session
        final currentHistory = await getStudyHistory();
        final updatedHistory = currentHistory.addSession(session);

        // Update local stats
        final currentStats = await getStudyStats();
        final now = DateTime.now();
        final isToday = session.date.year == now.year &&
            session.date.month == now.month &&
            session.date.day == now.day;

        final updatedStats = currentStats.copyWith(
          totalTermsLearned:
              currentStats.totalTermsLearned + session.termsLearned,
          totalSessionsCompleted: currentStats.totalSessionsCompleted + 1,
          totalStudyTimeSeconds:
              currentStats.totalStudyTimeSeconds + session.durationSeconds,
          lastStudyDate: isToday ? now : currentStats.lastStudyDate,
        );

        // Cache the updated data
        await _prefs.setString(
            _historyKey, jsonEncode(updatedHistory.toJson()));
        await _prefs.setString(_statsKey, jsonEncode(updatedStats.toJson()));

        return true;
      } catch (e) {
        debugPrint('Error recording study session locally: $e');
        return false;
      }
    }

    try {
      // Send to API
      final response = await _dio.post(
        '/api/user/record-session',
        data: session.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Update local cache
        try {
          final currentHistory = await getStudyHistory();
          final updatedHistory = currentHistory.addSession(session);
          await _prefs.setString(
              _historyKey, jsonEncode(updatedHistory.toJson()));

          // Force refresh stats to get the updated version from the server
          await getStudyStats(forceRefresh: true);
        } catch (e) {
          debugPrint('Error updating local cache: $e');
        }

        return true;
      } else {
        throw Exception(
            'Failed to record study session: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error recording study session: $e');
      return false;
    }
  }

  /// Check if cache is still valid (less than 1 hour old)
  bool _isCacheValid() {
    final lastSyncStr = _prefs.getString(_lastSyncKey);
    if (lastSyncStr == null) return false;

    try {
      final lastSync = DateTime.parse(lastSyncStr);
      final now = DateTime.now();
      final difference = now.difference(lastSync);

      // Cache is valid if less than 1 hour old
      return difference.inHours < 1;
    } catch (e) {
      debugPrint('Error parsing last sync date: $e');
      return false;
    }
  }

  /// Get mock study stats for development
  StudyStatsModel _getMockStudyStats() {
    final now = DateTime.now();
    return StudyStatsModel(
      totalTermsLearned: 856,
      totalDifficultTerms: 124,
      totalSessionsCompleted: 57,
      totalStudyTimeSeconds: 103245, // About 28.7 hours
      currentStreak: 11,
      longestStreak: 14,
      lastStudyDate: DateTime(now.year, now.month, now.day - 1),
    );
  }

  /// Get mock study history for development
  StudyHistoryModel _getMockStudyHistory() {
    final now = DateTime.now();
    final dailyStudyTime = <String, int>{};
    final dailyTermsLearned = <String, int>{};
    final sessions = <StudySessionEntry>[];

    // Generate data for the past 30 days
    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      final dateString = _formatDateToString(date);

      // Create some realistic patterns in the data
      // Users study more on weekdays
      if (date.weekday <= 5) {
        dailyStudyTime[dateString] =
            1800 + (500 * date.weekday); // More study time on later weekdays
        dailyTermsLearned[dateString] = 20 + (5 * date.weekday);
      } else {
        // Weekend has lower study time
        dailyStudyTime[dateString] = 900;
        dailyTermsLearned[dateString] = 15;
      }

      // Skip some days to create gaps
      if (i == 12 || i == 13 || i == 20) {
        dailyStudyTime[dateString] = 0;
        dailyTermsLearned[dateString] = 0;
      }

      // Create sessions for days with study time
      if (dailyStudyTime[dateString]! > 0) {
        // Each day might have 1-3 sessions
        final sessionsCount = 1 + (date.day % 3);

        for (int j = 0; j < sessionsCount; j++) {
          final sessionTime = dailyStudyTime[dateString]! ~/ sessionsCount;
          final termsStudied = dailyTermsLearned[dateString]! ~/ sessionsCount;

          sessions.add(StudySessionEntry(
            date: date.add(Duration(
                hours: 8 + j * 4)), // Space sessions throughout the day
            moduleId: 'module-${j + 1}',
            moduleName: 'Tiếng Hàn Chương ${j + 1}',
            termsStudied: termsStudied + 5,
            termsLearned: termsStudied,
            durationSeconds: sessionTime,
          ));
        }
      }
    }

    return StudyHistoryModel(
      dailyStudyTime: dailyStudyTime,
      dailyTermsLearned: dailyTermsLearned,
      sessions: sessions,
    );
  }

  /// Get mock recommended modules for development
  List<StudyModule> _getMockRecommendedModules() {
    final now = DateTime.now();
    return [
      StudyModule(
        id: 'rec-1',
        title: 'Tiếng Hàn giao tiếp cơ bản',
        description: 'Từ vựng phổ biến dùng trong giao tiếp hàng ngày',
        creatorName: 'Korean Teacher',
        hasPlusBadge: true,
        termCount: 72,
        flashcards: const [],
        createdAt: now.subtract(const Duration(days: 15)),
      ),
      StudyModule(
        id: 'rec-2',
        title: 'Động từ bất quy tắc',
        description: 'Các động từ bất quy tắc trong tiếng Hàn',
        creatorName: 'Korean Academy',
        hasPlusBadge: true,
        termCount: 45,
        flashcards: const [],
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      StudyModule(
        id: 'rec-3',
        title: 'TOPIK I - Chủ đề gia đình',
        description: 'Từ vựng về chủ đề gia đình trong TOPIK cấp độ 1',
        creatorName: 'TOPIK Master',
        hasPlusBadge: false,
        termCount: 35,
        flashcards: const [],
        createdAt: now.subtract(const Duration(days: 5)),
      ),
    ];
  }

  /// Format a date to string (YYYY-MM-DD)
  String _formatDateToString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
