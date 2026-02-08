import 'package:aura/core/routes/app_routes.dart';
import 'package:aura/features/auth/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _hasNavigated = false;

  void _navigateBasedOnAuthState(AuthState authState) {
    // Don't navigate if still loading or already navigated
    if (authState.isLoading || _hasNavigated || !mounted) {
      return;
    }

    _hasNavigated = true;

    if (authState.isAuthenticated) {
      // Navigate based on clinic setup status
      if (authState.hasClinic) {
        AppRouter.pushReplacementNamed(context, AppRoutes.dashboard);
      } else {
        // User authenticated but no clinic setup
        AppRouter.pushReplacementNamed(
          context,
          AppRoutes.clinicSetup,
          arguments: ClinicSetupArguments(userEmail: authState.userEmail),
        );
      }
    } else {
      // Not authenticated - go to landing screen
      AppRouter.pushReplacementNamed(context, AppRoutes.landing);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      // Listen for changes when status is no longer loading
      listenWhen: (previous, current) {
        // Navigate when status changes from loading to something else
        // or when status changes and we haven't navigated yet
        return (previous.isLoading && !current.isLoading) ||
            (!current.isLoading && !_hasNavigated);
      },
      listener: (context, authState) {
        _navigateBasedOnAuthState(authState);
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          // Also check current state in case we missed the listener
          if (!authState.isLoading && !_hasNavigated) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _navigateBasedOnAuthState(authState);
              }
            });
          }

          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/logo.svg',
                    width: 80,
                    height: 80,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Aura Connect',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'AI-Powered Veterinary Care',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 48),
                  const CircularProgressIndicator(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
