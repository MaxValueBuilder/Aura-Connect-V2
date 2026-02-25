import 'package:aura/core/routes/app_routes.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/auth/auth_cubit.dart';
import 'package:aura/screens/auth/widgets/custom_auth_button.dart';
import 'package:aura/screens/auth/widgets/google_sign_in_button.dart';
import 'package:aura/screens/widgets/logo_badge.dart';
import 'package:aura/screens/auth/widgets/paw_print_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
        listenWhen: (previous, current) => current.isSignupSuccess,
        listener: (context, state) {
          if (state.isSignupSuccess && state.signupSuccessMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.signupSuccessMessage!),
                backgroundColor: AppColors.success,
              ),
            );
            context.read<AuthCubit>().clearSignupSuccess();
            Navigator.of(context).pop();
          }
        },
        child: BlocListener<AuthCubit, AuthState>(
          listenWhen: (previous, current) => current.hasError,
          listener: (context, state) {
            if (state.hasError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.errorMessage.replaceAll('Exception: ', ''),
                  ),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          child: Scaffold(
            backgroundColor: AppColors.secondary,
            body: Stack(
              children: [
                const PawPrintBackground(),
                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 24),
                        const LogoBadge(),
                        const SizedBox(height: 32),
                        Text(
                          'Sign Up to your Account',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.white,
                            fontFamily: 'Fraunces',
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sign up to get started with Aura Connect',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: AppColors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildLabel('First Name*'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _firstNameController,
                          hint: 'Enter your first name',
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 20),
                        _buildLabel('Last Name*'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _lastNameController,
                          hint: 'Enter your last name',
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 20),
                        _buildLabel('Email*'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _emailController,
                          hint: 'Enter your email address',
                          icon: Icons.mail_outline,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 20),
                        _buildLabel('Password*'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _passwordController,
                          hint: 'Create a password',
                          icon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          onToggleObscure: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildLabel('Confirm Password*'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _confirmPasswordController,
                          hint: 'Confirm your password',
                          icon: Icons.lock_outline,
                          obscureText: _obscureConfirmPassword,
                          onToggleObscure: () => setState(
                            () => _obscureConfirmPassword =
                                !_obscureConfirmPassword,
                          ),
                        ),
                        SizedBox(height: screenSize.height * 0.04),
                        BlocBuilder<AuthCubit, AuthState>(
                          buildWhen: (p, c) => p.status != c.status,
                          builder: (context, state) {
                            return CustomAuthButton(
                              label: 'Sign Up',
                              onPressed: state.status == AuthStatus.loading
                                  ? null
                                  : () {
                                      final email = _emailController.text
                                          .trim();
                                      final password = _passwordController.text;
                                      final confirmPassword =
                                          _confirmPasswordController.text;
                                      final firstName = _firstNameController
                                          .text
                                          .trim();
                                      final lastName = _lastNameController.text
                                          .trim();
                                      if (firstName.isEmpty ||
                                          lastName.isEmpty ||
                                          email.isEmpty ||
                                          password.isEmpty) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Please fill in all fields',
                                            ),
                                            backgroundColor: AppColors.error,
                                          ),
                                        );
                                        return;
                                      }
                                      if (password != confirmPassword) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Passwords do not match',
                                            ),
                                            backgroundColor: AppColors.error,
                                          ),
                                        );
                                        return;
                                      }
                                      context.read<AuthCubit>().signup(
                                        email: email,
                                        password: password,
                                        firstName: firstName,
                                        lastName: lastName,
                                      );
                                    },
                              isLoading: state.status == AuthStatus.loading,
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: AppColors.white.withValues(alpha: 0.3),
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
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
                        BlocBuilder<AuthCubit, AuthState>(
                          buildWhen: (p, c) => p.status != c.status,
                          builder: (context, state) {
                            return GoogleSignInButton(
                              onPressed: state.status == AuthStatus.loading
                                  ? null
                                  : () => context
                                        .read<AuthCubit>()
                                        .loginWithGoogle(),
                            );
                          },
                        ),
                        SizedBox(height: screenSize.height * 0.08),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: TextStyle(
                                color: AppColors.white.withValues(alpha: 0.9),
                                fontSize: 14,
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Log In',
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
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    VoidCallback? onToggleObscure,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: AppColors.gray900),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.gray500),
        prefixIcon: Icon(icon, color: AppColors.gray500, size: 22),
        suffixIcon: onToggleObscure != null
            ? IconButton(
                icon: Icon(
                  obscureText
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.gray500,
                  size: 22,
                ),
                onPressed: onToggleObscure,
              )
            : null,
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gray300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gray300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}
