class ApiEndpoints {
  ApiEndpoints._();

  // Default production base URL
  static const String defaultBaseUrl = 'https://www.easydealworld.com/v1/api';

  // Configurable base URL for dev/custom host
  static String baseUrl = defaultBaseUrl;

  // Auth endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String me = '/auth/me';
  static const String changePassword = '/auth/change-password';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String logout = '/auth/logout';

  // Property endpoints
  static const String properties = '/property/all';
  static const String addProperty = '/property/add';
  static String propertyDetail(dynamic id) => '/property/$id';
  static String updateProperty(dynamic id) => '/property/$id';
  static String deleteProperty(dynamic id) => '/property/$id';
  static const String myProperties = '/property/my/listings';
  static String updatePropertyStatus(dynamic id) => '/property/$id/status';

  // Vehicle endpoints
  static const String vehicles = '/vehicle/all';
  static const String addVehicle = '/vehicle/add';
  static String vehicleDetail(dynamic id) => '/vehicle/$id';
  static String updateVehicle(dynamic id) => '/vehicle/$id';
  static String deleteVehicle(dynamic id) => '/vehicle/$id';
  static const String myVehicles = '/vehicle/my/listings';
  static String updateVehicleStatus(dynamic id) => '/vehicle/$id/status';

  // Subscription & Payment endpoints
  static const String upgradeSubscription = '/subscription/upgrade';
  static const String subscriptionStatus = '/subscription/status';
  static const String createPaymentOrder = '/payment/create-order';

  // Booking endpoints
  static const String initiateBooking = '/booking/initiate';
  static const String verifyBooking = '/booking/verify';
  static const String myBookings = '/booking/my';
  static const String receivedBookings = '/booking/received';
  static String bookingDetail(dynamic id) => '/booking/$id';

  // Seller & Seller Request endpoints
  static const String requestSeller = '/seller-request/request';
  static const String mySellerRequest = '/seller-request/my-request';
  static const String sellerStats = '/seller/stats';
  static const String sellerListings = '/seller/listings';
  static const String sellerOrders = '/seller/orders';

  // Admin endpoints
  static const String adminDashboardStats = '/admin/dashboard-stats';
  static const String adminPendingListings = '/admin/pending-listings';
  static const String adminCustomers = '/admin/customers';
  static const String adminSellers = '/admin/sellers';
  static const String adminAllBookings = '/admin/all-bookings';
  static String adminUpdateUserRole(dynamic id) => '/admin/users/$id/role';
  static String adminUpdateUserStatus(dynamic id) => '/admin/users/$id/status';
  static const String adminExportCustomers = '/admin/export/customers';
}
