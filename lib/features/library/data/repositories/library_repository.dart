// lib/features/library/data/repositories/library_repository.dart
import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/class_model.dart';
import '../models/folder_model.dart';
import '../models/study_set_model.dart';

class LibraryRepository {
  final Dio _dio;
  final SharedPreferences _prefs;
  
  // Cache keys
  static const String _studySetsKey = 'library_study_sets';
  static const String _foldersKey = 'library_folders';
  static const String _classesKey = 'library_classes';
  static const String _lastSyncKey = 'library_last_sync';
  
  // Mock data for development purpose
  final bool _useMockData = true;

  LibraryRepository(this._dio, this._prefs);

  // Fetch study sets with optional filter
  Future<List<StudySet>> getStudySets({String? filter, bool forceRefresh = false}) async {
    if (_useMockData) {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));
      return _getMockStudySets();
    }
    
    try {
      // Check if we have cached data and it's still valid (not forced refresh)
      if (!forceRefresh && _isCacheValid()) {
        final cachedData = _prefs.getString(_studySetsKey);
        if (cachedData != null) {
          // Parse and return cached data
          List<dynamic> decoded;
          try {
            decoded = jsonDecode(cachedData) as List<dynamic>;
            return decoded.map((json) => StudySet.fromJson(json)).toList();
          } catch (e) {
            debugPrint('Error decoding cached study sets: $e');
            // Continue to fetch from network if cache decode fails
          }
        }
      }
      
      // If no cache or force refresh, fetch from network
      final response = await _dio.get('/api/study-sets', queryParameters: {
        if (filter != null) 'filter': filter,
      });
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        final studySets = data.map((json) => StudySet.fromJson(json)).toList();
        
        // Cache the result
        try {
          await _prefs.setString(_studySetsKey, jsonEncode(studySets.map((e) => e.toJson()).toList()));
          await _prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
        } catch (e) {
          debugPrint('Error caching study sets: $e');
          // Continue even if caching fails
        }
        
        return studySets;
      } else {
        throw Exception('Failed to load study sets: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching study sets: $e');
      
      // If network request fails, try to use cached data if available
      final cachedData = _prefs.getString(_studySetsKey);
      if (cachedData != null) {
        try {
          final List<dynamic> decoded = jsonDecode(cachedData) as List<dynamic>;
          return decoded.map((json) => StudySet.fromJson(json)).toList();
        } catch (e) {
          debugPrint('Error using cached data: $e');
        }
      }
      
      // If no cached data, rethrow the exception
      rethrow;
    }
  }

  // Fetch folders
  Future<List<Folder>> getFolders({bool forceRefresh = false}) async {
    if (_useMockData) {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));
      return _getMockFolders();
    }
    
    try {
      // Check if we have cached data and it's still valid
      if (!forceRefresh && _isCacheValid()) {
        final cachedData = _prefs.getString(_foldersKey);
        if (cachedData != null) {
          try {
            final List<dynamic> decoded = jsonDecode(cachedData) as List<dynamic>;
            return decoded.map((json) => Folder.fromJson(json)).toList();
          } catch (e) {
            debugPrint('Error decoding cached folders: $e');
            // Continue to fetch from network if cache decode fails
          }
        }
      }
      
      // If no cache or force refresh, fetch from network
      final response = await _dio.get('/api/folders');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        final folders = data.map((json) => Folder.fromJson(json)).toList();
        
        // Cache the result
        try {
          await _prefs.setString(_foldersKey, jsonEncode(folders.map((e) => e.toJson()).toList()));
          await _prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
        } catch (e) {
          debugPrint('Error caching folders: $e');
          // Continue even if caching fails
        }
        
        return folders;
      } else {
        throw Exception('Failed to load folders: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching folders: $e');
      
      // If network request fails, try to use cached data if available
      final cachedData = _prefs.getString(_foldersKey);
      if (cachedData != null) {
        try {
          final List<dynamic> decoded = jsonDecode(cachedData) as List<dynamic>;
          return decoded.map((json) => Folder.fromJson(json)).toList();
        } catch (e) {
          debugPrint('Error using cached data: $e');
        }
      }
      
      // If no cached data, rethrow the exception
      rethrow;
    }
  }

  // Fetch classes
  Future<List<ClassModel>> getClasses({bool forceRefresh = false}) async {
    if (_useMockData) {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));
      return _getMockClasses();
    }
    
    try {
      // Check if we have cached data and it's still valid
      if (!forceRefresh && _isCacheValid()) {
        final cachedData = _prefs.getString(_classesKey);
        if (cachedData != null) {
          try {
            final List<dynamic> decoded = jsonDecode(cachedData) as List<dynamic>;
            return decoded.map((json) => ClassModel.fromJson(json)).toList();
          } catch (e) {
            debugPrint('Error decoding cached classes: $e');
            // Continue to fetch from network if cache decode fails
          }
        }
      }
      
      // If no cache or force refresh, fetch from network
      final response = await _dio.get('/api/classes');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        final classes = data.map((json) => ClassModel.fromJson(json)).toList();
        
        // Cache the result
        try {
          await _prefs.setString(_classesKey, jsonEncode(classes.map((e) => e.toJson()).toList()));
          await _prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
        } catch (e) {
          debugPrint('Error caching classes: $e');
          // Continue even if caching fails
        }
        
        return classes;
      } else {
        throw Exception('Failed to load classes: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching classes: $e');
      
      // If network request fails, try to use cached data if available
      final cachedData = _prefs.getString(_classesKey);
      if (cachedData != null) {
        try {
          final List<dynamic> decoded = jsonDecode(cachedData) as List<dynamic>;
          return decoded.map((json) => ClassModel.fromJson(json)).toList();
        } catch (e) {
          debugPrint('Error using cached data: $e');
        }
      }
      
      // If no cached data, rethrow the exception
      rethrow;
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

  // Mock data methods for development
  List<StudySet> _getMockStudySets() {
    return [
      StudySet(
        id: '1',
        title: 'Section 4: 병원',
        wordCount: 88,
        creatorName: 'giapnguyen1994',
        hasPlusBadge: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      StudySet(
        id: '2',
        title: 'Vitamin_Book2_Chapter4-2: Vocabulary',
        wordCount: 55,
        creatorName: 'giapnguyen1994',
        hasPlusBadge: true,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      StudySet(
        id: '3',
        title: 'Vitamin_Book2_Chapter1-1: Vocabulary',
        wordCount: 74,
        creatorName: 'giapnguyen1994',
        hasPlusBadge: false,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      StudySet(
        id: '4',
        title: 'TOPIK I - Luyện nghe cấp độ 1-2',
        wordCount: 120,
        creatorName: 'korean_teacher',
        hasPlusBadge: true,
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
      ),
      StudySet(
        id: '5',
        title: 'Từ vựng tiếng Hàn chủ đề Ẩm thực',
        wordCount: 45,
        creatorName: 'hangul_study',
        hasPlusBadge: false,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      StudySet(
        id: '6',
        title: 'Động từ bất quy tắc - 불규칙 동사',
        wordCount: 32,
        creatorName: 'koreanwithme',
        hasPlusBadge: true,
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
      ),
      StudySet(
        id: '7',
        title: 'EPS-TOPIK 60일 완성',
        wordCount: 210,
        creatorName: 'eps_study',
        hasPlusBadge: true,
        createdAt: DateTime.now().subtract(const Duration(days: 9)),
      ),
    ];
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
      Folder(
        id: '6',
        name: 'Luyện thi TOPIK II',
        creatorName: 'hangul_study',
        hasPlusBadge: false,
        moduleCount: 25,
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
      ),
      Folder(
        id: '7',
        name: 'Khóa học EPS',
        creatorName: 'eps_study',
        hasPlusBadge: true,
        moduleCount: 15,
        createdAt: DateTime.now().subtract(const Duration(days: 14)),
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