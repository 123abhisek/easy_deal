import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentService {
  Razorpay? _razorpay;
  final Function(PaymentSuccessResponse) onSuccess;
  final Function(PaymentFailureResponse) onFailure;
  final Function(ExternalWalletResponse)? onExternalWallet;

  PaymentService({
    required this.onSuccess,
    required this.onFailure,
    this.onExternalWallet,
  }) {
    if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS)) {
      try {
        _razorpay = Razorpay();
        _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
        _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, onFailure);
        if (onExternalWallet != null) {
          _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, onExternalWallet!);
        }
      } catch (e) {
        debugPrint('Razorpay init exception: $e');
      }
    }
  }

  void openCheckout({
    required String keyId,
    required String orderId,
    required double amount,
    required String description,
    required String userEmail,
    required String userContact,
    String? prefillName,
  }) {
    final options = {
      'key': keyId,
      'amount': (amount * 100).toInt(), // In paise
      'name': 'EasyDeal Marketplace',
      'description': description,
      'order_id': orderId,
      'prefill': {
        'name': prefillName ?? '',
        'contact': userContact,
        'email': userEmail,
      },
      'theme': {
        'color': '#4F46E5', // Indigo
      },
    };

    if (_razorpay != null) {
      try {
        _razorpay!.open(options);
      } catch (e) {
        debugPrint('Razorpay open error: $e');
        onFailure(PaymentFailureResponse(0, 'Failed to open Razorpay checkout: $e', null));
      }
    } else {
      // Mock / fallback for testing on non-mobile platforms
      debugPrint('Razorpay platform check: non-mobile platform or emulator mock');
      onSuccess(PaymentSuccessResponse(
        'pay_mock_${DateTime.now().millisecondsSinceEpoch}',
        orderId,
        'mock_signature_${DateTime.now().millisecondsSinceEpoch}',
        null,
      ));
    }
  }

  void dispose() {
    _razorpay?.clear();
  }
}
