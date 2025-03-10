import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:qlz_flash_cards_ui/core/utils/time_formatter.dart';
import 'package:qlz_flash_cards_ui/features/dashboard/data/models/study_history_model.dart';
import 'package:qlz_flash_cards_ui/features/dashboard/data/models/study_stats_model.dart';
import 'package:qlz_flash_cards_ui/features/module/data/models/study_module_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardRepository {
  final Dio _dio;
  final SharedPreferences _prefs;
  static const String _statsKey = 'dashboard_study_stats';
  static const String _historyKey = 'dashboard_study_history';
  static const String _recommendationsKey = 'dashboard_recommendations';
  static const String _lastSyncKey = 'dashboard_last_sync';
  final bool _useMockData = true;

  DashboardRepository(this._dio, this._prefs);

  Future<T> _fetchWithCache<T>({
    required String cacheKey,
    required String apiEndpoint,
    required T Function(dynamic) fromJson, // Thay đổi để hỗ trợ dynamic
    required T Function() mockData,
    required T emptyData,
    bool forceRefresh = false,
  }) async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 800));
      return mockData();
    }

    try {
      if (!forceRefresh && _isCacheValid()) {
        final cachedData = _prefs.getString(cacheKey);
        if (cachedData != null) {
          try {
            return fromJson(jsonDecode(cachedData));
          } catch (e) {
            debugPrint('Error decoding cached data for $cacheKey: $e');
          }
        }
      }

      final response = await _dio.get(apiEndpoint);
      if (response.statusCode == 200) {
        final data = fromJson(response.data);
        // Xử lý lưu cache dựa trên kiểu của T
        if (data is StudyStatsModel) {
          await _prefs.setString(cacheKey, jsonEncode(data.toJson()));
        } else if (data is StudyHistoryModel) {
          await _prefs.setString(cacheKey, jsonEncode(data.toJson()));
        } else if (data is List<StudyModule>) {
          await _prefs.setString(
              cacheKey, jsonEncode(data.map((e) => e.toJson()).toList()));
        } else {
          debugPrint('Unsupported type for caching: ${T.toString()}');
        }
        await _prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
        return data;
      } else {
        throw Exception(
            'Failed to load data from $apiEndpoint: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching data from $apiEndpoint: $e');
      final cachedData = _prefs.getString(cacheKey);
      if (cachedData != null) {
        try {
          return fromJson(jsonDecode(cachedData));
        } catch (e) {
          debugPrint('Error using cached data for $cacheKey: $e');
        }
      }
      return emptyData;
    }
  }

  Future<StudyStatsModel> getStudyStats({bool forceRefresh = false}) async {
    return _fetchWithCache(
      cacheKey: _statsKey,
      apiEndpoint: '/api/user/study-stats',
      fromJson: (json) =>
          StudyStatsModel.fromJson(json as Map<String, dynamic>),
      mockData: _getMockStudyStats,
      emptyData: StudyStatsModel.empty(),
      forceRefresh: forceRefresh,
    );
  }

  Future<StudyHistoryModel> getStudyHistory({bool forceRefresh = false}) async {
    return _fetchWithCache(
      cacheKey: _historyKey,
      apiEndpoint: '/api/user/study-history',
      fromJson: (json) =>
          StudyHistoryModel.fromJson(json as Map<String, dynamic>),
      mockData: _getMockStudyHistory,
      emptyData: StudyHistoryModel.empty(),
      forceRefresh: forceRefresh,
    );
  }

  Future<List<StudyModule>> getRecommendedModules(
      {bool forceRefresh = false}) async {
    return _fetchWithCache(
      cacheKey: _recommendationsKey,
      apiEndpoint: '/api/user/recommendations',
      fromJson: (json) => (json as List<dynamic>)
          .map((e) => StudyModule.fromJson(e as Map<String, dynamic>))
          .toList(),
      mockData: _getMockRecommendedModules,
      emptyData: [],
      forceRefresh: forceRefresh,
    );
  }

  Future<bool> recordStudySession(StudySessionEntry session) async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      try {
        final currentHistory = await getStudyHistory();
        final updatedHistory = currentHistory.addSession(session);
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
      final response = await _dio.post(
        '/api/user/record-session',
        data: session.toJson(),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final currentHistory = await getStudyHistory();
          final updatedHistory = currentHistory.addSession(session);
          await _prefs.setString(
              _historyKey, jsonEncode(updatedHistory.toJson()));
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

  bool _isCacheValid() {
    final lastSyncStr = _prefs.getString(_lastSyncKey);
    if (lastSyncStr == null) return false;
    try {
      final lastSync = DateTime.parse(lastSyncStr);
      final now = DateTime.now();
      final difference = now.difference(lastSync);
      return difference.inHours < 1;
    } catch (e) {
      debugPrint('Error parsing last sync date: $e');
      return false;
    }
  }

  StudyStatsModel _getMockStudyStats() {
    final now = DateTime.now();
    return StudyStatsModel(
      totalTermsLearned: 856,
      totalDifficultTerms: 124,
      totalSessionsCompleted: 57,
      totalStudyTimeSeconds: 103245,
      currentStreak: 11,
      longestStreak: 14,
      lastStudyDate: DateTime(now.year, now.month, now.day - 1),
    );
  }

  StudyHistoryModel _getMockStudyHistory() {
    final now = DateTime.now();
    final dailyStudyTime = <String, int>{};
    final dailyTermsLearned = <String, int>{};
    final sessions = <StudySessionEntry>[];
    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      final dateString = TimeFormatter.formatDateToString(date);
      if (date.weekday <= 5) {
        dailyStudyTime[dateString] = 1800 + (500 * date.weekday);
        dailyTermsLearned[dateString] = 20 + (5 * date.weekday);
      } else {
        dailyStudyTime[dateString] = 900;
        dailyTermsLearned[dateString] = 15;
      }
      if (i == 12 || i == 13 || i == 20) {
        dailyStudyTime[dateString] = 0;
        dailyTermsLearned[dateString] = 0;
      }
      if (dailyStudyTime[dateString]! > 0) {
        final sessionsCount = 1 + (date.day % 3);
        for (int j = 0; j < sessionsCount; j++) {
          final sessionTime = dailyStudyTime[dateString]! ~/ sessionsCount;
          final termsStudied = dailyTermsLearned[dateString]! ~/ sessionsCount;
          sessions.add(StudySessionEntry(
            date: date.add(Duration(hours: 8 + j * 4)),
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
}
