/// lib/core/api/api_provider.dart

import 'package:dio/dio.dart';
import 'package:qlz_flash_cards_ui/config/app_config.dart';
import 'package:qlz_flash_cards_ui/core/api/api_error.dart';
import 'package:qlz_flash_cards_ui/core/api/network_error.dart';

/// A generic sealed class for handling API requests with type safety
///
/// [T] represents the type of data model being handled
sealed class ApiProvider<T> {
  /// Base URL for API requests
  final String baseUrl;

  /// Function to convert JSON to model instance
  final T Function(Map<String, dynamic>) fromJson;

  /// Function to convert model instance to JSON
  final Map<String, dynamic> Function(T) toJson;

  /// Dio HTTP client for making network requests
  late final Dio _dio;

  /// Constructor initializes Dio with base configuration
  ApiProvider({
    required this.baseUrl,
    required this.fromJson,
    required this.toJson,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: ApiConfig.timeouts.connection,
        receiveTimeout: ApiConfig.timeouts.receive,
        headers: BuildConfig.defaultHeaders,
      ),
    )..interceptors.addAll([
        _AuthInterceptor(),
        // Log interceptor only in non-production environments
        if (!BuildConfig.environment.isProduction)
          LogInterceptor(requestBody: true, responseBody: true),
      ]);
  }

  /// Generic GET request method
  ///
  /// Fetches a single resource by [path]
  Future<T> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
        options: options,
      );

      return fromJson(response.data!);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiError(message: e.toString());
    }
  }

  /// Generic GET request method for list of resources
  ///
  /// Fetches multiple resources by [path]
  Future<List<T>> getList(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        path,
        queryParameters: queryParameters,
        options: options,
      );

      return response.data!
          .map((item) => fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiError(message: e.toString());
    }
  }

  /// Generic POST request method
  ///
  /// Creates a new resource using [path] and optional [data]
  Future<T> post(
    String path, {
    T? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: data != null ? toJson(data) : null,
        queryParameters: queryParameters,
        options: options,
      );

      return fromJson(response.data!);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiError(message: e.toString());
    }
  }

  /// Generic PUT request method
  ///
  /// Updates an existing resource using [path] and optional [data]
  Future<T> put(
    String path, {
    T? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        path,
        data: data != null ? toJson(data) : null,
        queryParameters: queryParameters,
        options: options,
      );

      return fromJson(response.data!);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiError(message: e.toString());
    }
  }

  /// Generic DELETE request method
  ///
  /// Deletes a resource using [path]
  Future<void> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      await _dio.delete(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiError(message: e.toString());
    }
  }

  /// Handles Dio exceptions and converts them to more specific [NetworkError]
  NetworkError _handleDioError(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        const TimeoutError(message: 'Connection timeout'),
      DioExceptionType.badResponse => _handleResponseError(error.response),
      _ =>
        GeneralNetworkError(message: error.message ?? 'Network error occurred'),
    };
  }

  /// Handles different HTTP response errors
  NetworkError _handleResponseError(Response? response) {
    final statusCode = response?.statusCode ?? 500;
    final message = switch (response?.data) {
          Map<String, dynamic> data => data['message'] as String?,
          _ => null,
        } ??
        'Unknown error occurred';

    return switch (statusCode) {
      401 => UnauthorizedError(message: message),
      403 => ForbiddenError(message: message),
      404 => NotFoundError(message: message),
      400 || 422 => ValidationError(message: message),
      >= 500 => ServerError(message: message),
      _ => GeneralNetworkError(message: message),
    };
  }
}

/// Authentication interceptor for handling token-based authentication
final class _AuthInterceptor extends Interceptor {
  /// Adds authentication token to request headers
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  /// Handles token refresh for 401 (Unauthorized) errors
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      if (await _refreshToken()) {
        // Retry request with new token
        return handler.resolve(await _retry(err.requestOptions));
      }
    }
    handler.next(err);
  }

  /// Retrieves the current authentication token
  ///
  /// Should be implemented to fetch token from secure storage
  Future<String?> _getToken() async {
    // TODO: Implement token retrieval from secure storage
    return null;
  }

  /// Attempts to refresh the authentication token
  ///
  /// Should be implemented with actual token refresh logic
  Future<bool> _refreshToken() async {
    // TODO: Implement token refresh mechanism
    return false;
  }

  /// Retries a failed request with updated token
  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );

    final dio = Dio(BaseOptions(
      baseUrl: requestOptions.baseUrl,
      headers: requestOptions.headers,
    ));

    return dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
}
