// lib/features/auth/data/repositories/auth_repository.dart
import 'package:dio/dio.dart';
import 'package:qlz_flash_cards_ui/core/api/api_error.dart';

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  Future<void> login(String email, String password) async {
    try {
      // Trong môi trường thực, đây sẽ là một cuộc gọi API
      // Giả lập trễ mạng
      await Future.delayed(const Duration(seconds: 1));

      // Mô phỏng gọi API
      // final response = await _dio.post('/api/auth/login', data: {
      //   'email': email,
      //   'password': password,
      // });

      // Xử lý token trả về
      // if (response.statusCode == 200) {
      //   final token = response.data['token'];
      //   // Lưu token
      // }

      return;
    } on DioException catch (e) {
      throw ApiError(
          message: e.message ?? 'Lỗi đăng nhập', stackTrace: e.stackTrace);
    } catch (e, stackTrace) {
      throw ApiError(message: 'Lỗi không xác định: $e', stackTrace: stackTrace);
    }
  }

  Future<void> register(
      String displayName, String email, String password) async {
    try {
      // Giả lập trễ mạng
      await Future.delayed(const Duration(seconds: 1));

      // Mô phỏng gọi API
      // final response = await _dio.post('/api/auth/register', data: {
      //   'displayName': displayName,
      //   'email': email,
      //   'password': password,
      // });

      // Xử lý token trả về
      // if (response.statusCode == 200) {
      //   final token = response.data['token'];
      //   // Lưu token
      // }

      return;
    } on DioException catch (e) {
      throw ApiError(
          message: e.message ?? 'Lỗi đăng ký', stackTrace: e.stackTrace);
    } catch (e, stackTrace) {
      throw ApiError(message: 'Lỗi không xác định: $e', stackTrace: stackTrace);
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      // Giả lập trễ mạng
      await Future.delayed(const Duration(seconds: 2));

      // Mô phỏng gọi API
      // await _dio.post('/api/auth/forgot-password', data: {
      //   'email': email,
      // });

      return;
    } on DioException catch (e) {
      throw ApiError(
          message: e.message ?? 'Lỗi gửi yêu cầu đặt lại mật khẩu',
          stackTrace: e.stackTrace);
    } catch (e, stackTrace) {
      throw ApiError(message: 'Lỗi không xác định: $e', stackTrace: stackTrace);
    }
  }
}
