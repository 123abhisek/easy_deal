class ApiEndpoints {
  ApiEndpoints._();

  // Default production base URL (Proxied by VPS Nginx to FastAPI)
  static const String defaultBaseUrl = 'https://easydealworld.com/v1/api';

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
  static const String downgradeSubscription = '/subscription/downgrade';
  static const String createPaymentOrder = '/payment/create-order';
  static const String verifyPayment = '/payment/verify-payment';
  static const String myPayments = '/payment/my/payments';
  static String paymentDetail(dynamic id) => '/payment/$id';

  // Booking endpoints
  static const String initiateBooking = '/booking/initiate';
  static const String verifyBooking = '/booking/verify';
  static const String allBookings = '/booking/all';
  static const String myBookings = '/booking/my';
  static const String receivedBookings = '/booking/received';
  static String bookingDetail(dynamic id) => '/booking/$id';
  static String cancelBooking(dynamic id) => '/booking/$id';

  // Seller & Seller Request endpoints
  static const String requestSeller = '/seller-request/request';
  static const String mySellerRequests = '/seller-request/my-requests';
  static const String mySellerRequest = '/seller-request/my-request';
  static const String sellerProfile = '/seller/profile';
  static const String sellerStats = '/seller/dashboard-stats';
  static const String sellerProperties = '/seller/properties';
  static const String sellerVehicles = '/seller/vehicles';
  static const String sellerBookings = '/seller/bookings';
  static String sellerBookingDetail(dynamic id) => '/seller/bookings/$id';

  // Admin endpoints
  static const String adminDashboardStats = '/admin/dashboard-stats';
  static const String adminAnalyticsSummary = '/admin/analytics-summary';
  static const String adminPendingListings = '/admin/pending-listings';
  static const String adminUsers = '/admin/users';
  static const String adminCustomers = '/admin/customers';
  static const String adminSellers = '/admin/sellers';
  static const String adminSellersWithOrders = '/admin/sellers-with-orders';
  static const String adminAllBookings = '/admin/all-bookings';
  static const String adminAllPropertyVehicle = '/admin/all-property-vehicle';
  static const String adminPremiumSubscriptions = '/admin/premium-subscriptions';
  static const String adminSellerRequests = '/seller-request/admin/all';
  static String adminSellerRequestDetail(dynamic id) => '/seller-request/admin/$id';
  static String adminApproveSellerRequest(dynamic id) => '/seller-request/admin/$id/approve';
  static String adminRejectSellerRequest(dynamic id) => '/seller-request/admin/$id/reject';
  static String adminSuspendUser(dynamic id) => '/admin/users/$id/suspend';
  static String adminActivateUser(dynamic id) => '/admin/users/$id/activate';
  static const String adminExportUsers = '/admin/export/users.xlsx';
  static const String adminExportCustomers = '/admin/export/customers.xlsx';
  static const String adminExportSellers = '/admin/export/sellers.xlsx';
  static const String adminExportPremiumSubscriptions = '/admin/export/premium-subscriptions.xlsx';
}

