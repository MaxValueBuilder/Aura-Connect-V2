import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'widgets/consultation_progress_indicator.dart';

class PatientExtractionProgressView extends StatefulWidget {
  final Map<String, dynamic> stepInfo;
  final int totalSteps;

  const PatientExtractionProgressView({
    super.key,
    required this.stepInfo,
    required this.totalSteps,
  });

  @override
  State<PatientExtractionProgressView> createState() =>
      _PatientExtractionProgressViewState();
}

class _PatientExtractionProgressViewState
    extends State<PatientExtractionProgressView>
    with SingleTickerProviderStateMixin {
  double _progress = 0.0;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Simulate progress
    _simulateProgress();
  }

  void _simulateProgress() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _progress += 0.01;
          if (_progress < 1.0) {
            _simulateProgress();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _getProgressMessage() {
    if (_progress < 0.25) return 'Identifying patient information...';
    if (_progress < 0.5) return 'Extracting owner details...';
    if (_progress < 0.75) return 'Analyzing symptoms...';
    return 'Finalizing patient record...';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: null, // Disabled during extraction
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
              // AI Processing
              SizedBox(height: 48),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.infoLight,
                        shape: BoxShape.circle,
                      ),
                      child: AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Icon(
                            Icons.psychology,
                            size: 40,
                            color: AppColors.primary.withAlpha(50),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'AI Extracting Patient Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontFamily: "Fraunces",
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Analyzing conversation to automatically create patient record',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Progress Card
              Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Extracting patient details...',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${(_progress * 100).round()}%',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ConsultationProgressIndicator(value: _progress),
                      const SizedBox(height: 12),
                      Text(
                        _getProgressMessage(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
