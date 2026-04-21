import 'package:aura/screens/widgets/app_bar_logo_title.dart';
import 'package:aura/screens/widgets/logout_button.dart';
import 'package:aura/screens/widgets/screen_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../features/notification/notification_cubit.dart';
import '../../../features/auth/auth_cubit.dart';
import '../../../features/settings/settings_cubit.dart';
import '../../../features/settings/settings_state.dart';
import '../../../core/routes/app_routes.dart';
import 'widgets/profile_tab.dart';
import 'widgets/practice_tab.dart';
import 'widgets/billing_tab.dart';
import 'widgets/notifications_tab.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // Load data when screen initializes (matches web: getUserProfile, getClinicInfo, getClinicMembers, getNotifStatus)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthCubit>().state;
      final user = authState.user;
      final userId = user?.id;
      final clinicId = user?.clinicId;

      if (userId != null) {
        context.read<SettingsCubit>().loadProfile(userId);
        context.read<SettingsCubit>().loadNotificationPreferences(userId);
      }
      if (clinicId != null) {
        context.read<SettingsCubit>().loadClinic(clinicId);
        context.read<SettingsCubit>().loadClinicMembers(clinicId);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) =>
          previous.isAuthenticated && !current.isAuthenticated,
      listener: (context, state) {
        // Navigate to landing screen after logout
        AppRouter.pushNamedAndRemoveUntil(context, AppRoutes.onboarding);
      },
      child: Scaffold(
        appBar: AppBar(
          title: AppBarLogoTitle(),
          backgroundColor: AppColors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [const LogoutButton(), const SizedBox(width: 16)],
        ),
        body: BlocListener<SettingsCubit, SettingsState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: AppColors.error,
                ),
              );
              context.read<SettingsCubit>().clearError();
            }
            if (state.successMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.successMessage!),
                  backgroundColor: AppColors.success,
                ),
              );
              context.read<SettingsCubit>().clearSuccess();
              // Refresh notification badge after profile/practice update
              getIt<NotificationCubit>().refreshUnreadNotifications();
            }
          },
          child: SafeArea(
            child: Column(
              children: [
                ScreenHeader(
                  title: 'Settings',
                  subtitle: 'Manage your account, clinic, and preference',
                ),
                const SizedBox(height: 16),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.background,

                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withAlpha(200),
                      width: 1.5,
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textSecondary,
                    dividerColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.gray200, width: 1),
                      color: AppColors.white,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: 2,
                    ),
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_outline, size: 20),
                            const SizedBox(width: 6),
                            const Text('Profile'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.business_outlined, size: 20),
                            const SizedBox(width: 6),
                            const Text('Practice'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.credit_card_outlined, size: 20),
                            const SizedBox(width: 6),
                            const Text('Billing'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notifications_outlined, size: 20),
                            const SizedBox(width: 6),
                            const Text('Notifications'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      ProfileTab(),
                      PracticeTab(),
                      BillingTab(),
                      NotificationsTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
