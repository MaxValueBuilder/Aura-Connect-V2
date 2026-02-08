import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
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
    // Load data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthCubit>().state;
      final userEmail = authState.userEmail;
      if (userEmail != null) {
        context.read<SettingsCubit>().setUserEmail(userEmail);
      }
      context.read<SettingsCubit>().loadProfile(userEmail: userEmail);
      context.read<SettingsCubit>().loadClinic();
      context.read<SettingsCubit>().loadClinicUsers();
      context.read<SettingsCubit>().loadNotificationPreferences();
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
        AppRouter.pushNamedAndRemoveUntil(context, AppRoutes.landing);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Settings',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: AppColors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          bottom: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(icon: Icon(Icons.person_outline, size: 20), text: 'Profile'),
              Tab(
                icon: Icon(Icons.business_outlined, size: 20),
                text: 'Practice',
              ),
              Tab(
                icon: Icon(Icons.credit_card_outlined, size: 20),
                text: 'Billing',
              ),
              Tab(
                icon: Icon(Icons.notifications_outlined, size: 20),
                text: 'Notifications',
              ),
            ],
          ),
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
            }
          },
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
      ),
    );
  }
}
