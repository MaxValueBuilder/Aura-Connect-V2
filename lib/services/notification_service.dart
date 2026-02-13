import 'dart:developer';

import 'package:dio/dio.dart';
import '../core/error/exceptions.dart';
import '../models/notification_model.dart';

class NotificationService {
  final Dio _dio;

  NotificationService(this._dio);

  /// Get all notifications
  Future<Map<String, dynamic>> getNotifications({
    int? limit,
    int? offset,
    bool? unreadOnly,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;
      if (unreadOnly != null) queryParams['unreadOnly'] = unreadOnly.toString();

      final response = await _dio.get(
        '/notifications',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final notificationsList =
          response.data['notifications'] as List<dynamic>? ?? [];
      final notifications = notificationsList
          .map(
            (json) => NotificationModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      return {
        'notifications': notifications,
        'totalCount': response.data['totalCount'] ?? 0,
        'unreadCount': response.data['unreadCount'] ?? 0,
      };
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get unread notification count
  Future<int> getUnreadCount() async {
    try {
      final response = await _dio.get('/notifications/unread-count');
      return response.data['count'] ?? 0;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      log('Marking notification as read: $notificationId');
      await _dio.patch('/notifications/$notificationId/read');
      log('Notification marked as read: $notificationId');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _dio.patch('/notifications/read-all');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _dio.delete('/notifications/$notificationId');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final message =
          e.response!.data?['error'] ??
          e.response!.data?['message'] ??
          'Unknown error';

      switch (statusCode) {
        case 401:
          return AuthException(message: message);
        case 403:
          return AuthException(message: 'Forbidden: $message');
        case 404:
          return ServerException(message: 'Not found: $message');
        case 500:
        default:
          return ServerException(message: message);
      }
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return NetworkException(
        message: 'Connection timeout. Please check your internet connection.',
      );
    } else if (e.type == DioExceptionType.connectionError) {
      return NetworkException(
        message: 'No internet connection. Please check your network settings.',
      );
    } else {
      return ServerException(message: e.message ?? 'Unknown error occurred');
    }
  }
}
