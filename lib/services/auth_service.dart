import 'dart:developer' show log;

import 'package:dio/dio.dart';

import '../core/error/exceptions.dart';

/// Service for authentication and clinic setup API calls
class AuthService {
  final Dio _dio;

  AuthService(this._dio);

  /// Login with email and password. Sends plain password over HTTPS so backend
  /// can use Supabase signInWithPassword (same as web). Credentials registered
  /// on web work on mobile and vice versa.
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Login with Google ID token (from Google Sign-In plugin). Backend exchanges it for app session.
  Future<Map<String, dynamic>> loginWithGoogle({
    required String idToken,
    String? nonce,
  }) async {
    try {
      final payload = <String, dynamic>{'id_token': idToken};
      final normalizedNonce = nonce?.trim();
      if (normalizedNonce != null && normalizedNonce.isNotEmpty) {
        payload['nonce'] = normalizedNonce;
      }
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/google',
        data: payload,
      );
      log('Login with Google response: ${response.data}');
      final data = response.data;
      if (data == null) {
        throw const ServerException(
          message: 'Invalid response from server',
          statusCode: 500,
        );
      }
      return data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Sign up with email, password, first name, last name. Sends plain password
  /// over HTTPS so backend can create user in Supabase (same as web). Account
  /// can then be used on both web and mobile.
  Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/signup',
        data: {
          'email': email,
          'password': password,
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
