import 'package:aura/core/constants/app_constants.dart';
import 'package:aura/core/routes/app_routes.dart';
import 'package:aura/features/auth/auth_cubit.dart';
import 'package:aura/screens/widgets/app_bar_logo_title.dart';
import 'package:aura/screens/widgets/custom_landing_page_button.dart';
import 'package:aura/screens/landing/widgets/testimonial_card.dart';
import 'package:aura/screens/landing/widgets/feature_card.dart';
import 'package:aura/screens/landing/widgets/stat_overview_card.dart';
import 'package:aura/screens/landing/widgets/landing_stat_card.dart';
import 'package:aura/screens/landing/widgets/how_it_works_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_colors.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return BlocListener<AuthCubit, AuthState>(
      // Only listen when transitioning from loading to authenticated (after login/signup)
      listenWhen: (previous, current) {
        // Only navigate if we just completed a login/signup (was loading, now authenticated)
        return previous.status == AuthStatus.loading &&
            current.status == AuthStatus.authenticated;
      },
      listener: (context, state) {
        // Only navigate if we're still on the landing screen (not if we navigated away)
        // Check if current route is landing before navigating
        final currentRoute = ModalRoute.of(context)?.settings.name;
        if (currentRoute != AppRoutes.landing) {
          return; // Don't navigate if we're not on landing screen
        }

        // This will only trigger after a successful login or signup
        if (state.isAuthenticated) {
          // For signup: always go to clinic setup (new users)
          // For login: check hasClinic status
          if (state.hasClinic) {
            AppRouter.pushNamedAndRemoveUntil(context, AppRoutes.dashboard);
          } else {
            // User authenticated but no clinic setup
            AppRouter.pushNamedAndRemoveUntil(
              context,
              AppRoutes.clinicSetup,
              arguments: ClinicSetupArguments(userEmail: state.userEmail),
            );
          }
        }
      },
      child: BlocListener<AuthCubit, AuthState>(
        // Listen for errors separately
        listenWhen: (previous, current) => current.hasError,
        listener: (context, state) {
          if (state.hasError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage.replaceAll('Exception: ', '')),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            return Stack(
              children: [
                Scaffold(
                  appBar: AppBar(
                    automaticallyImplyLeading: false,
                    title: AppBarLogoTitle(),
                    actions: [
                      CustomLandingPageButton(
                        onPressed: () =>
                            AppRouter.pushNamed(context, AppRoutes.login),
                        label: 'Try Free',
                        textSize: 14,
                        icon: Icons.arrow_forward,
                        paddingSize: 10,
                      ),
                      SizedBox(width: 4),
                      IconButton(
                        icon: Icon(Icons.menu, color: AppColors.primary),
                        onPressed: () {
                          // Add your menu open logic here (e.g., open a Drawer, show a menu, etc.)
                          Scaffold.of(context).openEndDrawer();
                        },
                      ),
                      SizedBox(width: 8),
                    ],
                  ),

                  body: SafeArea(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Hero Section
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                              vertical: 48.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                    vertical: 6.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppColors.secondaryLight.withAlpha(
                                        54,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(
                                        Icons.star,
                                        color: AppColors.primary,
                                        size: 18,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'TRUSTED BY 5,000+ CLINICS',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Go Home',
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontSize: 52,
                                        fontWeight: FontWeight.bold,
                                        height: 1.2,
                                        fontFamily: 'Fraunces',
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'On Time',
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontFamily: 'Fraunces',
                                        fontSize: 52,
                                        fontWeight: FontWeight.w400,
                                        height: 1.2,
                                        color: Colors.black,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                RichText(
                                  textAlign: TextAlign.left,
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[600],
                                      height: 1.8,
                                    ),
                                    children: [
                                      const TextSpan(
                                        text:
                                            'AI-Powered vet software designed for modern practices. Let AI handle the paperwork while you focus on what matters most—',
                                      ),
                                      TextSpan(
                                        text: 'your patients',
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const TextSpan(text: '.'),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 32),
                                // BlocBuilder<AuthCubit, AuthState>(
                                //   builder: (context, state) {
                                //     return SizedBox(
                                //       width: double.infinity,
                                //       height: 56,
                                //       child: ElevatedButton(
                                //         onPressed: state.isLoading
                                //             ? null
                                //             : () => context.read<AuthCubit>().signup(),
                                //         child: state.isLoading
                                //             ? const SizedBox(
                                //                 width: 24,
                                //                 height: 24,
                                //                 child: CircularProgressIndicator(
                                //                   strokeWidth: 2,
                                //                   color: Colors.white,
                                //                 ),
                                //               )
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: screenSize.width * 0.8,
                                      child: CustomLandingPageButton(
                                        paddingSize: 16,
                                        onPressed: () => AppRouter.pushNamed(
                                          context,
                                          AppRoutes.signup,
                                        ),
                                        label: 'Start Free Trial',
                                        icon: Icons.arrow_forward,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: screenSize.width * 0.8,
                                      child: CustomLandingPageButton(
                                        paddingSize: 16,
                                        onPressed: () {},
                                        label: 'Watch Demo',
                                        icon: Icons.play_arrow_rounded,
                                        color: AppColors.background,
                                        textColor: AppColors.textPrimary,
                                        borderColor: AppColors.border,
                                        textSize: 18,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 32),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.check,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'No card necessary',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.check,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '30-day free trial',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Image Section with overlay stat cards
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24.0,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    'assets/images/landing_image.png',
                                  ),
                                ),
                              ),
                              Positioned(
                                top: -16,
                                right: 0,
                                child: LandingStatCard(
                                  value: '98%',
                                  label: 'Accuracy',
                                ),
                              ),
                              Positioned(
                                bottom: -16,
                                left: 0,
                                child: LandingStatCard(
                                  value: '2hrs',
                                  label: 'Saved Daily',
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 48),

                          // Features Grid
                          Container(
                            color: AppColors.secondary,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24.0,
                                vertical: 96.0,
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 44,
                                    ),
                                    child: RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        style: const TextStyle(
                                          fontSize: 36,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Fraunces',
                                        ),
                                        children: const [
                                          TextSpan(
                                            text: 'Everything\nYou Need to\n',
                                            style: TextStyle(
                                              color: AppColors.white,
                                            ),
                                          ),
                                          TextSpan(
                                            text: 'Streamline\nYour Practice',
                                            style: TextStyle(
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Our Al co-pilot handles the paperwork while you focus on what matters most - your patients.',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: AppColors.textSecondary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 32),
                                  ...[
                                    for (final item
                                        in AppConstants.featureCards) ...[
                                      FeatureCard.fromItem(item),
                                      const SizedBox(height: 16),
                                    ],
                                  ]..removeLast(),
                                ],
                              ),
                            ),
                          ),

                          // Stat overview cards
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                              vertical: 96.0,
                            ),
                            child: Column(
                              children: [
                                for (final item
                                    in AppConstants.statOverviewCards) ...[
                                  StatOverviewCard.fromItem(item),
                                  const SizedBox(height: 24),
                                ],
                              ]..removeLast(),
                            ),
                          ),

                          // How it works Section
                          Container(
                            width: double.infinity,
                            color: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                              vertical: 96.0,
                            ),
                            child: Column(
                              children: [
                                Text.rich(
                                  TextSpan(
                                    text: "How It ",
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Fraunces',
                                      color: AppColors.textPrimary,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: "Works",
                                        style: const TextStyle(
                                          fontSize: 36,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Fraunces',
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  AppConstants.howItWorksSectionSubtitle,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 40),
                                ...AppConstants.howItWorksSteps
                                    .expand<Widget>(
                                      (item) => [
                                        HowItWorksStep.fromItem(item),
                                        const SizedBox(height: 32),
                                      ],
                                    )
                                    .toList()
                                  ..removeLast(),
                              ],
                            ),
                          ),

                          // Testimonials Section
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                              vertical: 96,
                            ),
                            child: Column(
                              children: [
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors
                                          .black, // Default color, will be overridden in children
                                    ),
                                    children: [
                                      const TextSpan(
                                        text: 'Loved by ',
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontFamily: 'Fraunces',
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'Veterinary',
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Fraunces',
                                        ),
                                      ),
                                      const TextSpan(
                                        text: ' Professionals',
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontFamily: 'Fraunces',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'See what our customers have to say about how Aura Connect has transformed their practice.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 40),
                                ...AppConstants.testimonials
                                    .expand<Widget>(
                                      (item) => [
                                        TestimonialCard.fromItem(item),
                                        const SizedBox(height: 24),
                                      ],
                                    )
                                    .toList()
                                  ..removeLast(),
                              ],
                            ),
                          ),

                          // Pricing Section
                          Container(
                            width: double.infinity,
                            color: AppColors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                              vertical: 96.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontFamily: 'Fraunces',
                                    ),
                                    children: [
                                      const TextSpan(text: 'Simple, '),
                                      TextSpan(
                                        text: 'Transparent',
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const TextSpan(text: ' pricing'),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'One plan that grows with your practice.',
                                  style: TextStyle(fontSize: 18),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: const BorderSide(
                                      color: AppColors.primary,
                                      width: 2,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Column(
                                      children: [
                                        const Text(
                                          'Professional Plan',
                                          style: TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Fraunces',
                                          ),
                                        ),
                                        const SizedBox(height: 16),

                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Text(
                                              '\$',
                                              style: TextStyle(
                                                fontSize: 60,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Fraunces',
                                                color: AppColors.primary,
                                              ),
                                            ),
                                            const Text(
                                              '99',
                                              style: TextStyle(
                                                fontSize: 48,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Fraunces',
                                                color: AppColors.primary,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 8.0,
                                              ),
                                              child: Text(
                                                '/month',
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          'Perfect for veterinary practices of all sizes',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(height: 24),
                                        ...AppConstants.pricingPlanFeatures.map(
                                          (feature) => Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 8.0,
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.check,
                                                  color: AppColors.primary,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  feature,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 16),
                                        SizedBox(
                                          width: double.infinity,
                                          child: CustomLandingPageButton(
                                            paddingSize: 16,
                                            onPressed: () =>
                                                AppRouter.pushNamed(
                                                  context,
                                                  AppRoutes.signup,
                                                ),
                                            label: 'Start Free Trial',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Footer CTA
                          Container(
                            width: double.infinity,
                            color: AppColors.secondary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                              vertical: 96.0,
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'Ready to Go Home On Time?',
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'Fraunces',
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Join thousands of veterinarians who are already saving hours every day with Aura Connect.',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: AppColors.gray400,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: screenSize.width * 0.8,
                                  child: CustomLandingPageButton(
                                    paddingSize: 16,
                                    textSize: 18,
                                    onPressed: () => AppRouter.pushNamed(
                                      context,
                                      AppRoutes.signup,
                                    ),
                                    label: 'Start Your Free Trial',
                                    icon: Icons.arrow_forward,
                                    color: AppColors.white,
                                    textColor: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Footer
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/logo.svg',
                                      width: 32,
                                      height: 32,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Aura Connect',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '© 202 Aura Connect. All rights reserved.',
                                  style: TextStyle(
                                    color: AppColors.gray500,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Loading overlay
                if (state.isLoading)
                  AbsorbPointer(
                    child: Container(
                      color: Colors.black.withAlpha(128),
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
