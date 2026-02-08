import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/subscription_service.dart';
import 'subscription_state.dart';

class SubscriptionCubit extends Cubit<SubscriptionState> {
  final SubscriptionService _subscriptionService;

  SubscriptionCubit(this._subscriptionService) : super(const SubscriptionState());

  /// Load subscription data
  Future<void> loadSubscription() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final subscriptionData = await _subscriptionService.getSubscription();
      emit(state.copyWith(
        subscriptionData: subscriptionData,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Cancel subscription
  Future<bool> cancelSubscription() async {
    emit(state.copyWith(isCancelling: true, errorMessage: null));
    try {
      await _subscriptionService.cancelSubscription();
      // Reload subscription data
      await loadSubscription();
      emit(state.copyWith(
        isCancelling: false,
        successMessage: 'Subscription cancelled successfully',
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isCancelling: false,
        errorMessage: e.toString(),
      ));
      return false;
    }
  }

  /// Reactivate subscription
  Future<bool> reactivateSubscription() async {
    emit(state.copyWith(isReactivating: true, errorMessage: null));
    try {
      await _subscriptionService.reactivateSubscription();
      // Reload subscription data
      await loadSubscription();
      emit(state.copyWith(
        isReactivating: false,
        successMessage: 'Subscription reactivated successfully',
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isReactivating: false,
        errorMessage: e.toString(),
      ));
      return false;
    }
  }

  /// Create checkout session for upgrade (legacy - returns URL)
  Future<Map<String, dynamic>?> createCheckoutSession({
    required String tier,
    required String billingCycle,
  }) async {
    emit(state.copyWith(isProcessingCheckout: true, errorMessage: null));
    try {
      final result = await _subscriptionService.createCheckoutSession(
        tier: tier,
        billingCycle: billingCycle,
      );
      emit(state.copyWith(isProcessingCheckout: false));
      return result;
    } catch (e) {
      emit(state.copyWith(
        isProcessingCheckout: false,
        errorMessage: e.toString(),
      ));
      return null;
    }
  }

  /// Create payment intent for mobile PaymentSheet
  Future<Map<String, dynamic>?> createPaymentIntent({
    required String tier,
    required String billingCycle,
  }) async {
    emit(state.copyWith(isProcessingCheckout: true, errorMessage: null));
    try {
      final result = await _subscriptionService.createPaymentIntent(
        tier: tier,
        billingCycle: billingCycle,
      );
      emit(state.copyWith(isProcessingCheckout: false));
      return result;
    } catch (e) {
      emit(state.copyWith(
        isProcessingCheckout: false,
        errorMessage: e.toString(),
      ));
      return null;
    }
  }

  /// Clear error message
  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }

  /// Clear success message
  void clearSuccess() {
    emit(state.copyWith(successMessage: null));
  }
}

