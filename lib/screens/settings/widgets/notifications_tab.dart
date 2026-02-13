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

  // Notification preferences are loaded by SettingsScreen on init

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
    String? userId,
  ) async {
    if (userId == null) return;

    // Update local state immediately for responsive UI
    final newConsultation = key == 'emailConsultationCompletion'
        ? value
        : _emailConsultationReminders;
    final newSystemAlerts = key == 'emailSystemAlerts'
        ? value
        : _emailSystemAlerts;
    final newBillingUpdates = key == 'emailBillingUpdates'
        ? value
        : _emailBillingUpdates;
    final newInApp = key == 'inAppNotifications' ? value : _inAppNotifications;

    setState(() {
      _emailConsultationReminders = newConsultation;
      _emailSystemAlerts = newSystemAlerts;
      _emailBillingUpdates = newBillingUpdates;
      _inAppNotifications = newInApp;
    });

    // Auto-save to backend (send full notif map, matches web)
    final notif = <String, bool>{
      'emailConsultationCompletion': newConsultation,
      'emailSystemAlerts': newSystemAlerts,
      'emailBillingUpdates': newBillingUpdates,
      'inAppNotifications': newInApp,
    };
    final success = await cubit.updateNotificationPreferences(userId, notif);

    // Revert state on error
    if (!success && mounted) {
      final prefs = cubit.state.notificationPreferences;
      if (prefs != null) {
        setState(() {
          _emailConsultationReminders =
              prefs['emailConsultationCompletion'] ?? true;
          _emailSystemAlerts = prefs['emailSystemAlerts'] ?? true;
          _emailBillingUpdates = prefs['emailBillingUpdates'] ?? true;
          _inAppNotifications = prefs['inAppNotifications'] ?? true;
        });
      }
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
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 16.0,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Icon(
                        Icons.notifications_outlined,
                        size: 20,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notification Preferences',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            fontFamily: 'Fraunces',
                          ),
                        ),
                        Text(
                          'Pick notification style for key events.',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                const SizedBox(height: 32),
                // Email Notifications Section
                Row(
                  children: [
                    Icon(
                      Icons.email_outlined,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Email Notifications',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
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
                      state.profile?.id,
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
                      state.profile?.id,
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
                      state.profile?.id,
                    );
                  },
                ),
                const SizedBox(height: 32),

                // In-App Notifications Section
                Row(
                  children: [
                    Icon(
                      Icons.notifications_outlined,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'In-App Notifications',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
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
                      state.profile?.id,
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
        color: AppColors.gray100,
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
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
