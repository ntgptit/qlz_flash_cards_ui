import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/features/library/data/models/class_model.dart';
import 'package:qlz_flash_cards_ui/features/library/data/models/folder_model.dart';
import 'package:qlz_flash_cards_ui/features/library/data/models/study_set_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LibraryRepository {
  final Dio _dio;
  final SharedPreferences _prefs;
  static const String _studySetsKey = 'library_study_sets';
  static const String _folderStudySetsPrefix = 'library_folder_study_sets_';
  static const String _foldersKey = 'library_folders';
  static const String _classesKey = 'library_classes';
  static const String _lastSyncKey = 'library_last_sync';
  final bool _useMockData = true;

  LibraryRepository(this._dio, this._prefs);

  Future<List<StudySet>> getStudySets(
      {String? filter, bool forceRefresh = false}) async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 800));
      return _getMockStudySets();
    }

    try {
      if (!forceRefresh && _isCacheValid()) {
        final cachedData = _prefs.getString(_studySetsKey);
        if (cachedData != null) {
          try {
            final List<dynamic> decoded =
                jsonDecode(cachedData) as List<dynamic>;
            return decoded.map((json) => StudySet.fromJson(json)).toList();
          } catch (e) {
            debugPrint('Error decoding cached study sets: $e');
          }
        }
      }

      final response = await _dio.get('/api/study-sets', queryParameters: {
        if (filter != null) 'filter': filter,
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        final studySets = data.map((json) => StudySet.fromJson(json)).toList();

        try {
          await _prefs.setString(_studySetsKey,
              jsonEncode(studySets.map((e) => e.toJson()).toList()));
          await _prefs.setString(
              _lastSyncKey, DateTime.now().toIso8601String());
        } catch (e) {
          debugPrint('Error caching study sets: $e');
        }

        return studySets;
      } else {
        throw Exception('Failed to load study sets: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching study sets: $e');
      final cachedData = _prefs.getString(_studySetsKey);
      if (cachedData != null) {
        try {
          final List<dynamic> decoded = jsonDecode(cachedData) as List<dynamic>;
          return decoded.map((json) => StudySet.fromJson(json)).toList();
        } catch (e) {
          debugPrint('Error using cached data: $e');
        }
      }
      rethrow;
    }
  }

  Future<List<StudySet>> getStudySetsByFolder(String folderId,
      {bool forceRefresh = false}) async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 800));
      return _getMockStudySetsByFolder(folderId);
    }

    try {
      final cacheKey = '$_folderStudySetsPrefix$folderId';
      if (!forceRefresh && _isCacheValid()) {
        final cachedData = _prefs.getString(cacheKey);
        if (cachedData != null) {
          try {
            final List<dynamic> decoded =
                jsonDecode(cachedData) as List<dynamic>;
            return decoded.map((json) => StudySet.fromJson(json)).toList();
          } catch (e) {
            debugPrint('Error decoding cached folder study sets: $e');
          }
        }
      }

      final response = await _dio.get('/api/folders/$folderId/study-sets');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        final studySets = data.map((json) => StudySet.fromJson(json)).toList();

        try {
          await _prefs.setString(
              cacheKey, jsonEncode(studySets.map((e) => e.toJson()).toList()));
          await _prefs.setString(
              _lastSyncKey, DateTime.now().toIso8601String());
        } catch (e) {
          debugPrint('Error caching folder study sets: $e');
        }

        return studySets;
      } else {
        throw Exception(
            'Failed to load folder study sets: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching folder study sets: $e');
      final cacheKey = '$_folderStudySetsPrefix$folderId';
      final cachedData = _prefs.getString(cacheKey);
      if (cachedData != null) {
        try {
          final List<dynamic> decoded = jsonDecode(cachedData) as List<dynamic>;
          return decoded.map((json) => StudySet.fromJson(json)).toList();
        } catch (e) {
          debugPrint('Error using cached data: $e');
        }
      }
      rethrow;
    }
  }

  Future<List<Folder>> getFolders({bool forceRefresh = false}) async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 800));
      return _getMockFolders();
    }

    try {
      if (!forceRefresh && _isCacheValid()) {
        final cachedData = _prefs.getString(_foldersKey);
        if (cachedData != null) {
          try {
            final List<dynamic> decoded =
                jsonDecode(cachedData) as List<dynamic>;
            return decoded.map((json) => Folder.fromJson(json)).toList();
          } catch (e) {
            debugPrint('Error decoding cached folders: $e');
          }
        }
      }

      final response = await _dio.get('/api/folders');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        final folders = data.map((json) => Folder.fromJson(json)).toList();

        try {
          await _prefs.setString(
              _foldersKey, jsonEncode(folders.map((e) => e.toJson()).toList()));
          await _prefs.setString(
              _lastSyncKey, DateTime.now().toIso8601String());
        } catch (e) {
          debugPrint('Error caching folders: $e');
        }

        return folders;
      } else {
        throw Exception('Failed to load folders: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching folders: $e');
      final cachedData = _prefs.getString(_foldersKey);
      if (cachedData != null) {
        try {
          final List<dynamic> decoded = jsonDecode(cachedData) as List<dynamic>;
          return decoded.map((json) => Folder.fromJson(json)).toList();
        } catch (e) {
          debugPrint('Error using cached data: $e');
        }
      }
      rethrow;
    }
  }

  Future<Folder> createFolder({
    required String name,
    String? description,
  }) async {
    if (_useMockData) {
      await Future.delayed(const Duration(seconds: 1));
      final String newId = DateTime.now().millisecondsSinceEpoch.toString();
      final DateTime createdAt = DateTime.now();
      final newFolder = Folder(
        id: newId,
        name: name,
        creatorName: 'giapnguyen1994', // Giả lập người tạo
        hasPlusBadge: true,
        moduleCount: 0, // Thư mục mới chưa có học phần
        createdAt: createdAt,
      );
      return newFolder;
    }

    try {
      final response = await _dio.post('/api/folders', data: {
        'name': name,
        'description': description,
      });

      if (response.statusCode == 201) {
        final newFolder = Folder.fromJson(response.data);
        return newFolder;
      } else {
        throw Exception('Failed to create folder: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error creating folder: $e');
      rethrow;
    }
  }

  Future<List<ClassModel>> getClasses({bool forceRefresh = false}) async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 800));
      return _getMockClasses();
    }

    try {
      if (!forceRefresh && _isCacheValid()) {
        final cachedData = _prefs.getString(_classesKey);
        if (cachedData != null) {
          try {
            final List<dynamic> decoded =
                jsonDecode(cachedData) as List<dynamic>;
            return decoded.map((json) => ClassModel.fromJson(json)).toList();
          } catch (e) {
            debugPrint('Error decoding cached classes: $e');
          }
        }
      }

      final response = await _dio.get('/api/classes');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        final classes = data.map((json) => ClassModel.fromJson(json)).toList();

        try {
          await _prefs.setString(
              _classesKey, jsonEncode(classes.map((e) => e.toJson()).toList()));
          await _prefs.setString(
              _lastSyncKey, DateTime.now().toIso8601String());
        } catch (e) {
          debugPrint('Error caching classes: $e');
        }

        return classes;
      } else {
        throw Exception('Failed to load classes: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching classes: $e');
      final cachedData = _prefs.getString(_classesKey);
      if (cachedData != null) {
        try {
          final List<dynamic> decoded = jsonDecode(cachedData) as List<dynamic>;
          return decoded.map((json) => ClassModel.fromJson(json)).toList();
        } catch (e) {
          debugPrint('Error using cached data: $e');
        }
      }
      rethrow;
    }
  }

  Future<ClassModel> createClass({
    required String name,
    required String description,
    required bool allowMembersToAdd,
  }) async {
    if (_useMockData) {
      await Future.delayed(const Duration(seconds: 1));
      final String newId = DateTime.now().millisecondsSinceEpoch.toString();
      final DateTime createdAt = DateTime.now();
      final newClass = ClassModel(
        id: newId,
        name: name,
        studyModulesCount: 0, // Lớp mới chưa có học phần
        creatorName: 'giapnguyen1994', // Giả lập người tạo
        createdAt: createdAt,
      );
      return newClass;
    }

    try {
      final response = await _dio.post('/api/classes', data: {
        'name': name,
        'description': description,
        'allowMembersToAdd': allowMembersToAdd,
      });

      if (response.statusCode == 201) {
        final newClass = ClassModel.fromJson(response.data);
        return newClass;
      } else {
        throw Exception('Failed to create class: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error creating class: $e');
      rethrow;
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

  List<StudySet> _getMockStudySets() {
    return [
      StudySet(
        id: '1',
        title: '500 Từ vựng TOEIC cơ bản',
        description: 'Bộ từ vựng cơ bản cho người mới học TOEIC',
        creatorName: 'giapnguyen1994',
        hasPlusBadge: true,
        wordCount: 500,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      StudySet(
        id: '2',
        title: 'Vitamin_Book2_Chapter4-2: Vocabulary',
        description: 'Từ vựng Tiếng Hàn chương 4-2',
        creatorName: 'giapnguyen1994',
        hasPlusBadge: true,
        wordCount: 55,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      StudySet(
        id: '3',
        title: 'Vitamin_Book2_Chapter1-1: Vocabulary',
        description: 'Từ vựng Tiếng Hàn chương 1-1',
        creatorName: 'giapnguyen1994',
        hasPlusBadge: false,
        wordCount: 74,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      StudySet(
        id: '4',
        title: 'TOPIK I - Luyện nghe cấp độ 1-2',
        description: 'Tài liệu luyện nghe thi TOPIK I',
        creatorName: 'korean_teacher',
        hasPlusBadge: true,
        wordCount: 120,
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
      ),
      StudySet(
        id: '5',
        title: 'Từ vựng tiếng Hàn chủ đề Ẩm thực',
        description: 'Các từ vựng về món ăn, nhà hàng',
        creatorName: 'hangul_study',
        hasPlusBadge: false,
        wordCount: 45,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];
  }

  List<StudySet> _getMockStudySetsByFolder(String folderId) {
    return List.generate(
      4,
      (index) => StudySet(
        id: 'folder-$folderId-study-set-${index + 1}',
        title: 'Section ${index + 1}: Chủ đề ${index + 1}',
        description: 'Mô tả cho học phần ${index + 1}',
        creatorName: 'giapnguyen1994',
        hasPlusBadge: index % 2 == 0,
        wordCount: 50 + index,
        createdAt: DateTime.now().subtract(Duration(days: index * 5)),
      ),
    );
  }

  List<Folder> _getMockFolders() {
    return [
      Folder(
        id: '1',
        name: 'Grammar',
        creatorName: 'giapnguyen1994',
        hasPlusBadge: true,
        moduleCount: 5,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Folder(
        id: '2',
        name: 'OJT_Korea_2024',
        creatorName: 'giapnguyen1994',
        hasPlusBadge: true,
        moduleCount: 65,
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      Folder(
        id: '3',
        name: 'Tiếng Hàn tổng hợp 2',
        creatorName: 'giapnguyen1994',
        hasPlusBadge: true,
        moduleCount: 55,
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
      ),
      Folder(
        id: '4',
        name: 'Duyen선생님_중급1',
        creatorName: 'giapnguyen1994',
        hasPlusBadge: true,
        moduleCount: 45,
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
      ),
      Folder(
        id: '5',
        name: 'Ngữ pháp nâng cao',
        creatorName: 'korean_teacher',
        hasPlusBadge: true,
        moduleCount: 35,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];
  }

  List<ClassModel> _getMockClasses() {
    return [
      ClassModel(
        id: '1',
        name: 'Korean_Multicampus',
        studyModulesCount: 80,
        creatorName: 'giapnguyen1994',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      ClassModel(
        id: '2',
        name: 'Korean_Online_Class_2024',
        studyModulesCount: 45,
        creatorName: 'giapnguyen1994',
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      ClassModel(
        id: '3',
        name: 'TOPIK 중급 스터디',
        studyModulesCount: 68,
        creatorName: 'korean_teacher',
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
      ),
      ClassModel(
        id: '4',
        name: 'Lớp học tiếng Hàn cơ bản',
        studyModulesCount: 32,
        creatorName: 'hangul_study',
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
      ),
    ];
  }
}
