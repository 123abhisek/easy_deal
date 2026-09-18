import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/empty_state_view.dart';
import 'package:easy_deal/features/booking/presentation/controllers/booking_controller.dart';
import 'package:easy_deal/features/booking/data/models/booking_model.dart';

class MyBookingsScreen extends ConsumerWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingState = ref.watch(bookingListControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings & Tokens'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.read(bookingListControllerProvider.notifier).fetchMyBookings(),
          ),
        ],
      ),
      body: bookingState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookingState.bookings.isEmpty
              ? EmptyStateView(
                  icon: Icons.receipt_long_rounded,
                  title: 'No Bookings Yet',
                  message: 'When you reserve properties or vehicles with token payments, they will appear here.',
                  actionLabel: 'Explore Marketplace',
                  onAction: () {},
                )
              : RefreshIndicator.adaptive(
                  onRefresh: () => ref.read(bookingListControllerProvider.notifier).fetchMyBookings(),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    itemCount: bookingState.bookings.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final booking = bookingState.bookings[index];
                      return _BookingCard(booking: booking);
                    },
                  ),
                ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingModel booking;

  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final isProperty = booking.listingType == 'property';
    String formattedDate = 'Recently';
    if (booking.createdAt != null) {
      try {
        final dt = DateTime.parse(booking.createdAt!);
        formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(dt);
      } catch (_) {}
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Status badge & Token amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded, color: AppColors.success, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Token Confirmed',
                        style: TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  CurrencyHelper.format(booking.amount),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Middle: Thumbnail and Title
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: booking.listingImageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: booking.listingImageUrl!,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => Container(
                              color: AppColors.surfaceVariant,
                              child: Icon(isProperty ? Icons.apartment : Icons.directions_car),
                            ),
                          )
                        : Container(
                            color: AppColors.surfaceVariant,
                            child: Icon(isProperty ? Icons.apartment : Icons.directions_car),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.listingTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (booking.listingLocation != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          booking.listingLocation!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 20, color: AppColors.border),

            // Metadata: Booking ID, Date, Razorpay ID
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ref: ${booking.id}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textTertiary, fontFamily: 'monospace'),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formattedDate,
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                if (booking.razorpayPaymentId != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      booking.razorpayPaymentId!,
                      style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontFamily: 'monospace'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
