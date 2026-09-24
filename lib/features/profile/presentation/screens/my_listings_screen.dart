import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/empty_state_view.dart';
import 'package:easy_deal/features/property/data/models/property_model.dart';
import 'package:easy_deal/features/property/presentation/controllers/property_controller.dart';
import 'package:easy_deal/features/vehicle/data/models/vehicle_model.dart';
import 'package:easy_deal/features/vehicle/presentation/controllers/vehicle_controller.dart';

class MyListingsScreen extends ConsumerStatefulWidget {
  const MyListingsScreen({super.key});

  @override
  ConsumerState<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends ConsumerState<MyListingsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  List<PropertyModel> _properties = [];
  List<VehicleModel> _vehicles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadListings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadListings() async {
    setState(() => _isLoading = true);
    final propRepo = ref.read(propertyRepositoryProvider);
    final vehRepo = ref.read(vehicleRepositoryProvider);

    final propRes = await propRepo.getMyProperties();
    final vehRes = await vehRepo.getMyVehicles();

    if (mounted) {
      setState(() {
        _properties = propRes.data ?? [];
        _vehicles = vehRes.data ?? [];
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteProperty(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Listing?'),
        content: const Text('Are you sure you want to delete this property listing?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(propertyRepositoryProvider).deleteProperty(id);
      setState(() {
        _properties.removeWhere((p) => p.id == id);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing removed successfully')),
        );
      }
    }
  }

  Future<void> _deleteVehicle(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Listing?'),
        content: const Text('Are you sure you want to delete this vehicle listing?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(vehicleRepositoryProvider).deleteVehicle(id);
      setState(() {
        _vehicles.removeWhere((v) => v.id == id);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vehicle listing removed successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Active Listings'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Properties'),
            Tab(text: 'Vehicles'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Properties Tab
                _properties.isEmpty
                    ? EmptyStateView(
                        icon: Icons.apartment_rounded,
                        title: 'No Properties Posted',
                        message: 'You have not listed any real estate properties yet.',
                        actionLabel: 'Post Property',
                        onAction: () => context.push('/add-property'),
                      )
                    : RefreshIndicator.adaptive(
                        onRefresh: _loadListings,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _properties.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final p = _properties[index];
                            return Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: const BorderSide(color: AppColors.border),
                              ),
                              child: ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: AppColors.propertyAccentLight,
                                  child: Icon(Icons.apartment_rounded, color: AppColors.propertyAccent),
                                ),
                                title: Text(p.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                subtitle: Text('${CurrencyHelper.format(p.price)} • ${p.location}', maxLines: 1, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                                  onPressed: () => _deleteProperty(p.id),
                                ),
                                onTap: () => context.push('/property/${p.id}'),
                              ),
                            );
                          },
                        ),
                      ),

                // Vehicles Tab
                _vehicles.isEmpty
                    ? EmptyStateView(
                        icon: Icons.directions_car_filled_rounded,
                        title: 'No Vehicles Posted',
                        message: 'You have not listed any cars or vehicles yet.',
                        actionLabel: 'Post Vehicle',
                        onAction: () => context.push('/add-vehicle'),
                      )
                    : RefreshIndicator.adaptive(
                        onRefresh: _loadListings,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _vehicles.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final v = _vehicles[index];
                            return Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: const BorderSide(color: AppColors.border),
                              ),
                              child: ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: AppColors.vehicleAccentLight,
                                  child: Icon(Icons.directions_car_filled_rounded, color: AppColors.vehicleAccent),
                                ),
                                title: Text(v.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                subtitle: Text('${CurrencyHelper.format(v.expectedPrice)} • ${v.location}', maxLines: 1, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                                  onPressed: () => _deleteVehicle(v.id),
                                ),
                                onTap: () => context.push('/vehicle/${v.id}'),
                              ),
                            );
                          },
                        ),
                      ),
              ],
            ),
    );
  }
}
