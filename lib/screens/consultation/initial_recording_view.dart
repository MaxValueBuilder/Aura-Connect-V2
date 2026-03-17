import 'package:aura/screens/consultation/widgets/consultation_progress_indicator.dart';
import 'package:aura/screens/widgets/app_bar_logo_title.dart';
import 'package:aura/screens/widgets/logout_button.dart';
import 'package:aura/screens/widgets/primary_icon_button.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/consultation_status.dart';

class InitialRecordingView extends StatelessWidget {
  final ConsultationStatus consultationStatus;
  final String patientName;
  final int recordingDuration;
  final bool isRecording;
  final bool isPaused;
  final bool isTranscribing;
  final Map<String, dynamic> stepInfo;
  final int totalSteps;
  final TextEditingController? manualTranscriptController;
  final VoidCallback onStartRecording;
  final VoidCallback onStopRecording;
  final VoidCallback onPauseRecording;
  final VoidCallback onResumeRecording;
  final VoidCallback onRestartRecording;
  final VoidCallback onManualSubmit;
  final VoidCallback onBack;

  const InitialRecordingView({
    super.key,
    required this.consultationStatus,
    required this.patientName,
    required this.recordingDuration,
    required this.isRecording,
    required this.isPaused,
    required this.isTranscribing,
    required this.stepInfo,
    required this.totalSteps,
    this.manualTranscriptController,
    required this.onStartRecording,
    required this.onStopRecording,
    required this.onPauseRecording,
    required this.onResumeRecording,
    required this.onRestartRecording,
    required this.onManualSubmit,
    required this.onBack,
  });

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')} : ${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final step = stepInfo['step'] as int;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: isRecording ? null : onBack,
        ),
        title: AppBarLogoTitle(),
        actions: [const LogoutButton(), const SizedBox(width: 16)],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress section (full width, no outer padding)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withAlpha(25),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Initial Consultation Recording',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        fontFamily: 'Fraunces',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Step $step of $totalSteps',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ConsultationProgressIndicator(value: step / totalSteps),
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          consultationStatus.apiValue,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Padded content below progress
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),

                    // Recording card (white)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 24,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.mic,
                                color: AppColors.textPrimary,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Initial Consultation Recording',

                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                  fontFamily: 'Fraunces',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Timer
                          Center(
                            child: Text(
                              _formatTime(recordingDuration),
                              style: const TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                fontFeatures: [FontFeature.tabularFigures()],
                                color: AppColors.textPrimary,
                              ),
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
                          const SizedBox(height: 24),
                          // Start Recording / Pause-Resume / Stop
                          if (!isRecording && recordingDuration == 0)
                            PrimaryIconButton(
                              onPressed: onStartRecording,
                              icon: Icons.mic,
                              text: 'Start Recording',
                              fontSize: 16,
                              verticalPadding: 14,
                            )
                          else if (isRecording) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: isTranscribing
                                        ? null
                                        : (isPaused
                                              ? onResumeRecording
                                              : onPauseRecording),
                                    icon: Icon(
                                      isPaused ? Icons.play_arrow : Icons.pause,
                                      size: 20,
                                    ),
                                    label: Text(isPaused ? 'Resume' : 'Pause'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.textPrimary,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 14,
                                      ),
                                      side: const BorderSide(
                                        color: AppColors.border,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: isTranscribing
                                        ? null
                                        : onStopRecording,
                                    icon: const Icon(Icons.stop, size: 20),
                                    label: const Text('Stop'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.error,
                                      foregroundColor: AppColors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed:
                                        !isTranscribing && recordingDuration > 0
                                        ? onRestartRecording
                                        : null,
                                    icon: const Icon(Icons.refresh, size: 20),
                                    label: const Text('Restart'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.textPrimary,
                                      disabledForegroundColor:
                                          AppColors.gray500,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 14,
                                      ),
                                      side: const BorderSide(
                                        color: AppColors.border,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          // Transcript editor (after transcription OR manual entry)
                          if (!isRecording) ...[
                            const SizedBox(height: 24),
                            const Text(
                              'Edit transcript:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (isTranscribing) ...[
                              Row(
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Transcribing...',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                            ],
                            TextField(
                              controller: manualTranscriptController,
                              maxLines: 6,
                              enabled: !isTranscribing,
                              decoration: InputDecoration(
                                hintText:
                                    'Review and edit your transcript here...',
                                hintStyle: const TextStyle(
                                  color: AppColors.gray500,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.primaryLight.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.primaryLight.withValues(
                                      alpha: 0.5,
                                    ),
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
                            ),
                            const SizedBox(height: 12),
                            manualTranscriptController != null
                                ? ValueListenableBuilder<TextEditingValue>(
                                    valueListenable:
                                        manualTranscriptController!,
                                    builder: (context, value, child) {
                                      final hasText = value.text
                                          .trim()
                                          .isNotEmpty;
                                      return PrimaryIconButton(
                                        onPressed: onManualSubmit,
                                        icon: Icons.description,
                                        text: 'Submit Transcript',
                                        fontSize: 16,
                                        verticalPadding: 14,
                                        enabled: hasText && !isTranscribing,
                                      );
                                    },
                                  )
                                : PrimaryIconButton(
                                    onPressed: onManualSubmit,
                                    icon: Icons.description,
                                    text: 'Submit Transcript',
                                    fontSize: 16,
                                    verticalPadding: 14,
                                    enabled: false,
                                  ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
