import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';

class SubscriptionRepository {
  final ApiClient client;

  SubscriptionRepository({required this.client});

  Future<ApiResponse<Map<String, dynamic>>> createPaymentOrder({
    required double amount,
    String currency = 'INR',
    String purpose = 'subscription',
    int planMonths = 1,
  }) async {
    final response = await client.post(
      ApiEndpoints.createPaymentOrder,
      data: {
        'amount': (amount * 100).toInt(),
        'currency': currency,
        'purpose': purpose,
        'plan_months': planMonths,
      },
    );

    if (response.isSuccess && response.data != null) {
      return ApiResponse.success(Map<String, dynamic>.from(response.data!));
    }
    return ApiResponse.error(response.message ?? 'Failed to create payment order');
  }

  Future<ApiResponse<Map<String, dynamic>>> upgradeSubscription({
    required String paymentId,
    required String razorpayOrderId,
    int planMonths = 1,
  }) async {
    final response = await client.post(
      ApiEndpoints.upgradeSubscription,
      data: {
        'payment_id': paymentId,
        'razorpay_order_id': razorpayOrderId,
        'plan_months': planMonths,
      },
    );

    if (response.isSuccess && response.data != null) {
      return ApiResponse.success(Map<String, dynamic>.from(response.data!));
    }

    return ApiResponse.error(response.message ?? 'Failed to upgrade subscription');
  }

  Future<ApiResponse<Map<String, dynamic>>> getSubscriptionStatus() async {
    final response = await client.get(ApiEndpoints.subscriptionStatus);
    if (response.isSuccess && response.data != null) {
      return ApiResponse.success(Map<String, dynamic>.from(response.data!));
    }
    return ApiResponse.error(response.message ?? 'Failed to fetch status');
  }
}
