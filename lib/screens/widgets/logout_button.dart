import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../features/auth/auth_cubit.dart';
import '../dashboard/widgets/app_bar_icon_button.dart';

/// Logout button for app bar. Shows a confirmation modal, then calls AuthCubit.logout(); navigation to login is handled by the root BlocListener in main.dart.
class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  Future<void> _showLogoutConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Sign out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Sign out',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<AuthCubit>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBarIconButton(
      backgroundColor: AppColors.error,
      icon: Icons.logout,
      onPressed: () => _showLogoutConfirmation(context),
    );
  }
}
