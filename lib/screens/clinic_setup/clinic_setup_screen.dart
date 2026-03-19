import 'package:aura/core/routes/app_routes.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/auth/auth_cubit.dart';
import 'package:aura/screens/auth/widgets/custom_auth_button.dart';
import 'package:aura/screens/widgets/logo_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ClinicSetupScreen extends StatefulWidget {
  final String? userEmail;

  const ClinicSetupScreen({super.key, this.userEmail});

  @override
  State<ClinicSetupScreen> createState() => _ClinicSetupScreenState();
}

class _ClinicSetupScreenState extends State<ClinicSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clinicNameController = TextEditingController();
  final _clinicEmailController = TextEditingController();
  final _clinicPhoneController = TextEditingController();
  final _clinicWebsiteController = TextEditingController();

  bool _isLoading = false;
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _clinicNameController.addListener(_updateButtonState);
    _clinicEmailController.addListener(_updateButtonState);

    if (widget.userEmail != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _clinicEmailController.text = widget.userEmail!;
          _updateButtonState();
        }
      });
    } else {
      _updateButtonState();
    }
  }

  void _updateButtonState() {
    if (mounted) {
      final wasEnabled = _isButtonEnabled;
      _isButtonEnabled = _areRequiredFieldsFilled && !_isLoading;

      if (wasEnabled != _isButtonEnabled) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _clinicNameController.removeListener(_updateButtonState);
    _clinicEmailController.removeListener(_updateButtonState);
    _clinicNameController.dispose();
    _clinicEmailController.dispose();
    _clinicPhoneController.dispose();
    _clinicWebsiteController.dispose();
    super.dispose();
  }

  bool get _areRequiredFieldsFilled {
    return _clinicNameController.text.trim().isNotEmpty &&
        _clinicEmailController.text.trim().isNotEmpty;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _isButtonEnabled = false;
    });

    try {
      await context.read<AuthCubit>().setupClinic(
        clinicName: _clinicNameController.text.trim(),
        clinicEmail: _clinicEmailController.text.trim(),
        clinicPhone: _clinicPhoneController.text.trim().isEmpty
            ? null
            : _clinicPhoneController.text.trim(),
        clinicWebsite: _clinicWebsiteController.text.trim().isEmpty
            ? null
            : _clinicWebsiteController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Clinic setup completed successfully!'),
            backgroundColor: AppColors.success,
          ),
        );

        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            AppRouter.pushNamedAndRemoveUntil(context, AppRoutes.dashboard);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e
                  .toString()
                  .replaceAll('Exception: ', '')
                  .replaceAll('AuthException: ', ''),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isButtonEnabled = _areRequiredFieldsFilled;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              AppRouter.pushReplacementNamed(context, AppRoutes.onboarding);
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const LogoBadge(),
                const SizedBox(height: 32),

                // Title
                const Text(
                  'Start Your New Trial',
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

                // Subtitle
                Text(
                  'Welcome to Aura Connect! Let\'s set up your new veterinary client for your free trial.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.white.withValues(alpha: 0.9),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // Clinic Name*
                _buildLabel('Clinic Name*'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _clinicNameController,
                  hintText: 'Enter your clinic name',
                  icon: Icons.business_rounded,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Clinic name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Clinic Website (optional)
                _buildLabel('Clinic Website'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _clinicWebsiteController,
                  hintText: 'Enter your clinic website',
                  icon: Icons.language_outlined,
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 20),

                // Clinic Email*
                _buildLabel('Clinic Email*'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _clinicEmailController,
                  hintText: 'Enter your clinic email',
                  icon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Clinic email is required';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Clinic Phone (optional)
                _buildLabel('Clinic Phone'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _clinicPhoneController,
                  hintText: 'Enter your clinic phone number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 40),

                // Start Free Trial Button (using CustomAuthButton)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: CustomAuthButton(
                    label: 'Start Free Trial',
                    onPressed: _isButtonEnabled ? _handleSubmit : null,
                    isLoading: _isLoading,
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
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.white,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: AppColors.gray900),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: AppColors.gray500),
        prefixIcon: Icon(icon, size: 22, color: AppColors.gray500),
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
          horizontal: 12,
          vertical: 14,
        ),
      ),
    );
  }
}
