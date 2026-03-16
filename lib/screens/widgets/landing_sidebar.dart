import 'package:aura/core/routes/app_routes.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/screens/widgets/custom_landing_page_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Section identifiers for landing page scroll targets.
enum LandingSection { features, pricing, reviews }

/// Sidebar drawer for the landing screen matching the design:
/// dark theme, Aura Connect logo, Features/Pricing/Reviews with separators,
/// Start Free Trial and Login buttons.
class LandingSidebar extends StatelessWidget {
  const LandingSidebar({
    super.key,
    required this.onClose,
    required this.onNavigateToSection,
    this.currentSection,
  });

  final VoidCallback onClose;
  final void Function(LandingSection section) onNavigateToSection;
  final LandingSection? currentSection;

  static const Color _sidebarBackground = Color(0xFF262A34);
  static const Color _separatorColor = Color(0xFF94B4D4);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.78,
      decoration: const BoxDecoration(color: _sidebarBackground),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Close button (top right)
            Padding(
              padding: const EdgeInsets.only(top: 8, right: 16),
              child: Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: onClose,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: const CircleBorder(),
                  ),
                  icon: const Icon(Icons.close),
                ),
              ),
            ),
            // Logo + title
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/logo.svg',
                    width: 32,
                    height: 32,
                    colorFilter: const ColorFilter.mode(
                      AppColors.white,
                      BlendMode.srcIn,
                    ),
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Aura Connect',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            // Menu items: Features, Pricing, Reviews
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SidebarItem(
                      label: 'Features',
                      isSelected: currentSection == LandingSection.features,
                      onTap: () => onNavigateToSection(LandingSection.features),
                    ),
                    const Divider(color: _separatorColor, height: 32),
                    _SidebarItem(
                      label: 'Pricing',
                      isSelected: currentSection == LandingSection.pricing,
                      onTap: () => onNavigateToSection(LandingSection.pricing),
                    ),
                    const Divider(color: _separatorColor, height: 32),
                    _SidebarItem(
                      label: 'Reviews',
                      isSelected: currentSection == LandingSection.reviews,
                      onTap: () => onNavigateToSection(LandingSection.reviews),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom CTAs
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: CustomLandingPageButton(
                      onPressed: () {
                        onClose();
                        Navigator.of(context).pushNamed(AppRoutes.signup);
                      },
                      label: 'Start Free Trial',
                      icon: Icons.arrow_forward,
                      paddingSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: CustomLandingPageButton(
                      onPressed: () {
                        onClose();
                        Navigator.of(context).pushNamed(AppRoutes.login);
                      },
                      label: 'Login',
                      paddingSize: 16,
                      color: AppColors.white,
                      textColor: AppColors.textPrimary,
                      borderColor: AppColors.border,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 6),
              Container(
                height: 2,
                width: 60,
                decoration: const BoxDecoration(
                  color: LandingSidebar._separatorColor,
                  borderRadius: BorderRadius.all(Radius.circular(1)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
