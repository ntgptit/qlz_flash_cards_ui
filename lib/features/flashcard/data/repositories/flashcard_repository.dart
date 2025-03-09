import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/data/models/flashcard_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/study_progress.dart';

/// Repository for handling flashcard data and study progress
class FlashcardRepository {
  final Dio _dio;
  final SharedPreferences _prefs;
  
  // Cache keys for local storage
  static const String _flashcardsPrefix = 'flashcards_';
  static const String _progressPrefix = 'progress_';
  static const String _difficultyPrefix = 'difficulty_';
  static const String _lastSyncKey = 'flashcards_last_sync';
  
  // Flag for using mock data (development mode)
  final bool _useMockData = true;

  /// Creates a FlashcardRepository instance
  FlashcardRepository(this._dio, this._prefs);

  /// Fetches flashcards for a specific module
  Future<List<Flashcard>> getFlashcards({String? moduleId, bool forceRefresh = false}) async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 800));
      return _getMockFlashcards();
    }
    
    try {
      // Check if valid cache exists and we're not forcing a refresh
      if (moduleId != null && !forceRefresh && _isCacheValid()) {
        final cacheKey = '$_flashcardsPrefix$moduleId';
        final cachedData = _prefs.getString(cacheKey);
        
        if (cachedData != null) {
          try {
            final List<dynamic> decoded = jsonDecode(cachedData) as List<dynamic>;
            return decoded.map((json) => Flashcard.fromJson(json)).toList();
          } catch (e) {
            debugPrint('Error decoding cached flashcards: $e');
          }
        }
      }
      
      // Fetch from API if no cache or force refresh
      final String endpoint = moduleId != null 
          ? '/api/modules/$moduleId/flashcards'
          : '/api/flashcards';
      
      final response = await _dio.get(endpoint);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        final flashcards = data.map((json) => Flashcard.fromJson(json)).toList();
        
        // Cache the fetched data if module ID is provided
        if (moduleId != null) {
          try {
            final cacheKey = '$_flashcardsPrefix$moduleId';
            await _prefs.setString(cacheKey, jsonEncode(flashcards.map((e) => e.toJson()).toList()));
            await _prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
          } catch (e) {
            debugPrint('Error caching flashcards: $e');
          }
        }
        
        return flashcards;
      } else {
        throw Exception('Failed to load flashcards: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching flashcards: $e');
      
      // Try to use cached data if available and module ID is provided
      if (moduleId != null) {
        final cacheKey = '$_flashcardsPrefix$moduleId';
        final cachedData = _prefs.getString(cacheKey);
        
        if (cachedData != null) {
          try {
            final List<dynamic> decoded = jsonDecode(cachedData) as List<dynamic>;
            return decoded.map((json) => Flashcard.fromJson(json)).toList();
          } catch (e) {
            debugPrint('Error using cached flashcards: $e');
          }
        }
      }
      
      rethrow;
    }
  }

  /// Marks a flashcard as difficult or not difficult
  Future<bool> toggleDifficulty(String flashcardId, bool isDifficult) async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      final key = '$_difficultyPrefix$flashcardId';
      return _prefs.setBool(key, isDifficult);
    }
    
    try {
      final response = await _dio.put(
        '/api/flashcards/$flashcardId/difficulty',
        data: {'isDifficult': isDifficult},
      );
      
      if (response.statusCode == 200) {
        // Cache the preference locally
        final key = '$_difficultyPrefix$flashcardId';
        await _prefs.setBool(key, isDifficult);
        return true;
      } else {
        throw Exception('Failed to update difficulty: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error updating difficulty: $e');
      // Still try to save locally even if API fails
      final key = '$_difficultyPrefix$flashcardId';
      return _prefs.setBool(key, isDifficult);
    }
  }

  /// Gets the difficulty status of a flashcard
  Future<bool> getFlashcardDifficulty(String flashcardId) async {
    final key = '$_difficultyPrefix$flashcardId';
    return _prefs.getBool(key) ?? false;
  }

  /// Saves study progress for a module
  Future<bool> saveStudyProgress(String moduleId, StudyProgress progress) async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      final key = '$_progressPrefix$moduleId';
      return _prefs.setString(key, jsonEncode(progress.toJson()));
    }
    
    try {
      final response = await _dio.post(
        '/api/modules/$moduleId/progress',
        data: progress.toJson(),
      );
      
      if (response.statusCode == 200) {
        // Cache the progress locally
        final key = '$_progressPrefix$moduleId';
        await _prefs.setString(key, jsonEncode(progress.toJson()));
        return true;
      } else {
        throw Exception('Failed to save progress: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error saving progress: $e');
      // Still try to save locally even if API fails
      final key = '$_progressPrefix$moduleId';
      return _prefs.setString(key, jsonEncode(progress.toJson()));
    }
  }

  /// Gets study progress for a module
  Future<StudyProgress?> getStudyProgress(String moduleId) async {
    final key = '$_progressPrefix$moduleId';
    final progressData = _prefs.getString(key);
    
    if (progressData != null) {
      try {
        return StudyProgress.fromJson(jsonDecode(progressData));
      } catch (e) {
        debugPrint('Error parsing study progress: $e');
        return null;
      }
    }
    
    if (_useMockData) {
      return null;
    }
    
    try {
      final response = await _dio.get('/api/modules/$moduleId/progress');
      
      if (response.statusCode == 200) {
        final progress = StudyProgress.fromJson(response.data);
        // Cache the progress locally
        await _prefs.setString(key, jsonEncode(progress.toJson()));
        return progress;
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching study progress: $e');
      return null;
    }
  }

  /// Checks if the cache is still valid
  bool _isCacheValid() {
    final lastSyncStr = _prefs.getString(_lastSyncKey);
    if (lastSyncStr == null) return false;
    
    try {
      final lastSync = DateTime.parse(lastSyncStr);
      final now = DateTime.now();
      final difference = now.difference(lastSync);
      // Consider cache valid if less than 1 hour old
      return difference.inHours < 1;
    } catch (e) {
      debugPrint('Error parsing last sync date: $e');
      return false;
    }
  }

  /// Generates mock flashcards for development
  List<Flashcard> _getMockFlashcards() {
    final List<Flashcard> flashcards = [];
    final List<Map<String, String>> koreanWords = [
      {'term': '사과', 'definition': 'Quả táo', 'example': '나는 사과를 좋아해요.'},
      {'term': '바나나', 'definition': 'Quả chuối', 'example': '바나나는 노란색이에요.'},
      {'term': '오렌지', 'definition': 'Quả cam', 'example': '오렌지 주스를 마셔요.'},
      {'term': '포도', 'definition': 'Quả nho', 'example': '포도는 달아요.'},
      {'term': '딸기', 'definition': 'Quả dâu tây', 'example': '딸기가 맛있어요.'},
      {'term': '수박', 'definition': 'Quả dưa hấu', 'example': '여름에 수박을 먹어요.'},
      {'term': '파인애플', 'definition': 'Quả dứa', 'example': '파인애플은 노란색이에요.'},
      {'term': '망고', 'definition': 'Quả xoài', 'example': '망고는 달고 맛있어요.'},
      {'term': '키위', 'definition': 'Quả kiwi', 'example': '키위는 갈색이에요.'},
      {'term': '복숭아', 'definition': 'Quả đào', 'example': '복숭아는 달아요.'},
    ];
    
    for (int i = 0; i < 10; i++) {
      final wordData = koreanWords[i % koreanWords.length];
      flashcards.add(
        Flashcard(
          id: 'flashcard-$i',
          term: wordData['term']!,
          definition: wordData['definition']!,
          example: wordData['example'],
          isDifficult: i % 5 == 0, // Every 5th card is difficult
          order: i,
        ),
      );
    }
    
    return flashcards;
  }
}