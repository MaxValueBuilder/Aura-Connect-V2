import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/consultation/consultation_cubit.dart';
import 'consultation_progress_indicator.dart';
import '../../../../features/consultation/consultation_state.dart';

/// Reusable card for uploading lab results. Can be embedded in TasksLabsView
/// or used inside LabUploadView. Matches Figma: white card, blue border,
/// document icon + title, dashed dropzone, Choose Files, notes, Cancel + Upload.
class LabUploadCard extends StatefulWidget {
  final VoidCallback onUploadComplete;
  final Function(String imageUrl)? onUploadSuccess;

  const LabUploadCard({
    super.key,
    required this.onUploadComplete,
    this.onUploadSuccess,
  });

  @override
  State<LabUploadCard> createState() => _LabUploadCardState();
}

class _LabUploadCardState extends State<LabUploadCard> {
  List<File> _selectedFiles = [];
  bool _isUploading = false;
  String? _uploadError;
  final TextEditingController _notesController = TextEditingController();
  bool _uploadCompleted = false;
  DateTime? _analysisCompletedTime;
  String _clinicalSummary = '';
  String _confidence = '95%';
  double _analyzingProgress = 0.0;
  Timer? _analyzingTimer;
  bool _hadDocxUploaded = false;
  bool _uploadSuccessCalled = false;

  @override
  void dispose() {
    _analyzingTimer?.cancel();
    _notesController.dispose();
    super.dispose();
  }

  void _startAnalyzingProgress() {
    _analyzingTimer?.cancel();
    _analyzingProgress = 0.0;
    _analyzingTimer = Timer.periodic(const Duration(milliseconds: 400), (_) {
      if (!mounted) return;
      setState(() {
        if (_analyzingProgress < 0.95) {
          _analyzingProgress += 0.03;
          if (_analyzingProgress > 0.95) _analyzingProgress = 0.95;
        }
      });
    });
  }

  void _stopAnalyzingProgress() {
    _analyzingTimer?.cancel();
    _analyzingTimer = null;
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
    _startAnalyzingProgress();

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

      final hadDocx = _selectedFiles.any((f) {
        final name = f.path.split(RegExp(r'[/\\]')).last.toLowerCase();
        return name.endsWith('.docx') || name.endsWith('.doc');
      });
      if (mounted) {
        setState(() {
          _isUploading = false;
          _hadDocxUploaded = hadDocx;
        });
      }
      if (uploadedUrls.isNotEmpty && widget.onUploadSuccess != null) {
        _uploadSuccessCalled = true;
        widget.onUploadSuccess!(uploadedUrls.first);
      }
    } catch (e) {
      if (mounted) {
        _stopAnalyzingProgress();
        setState(() {
          _isUploading = false;
          _uploadError = 'Upload failed: ${e.toString()}';
        });
      }
    }
  }

  void _handleCancel() {
    _stopAnalyzingProgress();
    setState(() {
      _selectedFiles.clear();
      _notesController.clear();
      _uploadError = null;
      _uploadCompleted = false;
      _analyzingProgress = 0.0;
      _hadDocxUploaded = false;
      _uploadSuccessCalled = false;
    });
  }

  Widget _buildAIAnalyzingCard() {
    final progressPercent = (_analyzingProgress * 100).round().clamp(0, 95);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title: brain icon + "AI Analyzing Lab Results"
          Row(
            children: [
              Icon(Icons.psychology, color: AppColors.primary, size: 24),
              const SizedBox(width: 10),
              const Text(
                'AI Analyzing Lab Results',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          // Central brain icon in light blue rounded square
          Center(
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.infoLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.psychology,
                size: 48,
                color: AppColors.primary.withOpacity(0.8),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Main status
          const Center(
            child: Text(
              'Processing Lab Results',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Subtitle
          Center(
            child: Text(
              'Analysing blood chemistry, CBC, and urinalysis...',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary.withOpacity(0.9),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Progress bar
          ConsultationProgressIndicator(value: _analyzingProgress),
          const SizedBox(height: 10),
          Center(
            child: Text(
              '$progressPercent% Complete',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Estimated time (blue text)
          Center(
            child: Text(
              'This usually takes 10-15 seconds',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.primary.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabAnalysisCompleteCard() {
    final completedStr = _analysisCompletedTime != null
        ? _formatTime(_analysisCompletedTime!)
        : '--';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row: checkmark + "Lab Analysis Complete" + "AI Generated" pill
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Lab Analysis Complete',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFC8E6C9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'AI Generated',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF388E3C),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Clinical Summary
          const Text(
            'Clinical Summary',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _clinicalSummary.isEmpty
                  ? 'Lab results uploaded successfully. AI analysis is available for image files (JPG, PNG, GIF, WebP, BMP) and PDF documents.'
                  : _clinicalSummary,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Key Findings + Recommendations row
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.error,
                size: 20,
              ),
              const SizedBox(width: 6),
              const Text(
                'Key Findings',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 24),
              const Icon(
                Icons.check_circle_outline,
                color: Color(0xFF4CAF50),
                size: 20,
              ),
              const SizedBox(width: 6),
              const Text(
                'Recommendations',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Footer: Analysis Completed time | Confidence
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Analysis Completed: $completedStr',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary.withOpacity(0.9),
                ),
              ),
              Text(
                'Confidence: $_confidence',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    final am = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:$m:$s $am';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ConsultationCubit, ConsultationState>(
      listenWhen: (prev, curr) =>
          prev.isProcessingAI && !curr.isProcessingAI && _uploadSuccessCalled,
      listener: (context, state) {
        _stopAnalyzingProgress();
        setState(() {
          _uploadCompleted = true;
          _analysisCompletedTime = DateTime.now();
          _clinicalSummary = _hadDocxUploaded
              ? 'Docx file uploaded successfully. AI analysis is only available for image files(JPG, PNG, GIF, WebP, BMP) and PDF documents.'
              : 'Lab results uploaded successfully. AI analysis has been run on the uploaded documents.';
        });
      },
      builder: (context, state) {
        final showAIAnalyzing = state.isProcessingAI || _isUploading;
        if (_uploadCompleted) {
          return _buildLabAnalysisCompleteCard();
        }
        if (showAIAnalyzing) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _analyzingTimer == null && !_uploadCompleted) {
              _startAnalyzingProgress();
            }
          });
          return _buildAIAnalyzingCard();
        }
        return _buildUploadForm();
      },
    );
  }

  Widget _buildUploadForm() {
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
                  label: Text('Upload Lab Results'),
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
                  ConsultationProgressIndicator(
                    value: (widget.stepInfo['step'] as int) /
                        widget.totalSteps,
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
