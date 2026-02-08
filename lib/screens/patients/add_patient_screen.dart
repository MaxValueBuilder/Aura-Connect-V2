import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../features/patient/patient_cubit.dart';
import '../../../features/patient/patient_state.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _microchipController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _ownerPhoneController = TextEditingController();
  final _ownerEmailController = TextEditingController();
  final _medicalHistoryController = TextEditingController();

  String _selectedSpecies = 'dog';
  String _selectedGender = 'male';
  String _ageUnit = 'years';
  String _weightUnit = 'kg';
  bool _isSubmitting = false;
  bool _showSuccess = false;

  final List<String> _speciesOptions = [
    'dog',
    'cat',
    'bird',
    'rabbit',
    'other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _microchipController.dispose();
    _ownerNameController.dispose();
    _ownerPhoneController.dispose();
    _ownerEmailController.dispose();
    _medicalHistoryController.dispose();
    super.dispose();
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (!RegExp(r'^[\d\s\-\(\)\+]+$').hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  String? _validateNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    final num = double.tryParse(value);
    if (num == null || num <= 0) {
      return 'Please enter a valid $fieldName';
    }
    return null;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Convert age to years if in months
      int? age;
      if (_ageController.text.isNotEmpty) {
        final ageValue = double.tryParse(_ageController.text) ?? 0;
        age = _ageUnit == 'months' ? (ageValue / 12).round() : ageValue.toInt();
      }

      // Convert weight to kg if in lbs
      double? weight;
      if (_weightController.text.isNotEmpty) {
        final weightValue = double.tryParse(_weightController.text) ?? 0;
        weight = _weightUnit == 'lbs' ? weightValue * 0.453592 : weightValue;
      }

      await context.read<PatientCubit>().createPatient(
        name: _nameController.text.trim(),
        species: _selectedSpecies,
        breed: _breedController.text.trim(),
        age: age,
        weight: weight,
        ownerName: _ownerNameController.text.trim(),
        ownerPhone: _ownerPhoneController.text.trim(),
        ownerEmail: _ownerEmailController.text.trim(),
        medicalHistory: _medicalHistoryController.text.trim().isNotEmpty
            ? _medicalHistoryController.text.trim()
            : null,
        microchipNumber: _microchipController.text.trim().isNotEmpty
            ? _microchipController.text.trim()
            : null,
        gender: _selectedGender,
      );

      if (mounted) {
        setState(() {
          _showSuccess = true;
          _isSubmitting = false;
        });

        // Navigate back after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pop(true); // Return true to indicate success
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding patient: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _handleCancel() {
    Navigator.of(context).pop();
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

  String _getSpeciesLabel(String species) {
    switch (species.toLowerCase()) {
      case 'dog':
        return 'Dog';
      case 'cat':
        return 'Cat';
      case 'bird':
        return 'Bird';
      case 'rabbit':
        return 'Rabbit';
      default:
        return 'Other';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showSuccess) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: Card(
              margin: const EdgeInsets.all(24),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Patient Added Successfully!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_nameController.text} has been added to your patient database.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Add New Patient',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: _handleCancel,
        ),
      ),
      body: BlocListener<PatientCubit, PatientState>(
        listener: (context, state) {
          if (state.errorMessage.isNotEmpty && !_isSubmitting) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: AppColors.error,
              ),
            );
            context.read<PatientCubit>().clearError();
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Patient Information Card
                _buildSectionCard(
                  title: 'Patient Information',
                  icon: Icons.favorite,
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      label: 'Patient Name',
                      hint: 'e.g., Bella, Max, Whiskers',
                      validator: (value) =>
                          _validateRequired(value, 'Patient name'),
                      required: true,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown<String>(
                            label: 'Species',
                            value: _selectedSpecies,
                            items: _speciesOptions.map((species) {
                              return DropdownMenuItem<String>(
                                value: species,
                                child: Row(
                                  children: [
                                    Icon(
                                      _getSpeciesIcon(species),
                                      size: 20,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(_getSpeciesLabel(species)),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedSpecies = value!);
                            },
                            required: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDropdown<String>(
                            label: 'Gender',
                            value: _selectedGender,
                            items: const [
                              DropdownMenuItem(
                                value: 'male',
                                child: Text('Male'),
                              ),
                              DropdownMenuItem(
                                value: 'female',
                                child: Text('Female'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() => _selectedGender = value!);
                            },
                            required: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _breedController,
                      label: 'Breed',
                      hint: 'e.g., Golden Retriever, Persian',
                      validator: (value) => _validateRequired(value, 'Breed'),
                      required: true,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildTextField(
                            controller: _ageController,
                            label: 'Age',
                            hint: '3',
                            keyboardType: TextInputType.number,
                            validator: (value) => _validateNumber(value, 'Age'),
                            required: true,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildDropdown<String>(
                            label: 'Unit',
                            value: _ageUnit,
                            items: const [
                              DropdownMenuItem(
                                value: 'years',
                                child: Text('Years'),
                              ),
                              DropdownMenuItem(
                                value: 'months',
                                child: Text('Months'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() => _ageUnit = value!);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildTextField(
                            controller: _weightController,
                            label: 'Weight',
                            hint: '22',
                            keyboardType: TextInputType.number,
                            validator: (value) =>
                                _validateNumber(value, 'Weight'),
                            required: true,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildDropdown<String>(
                            label: 'Unit',
                            value: _weightUnit,
                            items: const [
                              DropdownMenuItem(value: 'kg', child: Text('kg')),
                              DropdownMenuItem(
                                value: 'lbs',
                                child: Text('lbs'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() => _weightUnit = value!);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _microchipController,
                      label: 'Microchip ID (Optional)',
                      hint: 'e.g., 985141001234567',
                      keyboardType: TextInputType.text,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Owner Information Card
                _buildSectionCard(
                  title: 'Owner Information',
                  icon: Icons.person,
                  children: [
                    _buildTextField(
                      controller: _ownerNameController,
                      label: 'Owner Name',
                      hint: 'e.g., Sarah Johnson',
                      validator: (value) =>
                          _validateRequired(value, 'Owner name'),
                      required: true,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _ownerPhoneController,
                      label: 'Phone Number',
                      hint: '(555) 123-4567',
                      keyboardType: TextInputType.phone,
                      validator: _validatePhone,
                      required: true,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _ownerEmailController,
                      label: 'Email Address',
                      hint: 'sarah.johnson@email.com',
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                      required: true,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Medical Information Card
                _buildSectionCard(
                  title: 'Medical Information',
                  icon: Icons.medical_services,
                  children: [
                    _buildTextField(
                      controller: _medicalHistoryController,
                      label: 'Medical History / Special Notes',
                      hint:
                          'Any additional notes about the patient\'s behavior, preferences, or medical history...',
                      maxLines: 4,
                      keyboardType: TextInputType.multiline,
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Form Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSubmitting ? null : _handleCancel,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: AppColors.border),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.white,
                                  ),
                                ),
                              )
                            : const Text('Add'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            if (required) ...[
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(color: AppColors.error, fontSize: 14),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
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
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.error, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            filled: true,
            fillColor: AppColors.white,
          ),
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            if (required) ...[
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(color: AppColors.error, fontSize: 14),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: DropdownButtonFormField<T>(
            initialValue: value,
            items: items,
            onChanged: onChanged,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            ),
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            isExpanded: true,
          ),
        ),
      ],
    );
  }
}
