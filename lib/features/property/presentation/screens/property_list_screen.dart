import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/listing_card_skeleton.dart';
import '../../../../core/widgets/locked_feature_banner.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../explore/presentation/widgets/category_chip_bar.dart';
import '../../../explore/presentation/widgets/property_card.dart';
import '../../../subscription/presentation/widgets/subscription_modal.dart';
import '../controllers/property_controller.dart';

class PropertyListScreen extends ConsumerWidget {
  const PropertyListScreen({super.key});

  static const List<String> _propertyTypes = [
    'All',
    'Flat',
    'House',
    'Plot',
    'Commercial',
    'Agricultural Land',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(propertyListControllerProvider);
    final authState = ref.watch(authControllerProvider);
    final isPremium = authState.isPremium;
    final controller = ref.read(propertyListControllerProvider.notifier);
    final filtered = controller.filteredProperties;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Properties & Real Estate'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SearchBar(
              hintText: 'Search properties by location, name...',
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
            categories: _propertyTypes,
            selectedCategory: state.selectedType,
            onSelected: (cat) => controller.filterByType(cat),
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
                        icon: Icons.apartment_rounded,
                        title: 'No Properties Found',
                        message: 'Try changing your search keywords or category filters.',
                        actionLabel: 'Reset Filters',
                        onAction: () => controller.filterByType('All'),
                      )
                    : RefreshIndicator.adaptive(
                        onRefresh: () => controller.fetchProperties(),
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final property = filtered[index];
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (authState.user == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please sign in to post a property listing')),
            );
            context.push('/login');
          } else {
            context.push('/add-property');
          }
        },
        backgroundColor: AppColors.propertyAccent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_home_rounded),
        label: const Text('Post Property', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
