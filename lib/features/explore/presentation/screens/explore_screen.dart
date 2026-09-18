import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../property/presentation/controllers/property_controller.dart';
import '../../../subscription/presentation/widgets/subscription_modal.dart';
import '../../../vehicle/presentation/controllers/vehicle_controller.dart';
import '../widgets/category_chip_bar.dart';
import '../widgets/promo_subscription_banner.dart';
import '../widgets/property_card.dart';
import '../widgets/vehicle_card.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  String _selectedFeed = 'All';
  String _selectedCity = 'Bangalore, KA';
  final List<String> _cities = [
    'Bangalore, KA',
    'Mumbai, MH',
    'Delhi NCR',
    'Hyderabad, TS',
    'Chennai, TN',
    'Pune, MH',
  ];

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isPremium = authState.isPremium;
    final propertyState = ref.watch(propertyListControllerProvider);
    final vehicleState = ref.watch(vehicleListControllerProvider);

    final featuredProperties = propertyState.properties.where((p) => p.isFeatured).toList();
    final featuredVehicles = vehicleState.vehicles.where((v) => v.isFeatured).toList();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            const Icon(Icons.location_on, color: AppColors.primary, size: 20),
            const SizedBox(width: 4),
            DropdownButton<String>(
              value: _selectedCity,
              underline: const SizedBox.shrink(),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.textPrimary),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              items: _cities.map((city) {
                return DropdownMenuItem(value: city, child: Text(city));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCity = val);
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                if (authState.user == null) {
                  context.push('/login');
                } else {
                  context.go('/profile');
                }
              },
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryLight,
                child: authState.user != null
                    ? Text(
                        authState.user!.name.isNotEmpty ? authState.user!.name[0].toUpperCase() : 'U',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                      )
                    : const Icon(Icons.person_outline_rounded, size: 18, color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: () async {
          await ref.read(propertyListControllerProvider.notifier).fetchProperties();
          await ref.read(vehicleListControllerProvider.notifier).fetchVehicles();
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // Category Pills
              CategoryChipBar(
                categories: const ['✨ All', '🏠 Properties', '🚗 Vehicles'],
                selectedCategory: _selectedFeed,
                onSelected: (cat) => setState(() => _selectedFeed = cat),
              ),
              const SizedBox(height: 8),

              // Gold Banner
              if (!isPremium)
                PromoSubscriptionBanner(
                  onTap: () => SubscriptionModal.show(context),
                ),

              // Featured Horizontal Carousel
              if (featuredProperties.isNotEmpty || featuredVehicles.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.local_fire_department_rounded, color: Colors.deepOrange, size: 20),
                          SizedBox(width: 4),
                          Text(
                            'Featured Marketplace Deals',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () => context.go('/properties'),
                        child: const Text('View All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 200,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      ...featuredProperties.map((p) => _FeaturedMiniCard(
                            title: p.title,
                            subtitle: p.location,
                            price: p.price,
                            imageUrl: p.images.isNotEmpty ? p.images.first : null,
                            accentColor: AppColors.propertyAccent,
                            categoryTag: 'Property',
                            onTap: () => context.push('/property/${p.id}'),
                          )),
                      ...featuredVehicles.map((v) => _FeaturedMiniCard(
                            title: v.title,
                            subtitle: v.location,
                            price: v.expectedPrice,
                            imageUrl: v.images.isNotEmpty ? v.images.first : null,
                            accentColor: AppColors.vehicleAccent,
                            categoryTag: 'Vehicle',
                            onTap: () => context.push('/vehicle/${v.id}'),
                          )),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Dynamic Feed according to selected tab
              if (_selectedFeed == '✨ All' || _selectedFeed == '🏠 Properties') ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.home_work_rounded, color: AppColors.propertyAccent, size: 20),
                          SizedBox(width: 6),
                          Text(
                            'Verified Properties',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () => context.go('/properties'),
                        child: const Text('See More', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ),
                ...propertyState.properties.take(3).map((property) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: PropertyCard(
                      property: property,
                      isPremiumUser: isPremium,
                      onUnlockTap: () => SubscriptionModal.show(context),
                      onTap: () => context.push('/property/${property.id}'),
                    ),
                  );
                }),
              ],

              if (_selectedFeed == '✨ All' || _selectedFeed == '🚗 Vehicles') ...[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.directions_car_filled_rounded, color: AppColors.vehicleAccent, size: 20),
                          SizedBox(width: 6),
                          Text(
                            'Verified Vehicles',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () => context.go('/vehicles'),
                        child: const Text('See More', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ),
                ...vehicleState.vehicles.take(3).map((vehicle) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: VehicleCard(
                      vehicle: vehicle,
                      isPremiumUser: isPremium,
                      onUnlockTap: () => SubscriptionModal.show(context),
                      onTap: () => context.push('/vehicle/${vehicle.id}'),
                    ),
                  );
                }),
              ],

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturedMiniCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double price;
  final String? imageUrl;
  final Color accentColor;
  final String categoryTag;
  final VoidCallback onTap;

  const _FeaturedMiniCard({
    required this.title,
    required this.subtitle,
    required this.price,
    this.imageUrl,
    required this.accentColor,
    required this.categoryTag,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.border),
        ),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: 100,
                    width: double.infinity,
                    child: imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: imageUrl!,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => Container(color: Colors.grey.shade300),
                          )
                        : Container(color: accentColor.withOpacity(0.1)),
                  ),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        categoryTag,
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyHelper.format(price),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
