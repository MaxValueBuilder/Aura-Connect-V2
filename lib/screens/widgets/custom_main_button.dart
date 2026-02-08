import 'package:aura/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CustomMainButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;
  final Color? borderColor;
  final double paddingSize;
  final Color? textColor;
  final double? textSize;
  final bool isLoading;

  const CustomMainButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.paddingSize = 12,
    this.color,
    this.borderColor,
    this.textColor,
    this.textSize,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;
    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 10, // Increased elevation for stronger shadow
        shadowColor: color,
        padding: EdgeInsets.symmetric(
          vertical: paddingSize,
          horizontal: paddingSize,
        ),
        side: BorderSide(color: borderColor ?? Colors.transparent),
        backgroundColor: isDisabled
            ? Colors.grey
            : (color ?? Theme.of(context).colorScheme.primary),
        disabledBackgroundColor: Colors.grey,
        shape: const StadiumBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading) ...[
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
          ],
          if (!isLoading || label.isNotEmpty)
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                fontSize: textSize ?? 16,
                color: isDisabled
                    ? Colors.white70
                    : (textColor ?? Colors.white),
                fontWeight: FontWeight.bold,
              ),
            ),
          if (icon != null && !isLoading) ...[
            const SizedBox(width: 8),
            Icon(
              icon,
              color: isDisabled ? Colors.white70 : (textColor ?? Colors.white),
            ),
          ],
        ],
      ),
    );
  }
}
