import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/payment_service.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/booking_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_deal/features/booking/data/models/booking_model.dart';
import 'digital_receipt_dialog.dart';

class BookingBottomSheet extends ConsumerStatefulWidget {
  final String listingId;
  final String listingType;
  final String title;
  final double price;
  final String location;
  final String? imageUrl;

  const BookingBottomSheet({
    super.key,
    required this.listingId,
    required this.listingType,
    required this.title,
    required this.price,
    required this.location,
    this.imageUrl,
  });

  static Future<void> show(
    BuildContext context, {
    required String listingId,
    required String listingType,
    required String title,
    required double price,
    required String location,
    String? imageUrl,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BookingBottomSheet(
        listingId: listingId,
        listingType: listingType,
        title: title,
        price: price,
        location: location,
        imageUrl: imageUrl,
      ),
    );
  }

  @override
  ConsumerState<BookingBottomSheet> createState() => _BookingBottomSheetState();
}

class _BookingBottomSheetState extends ConsumerState<BookingBottomSheet> {
  late PaymentService _paymentService;
  bool _isLoading = false;
  String? _currentBookingId;
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
    setState(() => _isLoading = true);
    final paymentId = response.paymentId ?? 'mock_pay_id';
    final orderId = response.orderId ?? _currentOrderId ?? 'mock_order';
    final bookingId = _currentBookingId ?? 'book_${DateTime.now().millisecondsSinceEpoch}';

    final repo = ref.read(bookingRepositoryProvider);
    final verifyRes = await repo.verifyBooking(
      bookingId: bookingId,
      paymentId: paymentId,
      orderId: orderId,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (verifyRes.isSuccess) {
        final confirmedBooking = verifyRes.data ??
            BookingModel(
              id: bookingId,
              listingId: widget.listingId,
              listingType: widget.listingType,
              listingTitle: widget.title,
              amount: 999,
              status: 'confirmed',
              listingImageUrl: widget.imageUrl,
              listingLocation: widget.location,
              razorpayPaymentId: paymentId,
              createdAt: DateTime.now().toIso8601String(),
            );

        ref.read(bookingListControllerProvider.notifier).addConfirmedBooking(confirmedBooking);

        Navigator.of(context).pop();
        DigitalReceiptDialog.show(
          context,
          confirmedBooking,
          onViewBookings: () {
            context.push('/my-bookings');
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment verification failed. Please check with support.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message ?? 'Booking payment was cancelled.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _initiateBooking() async {
    final user = ref.read(authControllerProvider).user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in first to make a token booking')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final repo = ref.read(bookingRepositoryProvider);
    final response = await repo.initiateBooking(
      listingId: widget.listingId,
      listingType: widget.listingType,
      amount: 999.0,
    );

    if (response.isSuccess && response.data != null) {
      _currentBookingId = response.data!['booking_id']?.toString() ?? 'book_${DateTime.now().millisecondsSinceEpoch}';
      _currentOrderId = response.data!['order_id']?.toString() ?? 'order_${DateTime.now().millisecondsSinceEpoch}';
      final keyId = response.data!['key_id']?.toString() ?? 'rzp_test_12345';

      _paymentService.openCheckout(
        keyId: keyId,
        orderId: _currentOrderId!,
        amount: 999.0,
        description: 'Token Reservation for ${widget.title}',
        userEmail: user.email,
        userContact: user.phone ?? '9999999999',
        prefillName: user.name,
      );
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Failed to initiate booking'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
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
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.bolt_rounded, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Reserve with Token Fee',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Instant priority hold directly with seller',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Item card preview
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 64,
                      height: 64,
                      child: widget.imageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: widget.imageUrl!,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => Container(color: Colors.grey.shade300),
                            )
                          : Container(
                              color: AppColors.primaryLight,
                              child: const Icon(Icons.inventory_2_outlined),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyHelper.format(widget.price),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Token Breakdown
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Token Holding Deposit', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      Text('₹999', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Marketplace Convenience Fee', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      Text('₹0 (Waived)', style: TextStyle(fontSize: 13, color: AppColors.success, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const Divider(height: 18, color: AppColors.border),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Payable Now', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                      Text('₹999', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Pay Button
            PrimaryButton(
              text: 'Pay ₹999 & Confirm Booking',
              isLoading: _isLoading,
              icon: const Icon(Icons.payment_rounded, size: 18),
              onPressed: _initiateBooking,
            ),
            const SizedBox(height: 12),

            const Center(
              child: Text(
                'Refundable token subject to seller inspection & deal agreement',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
