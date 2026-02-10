import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// A square icon button for the app bar with configurable background color.
class AppBarIconButton extends StatelessWidget {
  const AppBarIconButton({
    super.key,
    required this.backgroundColor,
    required this.icon,
    required this.onPressed,
  });

  final Color backgroundColor;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Icon(icon, color: AppColors.white, size: 22),
        ),
      ),
    );
  }
}
