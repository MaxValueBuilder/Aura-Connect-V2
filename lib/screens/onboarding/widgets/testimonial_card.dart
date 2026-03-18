import 'package:flutter/material.dart';
import 'package:aura/core/constants/app_constants.dart';
import 'package:aura/core/theme/app_colors.dart';

/// Testimonial card matching the design: white card, profile image, stars, quote, name, title.
class TestimonialCard extends StatelessWidget {
  final int rating;
  final String quote;
  final String authorName;
  final String authorTitle;
  final String? imagePath;

  const TestimonialCard({
    super.key,
    required this.rating,
    required this.quote,
    required this.authorName,
    required this.authorTitle,
    this.imagePath,
  });

  factory TestimonialCard.fromItem(TestimonialItem item) {
    return TestimonialCard(
      rating: item.rating,
      quote: item.quote,
      authorName: item.authorName,
      authorTitle: item.authorTitle,
      imagePath: item.imagePath,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withAlpha(20),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Profile image: rounded rectangle, centered
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imagePath != null
                    ? Image.asset(
                        imagePath!,
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.fitWidth,
                        errorBuilder: (_, __, ___) => _buildPlaceholderAvatar(),
                      )
                    : _buildPlaceholderAvatar(),
              ),
            ),
            const SizedBox(height: 16),
            // Star rating, centered
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(
                rating,
                (_) => Icon(Icons.star, color: AppColors.warning, size: 22),
              ),
            ),
            const SizedBox(height: 16),
            // Quote: left-aligned, in quotes, body text
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '"$quote"',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Author name: bold
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                authorName,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  fontFamily: 'Serif',
                ),
              ),
            ),
            const SizedBox(height: 4),
            // Author title: regular, slightly smaller
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                authorTitle,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderAvatar() {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.gray200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.person, size: 64, color: AppColors.gray400),
    );
  }
}
