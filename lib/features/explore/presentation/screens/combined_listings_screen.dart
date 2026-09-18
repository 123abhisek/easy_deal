import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/listing_card_skeleton.dart';
import '../../../../core/widgets/locked_feature_banner.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../property/presentation/controllers/property_controller.dart';
import '../../../subscription/presentation/widgets/subscription_modal.dart';
import '../../../vehicle/presentation/controllers/vehicle_controller.dart';
import '../widgets/category_chip_bar.dart';
import '../widgets/property_card.dart';
import '../widgets/vehicle_card.dart';

class CombinedListingsScreen extends ConsumerStatefulWidget {
  final int initialTabIndex;
  const CombinedListingsScreen({super.key, this.initialTabIndex = 0});

  @override
  ConsumerState<CombinedListingsScreen> createState() => _CombinedListingsScreenState();
}

class _CombinedListingsScreenState extends ConsumerState<CombinedListingsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const List<String> _propertyTypes = [
    'All',
    'Flat',
    'House',
    'Plot',
    'Commercial',
    'Agricultural Land',
  ];

  static const List<String> _vehicleBrands = [
    'All',
    'Hyundai',
    'Mahindra',
    'Tata',
    'BMW',
    'Honda',
    'Toyota',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTabIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isPremium = authState.isPremium;

    final propertyState = ref.watch(propertyListControllerProvider);
    final propertyController = ref.read(propertyListControllerProvider.notifier);
    final filteredProps = propertyController.filteredProperties;

    final vehicleState = ref.watch(vehicleListControllerProvider);
    final vehicleController = ref.read(vehicleListControllerProvider.notifier);
    final filteredVehs = vehicleController.filteredVehicles;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace Listings'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: [
            Tab(
              icon: const Icon(Icons.home_work_outlined, size: 20),
              text: 'Properties (${filteredProps.length})',
            ),
            Tab(
              icon: const Icon(Icons.directions_car_outlined, size: 20),
              text: 'Vehicles (${filteredVehs.length})',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Properties Tab
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: SearchBar(
                  hintText: 'Search properties by location, name...',
                  leading: const Icon(Icons.search_rounded, size: 20, color: AppColors.textSecondary),
                  elevation: const WidgetStatePropertyAll(0),
                  backgroundColor: const WidgetStatePropertyAll(AppColors.surfaceVariant),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (val) => propertyController.search(val),
                ),
              ),
              CategoryChipBar(
                categories: _propertyTypes,
                selectedCategory: propertyState.selectedType,
                onSelected: (cat) => propertyController.filterByType(cat),
              ),
              const SizedBox(height: 6),
              if (!isPremium)
                LockedFeatureBanner(onUpgrade: () => SubscriptionModal.show(context)),
              Expanded(
                child: propertyState.isLoading
                    ? ListView.builder(itemCount: 4, itemBuilder: (_, __) => const ListingCardSkeleton())
                    : filteredProps.isEmpty
                        ? EmptyStateView(
                            icon: Icons.apartment_rounded,
                            title: 'No Properties Found',
                            message: 'Try changing your search keywords or category filters.',
                            actionLabel: 'Reset Filters',
                            onAction: () => propertyController.filterByType('All'),
                          )
                        : RefreshIndicator.adaptive(
                            onRefresh: () => propertyController.fetchProperties(),
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              itemCount: filteredProps.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final property = filteredProps[index];
                                return PropertyCard(
                                  property: property,
                                  isPremiumUser: isPremium,
                                  onUnlockTap: () => SubscriptionModal.show(context),
                                  onTap: () => context.push('/property/${property.id}'),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),

          // Vehicles Tab
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: SearchBar(
                  hintText: 'Search cars by brand, model, location...',
                  leading: const Icon(Icons.search_rounded, size: 20, color: AppColors.textSecondary),
                  elevation: const WidgetStatePropertyAll(0),
                  backgroundColor: const WidgetStatePropertyAll(AppColors.surfaceVariant),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (val) => vehicleController.search(val),
                ),
              ),
              CategoryChipBar(
                categories: _vehicleBrands,
                selectedCategory: vehicleState.selectedBrand,
                onSelected: (b) => vehicleController.filterByBrand(b),
              ),
              const SizedBox(height: 6),
              if (!isPremium)
                LockedFeatureBanner(onUpgrade: () => SubscriptionModal.show(context)),
              Expanded(
                child: vehicleState.isLoading
                    ? ListView.builder(itemCount: 4, itemBuilder: (_, __) => const ListingCardSkeleton())
                    : filteredVehs.isEmpty
                        ? EmptyStateView(
                            icon: Icons.directions_car_rounded,
                            title: 'No Vehicles Found',
                            message: 'Try searching with another brand or model name.',
                            actionLabel: 'Reset Filters',
                            onAction: () => vehicleController.filterByBrand('All'),
                          )
                        : RefreshIndicator.adaptive(
                            onRefresh: () => vehicleController.fetchVehicles(),
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              itemCount: filteredVehs.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final vehicle = filteredVehs[index];
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
        ],
      ),
    );
  }
}
