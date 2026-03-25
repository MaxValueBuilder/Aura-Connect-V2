import 'package:aura/features/patient/patient_state.dart';
import 'package:aura/screens/consultation/widgets/label_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/app_bar_logo_title.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../features/consultation/consultation_cubit.dart';
import '../../../features/consultation/consultation_state.dart';
import '../../../features/auth/auth_cubit.dart';
import '../../../features/navigation/navigation_cubit.dart';
import '../../../features/notification/notification_cubit.dart';
import '../../../features/patient/patient_cubit.dart';
import '../../../models/consultation_model.dart';
import '../../../core/constants/consultation_status.dart';
import 'widgets/dashboard_stat_card.dart';
import 'widgets/app_bar_icon_button.dart';
import '../widgets/primary_icon_button.dart';

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
    // Load consultations, patients, and notification count when screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConsultationCubit>().loadConsultations(refresh: true);
      context.read<PatientCubit>().loadPatients(refresh: true);
      context.read<NotificationCubit>().refreshUnreadNotifications();
    });
  }

  void _handleViewConsultation(
    String consultationId,
    ConsultationModel consultation,
  ) {
    // Navigate to SOAP note view for completed consultations
    AppRouter.pushNamed(
      context,
      AppRoutes.soapNote,
      arguments: SOAPNoteArguments(consultationId: consultationId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // titleSpacing: 0,
        title: const AppBarLogoTitle(),
        backgroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          AppBarIconButton(
            backgroundColor: AppColors.primary,
            icon: Icons.add,
            onPressed: () => _handleStartConsultation(context),
          ),
          const SizedBox(width: 16),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sticky header: Dashboard title, welcome, profile picture
                _buildHeaderSection(context),
                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stats Cards (2x2 grid)
                        Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: _buildStatsSection(state, context),
                        ),
                        const SizedBox(height: 32),
                        // Active Consultations Section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18.0),
                          child: _buildActiveConsultationsSection(state),
                        ),
                        const SizedBox(height: 32),
                        // Recent Consultations Section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18.0),
                          child: _buildRecentConsultationsSection(state),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final displayName =
            authState.user?.fullName ??
            authState.userEmail?.split('@').first ??
            'User';
        final initials = displayName
            .split(' ')
            .where((s) => s.isNotEmpty)
            .take(2)
            .map((s) => s[0].toUpperCase())
            .join();
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withAlpha(40),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dashboard',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        fontFamily: "Fraunces",
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Welcome back, ${displayName.toLowerCase()}',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.white,
                child: CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  child: initials.isNotEmpty
                      ? Text(
                          initials,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : const Icon(
                          Icons.person,
                          color: AppColors.primary,
                          size: 28,
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsSection(ConsultationState state, BuildContext context) {
    final stats = state.stats ?? {};
    return BlocBuilder<PatientCubit, PatientState>(
      builder: (context, patientState) {
        final patientCount = patientState.patients.length;
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DashboardStatCard(
                    title: 'Total Consultation',
                    value: '${stats['totalConsultations'] ?? 0}',
                    icon: Icons.event_note,
                    color: AppColors.info,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DashboardStatCard(
                    title: 'Active Consultation',
                    value: '${stats['activeConsultations'] ?? 0}',
                    icon: Icons.timeline,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DashboardStatCard(
                    title: 'Total Patients',
                    value: '$patientCount',
                    icon: Icons.people,
                    color: const Color(0xFF7C3AED),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DashboardStatCard(
                    title: 'Completed Today',
                    value: '${stats['completedToday'] ?? 0}',
                    icon: Icons.check_circle,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ],
        );
      },
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
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontFamily: "Fraunces",
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
            // Search and Filter (matched heights)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 44,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search consultations...',
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
                          horizontal: 8,
                          vertical: 8,
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
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 44,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.white,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _filterStatus,
                        hint: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Text('All'),
                        ),
                        isExpanded: false,
                        items: const [
                          DropdownMenuItem(value: null, child: Text('All')),
                          DropdownMenuItem(
                            value: 'active',
                            child: Text('Active'),
                          ),
                          DropdownMenuItem(
                            value: 'completed',
                            child: Text('Completed'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _filterStatus = value;
                          });
                          context.read<ConsultationCubit>().setFilterStatus(
                            value,
                          );
                        },
                        icon: const Icon(Icons.arrow_drop_down),
                        iconSize: 24,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                        dropdownColor: AppColors.white,
                      ),
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
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.white,
            ),
            child: Column(
              children: [
                ...consultations.map(
                  (consultation) => Column(
                    children: [
                      _buildActiveConsultationCard(consultation),
                      if (consultations.indexOf(consultation) !=
                          consultations.length - 1)
                        Divider(color: AppColors.border),
                    ],
                  ),
                ),
              ],
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
                    fontFamily: "Fraunces",
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Latest completed consultations',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            TextButton.icon(
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0),
                  side: BorderSide(color: AppColors.primary),
                ),
              ),
              onPressed: () {
                // Navigate to History tab (index 1) while keeping navigation bar
                context.read<NavigationCubit>().navigateToHistory();
              },
              icon: const Icon(Icons.history),
              iconAlignment: IconAlignment.end,
              label: const Text(
                'View All',
                style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
              ),
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
            (consultation) => _buildCompletedConsultationCard(consultation),
          ),
      ],
    );
  }

  Widget _buildActiveConsultationCard(ConsultationModel consultation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 0),
      elevation: 0,
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person, color: AppColors.primary, size: 18),
                ),
                SizedBox(width: 16),
                Text(
                  consultation.patientName ?? 'Unknown Patient',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${consultation.veterinarianName ?? "Unknown"} • ${consultation.aiAnalysis?.breed ?? "Unknown Breed"}',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                LabelChip(
                  label: "INITIAL COMPLETE",
                  textColor: AppColors.success,
                  backgroundColor: AppColors.successLight,
                  padding: 4,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  spacing: 8,
                  children: [
                    Icon(Icons.calendar_month, size: 16),
                    Text(
                      'Started ${_formatDate(consultation.startTime)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Text('Continue', style: TextStyle(fontSize: 14)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedConsultationCard(ConsultationModel consultation) {
    return Card(
      elevation: 0,
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.success.withAlpha(25),

                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle_outlined,

                        color: AppColors.success,
                        size: 28,
                      ),
                    ),
                    SizedBox(width: 16),
                    Text(
                      consultation.patientName ?? 'Unknown Patient',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),

                OutlinedButton(
                  onPressed: () {
                    // Navigate to consultation recording screen to continue
                    _handleViewConsultation(consultation.id, consultation);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                  ),

                  child: const Text(
                    'View Details',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${consultation.veterinarianName ?? "Unknown"} • ${consultation.aiAnalysis?.breed ?? "Unknown Breed"}',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),

            Row(
              spacing: 8,
              children: [
                LabelChip(
                  label: "COMPLETED",
                  textColor: AppColors.success,
                  backgroundColor: AppColors.successLight,
                  padding: 4,
                ),
                Text(
                  'Started ${_formatDate(consultation.startTime)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
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
    IconData actionIcon = Icons.add,
  }) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.primary.withAlpha(25),
              ),
              child: Icon(icon, size: 64, color: AppColors.gray300),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontFamily: "Fraunces",
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
                child: PrimaryIconButton(
                  onPressed: onAction,
                  icon: actionIcon,
                  text: actionLabel,
                  fontSize: 16,
                  verticalPadding: 12,
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
}
