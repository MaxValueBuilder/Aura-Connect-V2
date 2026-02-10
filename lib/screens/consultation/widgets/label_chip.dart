import 'package:flutter/material.dart';

/// A small chip/tag with configurable label, text color, and background color.
/// If [backgroundColor] is null, background is derived from [textColor] using [backgroundAlpha].
class LabelChip extends StatelessWidget {
  const LabelChip({
    super.key,
    required this.label,
    required this.textColor,
    required this.backgroundColor,
    this.padding = 12,
  });

  final String label;
  final Color textColor;
  final Color backgroundColor;
  final double padding;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: padding),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
