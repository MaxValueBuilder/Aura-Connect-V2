import 'package:aura/screens/widgets/primary_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../features/settings/settings_cubit.dart';
import '../../../../features/settings/settings_state.dart';
import '../../../../features/auth/auth_cubit.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _licenseController;
  late TextEditingController _specializationController;
  String? _lastLoadedProfileId; // Track which profile we've loaded
  bool _isInitialLoad = true; // Track if this is the initial load

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _phoneController = TextEditingController();
    _licenseController = TextEditingController();
    _specializationController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _licenseController.dispose();
    _specializationController.dispose();
    super.dispose();
  }

  void _loadProfileData(SettingsState state, {bool forceUpdate = false}) {
    // Only load if:
    // 1. Initial load (first time profile is available)
    // 2. Profile ID changed (different profile loaded)
    // 3. Force update (after successful save)
    if (state.profile != null &&
        (forceUpdate ||
            _isInitialLoad ||
            state.profile!.id != _lastLoadedProfileId)) {
      _firstNameController.text = state.profile!.firstName;
      _lastNameController.text = state.profile!.lastName;
      _phoneController.text = state.profile!.phone ?? '';
      _licenseController.text = state.profile!.licenseNumber ?? '';
      _specializationController.text = state.profile!.specialization ?? '';
      _lastLoadedProfileId = state.profile!.id;
      _isInitialLoad = false;
    }
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
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          if (state.isLoading && state.profile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          // Load profile data into controllers only when profile changes
          // Use postFrameCallback to avoid overwriting user input during typing
          if (state.profile != null &&
              (_isInitialLoad || state.profile!.id != _lastLoadedProfileId)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && state.profile != null) {
                _loadProfileData(state);
              }
            });
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),

            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Icon(Icons.person_outline, size: 24),
                        ),
                        const SizedBox(width: 4),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Personal Information',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                                fontFamily: 'Fraunces',
                              ),
                            ),
                            Text(
                              'Update your personal details and contact',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(
                      controller: _firstNameController,
                      label: 'First Name',
                      icon: Icons.person_outlined,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _lastNameController,
                      label: 'Last Name',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: TextEditingController(
                        text: state.profile?.email ?? '',
                      ),
                      label: 'Email Address',
                      icon: Icons.email_outlined,
                      enabled: false,
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Email is linked to your account',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(Icons.school_outlined, size: 24),
                        ),
                        Text(
                          'Professional Information',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            fontFamily: 'Fraunces',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(
                      controller: _licenseController,
                      label: 'Veterinary License',
                      icon: Icons.badge_outlined,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _specializationController,
                      label: 'Specialization',
                      icon: Icons.medical_services_outlined,
                    ),

                    const SizedBox(height: 32),
                    SizedBox(
                      child: PrimaryIconButton(
                        onPressed: state.isSaving
                            ? () {}
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  final profile = context
                                      .read<SettingsCubit>()
                                      .state
                                      .profile;
                                  if (profile == null) return;
                                  final success = await context
                                      .read<SettingsCubit>()
                                      .updateProfile(
                                        profile.id,
                                        firstName: _firstNameController.text
                                            .trim(),
                                        lastName: _lastNameController.text
                                            .trim(),
                                        phone:
                                            _phoneController.text.trim().isEmpty
                                            ? null
                                            : _phoneController.text.trim(),
                                        licenseNumber:
                                            _licenseController.text
                                                .trim()
                                                .isEmpty
                                            ? null
                                            : _licenseController.text.trim(),
                                        specialization:
                                            _specializationController.text
                                                .trim()
                                                .isEmpty
                                            ? null
                                            : _specializationController.text
                                                  .trim(),
                                      );
                                  if (success && mounted) {
                                    // Update controllers with the saved profile data
                                    // The state already contains the updated profile from updateProfile
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                          if (mounted) {
                                            final currentState = context
                                                .read<SettingsCubit>()
                                                .state;
                                            if (currentState.profile != null) {
                                              _loadProfileData(
                                                currentState,
                                                forceUpdate: true,
                                              );
                                            }
                                          }
                                        });
                                  }
                                }
                              },
                        icon: state.isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.white,
                                  ),
                                ),
                              )
                            : Icons.save_outlined,
                        text: state.isSaving ? 'Saving...' : 'Save Changes',
                        fontSize: 16,
                        verticalPadding: 16,
                        enabled: !state.isSaving,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: !enabled,
        fillColor: enabled ? null : AppColors.gray100,
      ),
      validator: (value) {
        if (label == 'First Name' || label == 'Last Name') {
          if (value == null || value.trim().isEmpty) {
            return 'This field is required';
          }
        }
        return null;
      },
    );
  }
}
