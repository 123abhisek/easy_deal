# Feature Mapping: React Web to Flutter Mobile

| React Component / Page | Flutter Screen / Widget | Primary Feature / Flow |
| :--- | :--- | :--- |
| `src/pages/LandingPage.jsx` & `ExplorePage.jsx` | `ExploreScreen.dart` | Interactive feed with category chips, banner carousels, latest properties and vehicles. |
| `src/pages/BrowsePage.jsx` | `CombinedListingsScreen.dart` | Unified listing grid with category switches, search, and sorting. |
| `src/dashboard/PropertiesPage.jsx` | `PropertyListScreen.dart` | Real estate catalog with property type filters (Apartment, Villa, Plot, Land). |
| `src/dashboard/VehiclesPage.jsx` | `VehicleListScreen.dart` | Vehicle catalog with type & brand filters (Car, SUV, Bike, Electric). |
| `src/pages/PropertyDetailPage.jsx` | `PropertyDetailScreen.dart` | Property view, HD gallery carousel, price conversion, Gold lock banner, and booking modal. |
| `src/pages/VehicleDetailPage.jsx` | `VehicleDetailScreen.dart` | Vehicle specs, brand/model info, km driven, RTO code, and booking trigger. |
| `src/forms/PropertyForm.jsx` / `AddPropertyPage.jsx` | `AddPropertyScreen.dart` | Property listing creation with image upload, land units selector, and price calculation. |
| `src/forms/VehicleForm.jsx` / `AddVehiclePage.jsx` | `AddVehicleScreen.dart` | Vehicle listing creation with brand, model, registration year, RTO details, and photos. |
| `src/pages/LoginPage.jsx` | `LoginScreen.dart` | Email/password sign in with secure JWT token storage. |
| `src/pages/RegisterPage.jsx` | `RegisterScreen.dart` | User signup with name, phone, email, and password. |
| `src/pages/ForgotPasswordPage.jsx` | `ForgotPasswordScreen.dart` | 2-step password reset with email verification and new password creation. |
| `src/dashboard/ProfilePage.jsx` | `ProfileScreen.dart` & `EditProfileScreen.dart` | Account hub, badge indicators, subscription status, and profile editor. |
| `src/dashboard/MyListingsPage.jsx` | `MyListingsScreen.dart` | Management of user-created properties and vehicles with status indicators. |
| `src/dashboard/MyBookingsPage.jsx` | `MyBookingsScreen.dart` | Buyer token reservations and digital receipt modal (`DigitalReceiptDialog`). |
| `src/components/BookingModal.jsx` / `bookingService.js` | `BookingBottomSheet.dart` | ₹999 token reservation initiation with Razorpay payment checkout. |
| `src/pages/SubscriptionPage.jsx` | `SubscriptionModal.dart` | EasyDeal Gold upgrade modal (₹299/mo) unlocking verified owner contacts. |
| `src/dashboard/SellerRequest.jsx` | `SellerRequestScreen.dart` | Seller verification application form with business details. |
| `src/pages/seller/SellerOverviewPage.jsx` | `SellerDashboardScreen.dart` | Seller operations center with listing statistics, inquiries, and earnings. |
| `src/pages/admin/AdminOverviewPage.jsx` & `AdminApprovalsPage.jsx` | `AdminDashboardScreen.dart` | Admin moderation hub with pending approval queue and approval/rejection actions. |
