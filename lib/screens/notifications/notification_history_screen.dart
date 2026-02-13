import 'package:aura/screens/consultation/widgets/label_chip.dart';
import 'package:aura/screens/widgets/app_bar_logo_title.dart';
import 'package:aura/screens/widgets/primary_icon_button.dart';
import 'package:aura/screens/widgets/screen_header.dart';
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
        title: AppBarLogoTitle(),
        backgroundColor: AppColors.white,
        elevation: 0,
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
                ScreenHeader(
                  title: 'Notifications',
                  subtitle: 'All caught up • ${state.totalCount} Total',
                ),

                if (state.unreadCount > 0)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 16, 16, 0),
                      child: SizedBox(
                        width: 160,
                        child: PrimaryIconButton(
                          onPressed: state.isMarkingAsRead
                              ? () {}
                              : () => context
                                    .read<NotificationCubit>()
                                    .markAllAsRead(),
                          icon: Icons.done_all,
                          text: 'Mark all as read',
                        ),
                      ),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: notification.read ? AppColors.white : AppColors.successLight,
        border: Border(
          left: BorderSide(
            color: notification.read ? Colors.transparent : AppColors.success,
            width: 4,
          ),
        ),
      ),

      child: InkWell(
        onTap: () =>
            context.read<NotificationCubit>().toggleExpansion(notification.id),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Icon + Title | Delete + Expand
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        _getNotificationIcon(notification.type),
                        color: _getNotificationIconColor(notification.type),
                        size: 22,
                      ),
                      const SizedBox(width: 8),

                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                notification.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                  fontFamily: 'Fraunces',
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!notification.read) ...[
                              const SizedBox(width: 4),
                              LabelChip(
                                label: 'New',
                                textColor: AppColors.white,
                                backgroundColor: AppColors.primary,
                                padding: 4,
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: AppColors.error,
                          size: 22,
                        ),
                        onPressed: () => _showDeleteDialog(notification),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        style: IconButton.styleFrom(
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: AppColors.textSecondary,
                          size: 24,
                        ),
                        onPressed: () => context
                            .read<NotificationCubit>()
                            .toggleExpansion(notification.id),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        style: IconButton.styleFrom(
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                  // Row 2: Category tag (pill)
                  const SizedBox(height: 12),
                  LabelChip(
                    label: _getNotificationTypeLabel(notification.type),
                    textColor: AppColors.textPrimary,
                    backgroundColor: AppColors.primaryLight.withAlpha(25),
                    padding: 6,
                  ),
                  // Row 3: Message/Description
                  const SizedBox(height: 12),
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: isExpanded ? null : 2,
                    overflow: isExpanded ? null : TextOverflow.ellipsis,
                  ),
                  // Row 4: Timestamp (relative • absolute)
                  const SizedBox(height: 8),
                  Text(
                    _formatTimestamp(notification.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
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
        color: AppColors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        border: Border(top: BorderSide(color: AppColors.border)),
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
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.infoLight,
            borderRadius: BorderRadius.circular(4),
            border: Border(
              left: BorderSide(color: AppColors.primary, width: 4),
            ),
          ),
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 12,
                color: AppColors.info,
                height: 1.5,
              ),
              children: [
                TextSpan(
                  text: 'Note:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.info,
                  ),
                ),
                TextSpan(
                  text:
                      ' Your consultation has been completed and saved. You can view it in the consultation history.',
                ),
              ],
            ),
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

  /// Format: "5 days ago • Dec 30, 2025, 4:03 PM"
  String _formatTimestamp(DateTime date) {
    final relative = _formatDate(date);
    final hour12 = date.hour == 0
        ? 12
        : (date.hour > 12 ? date.hour - 12 : date.hour);
    final amPm = date.hour >= 12 ? 'PM' : 'AM';
    final absolute =
        '${_monthAbbr(date.month)} ${date.day}, ${date.year}, '
        '${hour12.toString()}:${date.minute.toString().padLeft(2, '0')} $amPm';
    return '$relative • $absolute';
  }

  String _monthAbbr(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
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
