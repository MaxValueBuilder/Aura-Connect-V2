import 'package:flutter/material.dart';
import 'package:aura/core/constants/app_constants.dart';
import 'package:aura/core/theme/app_colors.dart';

/// Dark feature card with icon, optional tag, title and description.
/// Matches the landing feature card design (dark blue-purple background).
class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final String? tag;

  /// Builds a [FeatureCard] from [FeatureCardItem] from [AppConstants.featureCards].
  factory FeatureCard.fromItem(FeatureCardItem item) {
    return FeatureCard(
      icon: _iconFromName(item.iconName),
      title: item.title,
      description: item.description,
      color: Color(item.colorValue),
      tag: item.tag,
    );
  }

  static IconData _iconFromName(String name) {
    switch (name) {
      case 'mic':
        return Icons.mic_none;
      case 'description':
        return Icons.description_outlined;
      case 'group':
        return Icons.group_outlined;
      case 'access_time':
        return Icons.access_time;
      case 'check_circle_outlined':
        return Icons.bolt_outlined;
      case 'security':
        return Icons.security;

      default:
        return Icons.extension;
    }
  }

  static const Color _cardBackground = Color(0xFF1B2335);
  static const Color _iconAndTagBackground = Color(0x1A2563EB);
  static const Color _descriptionColor = Color(0xFF94A3B8);

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.white.withAlpha(25), width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _iconAndTagBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x4D2563EB), width: 2),
                ),
                child: Icon(icon, color: Color(0xFF60A5FA), size: 24),
              ),
              const Spacer(),
              if (tag != null && tag!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _iconAndTagBackground, // 10% opacity
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0x4D2563EB),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    tag!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF60A5FA),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: _descriptionColor,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
