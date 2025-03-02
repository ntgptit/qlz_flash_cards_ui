// lib/core/api/api_error.dart

final class ApiError implements Exception {
  final String message;
  final StackTrace? stackTrace;

  const ApiError({
    required this.message,
    this.stackTrace,
  });

  @override
  String toString() => message;
}
