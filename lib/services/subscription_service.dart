import 'package:dio/dio.dart';
import '../core/error/exceptions.dart';
import '../models/subscription_model.dart';

/// Service for subscription and billing API calls.
/// Matches web: getBillingInfo(clinicId), upgradeSubscription(tier, billingCycle, clinicId).
class SubscriptionService {
  final Dio _dio;

  SubscriptionService(this._dio);

  /// Get billing info – GET /api/clinic/getbillinginfo/:clinicId
  /// Returns { subscription, trialStatus, limits, currentUsage, usagePercentage }
  Future<SubscriptionDataModel> getBillingInfo(String clinicId) async {
    try {
      final response = await _dio.get('/clinic/getbillinginfo/$clinicId');
      final data = response.data as Map<String, dynamic>;

      final subscriptionData =
          data['subscription'] as Map<String, dynamic>? ?? {};
      final trialStatusData = data['trialStatus'] as Map<String, dynamic>? ?? {};
      final limits = data['limits'] as Map<String, dynamic>? ?? {};
      final currentUsageRaw = data['currentUsage'] as Map<String, dynamic>? ?? {};
      final usagePercentage =
          data['usagePercentage'] as Map<String, dynamic>? ?? {};

      // Map server subscription (tier, status, billingCycle, amount, trialEndDate, expiredOn)
      // to full SubscriptionModel with defaults for missing fields
      final fullSubscriptionData = {
        'id': subscriptionData['id'] ?? '',
        'clinicId': clinicId,
        'tier': subscriptionData['tier'] ?? 'unlimited',
        'status': subscriptionData['status'] ?? 'trial',
        'billingCycle': subscriptionData['billingCycle'] ?? 'monthly',
        'amount': subscriptionData['amount']?.toString() ?? '0.00',
        'currency': 'USD',
        'trialEndDate': subscriptionData['trialEndDate'],
        'endDate': subscriptionData['expiredOn'],
        'isActive': true,
      };

      final transformedData = {
        'subscription': fullSubscriptionData,
        'trialStatus': {
          'hasSubscription': trialStatusData['hasSubscription'] ?? true,
          'isExpired': trialStatusData['isExpired'] ?? false,
          'daysRemaining': trialStatusData['daysRemaining'] ?? 0,
          'status': trialStatusData['status'] ?? 'trial',
          'trialEndDate': trialStatusData['trialEndDate'],
          'tier': trialStatusData['tier'] ?? 'unlimited',
        },
        'limits': limits,
        'currentUsage': {
          'users': currentUsageRaw['users'] ?? 0,
          'patients': currentUsageRaw['patients'] ?? 0,
          'consultations': currentUsageRaw['consultations'] ?? 0,
        },
        'usagePercentage': usagePercentage,
      };

      return SubscriptionDataModel.fromJson(transformedData);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Upgrade subscription – POST /api/clinic/upgrade-subscription
  /// Body: { tier, billingCycle, clinicId }
  /// Returns { success, sessionId, url } – open url for Stripe Checkout (matches web)
  Future<Map<String, dynamic>> upgradeSubscription({
    required String tier,
    required String billingCycle,
    required String clinicId,
  }) async {
    try {
      final response = await _dio.post(
        '/clinic/upgrade-subscription',
        data: {
          'tier': tier,
          'billingCycle': billingCycle,
          'clinicId': clinicId,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

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
