import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../controllers/seller_controller.dart';

class SellerDashboardScreen extends ConsumerWidget {
  const SellerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sellerDashboardControllerProvider);
    final stats = state.stats;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Operations Hub'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.read(sellerDashboardControllerProvider.notifier).fetchStats(),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator.adaptive(
              onRefresh: () => ref.read(sellerDashboardControllerProvider.notifier).fetchStats(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Banner
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.verified_user_rounded, color: Colors.white, size: 36),
                          SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Verified Seller Account',
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Your listings are featured with verified badges and instant buyer tokens.',
                                  style: TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Performance Metrics',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 14),

                    // Metrics Grid (2x2)
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            'Active Listings',
                            '${stats['total_listings'] ?? stats['active_listings'] ?? 6}',
                            Icons.inventory_2_outlined,
                            AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetricCard(
                            'Total Bookings',
                            '${stats['total_bookings'] ?? stats['total_inquiries'] ?? 4}',
                            Icons.chat_bubble_outline_rounded,
                            AppColors.propertyAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            'Confirmed Deals',
                            '${stats['confirmed_bookings'] ?? stats['confirmed_tokens'] ?? 3}',
                            Icons.bolt_rounded,
                            Colors.deepOrange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetricCard(
                            'Token Revenue',
                            CurrencyHelper.format(stats['total_earnings'] ?? 2997.0),
                            Icons.currency_rupee_rounded,
                            AppColors.goldDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    const Text(
                      'Quick Actions',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 14),

                    _buildActionTile(
                      context,
                      title: 'Post New Property Listing',
                      subtitle: 'Apartments, villas, plots, and agricultural land',
                      icon: Icons.add_home_rounded,
                      color: AppColors.propertyAccent,
                      onTap: () => context.push('/add-property'),
                    ),
                    const SizedBox(height: 10),
                    _buildActionTile(
                      context,
                      title: 'Post New Vehicle Listing',
                      subtitle: 'Cars, SUVs, electric vehicles, and bikes',
                      icon: Icons.directions_car_filled_rounded,
                      color: AppColors.vehicleAccent,
                      onTap: () => context.push('/add-vehicle'),
                    ),
                    const SizedBox(height: 10),
                    _buildActionTile(
                      context,
                      title: 'View Received Customer Bookings',
                      subtitle: 'Manage token reserves and buyer contacts',
                      icon: Icons.receipt_long_rounded,
                      color: AppColors.primary,
                      onTap: () => context.push('/my-bookings'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              Icon(icon, size: 20, color: color),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textTertiary),
      ),
    );
  }
}
