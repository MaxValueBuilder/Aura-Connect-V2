import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../features/consultation/consultation_cubit.dart';
import '../../../features/consultation/consultation_state.dart';
import '../../../features/auth/auth_cubit.dart';
import '../../../features/navigation/navigation_cubit.dart';
import '../../../features/notification/notification_cubit.dart';
import '../../../features/notification/notification_state.dart';
import '../../../models/consultation_model.dart';
import '../../../core/constants/consultation_status.dart';
import '../../../core/utils/consultation_status_utils.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? _filterStatus;

  @override
  void initState() {
    super.initState();
    // Load consultations and notification count when screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConsultationCubit>().loadConsultations(refresh: true);
      context.read<NotificationCubit>().refreshUnreadCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, notificationState) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: () {
                      AppRouter.pushNamed(context, AppRoutes.notifications);
                    },
                  ),
                  if (notificationState.unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Center(
                          child: Text(
                            notificationState.unreadCount > 99
                                ? '99+'
                                : '${notificationState.unreadCount}',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<ConsultationCubit, ConsultationState>(
        listener: (context, state) {
          if (state.hasError && state.errorMessage.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoadingConsultations && state.consultations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, authState) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withAlpha(230),
                              AppColors.primaryLight.withAlpha(230),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Welcome To Aura Connect!',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Ready to start your next consultation?',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: AppColors.white.withOpacity(
                                            0.9,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    _handleStartConsultation(context),
                                icon: const Icon(Icons.add),
                                label: const Text('New Consultation'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 14,
                                  ),
                                  backgroundColor: AppColors.white,
                                  foregroundColor: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  // Stats Cards
                  _buildStatsSection(state),
                  const SizedBox(height: 32),

                  // Active Consultations Section
                  _buildActiveConsultationsSection(state),
                  const SizedBox(height: 32),

                  // Recent Consultations Section
                  _buildRecentConsultationsSection(state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsSection(ConsultationState state) {
    final stats = state.stats ?? {};
    return Column(
      children: [
        _buildStatCard(
          title: 'Total Consultations',
          value: '${stats['totalConsultations'] ?? 0}',
          icon: Icons.calendar_today,
          color: AppColors.info,
        ),
        const SizedBox(height: 4),
        _buildStatCard(
          title: 'Active',
          value: '${stats['activeConsultations'] ?? 0}',
          icon: Icons.access_time,
          color: AppColors.warning,
        ),
        const SizedBox(height: 4),
        _buildStatCard(
          title: 'Completed',
          value: '${stats['completedConsultations'] ?? 0}',
          icon: Icons.check_circle,
          color: AppColors.success,
        ),
        const SizedBox(height: 4),
        _buildStatCard(
          title: 'Today',
          value: '${stats['completedToday'] ?? 0}',
          icon: Icons.today,
          color: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildActiveConsultationsSection(ConsultationState state) {
    // Use filtered consultations if filters are active, otherwise use active consultations
    final consultations =
        (state.filterStatus != null || state.searchTerm.isNotEmpty)
        ? state.filteredConsultations.where((c) {
            return c.status == ConsultationStatus.initialConsult ||
                c.status == ConsultationStatus.initialComplete ||
                c.status == ConsultationStatus.finalConsult ||
                c.status == ConsultationStatus.processing;
          }).toList()
        : state.activeConsultations;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Consultations',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${consultations.length} consultation${consultations.length != 1 ? 's' : ''} in progress',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Search and Filter
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      isDense: true,
                      filled: true,
                      fillColor: AppColors.white,
                    ),
                    onChanged: (value) {
                      context.read<ConsultationCubit>().setSearchTerm(value);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.white,
                  ),
                  child: DropdownButton<String>(
                    value: _filterStatus,
                    hint: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('All'),
                    ),
                    isExpanded: false,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('All')),
                      DropdownMenuItem(value: 'active', child: Text('Active')),
                      DropdownMenuItem(
                        value: 'completed',
                        child: Text('Completed'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _filterStatus = value;
                      });
                      context.read<ConsultationCubit>().setFilterStatus(value);
                    },
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    icon: const Icon(Icons.arrow_drop_down),
                    iconSize: 24,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (consultations.isEmpty)
          _buildEmptyState(
            icon: Icons.access_time,
            title: 'No Active Consultations',
            message: 'Start a new consultation to begin working with patients.',
            actionLabel: 'Start New Consultation',
            onAction: () => _handleStartConsultation(context),
          )
        else
          ...consultations.map(
            (consultation) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildConsultationCard(consultation),
            ),
          ),
      ],
    );
  }

  Widget _buildRecentConsultationsSection(ConsultationState state) {
    final recentConsultations = state.completedConsultations.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Consultations',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Latest consultations',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: () {
                // Navigate to History tab (index 1) while keeping navigation bar
                context.read<NavigationCubit>().navigateToHistory();
              },
              icon: const Icon(Icons.history),
              label: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (recentConsultations.isEmpty)
          SizedBox(
            width: double.infinity,
            child: _buildEmptyState(
              icon: Icons.history,
              title: 'No Recent Consultations',
              message: 'Completed consultations will appear here.',
            ),
          )
        else
          ...recentConsultations.map(
            (consultation) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildConsultationCard(consultation, isCompleted: true),
            ),
          ),
      ],
    );
  }

  Widget _buildConsultationCard(
    ConsultationModel consultation, {
    bool isCompleted = false,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.success.withAlpha(25)
                    : AppColors.primary.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted ? Icons.check_circle_outlined : Icons.person,
                color: isCompleted ? AppColors.success : AppColors.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    consultation.patientName ?? 'Unknown Patient',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${consultation.veterinarianName ?? "Unknown"} • ${consultation.aiAnalysis?.breed ?? "Unknown Breed"}',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Chip(
                        label: Text(
                          ConsultationStatusUtils.getActionButtonText(
                            consultation.status,
                          ),
                          style: const TextStyle(fontSize: 9, height: 1),
                        ),
                        backgroundColor: _getStatusColor(
                          consultation.status,
                        ).withOpacity(0.08),
                        labelStyle: TextStyle(
                          color: _getStatusColor(consultation.status),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 0,
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        elevation: 0,
                        side: BorderSide.none,
                      ),
                      const SizedBox(width: 8),
                      Center(
                        child: Text(
                          _formatDate(consultation.startTime),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Actions
            Column(
              children: [
                if (!isCompleted)
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to consultation recording screen to continue
                      AppRouter.pushNamed(
                        context,
                        AppRoutes.consultationRecording,
                        arguments: ConsultationRecordingArguments(
                          consultationId: consultation.id,
                          initialStatus: consultation.status,
                          initialPatientName:
                              consultation.patientName ?? 'Unknown Patient',
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    child: const Text('Resume', style: TextStyle(fontSize: 14)),
                  )
                else
                  OutlinedButton(
                    onPressed: () {
                      // Navigate to SOAP note view for completed consultations
                      AppRouter.pushNamed(
                        context,
                        AppRoutes.soapNote,
                        arguments: SOAPNoteArguments(
                          consultationId: consultation.id,
                        ),
                      );
                    },
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                      ),
                    ),
                    child: const Text('View', style: TextStyle(fontSize: 14)),
                  ),
                // const SizedBox(height: 8),
                // IconButton(
                //   icon: const Icon(Icons.delete_outline, size: 20),
                //   color: AppColors.error,
                //   onPressed: () =>
                //       _handleDeleteConsultation(context, consultation.id),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AppColors.gray300),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            // Always reserve space for button to keep consistent layout
            SizedBox(height: actionLabel != null && onAction != null ? 24 : 0),
            if (actionLabel != null && onAction != null)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                  ),
                  child: Text(actionLabel),
                ),
              )
            else
              // Placeholder to maintain consistent spacing when no button
              const SizedBox(height: 0),
          ],
        ),
      ),
    );
  }

  Future<void> _handleStartConsultation(BuildContext context) async {
    try {
      // Navigate directly to consultation recording screen
      // Consultation will be created when recording stops
      AppRouter.pushNamed(context, AppRoutes.consultationRecording);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // Future<void> _handleDeleteConsultation(
  //   BuildContext context,
  //   String consultationId,
  // ) async {
  //   final confirmed = await showDialog<bool>(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Delete Consultation'),
  //       content: const Text(
  //         'Are you sure you want to delete this consultation? This action cannot be undone.',
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context, false),
  //           child: const Text('Cancel'),
  //         ),
  //         TextButton(
  //           onPressed: () => Navigator.pop(context, true),
  //           style: TextButton.styleFrom(foregroundColor: AppColors.error),
  //           child: const Text('Delete'),
  //         ),
  //       ],
  //     ),
  //   );

  //   if (confirmed == true && context.mounted) {
  //     await context.read<ConsultationCubit>().deleteConsultation(
  //       consultationId,
  //     );
  //   }
  // }

  Color _getStatusColor(ConsultationStatus status) {
    switch (status) {
      case ConsultationStatus.initialConsult:
        return AppColors.primary;
      case ConsultationStatus.initialComplete:
        return AppColors.success;
      case ConsultationStatus.finalConsult:
        return AppColors.warning;
      case ConsultationStatus.processing:
        return AppColors.info;
      case ConsultationStatus.complete:
      case ConsultationStatus.finalComplete:
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon on the left
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            // Title and value on the right
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
