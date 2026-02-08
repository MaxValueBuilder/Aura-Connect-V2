import 'package:dio/dio.dart';
import '../core/error/exceptions.dart';
import '../models/subscription_model.dart';

/// Service for subscription and billing API calls
class SubscriptionService {
  final Dio _dio;

  SubscriptionService(this._dio);

  /// Get current subscription data
  Future<SubscriptionDataModel> getSubscription() async {
    try {
      final response = await _dio.get('/subscriptions');

      // Handle the response structure from backend
      // Backend returns: { subscription, trialStatus, limits, currentUsage, usagePercentage }
      final data = response.data;

      // Backend returns partial subscription object, so we need to fill in missing fields
      final subscriptionData =
          data['subscription'] as Map<String, dynamic>? ?? {};

      // Ensure all required fields have defaults
      final fullSubscriptionData = {
        'id': subscriptionData['id'] ?? '',
        'clinicId': subscriptionData['clinicId'] ?? '',
        'tier': subscriptionData['tier'] ?? 'unlimited',
        'status': subscriptionData['status'] ?? 'trial',
        'billingCycle': subscriptionData['billingCycle'] ?? 'monthly',
        'amount': subscriptionData['amount'] ?? '0.00',
        'currency': subscriptionData['currency'] ?? 'USD',
        'startDate': subscriptionData['startDate'],
        'endDate': subscriptionData['endDate'],
        'trialEndDate': subscriptionData['trialEndDate'],
        'stripeSubscriptionId': subscriptionData['stripeSubscriptionId'],
        'stripeCustomerId': subscriptionData['stripeCustomerId'],
        'features': subscriptionData['features'],
        'limits': subscriptionData['limits'],
        'isActive': subscriptionData['isActive'] ?? true,
        'createdAt': subscriptionData['createdAt'],
        'updatedAt': subscriptionData['updatedAt'],
      };

      // Transform the response to match SubscriptionDataModel structure
      final transformedData = {
        'subscription': fullSubscriptionData,
        'trialStatus':
            data['trialStatus'] ??
            {
              'hasSubscription': true,
              'isExpired': false,
              'daysRemaining': 0,
              'status': subscriptionData['status'] ?? 'trial',
              'trialEndDate': subscriptionData['trialEndDate'],
              'tier': subscriptionData['tier'] ?? 'unlimited',
            },
        'limits': data['limits'] ?? {},
        'currentUsage':
            data['currentUsage'] ??
            {'users': 0, 'patients': 0, 'consultations': 0},
        'usagePercentage': data['usagePercentage'] ?? {},
      };

      return SubscriptionDataModel.fromJson(transformedData);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Cancel subscription
  Future<void> cancelSubscription() async {
    try {
      await _dio.post('/subscriptions/cancel');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Reactivate subscription
  Future<void> reactivateSubscription() async {
    try {
      await _dio.post('/subscriptions/reactivate');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Create checkout session for subscription upgrade
  /// Returns payment intent details for mobile PaymentSheet
  Future<Map<String, dynamic>> createCheckoutSession({
    required String tier,
    required String billingCycle,
  }) async {
    try {
      final response = await _dio.post(
        '/payments/create-checkout-session',
        data: {
          'tier': tier,
          'billingCycle': billingCycle,
          'platform': 'mobile', // Indicate this is for mobile
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Create payment intent for subscription (mobile-specific)
  Future<Map<String, dynamic>> createPaymentIntent({
    required String tier,
    required String billingCycle,
  }) async {
    try {
      final response = await _dio.post(
        '/payments/create-payment-intent',
        data: {'tier': tier, 'billingCycle': billingCycle},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle Dio errors
  Exception _handleError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final message =
          error.response!.data['error'] ??
          error.response!.data['message'] ??
          'An error occurred';

      if (statusCode == 401) {
        return AuthException(message: message, statusCode: statusCode);
      }

      return ServerException(message: message, statusCode: statusCode);
    }

    return NetworkException(message: error.message ?? 'Network error occurred');
  }
}
