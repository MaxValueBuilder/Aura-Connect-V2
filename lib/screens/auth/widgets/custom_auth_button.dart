import 'package:aura/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CustomAuthButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const CustomAuthButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;
    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 10,
        shadowColor: AppColors.primary.withAlpha(50),
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        backgroundColor: isDisabled ? AppColors.gray400 : AppColors.primary,
        disabledBackgroundColor: AppColors.gray400,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading) ...[
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
              ),
            ),
            const SizedBox(width: 12),
          ],
          if (!isLoading || label.isNotEmpty)
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                fontSize: 16,
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}
