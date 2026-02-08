/// Base exception class
class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => message;
}

/// Server exception
class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.statusCode,
  });
}

/// Network exception
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
  }) : super(statusCode: null);
}

/// Cache exception
class CacheException extends AppException {
  const CacheException({
    required super.message,
  }) : super(statusCode: null);
}

/// Authentication exception
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.statusCode,
  });
}

/// Validation exception
class ValidationException extends AppException {
  const ValidationException({
    required super.message,
  }) : super(statusCode: null);
}

/// Permission exception
class PermissionException extends AppException {
  const PermissionException({
    required super.message,
  }) : super(statusCode: null);
}

/// Recording exception
class RecordingException extends AppException {
  const RecordingException({
    required super.message,
  }) : super(statusCode: null);
}

/// AI Service exception
class AIServiceException extends AppException {
  const AIServiceException({
    required super.message,
  }) : super(statusCode: null);
}

