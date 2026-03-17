import 'package:aura/screens/consultation/widgets/label_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../core/utils/patient_utils.dart';
import '../../../features/patient/patient_cubit.dart';
import '../../../features/patient/patient_state.dart';
import '../../../models/patient_model.dart';
import '../history/widgets/filter_dropdown.dart';
import '../widgets/screen_header.dart';
import '../widgets/app_bar_logo_title.dart';

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

  // void _handleAddPatient() {
  //   AppRouter.pushNamed(context, AppRoutes.addPatient).then((success) {
  //     // Refresh patient list if patient was added successfully
  //     if (success == true && mounted) {
  //       context.read<PatientCubit>().loadPatients(refresh: true);
  //     }
  //   });
  // }

  void _handleEditPatient(PatientModel patient) {
    final rootContext = context;
    setState(() {
      _selectedPatient = patient;
    });
    showDialog(
      context: rootContext,
      barrierDismissible: true,
      builder: (dialogContext) =>
          _buildPatientDetailDialog(rootContext: rootContext),
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
            onPressed: () =>
                Navigator.of(context, rootNavigator: true).pop(true),
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
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        messenger.showSnackBar(
          SnackBar(
            key: ValueKey('snack_${DateTime.now().millisecondsSinceEpoch}'),
            content: Text(
              success
                  ? 'Patient deleted successfully'
                  : context.read<PatientCubit>().state.errorMessage,
            ),
            backgroundColor: success ? AppColors.success : AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
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
        title: const AppBarLogoTitle(),
        backgroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        // actions: [
        //   Container(
        //     padding: const EdgeInsets.symmetric(horizontal: 16),
        //     width: 160,
        //     child: PrimaryIconButton(
        //       onPressed: () => _handleAddPatient(),
        //       icon: Icons.add,
        //       text: 'Add Patient',
        //       fontSize: 14,
        //       verticalPadding: 8,
        //     ),
        //   ),
        // ],
      ),
      body: BlocListener<PatientCubit, PatientState>(
        listener: (context, state) {
          if (state.errorMessage.isNotEmpty) {
            final messenger = ScaffoldMessenger.of(context);
            messenger.clearSnackBars();
            messenger.showSnackBar(
              SnackBar(
                key: ValueKey('snack_${DateTime.now().millisecondsSinceEpoch}'),
                content: Text(state.errorMessage),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
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

            return SafeArea(
              child: Column(
                children: [
                  // Sticky header only
                  ScreenHeader(
                    title: 'Patient Management',
                    subtitle:
                        '${filteredPatients.length} Patient${filteredPatients.length != 1 ? 's' : ''} Found',
                  ),
                  // Scrollable content: Search & Filters + Patients List
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                    hintText:
                                        'Search patients, owners, or breeds...',
                                    prefixIcon: const Icon(
                                      Icons.search,
                                      size: 20,
                                    ),
                                    hintStyle: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 14,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                  onChanged: (value) {
                                    context.read<PatientCubit>().setSearchTerm(
                                      value,
                                    );
                                  },
                                ),
                                const SizedBox(height: 12),
                                // Filters Row
                                Row(
                                  children: [
                                    // Species Filter
                                    Expanded(
                                      child: FilterDropdown(
                                        value: _selectedSpecies,
                                        labelText: 'Species',
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 12,
                                            ),
                                        items: const [
                                          DropdownMenuItem(
                                            value: 'all',
                                            child: Text(
                                              'All Species',
                                              style: TextStyle(
                                                color: AppColors.textPrimary,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          DropdownMenuItem(
                                            value: 'dog',
                                            child: Text(
                                              'Dogs',
                                              style: TextStyle(
                                                color: AppColors.textPrimary,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          DropdownMenuItem(
                                            value: 'cat',
                                            child: Text(
                                              'Cats',
                                              style: TextStyle(
                                                color: AppColors.textPrimary,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          DropdownMenuItem(
                                            value: 'bird',
                                            child: Text(
                                              'Birds',
                                              style: TextStyle(
                                                color: AppColors.textPrimary,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          DropdownMenuItem(
                                            value: 'rabbit',
                                            child: Text(
                                              'Rabbits',
                                              style: TextStyle(
                                                color: AppColors.textPrimary,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          DropdownMenuItem(
                                            value: 'other',
                                            child: Text(
                                              'Other',
                                              style: TextStyle(
                                                color: AppColors.textPrimary,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedSpecies = value ?? 'all';
                                          });
                                          context
                                              .read<PatientCubit>()
                                              .setFilterSpecies(
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
                                      child: FilterDropdown(
                                        value: _selectedStatus,
                                        labelText: 'Status',
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 12,
                                            ),
                                        items: const [
                                          DropdownMenuItem(
                                            value: 'all',
                                            child: Text(
                                              'All Status',
                                              style: TextStyle(
                                                color: AppColors.textPrimary,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Active',
                                            child: Text(
                                              'Active',
                                              style: TextStyle(
                                                color: AppColors.textPrimary,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Inactive',
                                            child: Text(
                                              'Inactive',
                                              style: TextStyle(
                                                color: AppColors.textPrimary,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedStatus = value ?? 'all';
                                          });
                                          context
                                              .read<PatientCubit>()
                                              .setFilterStatus(
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
                          if (filteredPatients.isEmpty)
                            _buildEmptyState()
                          else
                            Container(
                              margin: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: filteredPatients.length,
                                itemBuilder: (context, index) {
                                  final patient = filteredPatients[index];
                                  return Column(
                                    children: [
                                      _buildPatientCard(patient),
                                      if (index < filteredPatients.length - 1)
                                        const Divider(
                                          color: AppColors.border,
                                          height: 1,
                                        ),
                                    ],
                                  );
                                },
                              ),
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
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32.0),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
        ),
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
              'No Patients Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontFamily: "Fraunces",
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
            // const SizedBox(height: 24),
            // SizedBox(
            //   width: 140,
            //   child: PrimaryIconButton(
            //     onPressed: _handleAddPatient,
            //     icon: Icons.add,
            //     text: 'Add Patient',
            //     fontSize: 14,
            // verticalPadding: 12,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientCard(PatientModel patient) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: avatar, name + status pill, edit/delete icons
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: PatientUtils.getSpeciesBackgroundColor(
                      patient.species,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      PatientUtils.getSpeciesIconPath(patient.species),
                      width: 26,
                      height: 26,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          patient.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      LabelChip(
                        label: _getStatusLabel(patient.isActive),
                        textColor: _getStatusColor(patient.isActive),
                        backgroundColor: _getStatusColor(
                          patient.isActive,
                        ).withValues(alpha: 0.15),
                        padding: 4,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _handleEditPatient(patient),
                  icon: Icon(Icons.edit, size: 22, color: AppColors.primary),
                  style: IconButton.styleFrom(minimumSize: const Size(40, 40)),
                ),
                IconButton(
                  onPressed: () => _handleDeletePatient(patient.id),
                  icon: Icon(
                    Icons.delete_outline_outlined,
                    size: 22,
                    color: AppColors.error,
                  ),
                  style: IconButton.styleFrom(minimumSize: const Size(40, 40)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Row 1: Breed
            _buildCardInfoRow(
              Icons.pets_outlined,
              patient.breed ?? 'Mixed breed',
            ),
            const SizedBox(height: 10),
            // Row 2: Age & Weight (spaced apart)
            Row(
              children: [
                Expanded(
                  child: _buildCardInfoRow(
                    Icons.schedule_outlined,
                    patient.age != null
                        ? '${patient.age} years'
                        : 'Age Unknown',
                  ),
                ),
                Expanded(
                  child: _buildCardInfoRow(
                    Icons.monitor_weight_outlined,
                    patient.weight != null
                        ? '${patient.weight} kg'
                        : 'Weight Unknown',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Row 3: Owner & Created date (spaced apart)
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          patient.ownerName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Created: ${_formatDate(patient.createdAt)}',
                      style: TextStyle(
                        fontSize: 13,
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
    );
  }

  Widget _buildCardInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Patient Detail Dialog (editable like web PatientsContent)
  Widget _buildPatientDetailDialog({required BuildContext rootContext}) {
    if (_selectedPatient == null) return const SizedBox.shrink();

    final patient = _selectedPatient!;

    final nameController = TextEditingController(text: patient.name);
    final breedController = TextEditingController(text: patient.breed ?? '');
    final speciesController = TextEditingController(text: patient.species);
    final ageController = TextEditingController(
      text: patient.age != null ? patient.age.toString() : '',
    );
    final weightController = TextEditingController(
      text: patient.weight != null ? patient.weight.toString() : '',
    );
    final ownerNameController = TextEditingController(text: patient.ownerName);

    bool isActive = patient.isActive;
    bool isSaving = false;
    String? saveError;

    Future<void> handleSave(StateSetter setState) async {
      if (isSaving) return;
      setState(() {
        isSaving = true;
        saveError = null;
      });

      try {
        final updated = await rootContext.read<PatientCubit>().updatePatient(
          patient.id,
          name: nameController.text.trim().isEmpty
              ? null
              : nameController.text.trim(),
          breed: breedController.text.trim().isEmpty
              ? null
              : breedController.text.trim(),
          species: speciesController.text.trim().isEmpty
              ? null
              : speciesController.text.trim(),
          age: ageController.text.trim().isEmpty
              ? null
              : int.tryParse(ageController.text.trim()),
          weight: weightController.text.trim().isEmpty
              ? null
              : double.tryParse(weightController.text.trim()),
          ownerName: ownerNameController.text.trim().isEmpty
              ? null
              : ownerNameController.text.trim(),
          isActive: isActive,
        );

        if (updated != null) {
          Navigator.of(rootContext, rootNavigator: true).pop();
          final messenger = ScaffoldMessenger.of(rootContext);
          messenger.clearSnackBars();
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Patient updated successfully'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          final message = rootContext.read<PatientCubit>().state.errorMessage;
          setState(() {
            saveError = message.isNotEmpty
                ? message
                : 'Failed to update patient';
          });
        }
      } catch (e) {
        setState(() {
          saveError = e.toString().replaceFirst('Exception: ', '');
        });
      } finally {
        setState(() {
          isSaving = false;
        });
      }
    }

    return StatefulBuilder(
      builder: (context, setState) {
        return Dialog(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800, maxHeight: 700),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header (title + subtitle, like web)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Edit Patient',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Fraunces',
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Update patient information and click Save.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                      ),
                    ],
                  ),
                ),
                Divider(color: AppColors.divider, height: 1),
                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Error banner (top of form, like web)
                        if (saveError != null && saveError!.isNotEmpty) ...[
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.error.withOpacity(0.4),
                              ),
                            ),
                            child: Text(
                              saveError!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ],
                        // Patient Name (first field, no avatar, no prefix icon)
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Patient Name',
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Breed
                        TextField(
                          controller: breedController,
                          decoration: const InputDecoration(labelText: 'Breed'),
                        ),
                        const SizedBox(height: 12),
                        // Species
                        TextField(
                          controller: speciesController,
                          decoration: const InputDecoration(
                            labelText: 'Species',
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Status dropdown
                        DropdownButtonFormField<bool>(
                          value: isActive,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: true,
                              child: Text('Active'),
                            ),
                            DropdownMenuItem(
                              value: false,
                              child: Text('Inactive'),
                            ),
                          ],
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() {
                              isActive = v;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        // Age & Weight in a row
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: ageController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Age',
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: weightController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: const InputDecoration(
                                  labelText: 'Weight',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Owner
                        TextField(
                          controller: ownerNameController,
                          decoration: const InputDecoration(labelText: 'Owner'),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(color: AppColors.divider, height: 1),
                // Actions
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (saveError != null && saveError!.isNotEmpty) ...[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            saveError!,
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(
                                context,
                                rootNavigator: true,
                              ).pop(),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isSaving
                                  ? null
                                  : () => handleSave(setState),
                              child: Text(
                                isSaving ? 'Saving...' : 'Save',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // No extra helpers needed for edit dialog – it uses plain TextFields
}
