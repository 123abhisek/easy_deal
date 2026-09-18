import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:easy_deal/features/auth/presentation/controllers/auth_controller.dart';
import 'package:easy_deal/features/subscription/data/subscription_repository.dart';

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return SubscriptionRepository(client: client);
});

class SubscriptionState {
  final bool isUpgrading;
  final String? errorMessage;
  final bool isSuccess;

  const SubscriptionState({
    this.isUpgrading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  SubscriptionState copyWith({
    bool? isUpgrading,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return SubscriptionState(
      isUpgrading: isUpgrading ?? this.isUpgrading,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class SubscriptionController extends StateNotifier<SubscriptionState> {
  final SubscriptionRepository _repository;
  final Ref _ref;

  SubscriptionController(this._repository, this._ref) : super(const SubscriptionState());

  Future<Map<String, dynamic>?> createOrder({double amount = 299.0, int months = 1}) async {
    state = state.copyWith(isUpgrading: true, errorMessage: null, isSuccess: false);
    final response = await _repository.createPaymentOrder(
      amount: amount,
      purpose: 'subscription',
      planMonths: months,
    );
    if (response.isSuccess && response.data != null) {
      return response.data;
    } else {
      state = state.copyWith(
        isUpgrading: false,
        errorMessage: response.message ?? 'Failed to create order',
      );
      return null;
    }
  }

  Future<bool> confirmUpgrade({
    required String paymentId,
    required String orderId,
    int months = 1,
  }) async {
    final response = await _repository.upgradeSubscription(
      paymentId: paymentId,
      razorpayOrderId: orderId,
      planMonths: months,
    );

    if (response.isSuccess) {
      final currentUser = _ref.read(authControllerProvider).user;
      if (currentUser != null) {
        _ref.read(authControllerProvider.notifier).setUser(
              currentUser.copyWith(isPremium: true, role: 'premium'),
            );
      }
      state = state.copyWith(isUpgrading: false, isSuccess: true);
      return true;
    } else {
      state = state.copyWith(
        isUpgrading: false,
        errorMessage: response.message ?? 'Failed to verify subscription',
      );
      return false;
    }
  }
}

final subscriptionControllerProvider =
    StateNotifierProvider<SubscriptionController, SubscriptionState>((ref) {
  final repository = ref.watch(subscriptionRepositoryProvider);
  return SubscriptionController(repository, ref);
});
