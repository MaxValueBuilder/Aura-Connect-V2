import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_colors.dart';

/// Reusable AppBar title with Aura Connect logo and text.
class AppBarLogoTitle extends StatelessWidget {
  const AppBarLogoTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          width: 32,
          height: 32,
          'assets/icons/logo.svg',
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
    );
  }
}
