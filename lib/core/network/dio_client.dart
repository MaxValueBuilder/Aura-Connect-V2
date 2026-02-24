import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';
import '../error/exceptions.dart';

/// Dio client for HTTP requests.
/// Base URL is read from .env BACKEND_URL (e.g. https://api.auraconnect.vet or .../api).
class DioClient {
  late final Dio _dio;
  final FlutterSecureStorage _storage;

  DioClient(this._storage) {
    final baseUrl = dotenv.env['BACKEND_URL'];
    log("DioClient baseUrl: $baseUrl");
    if (baseUrl == null || baseUrl.isEmpty) {
      throw Exception(
        'BACKEND_URL is not set in assets/.env. Add BACKEND_URL=<your-api-base-url>',
      );
    }
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: AppConstants.apiTimeout,
        receiveTimeout: AppConstants.apiTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onError: _onError,
        onResponse: _onResponse,
      ),
    );

    // Debug: log request URL and response/error (helps diagnose "no response" issues)
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (opt, h) {
          final uri = opt.uri;
          log('Dio request: ${opt.method} $uri');
          h.next(opt);
        },
        onResponse: (r, h) {
          log('Dio response: ${r.statusCode} ${r.requestOptions.uri}');
          h.next(r);
        },
        onError: (e, h) {
          log('Dio error: ${e.type} ${e.message} uri=${e.requestOptions.uri} statusCode=${e.response?.statusCode}');
          h.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Add auth token
    final token = await _storage.read(key: AppConstants.accessTokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Add user email if available
    final userEmail = await _storage.read(key: 'user_email');
    if (userEmail != null) {
      options.queryParameters['userEmail'] = userEmail;
    }

    handler.next(options);
  }

  void _onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }

  Future<void> _onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      // Token expired, try to refresh
      final refreshed = await _refreshToken();
      if (refreshed) {
        // Retry the request
        final options = err.requestOptions;
        final token = await _storage.read(key: AppConstants.accessTokenKey);
        options.headers['Authorization'] = 'Bearer $token';

        try {
          final response = await _dio.fetch(options);
          return handler.resolve(response);
        } catch (e) {
          return handler.reject(err);
        }
      }
    }

    handler.next(err);
  }

  /// Refresh JWT: POST /auth/refresh with current Bearer token; response is { token }
  Future<bool> _refreshToken() async {
    try {
      final currentToken = await _storage.read(
        key: AppConstants.accessTokenKey,
      );
      if (currentToken == null) return false;

      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        options: Options(headers: {'Authorization': 'Bearer $currentToken'}),
      );

      if (response.statusCode == 200) {
        final newToken = response.data?['token'];
        if (newToken != null) {
          await _storage.write(
            key: AppConstants.accessTokenKey,
            value: newToken,
          );
          return true;
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Handle Dio errors
  Exception handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException(
          message: 'Connection timeout. Please check your internet connection.',
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message =
            error.response?.data['error'] ??
            error.response?.data['message'] ??
            'Server error occurred';

        if (statusCode == 401) {
          return AuthException(message: message, statusCode: statusCode);
        }

        return ServerException(message: message, statusCode: statusCode);

      case DioExceptionType.cancel:
        return const NetworkException(message: 'Request cancelled');

      case DioExceptionType.unknown:
        if (error.error.toString().contains('SocketException')) {
          return const NetworkException(
            message: 'No internet connection. Please check your network.',
          );
        }
        return NetworkException(
          message: error.message ?? 'Unknown error occurred',
        );

      default:
        return NetworkException(
          message: error.message ?? 'Unknown error occurred',
        );
    }
  }
}
