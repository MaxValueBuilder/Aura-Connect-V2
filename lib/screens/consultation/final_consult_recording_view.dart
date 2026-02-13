import 'package:aura/screens/consultation/widgets/consultation_progress_indicator.dart';
import 'package:aura/screens/consultation/widgets/label_chip.dart';
import 'package:aura/screens/dashboard/widgets/app_bar_icon_button.dart';
import 'package:aura/screens/widgets/primary_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/theme/app_colors.dart';

class FinalConsultRecordingView extends StatelessWidget {
  final String patientName;
  final int recordingDuration;
  final bool isRecording;
  final bool isPaused;
  final Map<String, dynamic> stepInfo;
  final int totalSteps;
  final TextEditingController? manualTranscriptController;

  /// Optional pre-filled text for "Final Transcript" (e.g. generated report). If null, shows placeholder.
  final String? finalTranscriptPreview;
  final VoidCallback onStartRecording;
  final VoidCallback onStopRecording;
  final VoidCallback onPauseRecording;
  final VoidCallback onResumeRecording;
  final VoidCallback onManualSubmit;
  final VoidCallback onBack;

  const FinalConsultRecordingView({
    super.key,
    required this.patientName,
    required this.recordingDuration,
    required this.isRecording,
    required this.isPaused,
    required this.stepInfo,
    required this.totalSteps,
    this.manualTranscriptController,
    this.finalTranscriptPreview,
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
    return '${minutes.toString().padLeft(2, '0')} : ${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final step = stepInfo['step'] as int;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: isRecording ? null : onBack,
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/icons/logo.svg',
              width: 32,
              height: 32,
              colorFilter: const ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
            const Text(
              'Aura Connect',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          AppBarIconButton(
            backgroundColor: AppColors.error,
            icon: Icons.logout,
            onPressed: isRecording ? () {} : onBack,
          ),
          const SizedBox(width: 16),
        ],
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

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      runAlignment: WrapAlignment.center,
                      children: [
                        SizedBox(
                          width: screenSize.width * 0.42,
                          child: PrimaryIconButton(
                            onPressed: () {},
                            icon: Icons.edit,
                            text: 'Tasks & lab ',
                            fontSize: 14,
                            verticalPadding: 12,
                            enabled: true,
                          ),
                        ),
                        SizedBox(
                          width: screenSize.width * 0.42,
                          child: PrimaryIconButton(
                            onPressed: () {},
                            icon: Icons.chat_bubble_outline,
                            text: 'Initial Recording',
                            fontSize: 14,
                            verticalPadding: 12,
                            enabled: true,
                          ),
                        ),
                        LabelChip(
                          label: 'INITIAL CONSULT',
                          textColor: AppColors.primary,
                          backgroundColor: AppColors.primaryLight.withValues(
                            alpha: 0.1,
                          ),
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
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.gray200),
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
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                  fontFamily: 'Fraunces',
                                ),
                              ),
                            ],
                          ),
                          if (recordingDuration > 0 || isRecording) ...[
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
                          const SizedBox(height: 20),
                          Builder(
                            builder: (context) {
                              final idle =
                                  !isRecording && recordingDuration == 0;
                              final stopped =
                                  !isRecording && recordingDuration > 0;
                              final leftEnabled = !stopped;
                              final rightEnabled = isRecording;
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
                                horizontal: 12,
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
                              return Row(
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
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      style: leftStyle,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: rightEnabled
                                          ? onStopRecording
                                          : null,
                                      icon: Icon(rightIcon, size: 22),
                                      label: Text(
                                        rightLabel,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      style: rightStyle,
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
                    // Final Transcript (read-only / preview)
                    const Text(
                      'Final Transcript:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gray50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primaryLight.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        finalTranscriptPreview?.isNotEmpty == true
                            ? finalTranscriptPreview!
                            : 'You have to generate report',
                        style: TextStyle(
                          fontSize: 14,
                          color: finalTranscriptPreview?.isNotEmpty == true
                              ? AppColors.textPrimary
                              : AppColors.gray500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'or enter transcript manually:',
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
                      decoration: InputDecoration(
                        hintText:
                            'Enter your consultation transcript here......',
                        hintStyle: const TextStyle(color: AppColors.gray500),
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
                    const SizedBox(height: 24),
                    // Back to Lab and Tasks | Complete Consultation
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
                                          ? onManualSubmit
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
                                        'Complete',
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
                                    'Complete Consultation',
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
