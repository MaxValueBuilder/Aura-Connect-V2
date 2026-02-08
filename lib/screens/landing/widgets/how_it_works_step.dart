import 'package:flutter/material.dart';
import 'package:aura/core/constants/app_constants.dart';
import 'package:aura/core/theme/app_colors.dart';

/// Single "How it works" step: blue numbered circle, title, and description.
/// Layout is vertical and centered to match the design.
class HowItWorksStep extends StatelessWidget {
  final String number;
  final String title;
  final String description;

  const HowItWorksStep({
    super.key,
    required this.number,
    required this.title,
    required this.description,
  });

  /// Builds a [HowItWorksStep] from [HowItWorksStepItem] in [AppConstants.howItWorksSteps].
  factory HowItWorksStep.fromItem(HowItWorksStepItem item) {
    return HowItWorksStep(
      number: item.number,
      title: item.title,
      description: item.description,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 128,
          height: 128,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.35),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            fontFamily: 'Serif',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          description,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
