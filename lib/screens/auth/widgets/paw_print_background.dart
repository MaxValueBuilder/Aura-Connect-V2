import 'package:aura/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PawPrintBackground extends StatelessWidget {
  const PawPrintBackground({super.key});

  static Widget _footprint({
    required double size,
    double angle = 0,
    double opacity = 0.06,
  }) {
    return Transform.rotate(
      angle: angle,
      child: Opacity(
        opacity: opacity,
        child: SvgPicture.asset(
          'assets/icons/footprint.svg',
          width: size,
          height: size,
          colorFilter: const ColorFilter.mode(AppColors.white, BlendMode.srcIn),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top-left area
        Positioned(
          top: 80,
          left: 20,
          child: _footprint(size: 24, opacity: 0.08),
        ),
        Positioned(
          top: 140,
          left: 48,
          child: _footprint(size: 18, angle: 0.4, opacity: 0.05),
        ),
        Positioned(
          top: 200,
          left: 12,
          child: _footprint(size: 22, angle: -0.3),
        ),
        // Top-right area
        Positioned(top: 85, right: 30, child: _footprint(size: 20, angle: 0.7)),
        Positioned(
          top: 120,
          right: 16,
          child: _footprint(size: 16, angle: -0.5, opacity: 0.07),
        ),
        Positioned(
          top: 180,
          right: 56,
          child: _footprint(size: 26, angle: 0.2),
        ),
        // Middle-left
        Positioned(
          top: 300,
          left: 8,
          child: _footprint(size: 20, angle: -0.6, opacity: 0.05),
        ),
        Positioned(
          top: 382,
          left: 36,
          child: _footprint(size: 28, angle: 0.35),
        ),
        // Middle-right
        Positioned(
          top: 350,
          right: 12,
          child: _footprint(size: 18, angle: 0.9),
        ),
        Positioned(
          top: 420,
          right: 44,
          child: _footprint(size: 24, angle: -0.4, opacity: 0.07),
        ),
        // Bottom area
        Positioned(
          bottom: 17,
          left: 40,
          child: _footprint(size: 26, angle: -0.7),
        ),
        Positioned(
          bottom: 180,
          right: 24,
          child: _footprint(size: 28, opacity: 0.08),
        ),
        Positioned(
          bottom: 240,
          left: 16,
          child: _footprint(size: 22, angle: 0.5, opacity: 0.05),
        ),
        Positioned(
          bottom: 320,
          right: 40,
          child: _footprint(size: 20, angle: -0.25),
        ),
        Positioned(
          bottom: 100,
          left: 60,
          child: _footprint(size: 18, angle: 0.6, opacity: 0.06),
        ),
        Positioned(
          bottom: 140,
          right: 8,
          child: _footprint(size: 16, angle: -0.8),
        ),
      ],
    );
  }
}
