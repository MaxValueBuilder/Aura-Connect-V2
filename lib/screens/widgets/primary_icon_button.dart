import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// A primary-styled elevated button with an icon and text, reusable across screens.
class PrimaryIconButton extends StatelessWidget {
  const PrimaryIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.text,
    this.fontSize = 16,
    this.verticalPadding = 12,
    this.enabled = true,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final String text;
  final double fontSize;
  final double verticalPadding;

  /// Whether the button is enabled. When false, the button is disabled
  /// and uses Flutter's default disabled styling.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: enabled ? onPressed : null,
        icon: Icon(icon, size: fontSize + 2),
        label: Text(text, style: TextStyle(fontSize: fontSize)),
        style: ElevatedButton.styleFrom(
          side: BorderSide(color: AppColors.primary),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          padding: EdgeInsets.symmetric(vertical: verticalPadding),
        ),
      ),
    );
  }
}
