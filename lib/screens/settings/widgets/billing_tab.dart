import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;
import '../../../../core/theme/app_colors.dart';
import '../../../../features/subscription/subscription_cubit.dart';
import '../../../../features/subscription/subscription_state.dart';

class BillingTab extends StatefulWidget {
  const BillingTab({super.key});

  @override
  State<BillingTab> createState() => _BillingTabState();
}

class _BillingTabState extends State<BillingTab> {
  @override
  void initState() {
    super.initState();
    // Load subscription data when tab is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubscriptionCubit>().loadSubscription();
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.success;
      case 'trial':
        return AppColors.primary;
      case 'expired':
        return AppColors.error;
      case 'cancelled':
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }

  Widget _buildStatusBadge(String status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Future<void> _handleUpgradeSubscription(
    String tier,
    String billingCycle,
  ) async {
    final cubit = context.read<SubscriptionCubit>();

    try {
      // Try to get payment intent for native PaymentSheet
      final result = await cubit.createPaymentIntent(
        tier: tier,
        billingCycle: billingCycle,
      );

      if (result != null && result['clientSecret'] != null) {
        // Use PaymentSheet for native Stripe integration
        await _presentPaymentSheet(
          clientSecret: result['clientSecret'],
          cubit: cubit,
        );
      } else if (result != null && result['paymentIntent'] != null) {
        // Alternative: payment intent is nested
        final paymentIntent = result['paymentIntent'];
        if (paymentIntent['clientSecret'] != null) {
          await _presentPaymentSheet(
            clientSecret: paymentIntent['clientSecret'],
            cubit: cubit,
          );
        }
      } else {
        // Fallback: if backend doesn't support payment intent yet, show error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                cubit.state.errorMessage ??
                    'Payment intent not available. Please update backend to support mobile payments.',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing payment: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _presentPaymentSheet({
    required String clientSecret,
    required SubscriptionCubit cubit,
  }) async {
    try {
      // Initialize PaymentSheet with SetupIntent (for subscriptions)
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          setupIntentClientSecret:
              clientSecret, // Use setupIntentClientSecret for subscriptions
          merchantDisplayName: 'Aura Connect',
          style: ThemeMode.system,
        ),
      );

      // Present PaymentSheet
      await Stripe.instance.presentPaymentSheet();

      // Payment method collected successfully - now create subscription
      // The subscription will be created via webhook or we can call an endpoint here
      // For now, reload subscription data (webhook should handle subscription creation)
      await cubit.loadSubscription();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Payment method saved! Subscription will be activated shortly.',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        // User canceled the payment
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment canceled'),
              backgroundColor: AppColors.textSecondary,
            ),
          );
        }
      } else {
        // Payment failed
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Payment failed: ${e.error.message ?? 'Unknown error'}',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleCancelSubscription() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Subscription'),
        content: const Text(
          'Are you sure you want to cancel your subscription? You\'ll continue to have access until the end of your current billing period.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep Subscription'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Cancel Subscription'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await context
          .read<SubscriptionCubit>()
          .cancelSubscription();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Subscription cancelled successfully'
                  : 'Failed to cancel subscription',
            ),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleReactivateSubscription() async {
    final success = await context
        .read<SubscriptionCubit>()
        .reactivateSubscription();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Subscription reactivated successfully'
                : 'Failed to reactivate subscription',
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SubscriptionCubit, SubscriptionState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
          context.read<SubscriptionCubit>().clearError();
        }
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: AppColors.success,
            ),
          );
          context.read<SubscriptionCubit>().clearSuccess();
        }
      },
      child: BlocBuilder<SubscriptionCubit, SubscriptionState>(
        builder: (context, state) {
          if (state.isLoading && state.subscriptionData == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.errorMessage != null && state.subscriptionData == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading subscription data',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.errorMessage ?? 'Unknown error',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<SubscriptionCubit>().loadSubscription();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state.subscriptionData == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.credit_card_outlined,
                      size: 64,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Subscription Found',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Set up your subscription to get started',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () =>
                          _handleUpgradeSubscription('unlimited', 'monthly'),
                      icon: const Icon(Icons.credit_card),
                      label: const Text('Set Up Subscription'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final subscription = state.subscriptionData!.subscription;
          final trialStatus = state.subscriptionData!.trialStatus;
          final currentUsage = state.subscriptionData!.currentUsage;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Success Message
                if (state.successMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.success.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: AppColors.success),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            state.successMessage!,
                            style: TextStyle(color: AppColors.success),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Current Subscription Status
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.credit_card,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Current Subscription',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            _buildStatusBadge(subscription.status),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${subscription.tier.toUpperCase()} Plan',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '\$${subscription.amount} per ${subscription.billingCycle}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (trialStatus.hasSubscription &&
                            trialStatus.status == 'trial')
                          Container(
                            margin: const EdgeInsets.only(top: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    trialStatus.isExpired
                                        ? 'Your trial has expired. Please upgrade to continue using premium features.'
                                        : 'Your trial expires in ${trialStatus.daysRemaining} day${trialStatus.daysRemaining == 1 ? '' : 's'}.',
                                    style: TextStyle(color: AppColors.primary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (subscription.status == 'cancelled')
                          Container(
                            margin: const EdgeInsets.only(top: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.warning.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.warning, color: AppColors.warning),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Your subscription has been cancelled. You can reactivate it at any time.',
                                    style: TextStyle(color: AppColors.warning),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Usage Statistics
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Usage Statistics',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildUsageCard(
                                'Team Members',
                                currentUsage.users.toString(),
                                AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildUsageCard(
                                'Patients',
                                currentUsage.patients.toString(),
                                AppColors.success,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildUsageCard(
                                'Consultations',
                                currentUsage.consultations.toString(),
                                AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Subscription Actions
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Subscription Actions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (subscription.status == 'active')
                          _buildActionCard(
                            title: 'Cancel Subscription',
                            description:
                                'Cancel your subscription. You\'ll continue to have access until the end of your current billing period.',
                            buttonText: 'Cancel Subscription',
                            buttonColor: AppColors.error,
                            onPressed: state.isCancelling
                                ? null
                                : _handleCancelSubscription,
                            isLoading: state.isCancelling,
                          ),
                        if (subscription.status == 'cancelled')
                          _buildActionCard(
                            title: 'Reactivate Subscription',
                            description:
                                'Reactivate your subscription to restore full access to all features.',
                            buttonText: 'Reactivate Subscription',
                            buttonColor: AppColors.primary,
                            onPressed: state.isReactivating
                                ? null
                                : _handleReactivateSubscription,
                            isLoading: state.isReactivating,
                          ),
                        if (trialStatus.isExpired ||
                            subscription.status == 'trial')
                          _buildActionCard(
                            title: 'Upgrade to Full Plan',
                            description:
                                'Upgrade to continue using premium features.',
                            buttonText: 'Upgrade Now',
                            buttonColor: AppColors.primary,
                            onPressed: state.isProcessingCheckout
                                ? null
                                : () => _handleUpgradeSubscription(
                                    'unlimited',
                                    'monthly',
                                  ),
                            isLoading: state.isProcessingCheckout,
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Billing Information
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Billing Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoItem(
                                'Billing Cycle',
                                subscription.billingCycle.toUpperCase(),
                              ),
                            ),
                            Expanded(
                              child: _buildInfoItem(
                                'Amount',
                                '\$${subscription.amount}',
                              ),
                            ),
                          ],
                        ),
                        if (subscription.trialEndDate != null)
                          _buildInfoItem(
                            'Trial End Date',
                            _formatDate(subscription.trialEndDate),
                          ),
                      ],
                    ),
                  ),
                ),

                // Upgrade Options
                if (subscription.status == 'trial' ||
                    subscription.status == 'expired')
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Card(
                      color: AppColors.primary.withAlpha(2),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.flash_on, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Text(
                                  'Upgrade to Full Plan',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Unlimited Plan',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '\$99.99',
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 8,
                                          bottom: 8,
                                        ),
                                        child: Text(
                                          'per month',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  _buildFeatureItem('Unlimited team members'),
                                  _buildFeatureItem('Unlimited patients'),
                                  _buildFeatureItem('All AI features'),
                                  _buildFeatureItem('24/7 priority support'),
                                  _buildFeatureItem(
                                    'Advanced consultation tools',
                                  ),
                                  _buildFeatureItem('Unlimited storage'),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: state.isProcessingCheckout
                                          ? null
                                          : () => _handleUpgradeSubscription(
                                              'unlimited',
                                              'monthly',
                                            ),
                                      icon: state.isProcessingCheckout
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(AppColors.white),
                                              ),
                                            )
                                          : const Icon(Icons.credit_card),
                                      label: Text(
                                        state.isProcessingCheckout
                                            ? 'Loading Checkout...'
                                            : 'Upgrade Now - \$99.99/month',
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: AppColors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                      ),
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
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUsageCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String description,
    required String buttonText,
    required Color buttonColor,
    required VoidCallback? onPressed,
    required bool isLoading,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            child: isLoading
                ? const SizedBox(
                    // width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.white,
                      ),
                    ),
                  )
                : Text(buttonText, style: TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.success, size: 20),
          const SizedBox(width: 8),
          Text(
            feature,
            style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
