// lib/features/module/data/repositories/module_repository.dart
import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/data/models/flashcard_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/module_settings_model.dart';
import '../models/study_module_model.dart';

class ModuleRepository {
  final Dio _dio;
  final SharedPreferences _prefs;
  
  // Cache keys
  static const String _moduleListKey = 'module_list';
  static const String _moduleDetailPrefix = 'module_detail_';
  static const String _moduleSettingsPrefix = 'module_settings_';
  static const String _lastSyncKey = 'module_last_sync';
  
  // Mock data for development purpose
  final bool _useMockData = true;

  ModuleRepository(this._dio, this._prefs);

  // Fetch all study modules
  Future<List<StudyModule>> getStudyModules({bool forceRefresh = false}) async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 800));
      return _getMockModules();
    }
    
    try {
      if (!forceRefresh && _isCacheValid()) {
        final cachedData = _prefs.getString(_moduleListKey);
        if (cachedData != null) {
          try {
            final List<dynamic> decoded = jsonDecode(cachedData) as List<dynamic>;
            return decoded.map((json) => StudyModule.fromJson(json)).toList();
          } catch (e) {
            debugPrint('Error decoding cached modules: $e');
          }
        }
      }
      
      // Fetch from API
      final response = await _dio.get('/api/modules');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        final modules = data.map((json) => StudyModule.fromJson(json)).toList();
        
        // Cache the result
        try {
          await _prefs.setString(_moduleListKey, jsonEncode(modules.map((e) => e.toJson()).toList()));
          await _prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
        } catch (e) {
          debugPrint('Error caching modules: $e');
        }
        
        return modules;
      } else {
        throw Exception('Failed to load modules: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching modules: $e');
      
      // Try to use cached data if available
      final cachedData = _prefs.getString(_moduleListKey);
      if (cachedData != null) {
        try {
          final List<dynamic> decoded = jsonDecode(cachedData) as List<dynamic>;
          return decoded.map((json) => StudyModule.fromJson(json)).toList();
        } catch (e) {
          debugPrint('Error using cached data: $e');
        }
      }
      
      // If no cached data or error, rethrow
      rethrow;
    }
  }

  // Fetch study modules in a folder
  Future<List<StudyModule>> getStudyModulesByFolder(String folderId, {bool forceRefresh = false}) async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 800));
      return _getMockModulesByFolder(folderId);
    }
    
    try {
      // Fetch from API
      final response = await _dio.get('/api/folders/$folderId/modules');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => StudyModule.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load modules by folder: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching modules by folder: $e');
      rethrow;
    }
  }

  // Get a single module by ID
  Future<StudyModule> getStudyModuleById(String id, {bool forceRefresh = false}) async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return _getMockModuleById(id);
    }
    
    try {
      if (!forceRefresh) {
        final cacheKey = '$_moduleDetailPrefix$id';
        final cachedData = _prefs.getString(cacheKey);
        if (cachedData != null) {
          try {
            return StudyModule.fromJson(jsonDecode(cachedData) as Map<String, dynamic>);
          } catch (e) {
            debugPrint('Error decoding cached module: $e');
          }
        }
      }
      
      // Fetch from API
      final response = await _dio.get('/api/modules/$id');
      
      if (response.statusCode == 200) {
        final module = StudyModule.fromJson(response.data as Map<String, dynamic>);
        
        // Cache the result
        final cacheKey = '$_moduleDetailPrefix$id';
        try {
          await _prefs.setString(cacheKey, jsonEncode(module.toJson()));
        } catch (e) {
          debugPrint('Error caching module: $e');
        }
        
        return module;
      } else {
        throw Exception('Failed to load module: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching module: $e');
      
      // Try to use cached data if available
      final cacheKey = '$_moduleDetailPrefix$id';
      final cachedData = _prefs.getString(cacheKey);
      if (cachedData != null) {
        try {
          return StudyModule.fromJson(jsonDecode(cachedData) as Map<String, dynamic>);
        } catch (e) {
          debugPrint('Error using cached data: $e');
        }
      }
      
      // If no cached data or error, rethrow
      rethrow;
    }
  }

  // Create a new study module
  Future<StudyModule> createStudyModule(StudyModule module) async {
    if (_useMockData) {
      await Future.delayed(const Duration(seconds: 1));
      return module.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
      );
    }
    
    try {
      final response = await _dio.post(
        '/api/modules',
        data: module.toJson(),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final createdModule = StudyModule.fromJson(response.data as Map<String, dynamic>);
        
        // Update cache
        _updateModuleInCache(createdModule);
        
        return createdModule;
      } else {
        throw Exception('Failed to create module: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error creating module: $e');
      rethrow;
    }
  }

  // Update an existing study module
  Future<StudyModule> updateStudyModule(StudyModule module) async {
    if (_useMockData) {
      await Future.delayed(const Duration(seconds: 1));
      return module.copyWith(lastUpdatedAt: DateTime.now());
    }
    
    try {
      final response = await _dio.put(
        '/api/modules/${module.id}',
        data: module.toJson(),
      );
      
      if (response.statusCode == 200) {
        final updatedModule = StudyModule.fromJson(response.data as Map<String, dynamic>);
        
        // Update cache
        _updateModuleInCache(updatedModule);
        
        return updatedModule;
      } else {
        throw Exception('Failed to update module: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error updating module: $e');
      rethrow;
    }
  }

  // Delete a study module
  Future<bool> deleteStudyModule(String id) async {
    if (_useMockData) {
      await Future.delayed(const Duration(seconds: 1));
      return true;
    }
    
    try {
      final response = await _dio.delete('/api/modules/$id');
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        // Remove from cache
        final cacheKey = '$_moduleDetailPrefix$id';
        await _prefs.remove(cacheKey);
        
        // Update module list cache
        final moduleListCache = _prefs.getString(_moduleListKey);
        if (moduleListCache != null) {
          try {
            final List<dynamic> decoded = jsonDecode(moduleListCache) as List<dynamic>;
            final modules = decoded
                .map((json) => StudyModule.fromJson(json))
                .where((module) => module.id != id)
                .toList();
                
            await _prefs.setString(_moduleListKey, jsonEncode(modules.map((e) => e.toJson()).toList()));
          } catch (e) {
            debugPrint('Error updating module list cache: $e');
          }
        }
        
        return true;
      } else {
        throw Exception('Failed to delete module: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error deleting module: $e');
      rethrow;
    }
  }

  // Get module settings
  Future<ModuleSettings> getModuleSettings(String moduleId) async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return const ModuleSettings();
    }
    
    try {
      final cacheKey = '$_moduleSettingsPrefix$moduleId';
      final cachedData = _prefs.getString(cacheKey);
      if (cachedData != null) {
        try {
          return ModuleSettings.fromJson(jsonDecode(cachedData) as Map<String, dynamic>);
        } catch (e) {
          debugPrint('Error decoding cached settings: $e');
        }
      }
      
      // Fetch from API
      final response = await _dio.get('/api/modules/$moduleId/settings');
      
      if (response.statusCode == 200) {
        final settings = ModuleSettings.fromJson(response.data as Map<String, dynamic>);
        
        // Cache the result
        try {
          await _prefs.setString(cacheKey, jsonEncode(settings.toJson()));
        } catch (e) {
          debugPrint('Error caching settings: $e');
        }
        
        return settings;
      } else {
        throw Exception('Failed to load settings: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching settings: $e');
      return const ModuleSettings(); // Return default settings on error
    }
  }

  // Update module settings
  Future<ModuleSettings> updateModuleSettings(String moduleId, ModuleSettings settings) async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 800));
      return settings;
    }
    
    try {
      final response = await _dio.put(
        '/api/modules/$moduleId/settings',
        data: settings.toJson(),
      );
      
      if (response.statusCode == 200) {
        final updatedSettings = ModuleSettings.fromJson(response.data as Map<String, dynamic>);
        
        // Cache the result
        final cacheKey = '$_moduleSettingsPrefix$moduleId';
        try {
          await _prefs.setString(cacheKey, jsonEncode(updatedSettings.toJson()));
        } catch (e) {
          debugPrint('Error caching settings: $e');
        }
        
        return updatedSettings;
      } else {
        throw Exception('Failed to update settings: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error updating settings: $e');
      rethrow;
    }
  }

  // Helper method to update module in cache
  Future<void> _updateModuleInCache(StudyModule module) async {
    // Update detailed cache
    final detailCacheKey = '$_moduleDetailPrefix${module.id}';
    try {
      await _prefs.setString(detailCacheKey, jsonEncode(module.toJson()));
    } catch (e) {
      debugPrint('Error updating module cache: $e');
    }
    
    // Update list cache if exists
    final moduleListCache = _prefs.getString(_moduleListKey);
    if (moduleListCache != null) {
      try {
        final List<dynamic> decoded = jsonDecode(moduleListCache) as List<dynamic>;
        final modules = decoded.map((json) => StudyModule.fromJson(json)).toList();
        
        final index = modules.indexWhere((m) => m.id == module.id);
        if (index >= 0) {
          modules[index] = module;
        } else {
          modules.add(module);
        }
        
        await _prefs.setString(_moduleListKey, jsonEncode(modules.map((e) => e.toJson()).toList()));
      } catch (e) {
        debugPrint('Error updating module list cache: $e');
      }
    }
  }

  // Check if cache is still valid (less than 1 hour old)
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

  // Get mock data for development
  List<StudyModule> _getMockModules() {
    return [
      StudyModule(
        id: '1',
        title: 'Vitamin_Book2_Chapter4-2: Vocabulary',
        description: 'Từ vựng Tiếng Hàn chương 4-2',
        creatorName: 'giapnguyen1994',
        hasPlusBadge: true,
        termCount: 55,
        flashcards: _generateMockFlashcards(55),
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      StudyModule(
        id: '2',
        title: 'Section 4: 병원',
        description: 'Từ vựng về bệnh viện',
        creatorName: 'giapnguyen1994',
        hasPlusBadge: true,
        termCount: 88,
        flashcards: _generateMockFlashcards(88),
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      StudyModule(
        id: '3',
        title: 'Vitamin_Book2_Chapter1-1: Vocabulary',
        description: 'Từ vựng Tiếng Hàn chương 1-1',
        creatorName: 'giapnguyen1994',
        hasPlusBadge: false,
        termCount: 74,
        flashcards: _generateMockFlashcards(74),
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      StudyModule(
        id: '4',
        title: 'TOPIK I - Luyện nghe cấp độ 1-2',
        description: 'Tài liệu luyện nghe thi TOPIK I',
        creatorName: 'korean_teacher',
        hasPlusBadge: true,
        termCount: 120,
        flashcards: _generateMockFlashcards(120),
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
    ];
  }

  // Get mock modules by folder
  List<StudyModule> _getMockModulesByFolder(String folderId) {
    return List.generate(
      4,
      (index) => StudyModule(
        id: 'folder-$folderId-module-${index + 1}',
        title: 'Section ${index + 1}: Chủ đề ${index + 1}',
        description: 'Mô tả cho học phần ${index + 1}',
        creatorName: 'giapnguyen1994',
        hasPlusBadge: index % 2 == 0,
        termCount: 50 + index,
        flashcards: _generateMockFlashcards(50 + index),
        createdAt: DateTime.now().subtract(Duration(days: index * 5)),
      ),
    );
  }

  // Get a mock module by ID
  StudyModule _getMockModuleById(String id) {
    final allModules = _getMockModules();
    final module = allModules.firstWhere(
      (module) => module.id == id,
      orElse: () => StudyModule(
        id: id,
        title: 'Vitamin_Book2_Chapter4-2: Vocabulary',
        description: 'Từ vựng Tiếng Hàn chương 4-2',
        creatorName: 'giapnguyen1994',
        hasPlusBadge: true,
        termCount: 55,
        flashcards: _generateMockFlashcards(55),
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    );
    
    return module;
  }

  // Generate mock flashcards
  List<Flashcard> _generateMockFlashcards(int count) {
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
    
    for (int i = 0; i < count; i++) {
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