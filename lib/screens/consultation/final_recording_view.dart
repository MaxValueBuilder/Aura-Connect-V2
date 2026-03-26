import 'package:aura/screens/consultation/widgets/consultation_progress_indicator.dart';
import 'package:aura/screens/consultation/widgets/label_chip.dart';
import 'package:aura/screens/widgets/app_bar_logo_title.dart';
import 'package:aura/screens/widgets/primary_icon_button.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class FinalRecordingView extends StatelessWidget {
  final String patientName;
  final int recordingDuration;
  final bool isRecording;
  final bool isPaused;
  final bool isTranscribing;
  final Map<String, dynamic> stepInfo;
  final int totalSteps;
  final TextEditingController? manualTranscriptController;

  /// Optional pre-filled text for "Final Transcript" (e.g. generated report). If null, shows placeholder.
  final String? finalTranscriptPreview;
  final VoidCallback onStartRecording;
  final VoidCallback onStopRecording;
  final VoidCallback onPauseRecording;
  final VoidCallback onResumeRecording;
  final VoidCallback onRestartRecording;
  final VoidCallback onManualSubmit;
  final VoidCallback onBack;

  /// Called when user taps "Tasks & lab" to navigate to TasksLabsView
  final VoidCallback? onNavigateToTasksLabs;

  /// Called when user taps "Initial Recording" to navigate to RecordingView
  final VoidCallback? onNavigateToInitialRecording;

  const FinalRecordingView({
    super.key,
    required this.patientName,
    required this.recordingDuration,
    required this.isRecording,
    required this.isPaused,
    required this.isTranscribing,
    required this.stepInfo,
    required this.totalSteps,
    this.manualTranscriptController,
    this.finalTranscriptPreview,
    required this.onStartRecording,
    required this.onStopRecording,
    required this.onPauseRecording,
    required this.onResumeRecording,
    required this.onRestartRecording,
    required this.onManualSubmit,
    required this.onBack,
    this.onNavigateToTasksLabs,
    this.onNavigateToInitialRecording,
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress section
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
                      '$patientName - Final Consult',
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
                    const SizedBox(height: 16),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          spacing: 16,
                          children: [
                            Expanded(
                              child: PrimaryIconButton(
                                onPressed: isRecording
                                    ? () {}
                                    : (onNavigateToTasksLabs ?? () {}),
                                icon: Icons.edit,
                                text: 'Tasks & lab',
                                fontSize: 14,
                                verticalPadding: 14,
                                enabled:
                                    onNavigateToTasksLabs != null &&
                                    !isRecording,
                              ),
                            ),

                            Expanded(
                              child: PrimaryIconButton(
                                onPressed: isRecording
                                    ? () {}
                                    : (onNavigateToInitialRecording ?? () {}),
                                icon: Icons.chat_bubble_outline,
                                text: 'Initial Recording',
                                fontSize: 14,
                                verticalPadding: 14,
                                enabled:
                                    onNavigateToInitialRecording != null &&
                                    !isRecording,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            LabelChip(
                              label: 'INITIAL CONSULT',
                              textColor: AppColors.primary,
                              backgroundColor: AppColors.primaryLight
                                  .withValues(alpha: 0.1),
                            ),
                            LabelChip(
                              label: 'Final Recorded',
                              textColor: const Color(0xFF5F9C75),
                              backgroundColor: const Color(0xFFDCFCE7),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Info card: Final consultation recording description
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.gray200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.mic,
                            color: AppColors.primary,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              children: [
                                const Text(
                                  'Final consultation recording',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                    fontFamily: 'Fraunces',
                                  ),
                                ),

                                const SizedBox(height: 12),
                                Text(
                                  'Record the final consultation summary, findings, and treatment plan, this will be used to generate comprehensive documentation.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.primary.withOpacity(0.85),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Controls card: Start / Stop recording
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
                              const Text(
                                'Final Consultation Recording',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                  fontFamily: 'Fraunces',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: Text(
                              _formatTime(recordingDuration),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                fontFeatures: [FontFeature.tabularFigures()],
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Builder(
                            builder: (context) {
                              final idle =
                                  !isRecording && recordingDuration == 0;
                              final stopped =
                                  !isRecording && recordingDuration > 0;
                              final leftEnabled = !stopped && !isTranscribing;
                              final rightEnabled =
                                  isRecording && !isTranscribing;
                              final leftLabel = idle
                                  ? 'Start'
                                  : (isPaused ? 'Resume' : 'Pause');
                              final leftIcon = idle
                                  ? Icons.mic
                                  : (isPaused ? Icons.play_arrow : Icons.pause);
                              final rightLabel = 'Stop';

                              final rightIcon = Icons.stop;
                              const padding = EdgeInsets.symmetric(
                                vertical: 16,
                              );
                              const shape = RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                              );
                              final disabledStyle = ElevatedButton.styleFrom(
                                backgroundColor: AppColors.gray100,
                                foregroundColor: AppColors.gray500,
                                disabledBackgroundColor: AppColors.gray100,
                                disabledForegroundColor: AppColors.gray500,
                                padding: padding,
                                minimumSize: const Size(0, 48),
                                shape: shape,
                              );
                              final leftStyle = stopped
                                  ? disabledStyle
                                  : idle
                                  ? ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: AppColors.white,
                                      padding: padding,
                                      minimumSize: const Size(0, 48),
                                      shape: shape,
                                      elevation: 1,
                                    )
                                  : ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.white,
                                      foregroundColor: AppColors.textPrimary,
                                      padding: padding,
                                      minimumSize: const Size(0, 48),
                                      shape: shape,
                                      side: const BorderSide(
                                        color: AppColors.border,
                                      ),
                                      elevation: 0,
                                    );
                              final rightStyle = rightEnabled
                                  ? ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.error,
                                      foregroundColor: AppColors.white,
                                      padding: padding,
                                      minimumSize: const Size(0, 48),
                                      shape: shape,
                                      elevation: 1,
                                    )
                                  : disabledStyle;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: leftEnabled
                                              ? (idle
                                                    ? onStartRecording
                                                    : (isPaused
                                                          ? onResumeRecording
                                                          : onPauseRecording))
                                              : null,
                                          icon: Icon(leftIcon, size: 22),
                                          label: Text(
                                            leftLabel,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          style: leftStyle,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: rightEnabled
                                              ? onStopRecording
                                              : null,
                                          icon: Icon(rightIcon, size: 22),
                                          label: Text(
                                            rightLabel,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          style: rightStyle,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: recordingDuration > 0
                                              ? (isTranscribing
                                                    ? null
                                                    : onRestartRecording)
                                              : null,
                                          icon: const Icon(
                                            Icons.refresh,
                                            size: 22,
                                          ),
                                          label: const Text(
                                            'Restart',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.white,
                                            foregroundColor:
                                                AppColors.textPrimary,
                                            disabledBackgroundColor:
                                                AppColors.gray100,
                                            disabledForegroundColor:
                                                AppColors.gray500,
                                            padding: padding,
                                            minimumSize: const Size(0, 48),
                                            shape: shape,
                                            side: const BorderSide(
                                              color: AppColors.border,
                                            ),
                                            elevation: 0,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
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
                                    maxLines: 5,
                                    enabled: !isRecording && !isTranscribing,
                                    decoration: InputDecoration(
                                      hintText: isTranscribing
                                          ? 'Transcribing...'
                                          : 'Enter your transcript here.',
                                      hintStyle: const TextStyle(
                                        color: AppColors.gray500,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: AppColors.primaryLight
                                              .withValues(alpha: 0.5),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: AppColors.primaryLight
                                              .withValues(alpha: 0.5),
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
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isRecording ? null : onBack,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 12,
                              ),
                              minimumSize: const Size(0, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Back',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: manualTranscriptController != null
                              ? ValueListenableBuilder<TextEditingValue>(
                                  valueListenable: manualTranscriptController!,
                                  builder: (context, value, child) {
                                    final hasText = value.text
                                        .trim()
                                        .isNotEmpty;
                                    return ElevatedButton(
                                      onPressed: hasText
                                          ? (isRecording || isTranscribing
                                                ? null
                                                : onManualSubmit)
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: AppColors.white,
                                        disabledBackgroundColor:
                                            AppColors.gray200,
                                        disabledForegroundColor:
                                            AppColors.gray500,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                          horizontal: 12,
                                        ),
                                        minimumSize: const Size(0, 48),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        'Submit Transcript',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : ElevatedButton(
                                  onPressed: null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.gray200,
                                    foregroundColor: AppColors.gray500,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 12,
                                    ),
                                    minimumSize: const Size(0, 48),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Submit Transcript',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                        ),
                      ],
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
