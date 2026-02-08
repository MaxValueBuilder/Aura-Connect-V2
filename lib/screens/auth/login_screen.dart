import 'package:aura/core/routes/app_routes.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/auth/auth_cubit.dart';
import 'package:aura/screens/auth/widgets/custom_auth_button.dart';
import 'package:aura/screens/auth/widgets/google_sign_in_button.dart';
import 'package:aura/screens/auth/widgets/logo_badge.dart';
import 'package:aura/screens/auth/widgets/paw_print_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) =>
          previous.status == AuthStatus.loading &&
          current.status == AuthStatus.authenticated,
      listener: (context, state) {
        if (state.isAuthenticated) {
          if (state.hasClinic) {
            AppRouter.pushNamedAndRemoveUntil(context, AppRoutes.dashboard);
          } else {
            AppRouter.pushNamedAndRemoveUntil(
              context,
              AppRoutes.clinicSetup,
              arguments: ClinicSetupArguments(userEmail: state.userEmail),
            );
          }
        }
      },
      child: BlocListener<AuthCubit, AuthState>(
        listenWhen: (previous, current) => current.hasError,
        listener: (context, state) {
          if (state.hasError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage.replaceAll('Exception: ', '')),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.secondary,
          body: Stack(
            children: [
              // Paw print background pattern
              const PawPrintBackground(),

              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 24),

                      // Logo badge
                      const LogoBadge(),

                      const SizedBox(height: 32),

                      // Title
                      Text(
                        'Log in to your Account',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.white,
                          fontFamily: "Fraunces",
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Subtitle
                      Text(
                        'Log in to continue to Aura Connect',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Email field
                      Text(
                        'Email*',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: AppColors.gray900),
                        decoration: InputDecoration(
                          hintText: 'Enter your email address',
                          hintStyle: const TextStyle(color: AppColors.gray500),
                          prefixIcon: Icon(
                            Icons.mail_outline,
                            color: AppColors.gray500,
                            size: 22,
                          ),
                          filled: true,
                          fillColor: AppColors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.gray300,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.gray300,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Password field
                      Text(
                        'Password*',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: AppColors.gray900),
                        decoration: InputDecoration(
                          hintText: 'Enter your password',
                          hintStyle: const TextStyle(color: AppColors.gray500),
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: AppColors.gray500,
                            size: 22,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AppColors.gray500,
                              size: 22,
                            ),
                            onPressed: () {
                              setState(
                                () => _obscurePassword = !_obscurePassword,
                              );
                            },
                          ),
                          filled: true,
                          fillColor: AppColors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.gray300,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.gray300,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Remember me & Forgot password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _rememberMe,
                                  onChanged: (v) =>
                                      setState(() => _rememberMe = v ?? true),
                                  activeColor: AppColors.primary,
                                  fillColor: WidgetStateProperty.resolveWith((
                                    states,
                                  ) {
                                    if (states.contains(WidgetState.selected)) {
                                      return AppColors.primary;
                                    }
                                    return AppColors.gray300;
                                  }),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Remember Me',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () {
                              // TODO: Forgot password flow
                            },
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Login button
                      BlocBuilder<AuthCubit, AuthState>(
                        buildWhen: (p, c) => p.status != c.status,
                        builder: (context, state) {
                          return CustomAuthButton(
                            label: 'Login',
                            onPressed: state.status == AuthStatus.loading
                                ? null
                                : () => context.read<AuthCubit>().login(),
                            isLoading: state.status == AuthStatus.loading,
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // OR divider
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: AppColors.white.withValues(alpha: 0.3),
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'OR',
                              style: TextStyle(
                                color: AppColors.white.withValues(alpha: 0.9),
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: AppColors.white.withValues(alpha: 0.3),
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      GoogleSignInButton(
                        onPressed: () => context.read<AuthCubit>().login(),
                      ),

                      SizedBox(height: screenSize.height * 0.1),

                      // Sign up prompt
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't you have an account? ",
                            style: TextStyle(
                              color: AppColors.white.withValues(alpha: 0.9),
                              fontSize: 14,
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                AppRouter.pushNamed(context, AppRoutes.signup),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
