import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ProcessingView extends StatefulWidget {
  final Map<String, dynamic> stepInfo;
  final int totalSteps;
  final VoidCallback onComplete;

  const ProcessingView({
    super.key,
    required this.stepInfo,
    required this.totalSteps,
    required this.onComplete,
  });

  @override
  State<ProcessingView> createState() => _ProcessingViewState();
}

class _ProcessingViewState extends State<ProcessingView>
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
          } else {
            widget.onComplete();
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
    if (_progress < 0.3) return 'Analyzing consultation recordings...';
    if (_progress < 0.6) return 'Processing patient information...';
    if (_progress < 0.9) return 'Generating SOAP notes...';
    return 'Finalizing documentation...';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: null, // Disabled during processing
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
                      const Text(
                        '100%',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const LinearProgressIndicator(
                    value: 1.0,
                    backgroundColor: AppColors.gray200,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
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
                            Icons.psychology,
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
                      'AI Creating Final Outputs',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Processing recordings and patient data to generate comprehensive documentation',
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
                            'Generating documentation...',
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
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
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

