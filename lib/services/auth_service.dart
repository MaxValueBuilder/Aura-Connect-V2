import 'dart:developer' show log;

import 'package:dio/dio.dart';

import '../core/utils/crypto_utils.dart';
import '../core/error/exceptions.dart';

/// Service for authentication and clinic setup API calls
class AuthService {
  final Dio _dio;

  AuthService(this._dio);

  /// Login with email and password (password is hashed client-side before send)
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final hashedPassword = hashPassword(password);
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': hashedPassword},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Sign up with email, password, first name, last name
  Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final hashedPassword = hashPassword(password);
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/signup',
        data: {
          'email': email,
          'password': hashedPassword,
          'firstName': firstName,
          'lastName': lastName,
        },
      );
      final data = response.data;
      if (data == null) {
        return <String, dynamic>{
          'success': true,
          'message':
              'Account created. Please check your email to confirm, then sign in.',
        };
      }
      return data;
    } on DioException catch (e) {
      log(
        'Signup DioException: type=${e.type}, message=${e.message}, response=${e.response?.data}, statusCode=${e.response?.statusCode}',
      );
      throw _handleError(e);
    }
  }

  /// Register clinic for authenticated user (matches server POST /api/clinic/register)
  Future<Map<String, dynamic>> setupClinic({
    required String clinicName,
    required String clinicEmail,
    String? clinicPhone,
    String? clinicWebsite,
  }) async {
    try {
      final response = await _dio.post(
        '/clinic/register',
        data: {
          'clinicName': clinicName,
          'clinicEmail': clinicEmail,
          'clinicPhone': clinicPhone,
          'clinicWebsite': clinicWebsite,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle Dio errors
  Exception _handleError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;
      final message = data is Map
          ? (data['error'] ?? data['message'] ?? 'An error occurred')
          : 'An error occurred';

      if (statusCode == 401) {
        return AuthException(
          message: message.toString(),
          statusCode: statusCode,
        );
      }

      return ServerException(
        message: message.toString(),
        statusCode: statusCode,
      );
    }

    return NetworkException(message: error.message ?? 'Network error occurred');
  }
}
