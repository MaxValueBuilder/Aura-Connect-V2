import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class PatientReviewView extends StatefulWidget {
  final Map<String, dynamic> extractedPatientInfo;
  final Map<String, dynamic> stepInfo;
  final int totalSteps;
  final VoidCallback onComplete;

  const PatientReviewView({
    super.key,
    required this.extractedPatientInfo,
    required this.stepInfo,
    required this.totalSteps,
    required this.onComplete,
  });

  @override
  State<PatientReviewView> createState() => _PatientReviewViewState();
}

class _PatientReviewViewState extends State<PatientReviewView> {
  bool _isEditing = false;
  late Map<String, dynamic> _editedInfo;

  @override
  void initState() {
    super.initState();
    _editedInfo = Map<String, dynamic>.from(widget.extractedPatientInfo);
  }

  void _handleFieldChange(String field, String value) {
    setState(() {
      _editedInfo[field] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: null, // Disabled during review
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Step ${widget.stepInfo['step']} of ${widget.totalSteps}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.stepInfo['title'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${((widget.stepInfo['step'] as int) / widget.totalSteps * 100).round()}%',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (widget.stepInfo['step'] as int) / widget.totalSteps,
                    backgroundColor: AppColors.gray200,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 2,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.stepInfo['description'] as String,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Success Message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.success.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Patient Information Extracted',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.success,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'AI has automatically extracted patient details. Please review below.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.success.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Patient Information Card
              Card(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.favorite, color: AppColors.primary, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'Patient Details',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _isEditing = !_isEditing;
                              });
                            },
                            icon: Icon(
                              _isEditing ? Icons.save : Icons.edit,
                              size: 16,
                            ),
                            label: Text(_isEditing ? 'Save' : 'Edit'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildField(
                                  'Name',
                                  _editedInfo['name']?.toString() ?? '',
                                  'name',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildField(
                                  'Species',
                                  _editedInfo['species']?.toString().toUpperCase() ?? '',
                                  'species',
                                  editable: false,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildField(
                                  'Breed',
                                  _editedInfo['breed']?.toString() ?? '',
                                  'breed',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildField(
                                  'Age',
                                  '${_editedInfo['age'] ?? ''} ${_editedInfo['ageUnit'] ?? ''}',
                                  'age',
                                  editable: false,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildField(
                            'Owner',
                            _editedInfo['ownerName']?.toString() ?? '',
                            'ownerName',
                          ),
                          if (_editedInfo['ownerPhone'] != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              _editedInfo['ownerPhone']?.toString() ?? '',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          _buildField(
                            'Chief Complaint',
                            _editedInfo['chiefComplaint']?.toString() ?? '',
                            'chiefComplaint',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: widget.onComplete,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Confirm & Continue'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, String value, String fieldKey, {bool editable = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        if (_isEditing && editable)
          TextFormField(
            initialValue: value,
            onChanged: (newValue) => _handleFieldChange(fieldKey, newValue),
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          )
        else
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
      ],
    );
  }
}

