import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/consultation/consultation_cubit.dart';

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
  final ImagePicker _imagePicker = ImagePicker();
  List<File> _selectedFiles = [];
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _uploadError;
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedFiles.add(File(image.path));
          _uploadError = null;
        });
      }
    } catch (e) {
      setState(() {
        _uploadError = 'Error picking image: ${e.toString()}';
      });
    }
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
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  String _formatFileSize(int bytes) {
    if (bytes == 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];

    // Calculate the appropriate unit index using logarithm
    int i = 0;
    double size = bytes.toDouble();

    // Divide by k until we get a size less than k, or reach the last unit
    while (size >= k && i < sizes.length - 1) {
      size /= k;
      i++;
    }

    return '${size.toStringAsFixed(2)} ${sizes[i]}';
  }

  Future<void> _handleUpload() async {
    if (_selectedFiles.isEmpty) return;

    if (!mounted) return;
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _uploadError = null;
    });

    try {
      // Call onUploadComplete immediately to show loading
      // This will navigate to processing view, so we don't need to update UI here
      widget.onUploadComplete();

      final cubit = context.read<ConsultationCubit>();
      final uploadedUrls = <String>[];

      // Upload files to backend
      for (int i = 0; i < _selectedFiles.length; i++) {
        final file = _selectedFiles[i];

        // Upload file to backend
        final uploadResult = await cubit.uploadFile(file.path, 'image');

        if (uploadResult != null) {
          // Extract URL from response: { message: '...', file: { url: '...' } }
          final url =
              uploadResult['file']?['url'] ?? uploadResult['url'] ?? file.path;
          uploadedUrls.add(url);
        } else {
          throw Exception('Failed to upload ${file.path.split('/').last}');
        }
      }

      // Call success callback with first uploaded URL
      // This will trigger lab analysis in the parent
      if (uploadedUrls.isNotEmpty && widget.onUploadSuccess != null) {
        widget.onUploadSuccess!(uploadedUrls.first);
      }
    } catch (e) {
      // Only update state if widget is still mounted
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
      _uploadProgress = 0.0;
      _uploadError = null;
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
            crossAxisAlignment: CrossAxisAlignment.center,
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
              Column(
                children: [
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
                  Text(
                    'Lab Results Upload',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Upload Area
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.file_upload_outlined,
                        size: 48,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Upload Lab Results',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Supported formats: PDF, DOC, DOCX',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      OutlinedButton.icon(
                        onPressed: _isUploading ? null : _pickFile,
                        icon: const Icon(Icons.file_upload_outlined, size: 20),
                        label: const Text(
                          'Choose File',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Selected Files
              if (_selectedFiles.isNotEmpty) ...[
                Text(
                  'Selected Files (${_selectedFiles.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                ..._selectedFiles.asMap().entries.map((entry) {
                  final index = entry.key;
                  final file = entry.value;
                  final fileSize = file.lengthSync();

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(
                        Icons.description,
                        color: AppColors.primary,
                        size: 32,
                      ),
                      title: Text(
                        file.path.split('/').last,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        _formatFileSize(fileSize),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: _isUploading
                            ? null
                            : () => _removeFile(index),
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 24),
              ],

              // Notes
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Additional Notes (Optional)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText:
                              'Any additional context about the lab results...',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                        onChanged: (value) {
                          // Notes stored in controller
                        },
                        enabled: !_isUploading,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Upload Progress
              if (_isUploading) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Uploading files...',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '${_uploadProgress.round()}%',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: _uploadProgress / 100,
                          backgroundColor: AppColors.gray200,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Success Message
              if (_uploadProgress == 100 && !_isUploading) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.success.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Lab results uploaded successfully!',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Error Message
              if (_uploadError != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Upload failed',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.error,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _uploadError!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Action Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: (_selectedFiles.isEmpty || _isUploading)
                      ? null
                      : _handleUpload,
                  icon: _isUploading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
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
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: _isUploading ? null : widget.onSkip,
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
