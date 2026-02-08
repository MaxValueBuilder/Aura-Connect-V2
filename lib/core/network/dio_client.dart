import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';
import '../error/exceptions.dart';

/// Dio client for HTTP requests
class DioClient {
  late final Dio _dio;
  final FlutterSecureStorage _storage;

  DioClient(this._storage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
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

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(
        key: AppConstants.refreshTokenKey,
      );
      if (refreshToken == null) return false;

      final response = await _dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['accessToken'];
        final newRefreshToken = response.data['refreshToken'];

        await _storage.write(
          key: AppConstants.accessTokenKey,
          value: newAccessToken,
        );
        await _storage.write(
          key: AppConstants.refreshTokenKey,
          value: newRefreshToken,
        );

        return true;
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
