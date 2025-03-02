/// lib/core/api/network_error.dart

/// Base class for all network-related errors
///
/// This sealed class serves as the parent for all specific network error types
sealed class NetworkError implements Exception {
  /// Error message describing what went wrong
  final String message;

  /// Optional stack trace where the error occurred
  final StackTrace? stackTrace;

  /// Creates a new [NetworkError] instance
  const NetworkError({
    required this.message,
    this.stackTrace,
  });

  /// Returns the error message when converted to string
  @override
  String toString() => message;
}

/// Represents general network errors that don't fit other specific categories
final class GeneralNetworkError extends NetworkError {
  /// Creates a new [GeneralNetworkError] instance
  const GeneralNetworkError({
    required super.message,
    super.stackTrace,
  });
}

/// Represents timeout errors (connection, send, or receive timeouts)
final class TimeoutError extends NetworkError {
  /// Creates a new [TimeoutError] instance
  const TimeoutError({
    required super.message,
    super.stackTrace,
  });
}

/// Represents server-side errors (HTTP 5xx status codes)
final class ServerError extends NetworkError {
  /// Creates a new [ServerError] instance
  const ServerError({
    required super.message,
    super.stackTrace,
  });
}

/// Represents authentication errors (HTTP 401 status code)
final class UnauthorizedError extends NetworkError {
  /// Creates a new [UnauthorizedError] instance
  const UnauthorizedError({
    required super.message,
    super.stackTrace,
  });
}

/// Represents permission errors (HTTP 403 status code)
final class ForbiddenError extends NetworkError {
  /// Creates a new [ForbiddenError] instance
  const ForbiddenError({
    required super.message,
    super.stackTrace,
  });
}

/// Represents resource not found errors (HTTP 404 status code)
final class NotFoundError extends NetworkError {
  /// Creates a new [NotFoundError] instance
  const NotFoundError({
    required super.message,
    super.stackTrace,
  });
}

/// Represents validation errors (HTTP 400 or 422 status codes)
final class ValidationError extends NetworkError {
  /// Creates a new [ValidationError] instance
  const ValidationError({
    required super.message,
    super.stackTrace,
  });
}
