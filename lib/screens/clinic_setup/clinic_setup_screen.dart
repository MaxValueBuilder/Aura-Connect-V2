import 'package:aura/core/routes/app_routes.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/auth/auth_cubit.dart';
import 'package:aura/screens/widgets/custom_landing_page_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  bool _isLoading = false;
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    // Listen to text changes to update button state
    // Add listeners FIRST before setting initial values
    _clinicNameController.addListener(_updateButtonState);
    _clinicEmailController.addListener(_updateButtonState);
    _firstNameController.addListener(_updateButtonState);
    _lastNameController.addListener(_updateButtonState);

    // Pre-fill email if available (after listeners are added)
    if (widget.userEmail != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _clinicEmailController.text = widget.userEmail!;
          _updateButtonState();
        }
      });
    } else {
      // Update initial button state
      _updateButtonState();
    }
  }

  void _updateButtonState() {
    if (mounted) {
      final wasEnabled = _isButtonEnabled;
      _isButtonEnabled = _areRequiredFieldsFilled && !_isLoading;

      // Only call setState if the state actually changed
      if (wasEnabled != _isButtonEnabled) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _clinicNameController.removeListener(_updateButtonState);
    _clinicEmailController.removeListener(_updateButtonState);
    _firstNameController.removeListener(_updateButtonState);
    _lastNameController.removeListener(_updateButtonState);
    _clinicNameController.dispose();
    _clinicEmailController.dispose();
    _clinicPhoneController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  /// Check if all required fields are filled
  bool get _areRequiredFieldsFilled {
    return _clinicNameController.text.trim().isNotEmpty &&
        _clinicEmailController.text.trim().isNotEmpty &&
        _firstNameController.text.trim().isNotEmpty &&
        _lastNameController.text.trim().isNotEmpty;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _isButtonEnabled = false; // Disable when loading
    });

    try {
      // Call API to setup clinic via AuthCubit
      await context.read<AuthCubit>().setupClinic(
        clinicName: _clinicNameController.text.trim(),
        clinicEmail: _clinicEmailController.text.trim(),
        clinicPhone: _clinicPhoneController.text.trim().isEmpty
            ? null
            : _clinicPhoneController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Clinic setup completed successfully!'),
            backgroundColor: AppColors.success,
          ),
        );

        // Navigate to dashboard after successful setup
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
          _isButtonEnabled =
              _areRequiredFieldsFilled; // Re-evaluate enabled state
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            // Navigate to landing screen when back is pressed
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              AppRouter.pushReplacementNamed(context, AppRoutes.landing);
            }
          },
        ),
        title: const Text(
          'Clinic Setup',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo Icon
                Center(
                  child: Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(16),
                    child: SvgPicture.asset(
                      'assets/icons/logo.svg',
                      width: 48,
                      height: 48,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Subtitle
                Text(
                  'Welcome to Aura Connect! Let\'s set up your veterinary clinic.',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),

                // Clinic Name Field
                _buildTextField(
                  controller: _clinicNameController,
                  label: 'Clinic Name',
                  icon: Icons.business_rounded,
                  isRequired: true,
                  hintText: 'Enter your clinic name',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Clinic name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Clinic Email Field
                _buildTextField(
                  controller: _clinicEmailController,
                  label: 'Clinic Email',
                  icon: Icons.email_outlined,
                  isRequired: true,
                  hintText: 'Enter your clinic email',
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
                const SizedBox(height: 24),

                // Clinic Phone Field
                _buildTextField(
                  controller: _clinicPhoneController,
                  label: 'Clinic Phone',
                  icon: Icons.phone_outlined,
                  isRequired: false,
                  hintText: '+1-555-0000',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 24),

                // First Name Field
                _buildTextField(
                  controller: _firstNameController,
                  label: 'Your First Name',
                  icon: Icons.person_outline,
                  isRequired: true,
                  hintText: 'Enter your first name',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'First name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Last Name Field
                _buildTextField(
                  controller: _lastNameController,
                  label: 'Your Last Name',
                  icon: Icons.person_outline,
                  isRequired: true,
                  hintText: 'Your last name',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Last name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                // Complete Setup Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: CustomLandingPageButton(
                    label: 'Complete Setup',
                    onPressed: _isButtonEnabled ? _handleSubmit : null,
                    color: AppColors.primary,
                    textColor: AppColors.white,
                    paddingSize: 16,
                    textSize: 16,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isRequired,
    String? hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.error,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: AppColors.textSecondary),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12, // Increased from 12 to 16 for more height
            ),
            // Using theme's InputDecorationTheme from app_theme.dart
            // This will automatically apply the styling we defined
          ),
        ),
      ],
    );
  }
}
