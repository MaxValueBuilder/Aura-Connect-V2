import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class LabAnalysisView extends StatefulWidget {
  final Map<String, dynamic> stepInfo;
  final int totalSteps;
  final VoidCallback onComplete;

  const LabAnalysisView({
    super.key,
    required this.stepInfo,
    required this.totalSteps,
    required this.onComplete,
  });

  @override
  State<LabAnalysisView> createState() => _LabAnalysisViewState();
}

class _LabAnalysisViewState extends State<LabAnalysisView>
    with SingleTickerProviderStateMixin {
  double _progress = 0.0;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Simulate progress up to 90%, then wait for actual completion
    _simulateProgress();
  }

  void _simulateProgress() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          if (_progress < 0.9) {
            _progress += 0.05;
            _simulateProgress();
          }
          // Don't auto-complete - wait for actual analysis to finish
          // The parent will handle completion when analysis is done
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
    if (_progress < 0.25) return 'Uploading lab results...';
    if (_progress < 0.5) return 'Analyzing lab images...';
    if (_progress < 0.75) return 'Extracting key findings...';
    return 'Generating recommendations...';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: null, // Disabled during analysis
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
              const SizedBox(height: 48),

              // AI Processing
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
                            Icons.science,
                            size: 40,
                            color: AppColors.primary.withOpacity(
                              0.5 + (_animationController.value * 0.5),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'AI Analyzing Lab Results',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Processing lab images to extract findings and generate recommendations',
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
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Analyzing lab results...',
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
                      LinearProgressIndicator(
                        value: _progress,
                        backgroundColor: AppColors.gray200,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
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
