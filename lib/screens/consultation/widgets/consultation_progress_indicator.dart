import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Reusable [LinearProgressIndicator] for consultation flows.
/// Only [value] is variable; styling is consistent across screens.
class ConsultationProgressIndicator extends StatelessWidget {
  final double value;

  const ConsultationProgressIndicator({
    super.key,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: value,
      backgroundColor: AppColors.gray200,
      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
      minHeight: 8,
      borderRadius: BorderRadius.circular(4),
    );
  }
}
