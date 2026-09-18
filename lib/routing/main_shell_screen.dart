import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';

class MainShellScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShellScreen({
    super.key,
    required this.navigationShell,
  });

  int get _selectedBarIndex {
    final branch = navigationShell.currentIndex;
    if (branch == 0) return 0; // Explore
    if (branch == 1) return 1; // Listings
    if (branch == 2) return 3; // Bookings
    if (branch == 3) return 4; // Profile
    return 0;
  }

  void _onBarTap(BuildContext context, int index) {
    if (index == 2) {
      // Central ➕ Post Ad Action
      _showAddListingSheet(context);
      return;
    }

    int targetBranch = 0;
    if (index == 0) targetBranch = 0;
    if (index == 1) targetBranch = 1;
    if (index == 3) targetBranch = 2;
    if (index == 4) targetBranch = 3;

    navigationShell.goBranch(
      targetBranch,
      initialLocation: targetBranch == navigationShell.currentIndex,
    );
  }

  void _showAddListingSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Post an Ad on EasyDeal 🌐',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              const Text(
                'Choose a category to reach thousands of verified buyers directly.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: const EdgeInsets.all(12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppColors.border),
                ),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.propertyAccentLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.home_work_rounded, color: AppColors.propertyAccent),
                ),
                title: const Text('Post a Property Ad', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('Flats, independent houses, commercial plots & farmland', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () {
                  Navigator.of(ctx).pop();
                  context.push('/add-property');
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: const EdgeInsets.all(12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppColors.border),
                ),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.vehicleAccentLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.directions_car_filled_rounded, color: AppColors.vehicleAccent),
                ),
                title: const Text('Post a Vehicle Ad', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('Cars, SUVs, electric vehicles & motorcycles', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () {
                  Navigator.of(ctx).pop();
                  context.push('/add-vehicle');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedBarIndex,
        onDestinationSelected: (index) => _onBarTap(context, index),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore_rounded),
            label: 'Explore',
          ),
          const NavigationDestination(
            icon: Icon(Icons.list_alt_rounded),
            selectedIcon: Icon(Icons.list_alt_outlined),
            label: 'Listings',
          ),
          // Center ➕ Post Ad
          NavigationDestination(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
            label: 'Post Ad',
          ),
          const NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: 'Bookings',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
