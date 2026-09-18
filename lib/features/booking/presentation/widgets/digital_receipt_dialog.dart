import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../data/models/booking_model.dart';

class DigitalReceiptDialog extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback? onViewBookings;

  const DigitalReceiptDialog({
    super.key,
    required this.booking,
    this.onViewBookings,
  });

  static void show(BuildContext context, BookingModel booking, {VoidCallback? onViewBookings}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => DigitalReceiptDialog(booking: booking, onViewBookings: onViewBookings),
    );
  }

  Future<void> _callOwner(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());
    if (booking.createdAt != null) {
      try {
        final dt = DateTime.parse(booking.createdAt!);
        formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(dt);
      } catch (_) {}
    }

    final bookingRef = booking.id.startsWith('#BK-')
        ? booking.id
        : '#BK-${booking.id.replaceAll(RegExp(r'\D'), '').padLeft(5, '0').substring(0, 5)}';

    final ownerPhone = booking.payerPhone ?? '+91 98765 43210';
    final ownerName = booking.payerName ?? 'Rajesh Kumar (Verified Owner)';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success Icon
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 48),
            ),
            const SizedBox(height: 16),

            const Text(
              '🎉 Booking Confirmed!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Your token reservation is successful',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),

            // Receipt Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _buildRow('Booking ID', bookingRef, isBold: true, isMono: true),
                  const SizedBox(height: 10),
                  _buildRow('Listing', booking.listingTitle, isBold: true),
                  const SizedBox(height: 10),
                  _buildRow('Token Paid', CurrencyHelper.format(booking.amount), isPrimary: true),
                  const SizedBox(height: 10),
                  _buildRow('Date', formattedDate),
                  const SizedBox(height: 10),
                  _buildRow('Status', 'CONFIRMED ✅', isSuccess: true),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Owner Contact Information
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Owner Contact Information',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.primaryLight,
                        child: Icon(Icons.person, color: AppColors.primary, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ownerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text(ownerPhone, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _callOwner(ownerPhone),
                          icon: const Icon(Icons.phone, size: 16, color: AppColors.primary),
                          label: const Text('Call Owner'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(
                              text: 'EasyDeal Receipt: $bookingRef for ${booking.listingTitle} (₹${booking.amount.toInt()})',
                            ));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Receipt details copied!')),
                            );
                          },
                          icon: const Icon(Icons.download_rounded, size: 16),
                          label: const Text('Receipt'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // View in My Bookings CTA
            PrimaryButton(
              text: 'View in My Bookings',
              onPressed: () {
                Navigator.of(context).pop();
                onViewBookings?.call();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false, bool isMono = false, bool isPrimary = false, bool isSuccess = false}) {
    Color textColor = AppColors.textPrimary;
    if (isPrimary) textColor = AppColors.primary;
    if (isSuccess) textColor = AppColors.success;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold || isPrimary || isSuccess ? FontWeight.w800 : FontWeight.w500,
              color: textColor,
              fontFamily: isMono ? 'monospace' : null,
            ),
          ),
        ),
      ],
    );
  }
}
