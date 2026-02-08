import 'package:equatable/equatable.dart';

/// Base failure class
abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure({
    required this.message,
    this.statusCode,
  });

  @override
  List<Object?> get props => [message, statusCode];
}

/// Server failure
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.statusCode,
  });
}

/// Network failure
class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
  }) : super(statusCode: null);
}

/// Cache failure
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
  }) : super(statusCode: null);
}

/// Authentication failure
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.statusCode,
  });
}

/// Validation failure
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
  }) : super(statusCode: null);
}

/// Permission failure
class PermissionFailure extends Failure {
  const PermissionFailure({
    required super.message,
  }) : super(statusCode: null);
}

/// Recording failure
class RecordingFailure extends Failure {
  const RecordingFailure({
    required super.message,
  }) : super(statusCode: null);
}

/// AI Service failure
class AIServiceFailure extends Failure {
  const AIServiceFailure({
    required super.message,
  }) : super(statusCode: null);
}

