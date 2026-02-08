import 'package:dio/dio.dart';
import '../core/error/exceptions.dart';

/// Service for authentication and clinic setup API calls
class AuthService {
  final Dio _dio;

  AuthService(this._dio);

  /// Check if user has clinic setup
  Future<Map<String, dynamic>> checkClinicSetup() async {
    try {
      final response = await _dio.get('/auth/check-clinic-setup');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Setup clinic for authenticated user
  Future<Map<String, dynamic>> setupClinic({
    required String clinicName,
    required String clinicEmail,
    String? clinicPhone,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/setup-clinic',
        data: {
          'clinicName': clinicName,
          'clinicEmail': clinicEmail,
          'clinicPhone': clinicPhone,
          'firstName': firstName,
          'lastName': lastName,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle Dio errors
  Exception _handleError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final message = error.response!.data['error'] ??
          error.response!.data['message'] ??
          'An error occurred';

      if (statusCode == 401) {
        return AuthException(message: message, statusCode: statusCode);
      }

      return ServerException(message: message, statusCode: statusCode);
    }

    return NetworkException(message: error.message ?? 'Network error occurred');
  }
}

