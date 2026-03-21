import 'package:flutter/material.dart';
import 'package:aura/core/constants/app_constants.dart';
import 'package:aura/core/theme/app_colors.dart';

/// Stat card with icon, value and label for the landing stat overview section.
/// Layout: vertical stack, all items centered (icon container, value, label).
class StatOverviewCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  static const Color _cardBackground = Color(0xFFF9F8F6); // light beige
  static const Color _iconBackground = Color(0xFFF0F2FF); // light blue/lavender
  static const Color _labelColor = Color(0xFF4A5568); // dark grey

  const StatOverviewCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  /// Builds a [StatOverviewCard] from [StatOverviewItem] in [AppConstants.statOverviewCards].
  factory StatOverviewCard.fromItem(StatOverviewItem item) {
    return StatOverviewCard(
      icon: _iconFromName(item.iconName),
      value: item.value,
      label: item.label,
    );
  }

  static IconData _iconFromName(String name) {
    switch (name) {
      case 'trending_up':
        return Icons.trending_up;
      case 'description':
        return Icons.description;
      case 'psychology':
        return Icons.psychology;
      case 'gps_fixed':
        return Icons.gps_fixed;
      default:
        return Icons.extension;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: _cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          top: BorderSide(
            color: AppColors.secondaryDark.withAlpha(25),
            width: 2,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withAlpha(15),
            blurRadius: 8,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _iconBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primaryDark, size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              fontFamily: 'Serif',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: _labelColor,
            ),
          ),
        ],
      ),
    );
  }
}
