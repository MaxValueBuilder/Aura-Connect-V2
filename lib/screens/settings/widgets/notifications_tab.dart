import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/settings/settings_cubit.dart';
import '../../../../features/settings/settings_state.dart';

class NotificationsTab extends StatefulWidget {
  const NotificationsTab({super.key});

  @override
  State<NotificationsTab> createState() => _NotificationsTabState();
}

class _NotificationsTabState extends State<NotificationsTab> {
  bool _emailConsultationReminders = true;
  bool _emailSystemAlerts = true;
  bool _emailBillingUpdates = true;
  bool _inAppNotifications = true;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Load preferences when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsCubit>().loadNotificationPreferences();
    });
  }

  void _updateLocalStateFromBackend(SettingsState state) {
    if (state.notificationPreferences != null && !_isInitialized) {
      // Use postFrameCallback to avoid calling setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _emailConsultationReminders =
                state.notificationPreferences!['emailConsultationCompletion'] ??
                true;
            _emailSystemAlerts =
                state.notificationPreferences!['emailSystemAlerts'] ?? true;
            _emailBillingUpdates =
                state.notificationPreferences!['emailBillingUpdates'] ?? true;
            _inAppNotifications =
                state.notificationPreferences!['inAppNotifications'] ?? true;
            _isInitialized = true;
          });
        }
      });
    }
  }

  Future<void> _handleNotificationChange(
    String key,
    bool value,
    SettingsCubit cubit,
  ) async {
    // Update local state immediately for responsive UI
    setState(() {
      switch (key) {
        case 'emailConsultationCompletion':
          _emailConsultationReminders = value;
          break;
        case 'emailSystemAlerts':
          _emailSystemAlerts = value;
          break;
        case 'emailBillingUpdates':
          _emailBillingUpdates = value;
          break;
        case 'inAppNotifications':
          _inAppNotifications = value;
          break;
      }
    });

    // Auto-save to backend
    final success = await cubit.updateNotificationPreferences(
      emailConsultationCompletion: key == 'emailConsultationCompletion'
          ? value
          : null,
      emailSystemAlerts: key == 'emailSystemAlerts' ? value : null,
      emailBillingUpdates: key == 'emailBillingUpdates' ? value : null,
      inAppNotifications: key == 'inAppNotifications' ? value : null,
    );

    // Revert state on error
    if (!success && mounted) {
      setState(() {
        switch (key) {
          case 'emailConsultationCompletion':
            _emailConsultationReminders = !value;
            break;
          case 'emailSystemAlerts':
            _emailSystemAlerts = !value;
            break;
          case 'emailBillingUpdates':
            _emailBillingUpdates = !value;
            break;
          case 'inAppNotifications':
            _inAppNotifications = !value;
            break;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        // Update local state from backend preferences
        _updateLocalStateFromBackend(state);

        // Show loading state while loading preferences
        if (state.isLoadingNotifications && !_isInitialized) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notification Preferences',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose how you want to be notified about important events',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              // Email Notifications Section
              Row(
                children: [
                  Icon(
                    Icons.email_outlined,
                    size: 20,
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Email Notifications',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildNotificationSwitch(
                title: 'Consultation Completion',
                subtitle:
                    'Get notified when each consultation is completed and documentation is ready',
                value: _emailConsultationReminders,
                onChanged: (value) {
                  _handleNotificationChange(
                    'emailConsultationCompletion',
                    value,
                    context.read<SettingsCubit>(),
                  );
                },
              ),
              const SizedBox(height: 12),

              _buildNotificationSwitch(
                title: 'System Alerts',
                subtitle: 'Important system notifications and updates',
                value: _emailSystemAlerts,
                onChanged: (value) {
                  _handleNotificationChange(
                    'emailSystemAlerts',
                    value,
                    context.read<SettingsCubit>(),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildNotificationSwitch(
                title: 'Billing Updates',
                subtitle:
                    'Receive notifications about subscription and billing changes',
                value: _emailBillingUpdates,
                onChanged: (value) {
                  _handleNotificationChange(
                    'emailBillingUpdates',
                    value,
                    context.read<SettingsCubit>(),
                  );
                },
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 32),
              // In-App Notifications Section
              Row(
                children: [
                  Icon(
                    Icons.notifications_outlined,
                    size: 20,
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'In-App Notifications',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildNotificationSwitch(
                title: 'General In-App Notifications',
                subtitle: 'Show general notifications within the application',
                value: _inAppNotifications,
                onChanged: (value) {
                  _handleNotificationChange(
                    'inAppNotifications',
                    value,
                    context.read<SettingsCubit>(),
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Changes are saved automatically',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
