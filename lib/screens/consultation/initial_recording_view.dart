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
                          const SizedBox(height: 24),
                          // Controls (always visible): Start/Pause/Resume, Stop, Restart
                          Builder(
                            builder: (context) {
                              final idle =
                                  !isRecording && recordingDuration == 0;
                              final stopped =
                                  !isRecording && recordingDuration > 0;

                              final leftEnabled = !isTranscribing && !stopped;
                              final rightEnabled =
                                  !isTranscribing && isRecording;
                              final restartEnabled =
                                  !isTranscribing && recordingDuration > 0;

                              final leftLabel = idle
                                  ? 'Start'
                                  : (isPaused ? 'Resume' : 'Pause');
                              final leftIcon = idle
                                  ? Icons.mic
                                  : (isPaused ? Icons.play_arrow : Icons.pause);

                              return Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: leftEnabled
                                          ? (idle
                                                ? onStartRecording
                                                : (isPaused
                                                      ? onResumeRecording
                                                      : onPauseRecording))
                                          : null,
                                      icon: Icon(leftIcon, size: 20),
                                      label: Text(leftLabel),
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
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: rightEnabled
                                          ? onStopRecording
                                          : null,
                                      icon: const Icon(Icons.stop, size: 20),
                                      label: const Text('Stop'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.error,
                                        foregroundColor: AppColors.white,
                                        disabledBackgroundColor:
                                            AppColors.gray200,
                                        disabledForegroundColor:
                                            AppColors.gray500,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: restartEnabled
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
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          // Transcript editor (always visible)
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
                          TextField(
                            controller: manualTranscriptController,
                            maxLines: 6,
                            enabled: !isRecording && !isTranscribing,
                            decoration: InputDecoration(
                              hintText: isTranscribing
                                  ? 'Transcribing...'
                                  : 'Review and edit your transcript here...',
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
                                  valueListenable: manualTranscriptController!,
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
                                      enabled:
                                          hasText &&
                                          !isRecording &&
                                          !isTranscribing,
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
