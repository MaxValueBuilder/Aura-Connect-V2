import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/notification_model.dart';
import '../../services/notification_service.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationService _notificationService;

  NotificationCubit(this._notificationService) : super(const NotificationState());

  /// Load all notifications
  Future<void> loadNotifications({bool refresh = false}) async {
    try {
      emit(state.copyWith(isLoading: true, clearError: true));

      final result = await _notificationService.getNotifications(
        limit: 50,
        offset: 0,
      );

      emit(
        state.copyWith(
          notifications: result['notifications'] as List<NotificationModel>,
          totalCount: result['totalCount'] as int,
          unreadCount: result['unreadCount'] as int,
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      emit(state.copyWith(isMarkingAsRead: true, clearError: true));

      await _notificationService.markAsRead(notificationId);

      final updatedNotifications = state.notifications.map((n) {
        if (n.id == notificationId) {
          return NotificationModel(
            id: n.id,
            type: n.type,
            title: n.title,
            message: n.message,
            data: n.data,
            read: true,
            readAt: DateTime.now(),
            createdAt: n.createdAt,
            updatedAt: DateTime.now(),
          );
        }
        return n;
      }).toList();

      emit(
        state.copyWith(
          notifications: updatedNotifications,
          unreadCount: (state.unreadCount - 1).clamp(0, double.infinity).toInt(),
          isMarkingAsRead: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isMarkingAsRead: false,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      emit(state.copyWith(isMarkingAsRead: true, clearError: true));

      await _notificationService.markAllAsRead();

      final updatedNotifications = state.notifications.map((n) {
        return NotificationModel(
          id: n.id,
          type: n.type,
          title: n.title,
          message: n.message,
          data: n.data,
          read: true,
          readAt: DateTime.now(),
          createdAt: n.createdAt,
          updatedAt: DateTime.now(),
        );
      }).toList();

      emit(
        state.copyWith(
          notifications: updatedNotifications,
          unreadCount: 0,
          isMarkingAsRead: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isMarkingAsRead: false,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      emit(state.copyWith(isDeleting: true, clearError: true));

      await _notificationService.deleteNotification(notificationId);

      final deletedNotification = state.notifications.firstWhere(
        (n) => n.id == notificationId,
        orElse: () => throw Exception('Notification not found'),
      );

      final updatedNotifications = state.notifications
          .where((n) => n.id != notificationId)
          .toList();

      final newUnreadCount = deletedNotification.read
          ? state.unreadCount
          : (state.unreadCount - 1).clamp(0, double.infinity).toInt();

      emit(
        state.copyWith(
          notifications: updatedNotifications,
          totalCount: state.totalCount - 1,
          unreadCount: newUnreadCount,
          isDeleting: false,
          clearExpanded: state.expandedNotificationId == notificationId,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isDeleting: false,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  /// Toggle notification expansion
  void toggleExpansion(String notificationId) {
    if (state.expandedNotificationId == notificationId) {
      emit(state.copyWith(clearExpanded: true));
    } else {
      emit(state.copyWith(expandedNotificationId: notificationId));
      
      // Mark as read if unread
      final notification = state.notifications.firstWhere(
        (n) => n.id == notificationId,
        orElse: () => throw Exception('Notification not found'),
      );
      
      if (!notification.read) {
        markAsRead(notificationId);
      }
    }
  }

  /// Refresh unread count and notification list (keeps badge and list in sync)
  Future<void> refreshUnreadNotifications() async {
    try {
      final result = await _notificationService.getNotifications(
        limit: 100,
        offset: 0,
      );
      emit(
        state.copyWith(
          notifications: result['notifications'] as List<NotificationModel>,
          totalCount: result['totalCount'] as int,
          unreadCount: result['unreadCount'] as int,
        ),
      );
    } catch (e) {
      // Silently fail - don't show error for unread count refresh
    }
  }
}

