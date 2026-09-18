import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/booking/presentation/screens/my_bookings_screen.dart';
import '../features/explore/presentation/screens/combined_listings_screen.dart';
import '../features/explore/presentation/screens/explore_screen.dart';
import '../features/profile/presentation/screens/edit_profile_screen.dart';
import '../features/profile/presentation/screens/my_listings_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/property/presentation/screens/add_property_screen.dart';
import '../features/property/presentation/screens/property_detail_screen.dart';
import '../features/property/presentation/screens/property_list_screen.dart';
import '../features/seller/presentation/screens/seller_request_screen.dart';
import '../features/vehicle/presentation/screens/add_vehicle_screen.dart';
import '../features/vehicle/presentation/screens/vehicle_detail_screen.dart';
import '../features/vehicle/presentation/screens/vehicle_list_screen.dart';
import 'main_shell_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorExplore = GlobalKey<NavigatorState>(debugLabel: 'explore');
final _shellNavigatorListings = GlobalKey<NavigatorState>(debugLabel: 'listings');
final _shellNavigatorBookings = GlobalKey<NavigatorState>(debugLabel: 'bookings');
final _shellNavigatorProfile = GlobalKey<NavigatorState>(debugLabel: 'profile');

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/explore',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShellScreen(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Explore (Home Feed)
          StatefulShellBranch(
            navigatorKey: _shellNavigatorExplore,
            routes: [
              GoRoute(
                path: '/explore',
                builder: (context, state) => const ExploreScreen(),
              ),
            ],
          ),

          // Branch 1: Listings (Properties & Vehicles Unified)
          StatefulShellBranch(
            navigatorKey: _shellNavigatorListings,
            routes: [
              GoRoute(
                path: '/listings',
                builder: (context, state) => const CombinedListingsScreen(),
              ),
            ],
          ),

          // Branch 2: Bookings (My Orders & Reservations)
          StatefulShellBranch(
            navigatorKey: _shellNavigatorBookings,
            routes: [
              GoRoute(
                path: '/my-bookings',
                builder: (context, state) => const MyBookingsScreen(),
              ),
            ],
          ),

          // Branch 3: Profile & Account
          StatefulShellBranch(
            navigatorKey: _shellNavigatorProfile,
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Direct Catalog Routes
      GoRoute(
        path: '/properties',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PropertyListScreen(),
      ),
      GoRoute(
        path: '/vehicles',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const VehicleListScreen(),
      ),

      // Auth Routes
      GoRoute(
        path: '/login',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Detail screens
      GoRoute(
        path: '/property/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return PropertyDetailScreen(propertyId: id);
        },
      ),
      GoRoute(
        path: '/vehicle/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return VehicleDetailScreen(vehicleId: id);
        },
      ),

      // Creation workflows (Ad Posting)
      GoRoute(
        path: '/add-property',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddPropertyScreen(),
      ),
      GoRoute(
        path: '/add-vehicle',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddVehicleScreen(),
      ),

      // Seller Onboarding
      GoRoute(
        path: '/seller-request',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SellerRequestScreen(),
      ),

      // Profile sub-pages
      GoRoute(
        path: '/edit-profile',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/my-listings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MyListingsScreen(),
      ),
    ],
  );
});
