import 'package:aura/screens/consultation/widgets/label_chip.dart';
import 'package:aura/screens/widgets/primary_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/settings/settings_cubit.dart';
import '../../../../features/settings/settings_state.dart';

class TeamManagementSection extends StatelessWidget {
  const TeamManagementSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(2.0),
                    child: Icon(Icons.people_outline, size: 24),
                  ),
                  const SizedBox(width: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Team Management',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          fontFamily: 'Fraunces',
                        ),
                      ),
                      Text(
                        'Invite and manage team for your clinic',
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
              _buildClinicSummaryCard(state),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryLight),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(2.0),
                          child: Icon(Icons.people_outline, size: 24),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Team Members',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          child: PrimaryIconButton(
                            onPressed: () {
                              _showInviteDialog(context);
                            },
                            icon: const Icon(
                              Icons.person_add_outlined,
                              size: 14,
                            ),
                            text: 'Invite',
                            fontSize: 14,
                            verticalPadding: 4,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (state.isLoading && state.clinicUsers.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (state.clinicUsers.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 64,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No team members yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...state.clinicUsers.map(
                        (user) => _buildUserCard(context, user),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildClinicSummaryCard(SettingsState state) {
    final clinic = state.clinic;
    if (clinic == null) return const SizedBox.shrink();

    final clinicName = clinic['name'] as String? ?? '';
    final email = clinic['email'] as String? ?? '';
    final phone = clinic['phone'] as String? ?? '';
    final subscriptionTier =
        clinic['subscriptionTier']?.toString() ?? 'Unlimited';
    final maxUsers = clinic['maxUsers'];
    final usersCount = state.clinicUsers.length;
    final maxUsersDisplay = maxUsers == null || maxUsers == -1
        ? '∞'
        : maxUsers.toString();

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.business_outlined,
                            size: 20,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            clinicName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 16,
                        runSpacing: 4,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.email_outlined,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                email,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.phone_outlined,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                phone,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              LabelChip(
                label: subscriptionTier,
                textColor: AppColors.textPrimary,
                backgroundColor: AppColors.primaryLight.withAlpha(25),
              ),
              const SizedBox(height: 2),
              Text(
                '$usersCount/$maxUsersDisplay users',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, Map<String, dynamic> user) {
    final role = user['role'] as String? ?? 'veterinarian';
    final isActive = user['isActive'] as bool? ?? true;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withAlpha(25),
            child: Text(
              (user['firstName'] as String? ?? 'U')[0].toUpperCase(),
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  user['email'] as String? ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.black,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  role.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                isActive ? Icons.check_circle : null,
                color: isActive ? AppColors.success : AppColors.error,
                size: 14,
              ),
            ],
          ),

          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: AppColors.error,
              size: 18,
            ),
            onPressed: () {
              _showRemoveUserDialog(context, user);
            },
          ),
        ],
      ),
    );
  }

  /// Role options: value matches server/web (veterinarian, assistant, admin); label is display-only.
  static const List<MapEntry<String, String>> _inviteRoleOptions = [
    MapEntry('veterinarian', 'Veterinarian'),
    MapEntry('assistant', 'Veterinary Assistant'),
    MapEntry('admin', 'Admin'),
  ];

  void _showInviteDialog(BuildContext context) {
    final emailController = TextEditingController();
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    // Default role value must match server (same as web InviteUserModal).
    String selectedRole = _inviteRoleOptions.first.key;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          final screenWidth = MediaQuery.of(context).size.width;
          final maxWidth = screenWidth * 0.9; // 90% of screen width
          final dialogMaxWidth = maxWidth > 400
              ? 400.0
              : maxWidth; // Max 400px, but responsive

          return Dialog(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: dialogMaxWidth,
                minWidth: 280.0, // Minimum width for small screens
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Invite User',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: firstNameController,
                              decoration: const InputDecoration(
                                labelText: 'First Name',
                                prefixIcon: Icon(Icons.person_outlined),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: lastNameController,
                              decoration: const InputDecoration(
                                labelText: 'Last Name',
                                prefixIcon: Icon(Icons.person_outlined),
                              ),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: selectedRole,
                              decoration: const InputDecoration(
                                labelText: 'Role',
                                prefixIcon: Icon(Icons.badge_outlined),
                              ),
                              items: _inviteRoleOptions
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e.key,
                                      child: Text(e.value),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => selectedRole = value);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            if (emailController.text.isNotEmpty &&
                                firstNameController.text.isNotEmpty &&
                                lastNameController.text.isNotEmpty) {
                              // Close dialog immediately
                              Navigator.pop(dialogContext);

                              // Invite user in background (role = server value: veterinarian | assistant | admin)
                              final clinicId = context
                                  .read<SettingsCubit>()
                                  .state
                                  .clinic?['id']
                                  ?.toString();
                              if (clinicId == null) return;
                              await context.read<SettingsCubit>().inviteUser(
                                email: emailController.text.trim(),
                                firstName: firstNameController.text.trim(),
                                lastName: lastNameController.text.trim(),
                                role: selectedRole,
                                clinicId: clinicId,
                              );
                            }
                          },
                          child: const Text('Send'),
                        ),
                      ],
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

  void _showRemoveUserDialog(BuildContext context, Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove User'),
        content: Text(
          'Are you sure you want to remove ${user['firstName']} ${user['lastName']} from the clinic?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final clinicId = context
                  .read<SettingsCubit>()
                  .state
                  .clinic?['id']
                  ?.toString();
              if (clinicId == null) return;
              final success = await context.read<SettingsCubit>().removeUser(
                user['id'] as String,
                clinicId,
              );
              if (success && context.mounted) {
                Navigator.pop(dialogContext);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
