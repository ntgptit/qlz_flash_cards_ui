// C:/Users/ntgpt/OneDrive/workspace/qlz_flash_cards_ui/lib/features/module/data/repositories/module_repository.dart
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/data/models/flashcard_model.dart';
import 'package:qlz_flash_cards_ui/features/module/data/models/module_settings_model.dart';
import 'package:qlz_flash_cards_ui/features/module/data/models/study_module_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

sealed class CacheKeys {
  static const moduleList = 'module_list';
  static const moduleDetailPrefix = 'module_detail_';
  static const moduleSettingsPrefix = 'module_settings_';
  static const lastSyncKey = 'module_last_sync';
  static const cacheExpiryPrefix = 'cache_expiry_';

  static String moduleDetail(String id) => '$moduleDetailPrefix$id';
  static String moduleSettings(String id) => '$moduleSettingsPrefix$id';
  static String folderModules(String folderId) =>
      '${moduleList}_folder_$folderId';
  static String cacheExpiry(String key) => '$cacheExpiryPrefix$key';
}

class ModuleException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  ModuleException(this.message, [this.stackTrace]);

  @override
  String toString() => message;
}

class NetworkTimeoutException extends ModuleException {
  NetworkTimeoutException(super.message);
}

class PermissionException extends ModuleException {
  PermissionException(super.message);
}

class ModuleRepository {
  final Dio _dio;
  final SharedPreferences _prefs;
  static const int _defaultCacheExpiryHours = 1;
  final bool _useMockData = true;

  ModuleRepository(this._dio, this._prefs);

  Future<List<StudyModule>> getStudyModules({
    bool forceRefresh = false,
    Map<String, dynamic>? queryParams,
    CancelToken? cancelToken,
  }) async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 800));
      return _getMockModules();
    }

    try {
      if (!forceRefresh) {
        final cachedData = await _getCachedData<List<StudyModule>>(
          CacheKeys.moduleList,
          (json) =>
              (json as List).map((item) => StudyModule.fromJson(item)).toList(),
        );
        if (cachedData != null) {
          return cachedData;
        }
      }

      final response = await _dio.get(
        '/api/modules',
        queryParameters: queryParams,
        cancelToken: cancelToken,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        final modules = data.map((json) => StudyModule.fromJson(json)).toList();
        await _cacheData(CacheKeys.moduleList, modules);
        return modules;
      } else {
        throw DioException(
          requestOptions: RequestOptions(path: '/api/modules'),
          response: response,
          error: 'Failed to load modules: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('Network error fetching modules: ${e.message}');

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkTimeoutException('Không thể kết nối đến máy chủ');
      }

      // Trả về dữ liệu cache nếu có
      final cachedData = await _getCachedData<List<StudyModule>>(
        CacheKeys.moduleList,
        (json) =>
            (json as List).map((item) => StudyModule.fromJson(item)).toList(),
      );

      if (cachedData != null) {
        return cachedData;
      }

      throw ModuleException('Không thể tải danh sách học phần: ${e.message}');
    } catch (e) {
      debugPrint('Error fetching modules: $e');
      throw ModuleException('Đã xảy ra lỗi: $e');
    }
  }

  Future<List<StudyModule>> getStudyModulesByFolder(
    String folderId, {
    bool forceRefresh = false,
    CancelToken? cancelToken,
  }) async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 800));
      return _getMockModulesByFolder(folderId);
    }

    final cacheKey = CacheKeys.folderModules(folderId);

    try {
      if (!forceRefresh) {
        final cachedData = await _getCachedData<List<StudyModule>>(
          cacheKey,
          (json) =>
              (json as List).map((item) => StudyModule.fromJson(item)).toList(),
        );
        if (cachedData != null) {
          return cachedData;
        }
      }

      final response = await _dio.get(
        '/api/folders/$folderId/modules',
        cancelToken: cancelToken,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        final modules = data.map((json) => StudyModule.fromJson(json)).toList();
        await _cacheData(cacheKey, modules);
        return modules;
      } else {
        throw DioException(
          requestOptions:
              RequestOptions(path: '/api/folders/$folderId/modules'),
          response: response,
          error: 'Failed to load modules by folder: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('Network error fetching modules by folder: ${e.message}');

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkTimeoutException('Không thể kết nối đến máy chủ');
      }

      // Trả về dữ liệu cache nếu có
      final cachedData = await _getCachedData<List<StudyModule>>(
        cacheKey,
        (json) =>
            (json as List).map((item) => StudyModule.fromJson(item)).toList(),
      );

      if (cachedData != null) {
        return cachedData;
      }

      throw ModuleException(
          'Không thể tải danh sách học phần trong thư mục: ${e.message}');
    } catch (e) {
      debugPrint('Error fetching modules by folder: $e');
      throw ModuleException('Đã xảy ra lỗi: $e');
    }
  }

  Future<StudyModule> getStudyModuleById(
    String id, {
    bool forceRefresh = false,
    CancelToken? cancelToken,
  }) async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return _getMockModuleById(id);
    }

    final cacheKey = CacheKeys.moduleDetail(id);

    try {
      if (!forceRefresh) {
        final cachedData = await _getCachedData<StudyModule>(
          cacheKey,
          (json) => StudyModule.fromJson(json),
        );
        if (cachedData != null) {
          return cachedData;
        }
      }

      final response = await _dio.get(
        '/api/modules/$id',
        cancelToken: cancelToken,
      );

      if (response.statusCode == 200) {
        final module = StudyModule.fromJson(response.data);
        await _cacheData(cacheKey, module);
        return module;
      } else {
        throw DioException(
          requestOptions: RequestOptions(path: '/api/modules/$id'),
          response: response,
          error: 'Failed to load module: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('Network error fetching module details: ${e.message}');

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkTimeoutException('Không thể kết nối đến máy chủ');
      }

      if (e.response?.statusCode == 404) {
        throw ModuleException('Không tìm thấy học phần');
      }

      // Trả về dữ liệu cache nếu có
      final cachedData = await _getCachedData<StudyModule>(
        cacheKey,
        (json) => StudyModule.fromJson(json),
      );

      if (cachedData != null) {
        return cachedData;
      }

      throw ModuleException('Không thể tải thông tin học phần: ${e.message}');
    } catch (e) {
      debugPrint('Error fetching module: $e');
      throw ModuleException('Đã xảy ra lỗi: $e');
    }
  }

  Future<StudyModule> createStudyModule(
    StudyModule module, {
    CancelToken? cancelToken,
  }) async {
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
        cancelToken: cancelToken,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final createdModule = StudyModule.fromJson(response.data);
        await _updateModuleInCache(createdModule);
        return createdModule;
      } else {
        throw DioException(
          requestOptions: RequestOptions(path: '/api/modules'),
          response: response,
          error: 'Failed to create module: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('Network error creating module: ${e.message}');

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkTimeoutException('Không thể kết nối đến máy chủ');
      }

      if (e.response?.statusCode == 403) {
        throw PermissionException('Bạn không có quyền tạo học phần');
      }

      throw ModuleException('Không thể tạo học phần: ${e.message}');
    } catch (e) {
      debugPrint('Error creating module: $e');
      throw ModuleException('Đã xảy ra lỗi: $e');
    }
  }

  Future<StudyModule> updateStudyModule(
    StudyModule module, {
    CancelToken? cancelToken,
  }) async {
    if (_useMockData) {
      await Future.delayed(const Duration(seconds: 1));
      return module.copyWith(lastUpdatedAt: DateTime.now());
    }

    try {
      final response = await _dio.put(
        '/api/modules/${module.id}',
        data: module.toJson(),
        cancelToken: cancelToken,
      );

      if (response.statusCode == 200) {
        final updatedModule = StudyModule.fromJson(response.data);
        await _updateModuleInCache(updatedModule);
        return updatedModule;
      } else {
        throw DioException(
          requestOptions: RequestOptions(path: '/api/modules/${module.id}'),
          response: response,
          error: 'Failed to update module: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('Network error updating module: ${e.message}');

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkTimeoutException('Không thể kết nối đến máy chủ');
      }

      if (e.response?.statusCode == 403) {
        throw PermissionException('Bạn không có quyền cập nhật học phần này');
      }

      if (e.response?.statusCode == 404) {
        throw ModuleException('Không tìm thấy học phần để cập nhật');
      }

      throw ModuleException('Không thể cập nhật học phần: ${e.message}');
    } catch (e) {
      debugPrint('Error updating module: $e');
      throw ModuleException('Đã xảy ra lỗi: $e');
    }
  }

  Future<bool> deleteStudyModule(
    String id, {
    CancelToken? cancelToken,
  }) async {
    if (_useMockData) {
      await Future.delayed(const Duration(seconds: 1));
      return true;
    }

    try {
      final response = await _dio.delete(
        '/api/modules/$id',
        cancelToken: cancelToken,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        await _removeFromCache(id);
        return true;
      } else {
        throw DioException(
          requestOptions: RequestOptions(path: '/api/modules/$id'),
          response: response,
          error: 'Failed to delete module: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('Network error deleting module: ${e.message}');

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkTimeoutException('Không thể kết nối đến máy chủ');
      }

      if (e.response?.statusCode == 403) {
        throw PermissionException('Bạn không có quyền xóa học phần này');
      }

      if (e.response?.statusCode == 404) {
        throw ModuleException('Không tìm thấy học phần để xóa');
      }

      throw ModuleException('Không thể xóa học phần: ${e.message}');
    } catch (e) {
      debugPrint('Error deleting module: $e');
      throw ModuleException('Đã xảy ra lỗi: $e');
    }
  }

  Future<ModuleSettings> getModuleSettings(
    String moduleId, {
    CancelToken? cancelToken,
  }) async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return const ModuleSettings();
    }

    final cacheKey = CacheKeys.moduleSettings(moduleId);

    try {
      final cachedData = await _getCachedData<ModuleSettings>(
        cacheKey,
        (json) => ModuleSettings.fromJson(json),
      );
      if (cachedData != null) {
        return cachedData;
      }

      final response = await _dio.get(
        '/api/modules/$moduleId/settings',
        cancelToken: cancelToken,
      );

      if (response.statusCode == 200) {
        final settings = ModuleSettings.fromJson(response.data);
        await _cacheData(cacheKey, settings);
        return settings;
      } else {
        throw DioException(
          requestOptions:
              RequestOptions(path: '/api/modules/$moduleId/settings'),
          response: response,
          error: 'Failed to load settings: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('Network error fetching settings: ${e.message}');
      return const ModuleSettings(); // Return default settings on error
    } catch (e) {
      debugPrint('Error fetching settings: $e');
      return const ModuleSettings(); // Return default settings on error
    }
  }

  Future<ModuleSettings> updateModuleSettings(
    String moduleId,
    ModuleSettings settings, {
    CancelToken? cancelToken,
  }) async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 800));
      return settings;
    }

    try {
      final response = await _dio.put(
        '/api/modules/$moduleId/settings',
        data: settings.toJson(),
        cancelToken: cancelToken,
      );

      if (response.statusCode == 200) {
        final updatedSettings = ModuleSettings.fromJson(response.data);
        final cacheKey = CacheKeys.moduleSettings(moduleId);
        await _cacheData(cacheKey, updatedSettings);
        return updatedSettings;
      } else {
        throw DioException(
          requestOptions:
              RequestOptions(path: '/api/modules/$moduleId/settings'),
          response: response,
          error: 'Failed to update settings: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('Network error updating settings: ${e.message}');

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkTimeoutException('Không thể kết nối đến máy chủ');
      }

      if (e.response?.statusCode == 403) {
        throw PermissionException(
            'Bạn không có quyền cập nhật cài đặt cho học phần này');
      }

      throw ModuleException('Không thể cập nhật cài đặt: ${e.message}');
    } catch (e) {
      debugPrint('Error updating settings: $e');
      throw ModuleException('Đã xảy ra lỗi: $e');
    }
  }

  // Cache methods
  Future<void> _updateModuleInCache(StudyModule module) async {
    final detailCacheKey = CacheKeys.moduleDetail(module.id);
    await _cacheData(detailCacheKey, module);

    final moduleListCache = _prefs.getString(CacheKeys.moduleList);
    if (moduleListCache != null) {
      try {
        final List<dynamic> decoded =
            jsonDecode(moduleListCache) as List<dynamic>;
        final modules =
            decoded.map((json) => StudyModule.fromJson(json)).toList();

        final index = modules.indexWhere((m) => m.id == module.id);
        if (index >= 0) {
          modules[index] = module;
        } else {
          modules.add(module);
        }

        await _cacheData(CacheKeys.moduleList, modules);
      } catch (e) {
        debugPrint('Error updating module list cache: $e');
      }
    }
  }

  Future<void> _removeFromCache(String moduleId) async {
    final detailCacheKey = CacheKeys.moduleDetail(moduleId);
    await _prefs.remove(detailCacheKey);
    await _prefs.remove(CacheKeys.cacheExpiry(detailCacheKey));

    final settingsCacheKey = CacheKeys.moduleSettings(moduleId);
    await _prefs.remove(settingsCacheKey);
    await _prefs.remove(CacheKeys.cacheExpiry(settingsCacheKey));

    // Cập nhật danh sách
    final moduleListCache = _prefs.getString(CacheKeys.moduleList);
    if (moduleListCache != null) {
      try {
        final List<dynamic> decoded =
            jsonDecode(moduleListCache) as List<dynamic>;
        final modules = decoded
            .map((json) => StudyModule.fromJson(json))
            .where((module) => module.id != moduleId)
            .toList();

        await _cacheData(CacheKeys.moduleList, modules);
      } catch (e) {
        debugPrint('Error updating module list cache after deletion: $e');
      }
    }
  }

  Future<void> _cacheData<T>(String key, T data,
      {int expiryHours = _defaultCacheExpiryHours}) async {
    try {
      String jsonData;
      if (data is List<StudyModule>) {
        jsonData = jsonEncode(data.map((e) => e.toJson()).toList());
      } else if (data is StudyModule) {
        jsonData = jsonEncode(data.toJson());
      } else if (data is ModuleSettings) {
        jsonData = jsonEncode(data.toJson());
      } else {
        throw ArgumentError(
            'Unsupported type for caching: ${data.runtimeType}');
      }

      await _prefs.setString(key, jsonData);

      final expiryTime = DateTime.now().add(Duration(hours: expiryHours));
      await _prefs.setString(
          CacheKeys.cacheExpiry(key), expiryTime.toIso8601String());
      await _prefs.setString(
          CacheKeys.lastSyncKey, DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('Error caching data for key $key: $e');
    }
  }

  Future<T?> _getCachedData<T>(
      String key, T Function(dynamic json) fromJson) async {
    try {
      final cachedData = _prefs.getString(key);
      if (cachedData == null) return null;
      if (!_isCacheValid(key)) return null;

      final dynamic decoded = jsonDecode(cachedData);
      return fromJson(decoded);
    } catch (e) {
      debugPrint('Error retrieving cached data for key $key: $e');
      return null;
    }
  }

  bool _isCacheValid(String key) {
    final expiryTimeStr = _prefs.getString(CacheKeys.cacheExpiry(key));
    if (expiryTimeStr == null) return false;

    try {
      final expiryTime = DateTime.parse(expiryTimeStr);
      return DateTime.now().isBefore(expiryTime);
    } catch (e) {
      debugPrint('Error parsing cache expiry time: $e');
      return false;
    }
  }

  // Mock data methods
  List<StudyModule> _getMockModules() {
    return [
      StudyModule(
        id: '1',
        title: 'Vitamin_Book2_Chapter4-2: Vocabulary',
        description: 'Korean vocabulary chapter 4-2',
        creatorName: 'giapnguyen1994',
        hasPlusBadge: true,
        termCount: 55,
        flashcards: _generateMockFlashcards(55),
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      StudyModule(
        id: '2',
        title: 'Section 4: 병원',
        description: 'Hospital-related vocabulary',
        creatorName: 'giapnguyen1994',
        hasPlusBadge: true,
        termCount: 88,
        flashcards: _generateMockFlashcards(88),
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      StudyModule(
        id: '3',
        title: 'Vitamin_Book2_Chapter1-1: Vocabulary',
        description: 'Korean vocabulary chapter 1-1',
        creatorName: 'giapnguyen1994',
        hasPlusBadge: false,
        termCount: 74,
        flashcards: _generateMockFlashcards(74),
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      StudyModule(
        id: '4',
        title: 'TOPIK I - Listening Practice Level 1-2',
        description: 'Listening practice materials for TOPIK I',
        creatorName: 'korean_teacher',
        hasPlusBadge: true,
        termCount: 120,
        flashcards: _generateMockFlashcards(120),
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
    ];
  }

  List<StudyModule> _getMockModulesByFolder(String folderId) {
    return List.generate(
      4,
      (index) => StudyModule(
        id: 'folder-$folderId-module-${index + 1}',
        title: 'Section ${index + 1}: Topic ${index + 1}',
        description: 'Description for module ${index + 1}',
        creatorName: 'giapnguyen1994',
        hasPlusBadge: index % 2 == 0,
        termCount: 50 + index,
        flashcards: _generateMockFlashcards(50 + index),
        createdAt: DateTime.now().subtract(Duration(days: index * 5)),
      ),
    );
  }

  StudyModule _getMockModuleById(String id) {
    final allModules = _getMockModules();
    return allModules.firstWhere(
      (module) => module.id == id,
      orElse: () => StudyModule(
        id: id,
        title: 'Vitamin_Book2_Chapter4-2: Vocabulary',
        description: 'Korean vocabulary chapter 4-2',
        creatorName: 'giapnguyen1994',
        hasPlusBadge: true,
        termCount: 55,
        flashcards: _generateMockFlashcards(55),
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    );
  }

  List<Flashcard> _generateMockFlashcards(int count) {
    final List<Flashcard> flashcards = [];
    final List<Map<String, String>> koreanWords = [
      {'term': '사과', 'definition': 'Apple', 'example': 'I like apples.'},
      {'term': '바나나', 'definition': 'Banana', 'example': 'Bananas are yellow.'},
      {
        'term': '오렌지',
        'definition': 'Orange',
        'example': 'I drink orange juice.'
      },
      {'term': '포도', 'definition': 'Grape', 'example': 'Grapes are sweet.'},
      {
        'term': '딸기',
        'definition': 'Strawberry',
        'example': 'Strawberries are delicious.'
      },
      {
        'term': '수박',
        'definition': 'Watermelon',
        'example': 'I eat watermelon in summer.'
      },
      {
        'term': '파인애플',
        'definition': 'Pineapple',
        'example': 'Pineapples are yellow.'
      },
      {
        'term': '망고',
        'definition': 'Mango',
        'example': 'Mangoes are sweet and delicious.'
      },
      {'term': '키위', 'definition': 'Kiwi', 'example': 'Kiwis are brown.'},
      {'term': '복숭아', 'definition': 'Peach', 'example': 'Peaches are sweet.'},
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
