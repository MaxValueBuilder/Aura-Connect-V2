import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/consultation/consultation_cubit.dart';
import 'label_chip.dart';

/// Modal for editing consultation: patient name, breed, priority, emergency, notes.
/// Save calls [ConsultationCubit.updateConsultation] and [onSaved] on success.
class EditConsultationModal extends StatefulWidget {
  const EditConsultationModal({
    super.key,
    required this.consultationId,
    required this.initialPatientName,
    required this.initialBreed,
    this.initialPriority = 'medium',
    this.initialIsEmergency = false,
    this.initialNotes = '',
    this.onSaved,
  });

  final String consultationId;
  final String initialPatientName;
  final String initialBreed;
  final String initialPriority;
  final bool initialIsEmergency;
  final String initialNotes;
  final VoidCallback? onSaved;

  @override
  State<EditConsultationModal> createState() => _EditConsultationModalState();
}

class _EditConsultationModalState extends State<EditConsultationModal> {
  late TextEditingController _patientNameController;
  late TextEditingController _breedController;
  late TextEditingController _notesController;
  late String _priority;
  late bool _isEmergency;
  bool _isSaving = false;

  static const List<Map<String, String>> _priorityOptions = [
    {'value': 'low', 'label': 'Low priority'},
    {'value': 'medium', 'label': 'Medium priority'},
    {'value': 'high', 'label': 'High priority'},
    {'value': 'urgent', 'label': 'Urgent priority'},
  ];

  @override
  void initState() {
    super.initState();
    _patientNameController = TextEditingController(
      text: widget.initialPatientName,
    );
    _breedController = TextEditingController(text: widget.initialBreed);
    _notesController = TextEditingController(text: widget.initialNotes);
    _priority = widget.initialPriority;
    _isEmergency = widget.initialIsEmergency;
  }

  @override
  void dispose() {
    _patientNameController.dispose();
    _breedController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _priorityLabel(String value) {
    switch (value) {
      case 'low':
        return 'Low';
      case 'medium':
        return 'Medium';
      case 'high':
        return 'High';
      case 'urgent':
        return 'Urgent';
      default:
        return 'Medium';
    }
  }

  Color _priorityColor(String value) {
    switch (value) {
      case 'high':
      case 'urgent':
        return AppColors.error;
      case 'medium':
        return AppColors.warning;
      case 'low':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  Future<void> _handleSave() async {
    final patientName = _patientNameController.text.trim();
    if (patientName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Patient name is required')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      await context.read<ConsultationCubit>().updateConsultation(
        widget.consultationId,
        {
          'patientName': patientName,
          'priority': _priority,
          'isEmergency': _isEmergency,
          'notes': _notesController.text.trim(),
          'aiAnalysis': {
            'breed': _breedController.text.trim().isEmpty
                ? 'Mixed breed'
                : _breedController.text.trim(),
          },
        },
      );

      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onSaved?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Consultation updated'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update: ${e.toString().replaceAll('Exception: ', '')}',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.edit_note, color: AppColors.primary, size: 28),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Edit Consultation',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _buildLabel('Patient Name'),
              _buildTextField(
                controller: _patientNameController,
                icon: Icons.local_hospital,
                hint: 'Patient name',
              ),
              const SizedBox(height: 16),

              _buildLabel('Breed'),
              _buildTextField(
                controller: _breedController,
                icon: Icons.pets,
                hint: 'Breed',
              ),
              const SizedBox(height: 16),

              _buildLabel('Priority'),
              _buildPriorityDropdown(),
              const SizedBox(height: 16),

              Row(
                children: [
                  Checkbox(
                    value: _isEmergency,
                    onChanged: (v) => setState(() => _isEmergency = v ?? false),
                    activeColor: AppColors.primary,
                  ),
                  const Text(
                    'Marks as Emergency',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildLabel('Notes'),
              _buildTextField(
                controller: _notesController,
                icon: Icons.note,
                hint: 'Add Consultation Notes....',
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Preview
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Preview:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          _patientNameController.text.isEmpty
                              ? 'Patient'
                              : _patientNameController.text,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        LabelChip(
                          label: _priorityLabel(_priority),
                          textColor: _priorityColor(_priority),
                          backgroundColor: _priorityColor(
                            _priority,
                          ).withValues(alpha: 0.2),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Breed: ${_breedController.text.isEmpty ? 'Mixed breed' : _breedController.text}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving
                          ? null
                          : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white,
                              ),
                            )
                          : const Text('Save Changes'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.gray500),
        prefixIcon: Icon(icon, color: AppColors.gray400, size: 22),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.6),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildPriorityDropdown() {
    final current = _priorityOptions.firstWhere(
      (e) => e['value'] == _priority,
      orElse: () => _priorityOptions[1],
    );
    final label = current['label'] ?? 'Medium priority';
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (ctx) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Select priority',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                ..._priorityOptions.map(
                  (opt) => ListTile(
                    title: Text(opt['label']!),
                    trailing: _priority == opt['value']
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () {
                      setState(() => _priority = opt['value']!);
                      Navigator.pop(ctx);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.6)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.format_list_numbered,
              color: AppColors.gray400,
              size: 22,
            ),
            const SizedBox(width: 12),
            LabelChip(
              label: _priorityLabel(_priority),
              textColor: _priorityColor(_priority),
              backgroundColor: _priorityColor(_priority).withValues(alpha: 0.2),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
