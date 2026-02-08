import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../features/notification/notification_cubit.dart';
import '../../../features/notification/notification_state.dart';
import '../../../models/notification_model.dart';

class NotificationHistoryScreen extends StatefulWidget {
  const NotificationHistoryScreen({super.key});

  @override
  State<NotificationHistoryScreen> createState() =>
      _NotificationHistoryScreenState();
}

class _NotificationHistoryScreenState extends State<NotificationHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationCubit>().loadNotifications(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),

        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocConsumer<NotificationCubit, NotificationState>(
        listener: (context, state) {
          if (state.hasError && state.errorMessage.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return SafeArea(
            child: Column(
              children: [
                // Header with stats and mark all as read
                Container(
                  padding: const EdgeInsets.all(16),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            state.unreadCount > 0
                                ? '${state.unreadCount} unread'
                                : 'All caught up •',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${state.totalCount} total',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      if (state.unreadCount > 0)
                        TextButton.icon(
                          onPressed: state.isMarkingAsRead
                              ? null
                              : () => context
                                    .read<NotificationCubit>()
                                    .markAllAsRead(),
                          icon: const Icon(Icons.done_all, size: 18),
                          label: const Text('Mark all as read'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                          ),
                        ),
                    ],
                  ),
                ),

                // Notifications list
                Expanded(
                  child: state.notifications.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: () => context
                              .read<NotificationCubit>()
                              .loadNotifications(refresh: true),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: state.notifications.length,
                            itemBuilder: (context, index) {
                              final notification = state.notifications[index];
                              final isExpanded =
                                  state.expandedNotificationId ==
                                  notification.id;
                              return _buildNotificationCard(
                                notification,
                                isExpanded,
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(
    NotificationModel notification,
    bool isExpanded,
  ) {
    return Card(
      elevation: notification.read ? 0 : 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: notification.read ? AppColors.border : AppColors.primary,
          width: notification.read ? 1 : 2,
        ),
      ),
      color: notification.read
          ? AppColors.white
          : AppColors.white.withValues(alpha: 0.05),
      child: InkWell(
        onTap: () =>
            context.read<NotificationCubit>().toggleExpansion(notification.id),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notification header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getNotificationIconColor(
                        notification.type,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getNotificationIcon(notification.type),
                      color: _getNotificationIconColor(notification.type),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            if (!notification.read)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'New',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.message,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: isExpanded ? null : 2,
                          overflow: isExpanded ? null : TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Chip(
                              label: Text(
                                _getNotificationTypeLabel(notification.type),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              backgroundColor: AppColors.primaryLight
                                  .withValues(alpha: 0.2),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 0,
                              ),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                              side: BorderSide.none,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatDate(notification.createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Actions
                  Column(
                    children: [
                      IconButton(
                        icon: Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () => context
                            .read<NotificationCubit>()
                            .toggleExpansion(notification.id),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: AppColors.error,
                          size: 20,
                        ),
                        onPressed: () => _showDeleteDialog(notification),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Expanded details
            if (isExpanded) _buildNotificationDetails(notification),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationDetails(NotificationModel notification) {
    final data = notification.data ?? {};

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Render details based on notification type
          if (notification.type == 'system_alert' && data['details'] != null)
            _buildSystemAlertDetails(data['details'] as Map<String, dynamic>)
          else if (notification.type == 'billing_update' &&
              data['details'] != null)
            _buildBillingDetails(data['details'] as Map<String, dynamic>)
          else if (notification.type == 'consultation_completion')
            _buildConsultationDetails(data)
          else
            _buildDefaultDetails(),

          const SizedBox(height: 16),
          Divider(color: AppColors.border),
          const SizedBox(height: 8),
          Text(
            'Best regards,\nThe Aura Connect Team',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemAlertDetails(Map<String, dynamic> details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(
            'System Update',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.info,
            ),
          ),
        ),
        ...details.entries
            .where((e) => e.value is! Map && e.value is! List)
            .map(
              (entry) => _buildDetailRow(
                _capitalizeFirst(entry.key),
                entry.value.toString(),
              ),
            ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.infoLight,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'This is an automated system notification. If you did not make these changes, please contact support immediately.',
            style: TextStyle(fontSize: 12, color: AppColors.info),
          ),
        ),
      ],
    );
  }

  Widget _buildBillingDetails(Map<String, dynamic> details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(
            'Billing Update',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.success,
            ),
          ),
        ),
        ...details.entries
            .where((e) => e.value is! Map && e.value is! List)
            .map(
              (entry) => _buildDetailRow(
                _capitalizeFirst(entry.key),
                entry.value.toString(),
              ),
            ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.successLight,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'Your billing information has been updated. You can view full details in your billing settings',
            style: TextStyle(fontSize: 12, color: AppColors.success),
          ),
        ),
      ],
    );
  }

  Widget _buildConsultationDetails(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(
            'Consultation',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.info,
            ),
          ),
        ),
        if (data['consultationId'] != null)
          _buildDetailRow('Consultation ID', data['consultationId'].toString()),
        if (data['patientName'] != null)
          _buildDetailRow('Patient', data['patientName'].toString()),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.infoLight,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'Your consultation has been completed and saved. You can view it in the consultation history.',
            style: TextStyle(fontSize: 12, color: AppColors.info),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultDetails() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        border: Border(
          left: BorderSide(color: AppColors.textSecondary, width: 4),
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'Note: This is an automated notification from the Aura Connect system.',
        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 64, color: AppColors.gray300),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up! Notifications will appear here.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(NotificationModel notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Notification'),
        content: const Text(
          'Are you sure you want to delete this notification?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<NotificationCubit>().deleteNotification(
                notification.id,
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'consultation_completion':
        return Icons.description;
      case 'billing_update':
        return Icons.credit_card;
      case 'system_alert':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationIconColor(String type) {
    switch (type) {
      case 'consultation_completion':
        return AppColors.info;
      case 'billing_update':
        return AppColors.success;
      case 'system_alert':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getNotificationTypeLabel(String type) {
    switch (type) {
      case 'consultation_completion':
        return 'Consultation';
      case 'billing_update':
        return 'Billing';
      case 'system_alert':
        return 'System';
      default:
        return 'General';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min${difference.inMinutes > 1 ? 's' : ''} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() +
        text
            .substring(1)
            .replaceAllMapped(
              RegExp(r'([A-Z])'),
              (match) => ' ${match.group(0)}',
            );
  }
}
