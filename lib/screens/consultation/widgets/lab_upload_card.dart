import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/consultation/consultation_cubit.dart';

/// Reusable card for uploading lab results. Can be embedded in TasksLabsView
/// or used inside LabUploadView. Matches Figma: white card, blue border,
/// document icon + title, dashed dropzone, Choose Files, notes, Cancel + Upload.
class LabUploadCard extends StatefulWidget {
  final VoidCallback onUploadComplete;
  final Function(String imageUrl)? onUploadSuccess;
  final VoidCallback onCancel;

  const LabUploadCard({
    super.key,
    required this.onUploadComplete,
    this.onUploadSuccess,
    required this.onCancel,
  });

  @override
  State<LabUploadCard> createState() => _LabUploadCardState();
}

class _LabUploadCardState extends State<LabUploadCard> {
  List<File> _selectedFiles = [];
  bool _isUploading = false;
  String? _uploadError;
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          for (var file in result.files) {
            if (file.path != null) {
              _selectedFiles.add(File(file.path!));
            }
          }
          _uploadError = null;
        });
      }
    } catch (e) {
      setState(() {
        _uploadError = 'Error picking file: ${e.toString()}';
      });
    }
  }

  void _removeFile(int index) {
    setState(() => _selectedFiles.removeAt(index));
  }

  Future<void> _handleUpload() async {
    if (_selectedFiles.isEmpty) return;
    if (!mounted) return;
    setState(() {
      _isUploading = true;
      _uploadError = null;
    });

    try {
      widget.onUploadComplete();

      final cubit = context.read<ConsultationCubit>();
      final uploadedUrls = <String>[];

      for (int i = 0; i < _selectedFiles.length; i++) {
        final file = _selectedFiles[i];
        final uploadResult = await cubit.uploadFile(file.path, 'image');
        if (uploadResult != null) {
          final url =
              uploadResult['file']?['url'] ?? uploadResult['url'] ?? file.path;
          uploadedUrls.add(url);
        } else {
          throw Exception('Failed to upload ${file.path.split('/').last}');
        }
      }

      if (uploadedUrls.isNotEmpty && widget.onUploadSuccess != null) {
        widget.onUploadSuccess!(uploadedUrls.first);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadError = 'Upload failed: ${e.toString()}';
        });
      }
    }
  }

  void _handleCancel() {
    setState(() {
      _selectedFiles.clear();
      _notesController.clear();
      _uploadError = null;
    });
    widget.onCancel();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: document icon + "Upload Lab Result"
          Row(
            children: [
              const Icon(Icons.description, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Upload Lab Result',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  fontFamily: "Fraunces",
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Dashed dropzone
          GestureDetector(
            onTap: _isUploading ? null : _pickFile,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.file_upload_outlined,
                      size: 36,
                      color: AppColors.gray400,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Upload lab result and reports',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Drag and drop files or click to select',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _isUploading ? null : _pickFile,
                    icon: const Icon(
                      Icons.file_upload_outlined,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    label: const Text(
                      'Choose Files',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.white,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Selected files list
          if (_selectedFiles.isNotEmpty) ...[
            const SizedBox(height: 16),
            ..._selectedFiles.asMap().entries.map((entry) {
              final index = entry.key;
              final file = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.insert_drive_file,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        file.path.split(RegExp(r'[/\\]')).last,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: _isUploading ? null : () => _removeFile(index),
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              );
            }),
          ],

          const SizedBox(height: 20),

          // Additional notes (Optional)
          const Text(
            'Additional notes (Optional)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              fontFamily: "Fraunces",
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Any additional context about the lab results.....',
              hintStyle: const TextStyle(color: AppColors.gray500),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.primaryLight.withAlpha(128),
                ),
              ),
              fillColor: AppColors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.primaryLight.withAlpha(128),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            enabled: !_isUploading,
          ),

          if (_uploadError != null) ...[
            const SizedBox(height: 12),
            Text(
              _uploadError!,
              style: const TextStyle(fontSize: 12, color: AppColors.error),
            ),
          ],

          const SizedBox(height: 24),

          // Cancel + Upload Lab Results
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isUploading ? null : _handleCancel,
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
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: (_selectedFiles.isEmpty || _isUploading)
                      ? null
                      : _handleUpload,
                  icon: _isUploading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.upload, size: 20),
                  label: Text(
                    _isUploading ? 'Uploading...' : 'Upload Lab Results',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class LabUploadView extends StatefulWidget {
  final String patientName;
  final Map<String, dynamic> stepInfo;
  final int totalSteps;
  final VoidCallback onUploadComplete;
  final VoidCallback onSkip;
  final Function(String imageUrl)? onUploadSuccess;

  const LabUploadView({
    super.key,
    required this.patientName,
    required this.stepInfo,
    required this.totalSteps,
    required this.onUploadComplete,
    required this.onSkip,
    this.onUploadSuccess,
  });

  @override
  State<LabUploadView> createState() => _LabUploadViewState();
}

class _LabUploadViewState extends State<LabUploadView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: widget.onSkip,
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
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

              // Patient Info
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pets, color: AppColors.primary, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    widget.patientName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Lab Results Upload',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              LabUploadCard(
                onUploadComplete: widget.onUploadComplete,
                onUploadSuccess: widget.onUploadSuccess,
                onCancel: widget.onSkip,
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: widget.onSkip,
                  child: const Text('Skip Lab Upload'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
