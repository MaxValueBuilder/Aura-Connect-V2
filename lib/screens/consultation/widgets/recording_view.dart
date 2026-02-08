import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/consultation_status.dart';

class RecordingView extends StatelessWidget {
  final ConsultationStatus consultationStatus;
  final String patientName;
  final int recordingDuration;
  final bool isRecording;
  final bool isPaused;
  final Map<String, dynamic> stepInfo;
  final int totalSteps;
  final TextEditingController? manualTranscriptController;
  final VoidCallback onStartRecording;
  final VoidCallback onStopRecording;
  final VoidCallback onPauseRecording;
  final VoidCallback onResumeRecording;
  final VoidCallback onManualSubmit;
  final VoidCallback onBack;

  const RecordingView({
    super.key,
    required this.consultationStatus,
    required this.patientName,
    required this.recordingDuration,
    required this.isRecording,
    required this.isPaused,
    required this.stepInfo,
    required this.totalSteps,
    this.manualTranscriptController,
    required this.onStartRecording,
    required this.onStopRecording,
    required this.onPauseRecording,
    required this.onResumeRecording,
    required this.onManualSubmit,
    required this.onBack,
  });

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isInitial = consultationStatus == ConsultationStatus.initialConsult;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: isRecording ? null : onBack,
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
              'Step ${stepInfo['step']} of $totalSteps',
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
                        stepInfo['title'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${((stepInfo['step'] as int) / totalSteps * 100).round()}%',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (stepInfo['step'] as int) / totalSteps,
                    backgroundColor: AppColors.gray200,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                    minHeight: 2,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stepInfo['description'] as String,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Patient Info
              Column(
                children: [
                  Text(
                    patientName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isInitial ? 'Initial Consultation' : 'Final Consultation',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),

              // Timer
              if (isRecording || recordingDuration > 0)
                Column(
                  children: [
                    Text(
                      _formatTime(recordingDuration),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        fontFeatures: [FontFeature.tabularFigures()],
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (isRecording) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'AI is listening and transcribing...',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),

              if (!isRecording && recordingDuration == 0) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.mic, color: AppColors.primary, size: 16),
                    const SizedBox(width: 8),
                    const Text(
                      'Click "Start Recording" to begin',
                      style: TextStyle(fontSize: 16, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your device will ask for microphone permission',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],

              const SizedBox(height: 36),

              // Recording Controls
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    if (!isRecording && recordingDuration == 0)
                      ElevatedButton.icon(
                        onPressed: onStartRecording,
                        icon: const Icon(Icons.mic, size: 24),
                        label: const Text(
                          'Start Recording',
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    if (isRecording) ...[
                      OutlinedButton.icon(
                        onPressed: isPaused
                            ? onResumeRecording
                            : onPauseRecording,
                        icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
                        label: Text(isPaused ? 'Resume' : 'Pause'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 14,
                          ),
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: onStopRecording,
                        icon: const Icon(Icons.stop),
                        label: const Text('Stop'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Manual Transcript Input
              if (!isRecording && recordingDuration == 0) ...[
                const SizedBox(height: 32),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Or enter transcript manually:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: manualTranscriptController,
                      maxLines: 6,
                      decoration: InputDecoration(
                        hintText: 'Enter your consultation transcript here...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
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
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ValueListenableBuilder<TextEditingValue>(
                        valueListenable:
                            manualTranscriptController ??
                            TextEditingController(),
                        builder: (context, value, child) {
                          final hasText = value.text.trim().isNotEmpty;
                          return ElevatedButton.icon(
                            onPressed: hasText ? onManualSubmit : null,
                            icon: const Icon(Icons.description, size: 20),
                            label: const Text('Submit Transcript'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],

              // Instructions
              if (!isRecording && recordingDuration == 0) ...[
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.gray50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recording Tips:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '• Speak clearly and include patient details naturally\n'
                        '• Mention patient name, symptoms, and owner information\n'
                        '• AI will automatically extract patient information\n'
                        '• You can pause and resume recording as needed',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
