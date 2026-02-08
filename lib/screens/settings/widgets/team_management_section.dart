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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Team Members',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _showInviteDialog(context);
                  },
                  icon: const Icon(Icons.person_add_outlined, size: 18),
                  label: const Text('Invite User'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
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
              ...state.clinicUsers.map((user) => _buildUserCard(context, user)),
          ],
        );
      },
    );
  }

  Widget _buildUserCard(BuildContext context, Map<String, dynamic> user) {
    final role = user['role'] as String? ?? 'veterinarian';
    final isActive = user['isActive'] as bool? ?? true;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Text(
            (user['firstName'] as String? ?? 'U')[0].toUpperCase(),
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user['email'] as String? ?? ''),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getRoleColor(role).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    role.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getRoleColor(role),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isActive ? 'ACTIVE' : 'INACTIVE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isActive ? AppColors.success : AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: AppColors.error),
          onPressed: () {
            _showRemoveUserDialog(context, user);
          },
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return AppColors.error;
      case 'veterinarian':
        return AppColors.primary;
      case 'assistant':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  void _showInviteDialog(BuildContext context) {
    final emailController = TextEditingController();
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    String selectedRole = 'veterinarian';

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
                              items: const [
                                DropdownMenuItem(
                                  value: 'veterinarian',
                                  child: Text('Veterinarian'),
                                ),
                                DropdownMenuItem(
                                  value: 'assistant',
                                  child: Text('Assistant'),
                                ),
                                DropdownMenuItem(
                                  value: 'admin',
                                  child: Text('Admin'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  selectedRole = value!;
                                });
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

                              // Invite user in background
                              await context.read<SettingsCubit>().inviteUser(
                                email: emailController.text.trim(),
                                firstName: firstNameController.text.trim(),
                                lastName: lastNameController.text.trim(),
                                role: selectedRole,
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
              final success = await context.read<SettingsCubit>().removeUser(
                user['id'] as String,
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
