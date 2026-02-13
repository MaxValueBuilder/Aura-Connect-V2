import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/subscription_service.dart';
import 'subscription_state.dart';

class SubscriptionCubit extends Cubit<SubscriptionState> {
  final SubscriptionService _subscriptionService;

  SubscriptionCubit(this._subscriptionService) : super(const SubscriptionState());

  /// Load billing info – requires clinicId (matches web getBillingInfo)
  Future<void> loadBillingInfo(String clinicId) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final subscriptionData =
          await _subscriptionService.getBillingInfo(clinicId);
      emit(state.copyWith(
        subscriptionData: subscriptionData,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  /// Upgrade subscription – returns Stripe Checkout URL for redirect (matches web)
  /// Caller should launch the URL (e.g. via url_launcher)
  Future<Map<String, dynamic>?> upgradeSubscription({
    required String tier,
    required String billingCycle,
    required String clinicId,
  }) async {
    emit(state.copyWith(isProcessingCheckout: true, errorMessage: null));
    try {
      final result = await _subscriptionService.upgradeSubscription(
        tier: tier,
        billingCycle: billingCycle,
        clinicId: clinicId,
      );
      emit(state.copyWith(isProcessingCheckout: false));
      return result;
    } catch (e) {
      emit(state.copyWith(
        isProcessingCheckout: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
      return null;
    }
  }

  void clearError() => emit(state.copyWith(errorMessage: null));
  void clearSuccess() => emit(state.copyWith(successMessage: null));
}
