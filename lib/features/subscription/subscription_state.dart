import 'package:equatable/equatable.dart';
import '../../../models/subscription_model.dart';

class SubscriptionState extends Equatable {
  final SubscriptionDataModel? subscriptionData;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final bool isCancelling;
  final bool isReactivating;
  final bool isProcessingCheckout;

  const SubscriptionState({
    this.subscriptionData,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.isCancelling = false,
    this.isReactivating = false,
    this.isProcessingCheckout = false,
  });

  SubscriptionState copyWith({
    SubscriptionDataModel? subscriptionData,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    bool? isCancelling,
    bool? isReactivating,
    bool? isProcessingCheckout,
  }) {
    return SubscriptionState(
      subscriptionData: subscriptionData ?? this.subscriptionData,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      isCancelling: isCancelling ?? this.isCancelling,
      isReactivating: isReactivating ?? this.isReactivating,
      isProcessingCheckout: isProcessingCheckout ?? this.isProcessingCheckout,
    );
  }

  @override
  List<Object?> get props => [
        subscriptionData,
        isLoading,
        errorMessage,
        successMessage,
        isCancelling,
        isReactivating,
        isProcessingCheckout,
      ];
}

