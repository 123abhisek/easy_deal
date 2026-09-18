import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/listing_card_skeleton.dart';
import '../../../../core/widgets/locked_feature_banner.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../explore/presentation/widgets/category_chip_bar.dart';
import '../../../explore/presentation/widgets/vehicle_card.dart';
import '../../../subscription/presentation/widgets/subscription_modal.dart';
import '../controllers/vehicle_controller.dart';

class VehicleListScreen extends ConsumerWidget {
  const VehicleListScreen({super.key});

  static const List<String> _brands = [
    'All',
    'Hyundai',
    'Mahindra',
    'Tata',
    'BMW',
    'Honda',
    'Toyota',
    'Maruti Suzuki',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(vehicleListControllerProvider);
    final authState = ref.watch(authControllerProvider);
    final isPremium = authState.isPremium;
    final controller = ref.read(vehicleListControllerProvider.notifier);
    final filtered = controller.filteredVehicles;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicles & Cars'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SearchBar(
              hintText: 'Search cars by brand, model, location...',
              leading: const Icon(Icons.search_rounded, size: 20, color: AppColors.textSecondary),
              elevation: const WidgetStatePropertyAll(0),
              backgroundColor: const WidgetStatePropertyAll(AppColors.surfaceVariant),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (val) => controller.search(val),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          CategoryChipBar(
            categories: _brands,
            selectedCategory: state.selectedBrand,
            onSelected: (b) => controller.filterByBrand(b),
          ),
          const SizedBox(height: 8),

          if (!isPremium)
            LockedFeatureBanner(
              onUpgrade: () => SubscriptionModal.show(context),
            ),

          Expanded(
            child: state.isLoading
                ? ListView.builder(
                    itemCount: 4,
                    itemBuilder: (_, __) => const ListingCardSkeleton(),
                  )
                : filtered.isEmpty
                    ? EmptyStateView(
                        icon: Icons.directions_car_rounded,
                        title: 'No Vehicles Found',
                        message: 'Try searching with another brand or model name.',
                        actionLabel: 'Reset Filters',
                        onAction: () => controller.filterByBrand('All'),
                      )
                    : RefreshIndicator.adaptive(
                        onRefresh: () => controller.fetchVehicles(),
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final vehicle = filtered[index];
                            return VehicleCard(
                              vehicle: vehicle,
                              isPremiumUser: isPremium,
                              onUnlockTap: () => SubscriptionModal.show(context),
                              onTap: () => context.push('/vehicle/${vehicle.id}'),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (authState.user == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please sign in to post a vehicle listing')),
            );
            context.push('/login');
          } else {
            context.push('/add-vehicle');
          }
        },
        backgroundColor: AppColors.vehicleAccent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.directions_car_filled_rounded),
        label: const Text('Post Vehicle', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
