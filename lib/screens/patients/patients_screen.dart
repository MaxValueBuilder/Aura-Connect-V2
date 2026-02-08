import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/constants/consultation_status.dart';
import '../../../features/patient/patient_cubit.dart';
import '../../../features/patient/patient_state.dart';
import '../../../models/patient_model.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedSpecies = 'all';
  String _selectedStatus = 'all';
  PatientModel? _selectedPatient;

  @override
  void initState() {
    super.initState();
    // Load patients when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PatientCubit>().loadPatients();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleAddPatient() {
    AppRouter.pushNamed(context, AppRoutes.addPatient).then((success) {
      // Refresh patient list if patient was added successfully
      if (success == true && mounted) {
        context.read<PatientCubit>().loadPatients(refresh: true);
      }
    });
  }

  void _handleEditPatient(PatientModel patient) {
    setState(() {
      _selectedPatient = patient;
    });
    // Show dialog
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _buildPatientDetailDialog(),
    ).then((_) {
      setState(() {
        _selectedPatient = null;
      });
    });
  }

  Future<void> _handleDeletePatient(String patientId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Patient'),
        content: const Text(
          'Are you sure you want to delete this patient? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await context.read<PatientCubit>().deletePatient(
        patientId,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Patient deleted successfully'
                  : context.read<PatientCubit>().state.errorMessage,
            ),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
      }
    }
  }

  void _handleStartConsultation(PatientModel patient) {
    Navigator.pop(context); // Close dialog
    // Navigate to consultation recording screen with patient info
    AppRouter.pushNamed(
      context,
      AppRoutes.consultationRecording,
      arguments: ConsultationRecordingArguments(
        consultationId: null, // New consultation
        initialStatus: ConsultationStatus.initialConsult,
        initialPatientName: patient.name,
      ),
    );
  }

  IconData _getSpeciesIcon(String species) {
    switch (species.toLowerCase()) {
      case 'dog':
        return Icons.pets;
      case 'cat':
        return Icons.cruelty_free;
      case 'bird':
        return Icons.air;
      case 'rabbit':
        return Icons.pets;
      default:
        return Icons.favorite;
    }
  }

  Color _getStatusColor(bool isActive) {
    return isActive ? AppColors.success : AppColors.textSecondary;
  }

  String _getStatusLabel(bool isActive) {
    return isActive ? 'Active' : 'Inactive';
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Patient Management',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: IconButton(
              onPressed: _handleAddPatient,
              icon: const Icon(
                Icons.add_circle_outline_sharp,
                size: 26,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: BlocListener<PatientCubit, PatientState>(
        listener: (context, state) {
          if (state.errorMessage.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: AppColors.error,
              ),
            );
            context.read<PatientCubit>().clearError();
          }
        },
        child: BlocBuilder<PatientCubit, PatientState>(
          builder: (context, state) {
            if (state.isLoading && state.patients.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.errorMessage.isNotEmpty && state.patients.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading patients',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.errorMessage,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        context.read<PatientCubit>().loadPatients(
                          refresh: true,
                        );
                      },
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              );
            }

            final filteredPatients = state.filteredPatients;

            return Column(
              children: [
                // Search and Filters
                Container(
                  color: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    children: [
                      // Search Field
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search patients, owners, or breeds...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (value) {
                          context.read<PatientCubit>().setSearchTerm(value);
                        },
                      ),
                      const SizedBox(height: 12),
                      // Filters Row
                      Row(
                        children: [
                          // Species Filter
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedSpecies,
                              decoration: InputDecoration(
                                labelText: 'Species',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'all',
                                  child: Text('All Species'),
                                ),
                                DropdownMenuItem(
                                  value: 'dog',
                                  child: Text('Dogs'),
                                ),
                                DropdownMenuItem(
                                  value: 'cat',
                                  child: Text('Cats'),
                                ),
                                DropdownMenuItem(
                                  value: 'bird',
                                  child: Text('Birds'),
                                ),
                                DropdownMenuItem(
                                  value: 'rabbit',
                                  child: Text('Rabbits'),
                                ),
                                DropdownMenuItem(
                                  value: 'other',
                                  child: Text('Other'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedSpecies = value ?? 'all';
                                });
                                context.read<PatientCubit>().setFilterSpecies(
                                  _selectedSpecies == 'all'
                                      ? null
                                      : _selectedSpecies,
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Status Filter
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedStatus,
                              decoration: InputDecoration(
                                labelText: 'Status',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'all',
                                  child: Text('All Status'),
                                ),
                                DropdownMenuItem(
                                  value: 'Active',
                                  child: Text('Active'),
                                ),
                                DropdownMenuItem(
                                  value: 'Inactive',
                                  child: Text('Inactive'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedStatus = value ?? 'all';
                                });
                                context.read<PatientCubit>().setFilterStatus(
                                  _selectedStatus == 'all'
                                      ? null
                                      : _selectedStatus,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Patients List
                Expanded(
                  child: filteredPatients.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredPatients.length,
                          itemBuilder: (context, index) {
                            final patient = filteredPatients[index];
                            return _buildPatientCard(patient);
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.favorite,
                size: 32,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No patients found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isNotEmpty
                  ? 'Try adjusting your search terms or filters.'
                  : 'Get started by adding your first patient.',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _handleAddPatient,
              icon: const Icon(Icons.add),
              label: const Text('Add Patient'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientCard(PatientModel patient) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    _getSpeciesIcon(patient.species),
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              patient.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                patient.isActive,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _getStatusLabel(patient.isActive),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _getStatusColor(patient.isActive),
                              ),
                            ),
                          ),
                          if (patient.medicalHistory != null &&
                              patient.medicalHistory!.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.info.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: AppColors.border,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'Medical History',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.info,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          _buildInfoChip(
                            Icons.pets,
                            patient.breed ?? 'Unknown Breed',
                          ),
                          if (patient.age != null)
                            _buildInfoChip(
                              Icons.calendar_today,
                              '${patient.age} years',
                            ),
                          _buildInfoChip(Icons.person_outline, patient.gender),
                          if (patient.weight != null)
                            _buildInfoChip(
                              Icons.monitor_weight,
                              '${patient.weight} kg',
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              patient.ownerName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (patient.ownerPhone != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.phone,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                patient.ownerPhone!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (patient.ownerEmail != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.email,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                patient.ownerEmail!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Created: ${_formatDate(patient.createdAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    if (patient.microchipNumber != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Chip: ${patient.microchipNumber}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    if (patient.color != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Color: ${patient.color}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _handleEditPatient(patient),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit', style: TextStyle(fontSize: 14)),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _handleDeletePatient(patient.id),
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 16,
                    color: AppColors.error,
                  ),
                  label: const Text(
                    'Delete',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  // Patient Detail Dialog
  Widget _buildPatientDetailDialog() {
    if (_selectedPatient == null) return const SizedBox.shrink();

    final patient = _selectedPatient!;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      _getSpeciesIcon(patient.species),
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Patient Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Patient Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                patient.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${patient.breed ?? 'Unknown'} • ${patient.age != null ? '${patient.age} years' : 'Age unknown'} • ${patient.gender}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              patient.isActive,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getStatusLabel(patient.isActive),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _getStatusColor(patient.isActive),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Patient Information
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Patient Info',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildDetailRow(
                                Icons.favorite,
                                'Species',
                                patient.species,
                              ),
                              _buildDetailRow(
                                Icons.pets,
                                'Breed',
                                patient.breed ?? 'Unknown',
                              ),
                              _buildDetailRow(
                                Icons.calendar_today,
                                'Age',
                                patient.age != null
                                    ? '${patient.age} years'
                                    : 'Unknown',
                              ),
                              _buildDetailRow(
                                Icons.person_outline,
                                'Gender',
                                patient.gender,
                              ),
                              _buildDetailRow(
                                Icons.monitor_weight,
                                'Weight',
                                patient.weight != null
                                    ? '${patient.weight} kg'
                                    : 'Unknown',
                              ),
                              if (patient.color != null)
                                _buildDetailRow(
                                  Icons.palette,
                                  'Color',
                                  patient.color!,
                                ),
                              if (patient.microchipNumber != null)
                                _buildDetailRow(
                                  Icons.credit_card,
                                  'Microchip',
                                  patient.microchipNumber!,
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 32),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Owner Info',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildDetailRow(
                                Icons.person,
                                'Name',
                                patient.ownerName,
                              ),
                              if (patient.ownerPhone != null)
                                _buildDetailRow(
                                  Icons.phone,
                                  'Phone',
                                  patient.ownerPhone!,
                                ),
                              if (patient.ownerEmail != null)
                                _buildDetailRow(
                                  Icons.email,
                                  'Email',
                                  patient.ownerEmail!,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Medical History
                    if (patient.medicalHistory != null &&
                        patient.medicalHistory!.isNotEmpty) ...[
                      const SizedBox(height: 32),
                      const Text(
                        'Medical Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.gray50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          patient.medicalHistory!,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => _handleStartConsultation(patient),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                    ),
                    child: const Text('Start Consultation'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(
                    text: value,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
