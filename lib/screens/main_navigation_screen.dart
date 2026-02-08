import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/di/injection.dart';
import '../../features/navigation/navigation_cubit.dart';
import '../../features/navigation/navigation_state.dart';
import 'dashboard/dashboard_screen.dart';
import 'history/history_screen.dart';
import 'patients/patients_screen.dart';
import 'settings/settings_screen.dart';

/// Main navigation wrapper that manages bottom navigation bar
/// and switches between different screens
class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  final List<Widget> _screens = const [
    DashboardScreen(),
    HistoryScreen(),
    PatientsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NavigationCubit>.value(
      value: getIt<NavigationCubit>(),
      child: BlocBuilder<NavigationCubit, NavigationState>(
        builder: (context, state) {
          return Scaffold(
            body: _screens[state.selectedIndex],
            bottomNavigationBar: ConvexAppBar(
              key: ValueKey(state.selectedIndex),
              items: const [
                TabItem(
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard,
                  title: 'Dashboard',
                ),
                TabItem(
                  icon: Icons.history_outlined,
                  activeIcon: Icons.history,
                  title: 'History',
                ),
                TabItem(
                  icon: Icons.people_outline,
                  activeIcon: Icons.people,
                  title: 'Patients',
                ),
                TabItem(
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings,
                  title: 'Settings',
                ),
              ],
              initialActiveIndex: state.selectedIndex,
              backgroundColor: AppColors.white,
              activeColor: AppColors.primary,
              color: AppColors.textSecondary,
              style: TabStyle.react,
              height: 60,
              curveSize: 100,
              top: -20,
              onTap: (int index) {
                context.read<NavigationCubit>().changeTab(index);
              },
            ),
          );
        },
      ),
    );
  }
}
