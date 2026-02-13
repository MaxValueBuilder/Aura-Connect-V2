import 'package:aura/screens/widgets/primary_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/settings/settings_cubit.dart';
import '../../../../features/settings/settings_state.dart';
import 'team_management_section.dart';

class PracticeTab extends StatefulWidget {
  const PracticeTab({super.key});

  @override
  State<PracticeTab> createState() => _PracticeTabState();
}

class _PracticeTabState extends State<PracticeTab> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _websiteController;
  late TextEditingController _licenseController;
  String? _lastLoadedClinicId; // Track which clinic we've loaded
  bool _isInitialLoad = true; // Track if this is the initial load

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _websiteController = TextEditingController();
    _licenseController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  void _loadClinicData(SettingsState state, {bool forceUpdate = false}) {
    // Only load if:
    // 1. Initial load (first time clinic is available)
    // 2. Clinic ID changed (different clinic loaded)
    // 3. Force update (after successful save)
    if (state.clinic != null) {
      final clinicId = state.clinic!['id']?.toString();
      if (forceUpdate || _isInitialLoad || clinicId != _lastLoadedClinicId) {
        _nameController.text = state.clinic!['name'] ?? '';
        _addressController.text = state.clinic!['address'] ?? '';
        _phoneController.text = state.clinic!['phone'] ?? '';
        _emailController.text = state.clinic!['email'] ?? '';
        _websiteController.text = state.clinic!['website'] ?? '';
        _licenseController.text = state.clinic!['licenseNumber'] ?? '';
        _lastLoadedClinicId = clinicId;
        _isInitialLoad = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        if (state.isLoading && state.clinic == null) {
          return const Center(child: CircularProgressIndicator());
        }

        // Load clinic data into controllers only when clinic changes
        // Use postFrameCallback to avoid overwriting user input during typing
        if (state.clinic != null) {
          final clinicId = state.clinic!['id']?.toString();
          if (_isInitialLoad || clinicId != _lastLoadedClinicId) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && state.clinic != null) {
                _loadClinicData(state);
              }
            });
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                'Clinic Information',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                  fontFamily: 'Fraunces',
                                ),
                              ),
                              Text(
                                'Manage your clinic\'s details and contact',

                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Clinic Information Section
                      const SizedBox(height: 24),
                      _buildTextField(
                        controller: _nameController,
                        label: 'Clinic Name',
                        icon: Icons.business_outlined,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ' The official name of your veterinary practice',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _addressController,
                        label: 'Address',
                        icon: Icons.location_on_outlined,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ' Full street address of your clinic location',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _phoneController,
                        label: 'Phone',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ' Main clinic phone number',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 20),

                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ' Official clinic email address',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 20),

                      _buildTextField(
                        controller: _websiteController,
                        label: 'Website',
                        icon: Icons.language_outlined,
                        keyboardType: TextInputType.url,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ' Optional. must start with http:// or https://',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 20),

                      _buildTextField(
                        controller: _licenseController,
                        label: 'Clinic License',
                        icon: Icons.badge_outlined,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ' Optional. Business license or registration number',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 200,
                          child: PrimaryIconButton(
                            onPressed: state.isSaving
                                ? () {}
                                : () async {
                                    if (_formKey.currentState!.validate()) {
                                      final clinicId = context
                                          .read<SettingsCubit>()
                                          .state
                                          .clinic?['id']
                                          ?.toString();
                                      if (clinicId == null) return;
                                      final success = await context
                                          .read<SettingsCubit>()
                                          .updateClinic(
                                            clinicId,
                                            name:
                                                _nameController.text
                                                    .trim()
                                                    .isEmpty
                                                ? null
                                                : _nameController.text.trim(),
                                            address:
                                                _addressController.text
                                                    .trim()
                                                    .isEmpty
                                                ? null
                                                : _addressController.text
                                                      .trim(),
                                            phone:
                                                _phoneController.text
                                                    .trim()
                                                    .isEmpty
                                                ? null
                                                : _phoneController.text.trim(),
                                            email:
                                                _emailController.text
                                                    .trim()
                                                    .isEmpty
                                                ? null
                                                : _emailController.text.trim(),
                                            website:
                                                _websiteController.text
                                                    .trim()
                                                    .isEmpty
                                                ? null
                                                : _websiteController.text
                                                      .trim(),
                                            licenseNumber:
                                                _licenseController.text
                                                    .trim()
                                                    .isEmpty
                                                ? null
                                                : _licenseController.text
                                                      .trim(),
                                          );
                                      if (success && mounted) {
                                        // Update controllers with the saved clinic data
                                        // The state already contains the updated clinic from updateClinic
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                              if (mounted) {
                                                final currentState = context
                                                    .read<SettingsCubit>()
                                                    .state;
                                                if (currentState.clinic !=
                                                    null) {
                                                  _loadClinicData(
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
                      ),

                      // Team Management Section
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Team Management',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Invite and manage team members for your clinic',
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
                    const TeamManagementSection(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
