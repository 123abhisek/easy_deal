import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/payment_service.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/subscription_controller.dart';

class SubscriptionModal extends ConsumerStatefulWidget {
  const SubscriptionModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SubscriptionModal(),
    );
  }

  @override
  ConsumerState<SubscriptionModal> createState() => _SubscriptionModalState();
}

class _SubscriptionModalState extends ConsumerState<SubscriptionModal> {
  late PaymentService _paymentService;
  String? _currentOrderId;

  @override
  void initState() {
    super.initState();
    _paymentService = PaymentService(
      onSuccess: _handlePaymentSuccess,
      onFailure: _handlePaymentError,
    );
  }

  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final orderId = response.orderId ?? _currentOrderId ?? 'mock_order';
    final paymentId = response.paymentId ?? 'mock_pay_id';

    final success = await ref.read(subscriptionControllerProvider.notifier).confirmUpgrade(
          paymentId: paymentId,
          orderId: orderId,
        );

    if (mounted) {
      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Congratulations! EasyDeal Gold is now active on your account.'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification failed. Please contact support if amount was deducted.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message ?? 'Payment cancelled or failed.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _startCheckout() async {
    final user = ref.read(authControllerProvider).user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in first to upgrade to Gold')),
      );
      return;
    }

    final orderData = await ref.read(subscriptionControllerProvider.notifier).createOrder(amount: 299.0);
    if (orderData != null) {
      _currentOrderId = orderData['order_id'];
      final keyId = orderData['key_id'] ?? 'rzp_test_1234567890';

      _paymentService.openCheckout(
        keyId: keyId,
        orderId: _currentOrderId!,
        amount: 299.0,
        description: 'EasyDeal Gold - 1 Month Premium Access',
        userEmail: user.email,
        userContact: user.phone ?? '9999999999',
        prefillName: user.name,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final subState = ref.watch(subscriptionControllerProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A), // Slate 900
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Gold Star Header
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const RadialGradient(
                    colors: [Color(0xFFFDE68A), Color(0xFFF59E0B)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.goldAccent.withOpacity(0.4),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.workspace_premium_rounded, color: Color(0xFF78350F), size: 32),
              ),
            ),
            const SizedBox(height: 14),

            const Text(
              'EASYDEAL GOLD',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.goldAccent,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Unlock Full Marketplace Access',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),

            // Pricing Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E293B), Color(0xFF334155)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.goldAccent.withOpacity(0.3)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '₹299 / Month',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Billed monthly • Cancel anytime',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.check_circle_rounded, color: AppColors.goldAccent, size: 28),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Benefits checklist
            _buildBenefit('View all verified owner phone numbers & email'),
            _buildBenefit('Full HD unblurred photo galleries for all items'),
            _buildBenefit('Direct WhatsApp chat with property & car owners'),
            _buildBenefit('Instant ₹999 token direct reservation booking'),
            _buildBenefit('Post unlimited property & vehicle listings'),
            const SizedBox(height: 24),

            // Razorpay CTA
            PrimaryButton(
              text: 'Pay ₹299 with Razorpay',
              isLoading: subState.isUpgrading,
              backgroundColor: AppColors.goldAccent,
              textColor: const Color(0xFF0F172A),
              icon: const Icon(Icons.security_rounded, size: 18, color: Color(0xFF0F172A)),
              onPressed: _startCheckout,
            ),
            const SizedBox(height: 12),

            const Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_outline_rounded, size: 13, color: AppColors.textTertiary),
                  SizedBox(width: 4),
                  Text(
                    '100% Secure Checkout via Razorpay',
                    style: TextStyle(color: AppColors.textTertiary, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefit(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              color: Color(0xFF065F46), // Emerald
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 12, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFFE2E8F0),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
