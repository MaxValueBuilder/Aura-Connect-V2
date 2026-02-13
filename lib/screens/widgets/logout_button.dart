import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../features/auth/auth_cubit.dart';
import '../dashboard/widgets/app_bar_icon_button.dart';

/// Logout button for app bar. Calls AuthCubit.logout() then navigates to landing.
class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBarIconButton(
      backgroundColor: AppColors.error,
      icon: Icons.logout,
      onPressed: () async {
        await context.read<AuthCubit>().logout();
        if (context.mounted) {
          AppRouter.pushNamedAndRemoveUntil(context, AppRoutes.landing);
        }
      },
    );
  }
}
