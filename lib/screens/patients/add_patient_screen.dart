// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../../core/constants/app_constants.dart';
// import '../../../core/theme/app_colors.dart';
// import '../../core/utils/patient_utils.dart';
// import '../../../features/patient/patient_cubit.dart';
// import '../../../features/patient/patient_state.dart';
// import '../widgets/form_text_field.dart';
// import '../widgets/form_dropdown.dart';
// import '../widgets/screen_header.dart';

// class AddPatientScreen extends StatefulWidget {
//   const AddPatientScreen({super.key});

//   @override
//   State<AddPatientScreen> createState() => _AddPatientScreenState();
// }

// class _AddPatientScreenState extends State<AddPatientScreen> {
//   final _patientFormKey = GlobalKey<FormState>();
//   final _ownerFormKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _breedController = TextEditingController();
//   final _ageController = TextEditingController();
//   final _weightController = TextEditingController();
//   final _microchipController = TextEditingController();
//   final _ownerNameController = TextEditingController();
//   final _ownerPhoneController = TextEditingController();
//   final _ownerEmailController = TextEditingController();
//   final _medicalHistoryController = TextEditingController();
//   final _knownAllergiesController = TextEditingController();
//   final _currentMedicationsController = TextEditingController();

//   final Set<String> _medicalFlags = {};

//   String _selectedSpecies = 'dog';
//   String _selectedGender = 'male';
//   String _ageUnit = 'years';
//   String _weightUnit = 'kg';
//   bool _isSubmitting = false;
//   bool _showSuccess = false;
//   int _currentStep = 0;

//   final List<String> _speciesOptions = [
//     'dog',
//     'cat',
//     'bird',
//     'rabbit',
//     'other',
//   ];

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _breedController.dispose();
//     _ageController.dispose();
//     _weightController.dispose();
//     _microchipController.dispose();
//     _ownerNameController.dispose();
//     _ownerPhoneController.dispose();
//     _ownerEmailController.dispose();
//     _medicalHistoryController.dispose();
//     _knownAllergiesController.dispose();
//     _currentMedicationsController.dispose();
//     super.dispose();
//   }

//   void _goToNextStep() {
//     if (_currentStep == 0) {
//       if (!_patientFormKey.currentState!.validate()) return;
//       setState(() => _currentStep = 1);
//     } else if (_currentStep == 1) {
//       if (!_ownerFormKey.currentState!.validate()) return;
//       setState(() => _currentStep = 2);
//     }
//   }

//   Future<void> _handleSubmit() async {
//     if (!_patientFormKey.currentState!.validate() ||
//         !_ownerFormKey.currentState!.validate()) {
//       return;
//     }

//     setState(() => _isSubmitting = true);

//     try {
//       // Convert age to years if in months
//       int? age;
//       if (_ageController.text.isNotEmpty) {
//         final ageValue = double.tryParse(_ageController.text) ?? 0;
//         age = _ageUnit == 'months' ? (ageValue / 12).round() : ageValue.toInt();
//       }

//       // Convert weight to kg if in lbs
//       double? weight;
//       if (_weightController.text.isNotEmpty) {
//         final weightValue = double.tryParse(_weightController.text) ?? 0;
//         weight = _weightUnit == 'lbs' ? weightValue * 0.453592 : weightValue;
//       }

//       final patient = await context.read<PatientCubit>().createPatient(
//         name: _nameController.text.trim(),
//         species: _selectedSpecies,
//         breed: _breedController.text.trim(),
//         age: age,
//         weight: weight,
//         ownerName: _ownerNameController.text.trim(),
//         ownerPhone: _ownerPhoneController.text.trim(),
//         ownerEmail: _ownerEmailController.text.trim(),
//         medicalHistory: _buildMedicalHistoryString(),
//         microchipNumber: _microchipController.text.trim().isNotEmpty
//             ? _microchipController.text.trim()
//             : null,
//         gender: _selectedGender,
//       );

//       if (mounted) {
//         setState(() => _isSubmitting = false);
//         if (patient != null) {
//           setState(() => _showSuccess = true);
//           // Navigate back after 2 seconds
//           Future.delayed(const Duration(seconds: 2), () {
//             if (mounted) {
//               Navigator.of(context).pop(true); // Return true to indicate success
//             }
//           });
//         }
//         // On failure, BlocListener will show error SnackBar from state.errorMessage
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() => _isSubmitting = false);
//         _showErrorSnackBar('Error adding patient: ${e.toString()}');
//       }
//     }
//   }

//   void _handleCancel() {
//     Navigator.of(context).pop();
//   }

//   void _showErrorSnackBar(String message) {
//     final messenger = ScaffoldMessenger.of(context);
//     messenger.clearSnackBars();
//     messenger.showSnackBar(
//       SnackBar(
//         key: ValueKey('snack_${DateTime.now().millisecondsSinceEpoch}'),
//         content: Text(message),
//         backgroundColor: AppColors.error,
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }

//   String? _buildMedicalHistoryString() {
//     final parts = <String>[];
//     if (_medicalFlags.isNotEmpty) {
//       parts.add('Medical Flags: ${_medicalFlags.join(', ')}');
//     }
//     final allergies = _knownAllergiesController.text.trim();
//     if (allergies.isNotEmpty) {
//       parts.add('Known Allergies: $allergies');
//     }
//     final medications = _currentMedicationsController.text.trim();
//     if (medications.isNotEmpty) {
//       parts.add('Current Medications: $medications');
//     }
//     final notes = _medicalHistoryController.text.trim();
//     if (notes.isNotEmpty) {
//       parts.add('Special Notes: $notes');
//     }
//     return parts.isEmpty ? null : parts.join('\n');
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_showSuccess) {
//       return Scaffold(
//         backgroundColor: AppColors.background,
//         body: SafeArea(
//           child: Center(
//             child: Card(
//               margin: const EdgeInsets.all(24),
//               child: Padding(
//                 padding: const EdgeInsets.all(32),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Container(
//                       width: 64,
//                       height: 64,
//                       decoration: BoxDecoration(
//                         color: AppColors.success.withOpacity(0.1),
//                         shape: BoxShape.circle,
//                       ),
//                       child: const Icon(
//                         Icons.check_circle,
//                         color: AppColors.success,
//                         size: 40,
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//                     const Text(
//                       'Patient Added Successfully!',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: AppColors.textPrimary,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       '${_nameController.text} has been added to your patient database.',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: AppColors.textSecondary,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       );
//     }

//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         title: const Text(
//           'Add New Patient',
//           style: TextStyle(
//             color: AppColors.textPrimary,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         backgroundColor: AppColors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
//           onPressed: _handleCancel,
//         ),
//       ),
//       body: BlocListener<PatientCubit, PatientState>(
//         listener: (context, state) {
//           if (state.errorMessage.isNotEmpty && !_isSubmitting) {
//             _showErrorSnackBar(state.errorMessage);
//             context.read<PatientCubit>().clearError();
//           }
//         },
//         child: SafeArea(
//           child: Column(
//             children: [
//               const ScreenHeader(
//                 title: 'Add New Patient',
//                 subtitle: 'Register a new patient and owner information',
//               ),
//               Expanded(
//                 child: SingleChildScrollView(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _buildStepIndicator(),
//                       const SizedBox(height: 24),
//                       IndexedStack(
//                         index: _currentStep,
//                         children: [
//                           _buildPatientStep(),
//                           _buildOwnerStep(),
//                           _buildMedicalStep(),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildStepIndicator() {
//     const steps = ['Patient', 'Owner', 'Medical'];
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         // Circles and connecting lines - lines align with circle centers
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             for (int i = 0; i < 3; i++) ...[
//               Expanded(
//                 child: Center(
//                   child: _buildStepCircle(
//                     stepIndex: i,
//                     isCompleted: _currentStep > i,
//                     isActive: _currentStep == i,
//                   ),
//                 ),
//               ),
//               if (i < 2)
//                 Expanded(
//                   child: Container(
//                     height: 4,
//                     color: _currentStep > i
//                         ? AppColors.primary
//                         : AppColors.gray300,
//                   ),
//                 ),
//             ],
//           ],
//         ),
//         const SizedBox(height: 4),
//         // Labels row - match structure of circles (Expanded, Expanded, Expanded for 3 steps)
//         Row(
//           children: [
//             for (int i = 0; i < 3; i++) ...[
//               Expanded(
//                 child: Center(
//                   child: Text(
//                     steps[i],
//                     style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500,
//                       color: _currentStep >= i
//                           ? AppColors.primary
//                           : AppColors.gray500,
//                     ),
//                   ),
//                 ),
//               ),
//               if (i < 2) const Expanded(child: SizedBox.shrink()),
//             ],
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildStepCircle({
//     required int stepIndex,
//     required bool isCompleted,
//     required bool isActive,
//   }) {
//     final isHighlighted = isCompleted || isActive;
//     return Container(
//       width: 32,
//       height: 32,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: isHighlighted ? AppColors.primary : AppColors.gray300,
//       ),
//       child: Center(
//         child: isCompleted
//             ? const Icon(Icons.check, color: AppColors.white, size: 18)
//             : Text(
//                 '${stepIndex + 1}',
//                 style: TextStyle(
//                   color: isHighlighted ? AppColors.white : AppColors.gray600,
//                   fontWeight: FontWeight.w600,
//                   fontSize: 14,
//                 ),
//               ),
//       ),
//     );
//   }

//   Widget _buildPatientStep() {
//     return Form(
//       key: _patientFormKey,
//       child: _buildSectionCard(
//         title: 'Patient Information',
//         icon: Icons.favorite,
//         children: [
//           FormTextField(
//             controller: _nameController,
//             label: 'Patient Name',
//             hint: 'Enter your patient name',
//             validator: (value) =>
//                 PatientUtils.validateRequired(value, 'Patient name'),
//             required: true,
//           ),
//           const SizedBox(height: 16),
//           FormDropdown<String>(
//             label: 'Species',
//             value: _selectedSpecies,
//             items: _speciesOptions.map((species) {
//               return DropdownMenuItem<String>(
//                 value: species,
//                 child: Text(PatientUtils.getSpeciesLabel(species)),
//               );
//             }).toList(),
//             onChanged: (value) {
//               setState(() => _selectedSpecies = value!);
//             },
//             required: true,
//           ),
//           const SizedBox(height: 16),
//           FormTextField(
//             controller: _breedController,
//             label: 'Breed',
//             hint: 'Enter breed',
//             validator: (value) => PatientUtils.validateRequired(value, 'Breed'),
//             required: true,
//           ),
//           const SizedBox(height: 16),
//           FormDropdown<String>(
//             label: 'Gender',
//             value: _selectedGender,
//             items: const [
//               DropdownMenuItem(value: 'male', child: Text('Male')),
//               DropdownMenuItem(value: 'female', child: Text('Female')),
//             ],
//             onChanged: (value) {
//               setState(() => _selectedGender = value!);
//             },
//             required: true,
//           ),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               Expanded(
//                 flex: 2,
//                 child: FormTextField(
//                   controller: _ageController,
//                   label: 'Age',
//                   hint: 'Enter age',
//                   keyboardType: TextInputType.number,
//                   validator: (value) =>
//                       PatientUtils.validateNumber(value, 'Age'),
//                   required: true,
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: FormDropdown<String>(
//                   label: 'Unit',
//                   value: _ageUnit,
//                   items: const [
//                     DropdownMenuItem(value: 'years', child: Text('Years')),
//                     DropdownMenuItem(value: 'months', child: Text('Months')),
//                   ],
//                   onChanged: (value) {
//                     setState(() => _ageUnit = value!);
//                   },
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               Expanded(
//                 flex: 2,
//                 child: FormTextField(
//                   controller: _weightController,
//                   label: 'Weight',
//                   hint: 'Enter weight',
//                   keyboardType: TextInputType.number,
//                   validator: (value) =>
//                       PatientUtils.validateNumber(value, 'Weight'),
//                   required: true,
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: FormDropdown<String>(
//                   label: 'Unit',
//                   value: _weightUnit,
//                   items: const [
//                     DropdownMenuItem(value: 'kg', child: Text('kg')),
//                     DropdownMenuItem(value: 'lbs', child: Text('lbs')),
//                   ],
//                   onChanged: (value) {
//                     setState(() => _weightUnit = value!);
//                   },
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           FormTextField(
//             controller: _microchipController,
//             label: 'Microchip ID (Optional)',
//             hint: 'Enter microchip id',
//             keyboardType: TextInputType.text,
//           ),
//           const SizedBox(height: 24),
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               onPressed: _goToNextStep,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.primary,
//                 foregroundColor: AppColors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//               ),
//               child: const Text('Next'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildOwnerStep() {
//     return Form(
//       key: _ownerFormKey,
//       child: _buildSectionCard(
//         title: 'Owner Information',
//         icon: Icons.person,
//         children: [
//           FormTextField(
//             controller: _ownerNameController,
//             label: 'Owner Name',
//             hint: 'Enter your name',
//             validator: (value) =>
//                 PatientUtils.validateRequired(value, 'Owner name'),
//             required: true,
//           ),
//           const SizedBox(height: 16),
//           FormTextField(
//             controller: _ownerPhoneController,
//             label: 'Phone Number',
//             hint: 'Enter Phone Number',
//             keyboardType: TextInputType.phone,
//             validator: PatientUtils.validatePhone,
//             required: true,
//           ),
//           const SizedBox(height: 16),
//           FormTextField(
//             controller: _ownerEmailController,
//             label: 'Email Address',
//             hint: 'Enter email',
//             keyboardType: TextInputType.emailAddress,
//             validator: PatientUtils.validateEmail,
//             required: true,
//           ),
//           const SizedBox(height: 24),
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               onPressed: _goToNextStep,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.primary,
//                 foregroundColor: AppColors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//               ),
//               child: const Text('Next'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMedicalStep() {
//     return _buildSectionCard(
//       title: 'Medical Information',
//       icon: Icons.medical_services,
//       children: [
//         // Medical Flags
//         const Text(
//           'Medical Flags',
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w600,
//             color: AppColors.textPrimary,
//           ),
//         ),
//         const SizedBox(height: 12),
//         GridView.count(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           crossAxisCount: 2,
//           mainAxisSpacing: 8,
//           crossAxisSpacing: 8,
//           childAspectRatio: 3.5,
//           children: AppConstants.medicalFlagOptions.map((flag) {
//             final isChecked = _medicalFlags.contains(flag);
//             return InkWell(
//               onTap: () {
//                 setState(() {
//                   if (isChecked) {
//                     _medicalFlags.remove(flag);
//                   } else {
//                     _medicalFlags.add(flag);
//                   }
//                 });
//               },
//               borderRadius: BorderRadius.circular(8),
//               child: Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: AppColors.primary, width: 1),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 2,
//                     vertical: 8,
//                   ),
//                   child: Row(
//                     children: [
//                       Checkbox(
//                         value: isChecked,
//                         onChanged: (value) {
//                           setState(() {
//                             if (value == true) {
//                               _medicalFlags.add(flag);
//                             } else {
//                               _medicalFlags.remove(flag);
//                             }
//                           });
//                         },
//                         activeColor: AppColors.primary,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                       ),
//                       Expanded(
//                         child: Text(
//                           flag,
//                           style: const TextStyle(
//                             fontSize: 12,
//                             color: AppColors.textPrimary,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           }).toList(),
//         ),
//         const SizedBox(height: 20),
//         // Known Allergies
//         FormTextField(
//           controller: _knownAllergiesController,
//           label: 'Known Allergies',
//           hint: 'List any known allergies or sensitivities',
//           maxLines: 3,
//           keyboardType: TextInputType.multiline,
//         ),
//         const SizedBox(height: 16),
//         // Current Medications
//         FormTextField(
//           controller: _currentMedicationsController,
//           label: 'Current Medications',
//           hint: 'List current medications and dosages',
//           maxLines: 3,
//           keyboardType: TextInputType.multiline,
//         ),
//         const SizedBox(height: 16),
//         // Special Notes
//         FormTextField(
//           controller: _medicalHistoryController,
//           label: 'Special Notes',
//           hint:
//               'Any additional notes about the patient\'s behaviour, preferences, or medical history',
//           maxLines: 4,
//           keyboardType: TextInputType.multiline,
//         ),
//         const SizedBox(height: 24),
//         Row(
//           children: [
//             Expanded(
//               child: OutlinedButton(
//                 onPressed: _isSubmitting ? null : _handleCancel,
//                 style: OutlinedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   side: BorderSide(color: AppColors.border),
//                 ),
//                 child: const Text('Cancel'),
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: ElevatedButton(
//                 onPressed: _isSubmitting ? null : _handleSubmit,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primary,
//                   foregroundColor: AppColors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                 ),
//                 child: _isSubmitting
//                     ? const SizedBox(
//                         height: 20,
//                         width: 20,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           valueColor: AlwaysStoppedAnimation<Color>(
//                             AppColors.white,
//                           ),
//                         ),
//                       )
//                     : const Text('Add'),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildSectionCard({
//     required String title,
//     required IconData icon,
//     required List<Widget> children,
//   }) {
//     return Card(
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: BorderSide(color: AppColors.border, width: 1),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(icon, color: AppColors.primary, size: 20),
//                 const SizedBox(width: 8),
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.textPrimary,
//                     fontFamily: "Fraunces",
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             ...children,
//           ],
//         ),
//       ),
//     );
//   }
// }
