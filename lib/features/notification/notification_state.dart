import 'package:equatable/equatable.dart';
import '../../models/notification_model.dart';

class NotificationState extends Equatable {
  final List<NotificationModel> notifications;
  final int unreadCount;
  final int totalCount;
  final bool isLoading;
  final bool isMarkingAsRead;
  final bool isDeleting;
  final String errorMessage;
  final String? expandedNotificationId;

  const NotificationState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.totalCount = 0,
    this.isLoading = false,
    this.isMarkingAsRead = false,
    this.isDeleting = false,
    this.errorMessage = '',
    this.expandedNotificationId,
  });

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    int? unreadCount,
    int? totalCount,
    bool? isLoading,
    bool? isMarkingAsRead,
    bool? isDeleting,
    String? errorMessage,
    String? expandedNotificationId,
    bool clearError = false,
    bool clearExpanded = false,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      totalCount: totalCount ?? this.totalCount,
      isLoading: isLoading ?? this.isLoading,
      isMarkingAsRead: isMarkingAsRead ?? this.isMarkingAsRead,
      isDeleting: isDeleting ?? this.isDeleting,
      errorMessage: clearError ? '' : (errorMessage ?? this.errorMessage),
      expandedNotificationId: clearExpanded
          ? null
          : (expandedNotificationId ?? this.expandedNotificationId),
    );
  }

  bool get hasError => errorMessage.isNotEmpty;

  @override
  List<Object?> get props => [
        notifications,
        unreadCount,
        totalCount,
        isLoading,
        isMarkingAsRead,
        isDeleting,
        errorMessage,
        expandedNotificationId,
      ];
}

