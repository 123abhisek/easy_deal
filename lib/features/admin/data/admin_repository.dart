import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';

class AdminRepository {
  final ApiClient client;

  AdminRepository({required this.client});

  Future<ApiResponse<Map<String, dynamic>>> getDashboardStats() async {
    final response = await client.get(ApiEndpoints.adminDashboardStats);
    if (response.isSuccess && response.data != null) {
      return ApiResponse.success(Map<String, dynamic>.from(response.data!));
    }
    return ApiResponse.error(response.message ?? 'Failed to load dashboard statistics');
  }

  Future<ApiResponse<Map<String, dynamic>>> getAnalyticsSummary() async {
    final response = await client.get(ApiEndpoints.adminAnalyticsSummary);
    if (response.isSuccess && response.data != null) {
      return ApiResponse.success(Map<String, dynamic>.from(response.data!));
    }
    return ApiResponse.error(response.message ?? 'Failed to fetch analytics');
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getPendingListings() async {
    final response = await client.get(ApiEndpoints.adminPendingListings);
    if (response.isSuccess && response.data != null) {
      final data = response.data;
      List raw = [];
      if (data is List) {
        raw = data;
      } else if (data is Map && data['listings'] is List) {
        raw = data['listings'];
      }
      return ApiResponse.success(raw.map((e) => Map<String, dynamic>.from(e)).toList());
    }
    return ApiResponse.error(response.message ?? 'Failed to fetch pending listings');
  }

  Future<ApiResponse<bool>> updateListingStatus(String id, String type, String status) async {
    final endpoint = type == 'property'
        ? ApiEndpoints.updatePropertyStatus(id)
        : ApiEndpoints.updateVehicleStatus(id);

    final response = await client.patch(
      endpoint,
      data: {'status': status},
    );
    return ApiResponse.success(response.isSuccess);
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getAllUsers({int skip = 0, int limit = 50}) async {
    final response = await client.get(
      ApiEndpoints.adminUsers,
      queryParameters: {'skip': skip, 'limit': limit},
    );
    if (response.isSuccess && response.data is List) {
      final list = (response.data as List).map((e) => Map<String, dynamic>.from(e)).toList();
      return ApiResponse.success(list);
    }
    return ApiResponse.error(response.message ?? 'Failed to fetch users');
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getAllBookings({int skip = 0, int limit = 50}) async {
    final response = await client.get(
      ApiEndpoints.adminAllBookings,
      queryParameters: {'skip': skip, 'limit': limit},
    );
    if (response.isSuccess && response.data is List) {
      final list = (response.data as List).map((e) => Map<String, dynamic>.from(e)).toList();
      return ApiResponse.success(list);
    }
    return ApiResponse.error(response.message ?? 'Failed to fetch bookings');
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getSellerRequests({String? status}) async {
    final response = await client.get(
      ApiEndpoints.adminSellerRequests,
      queryParameters: status != null ? {'status': status} : null,
    );
    if (response.isSuccess && response.data is List) {
      final list = (response.data as List).map((e) => Map<String, dynamic>.from(e)).toList();
      return ApiResponse.success(list);
    }
    return ApiResponse.error(response.message ?? 'Failed to fetch seller requests');
  }

  Future<ApiResponse<bool>> approveSellerRequest(String requestId, {String? remarks}) async {
    final response = await client.post(
      ApiEndpoints.adminApproveSellerRequest(requestId),
      data: {'admin_remarks': remarks ?? 'Approved by administrator'},
    );
    return ApiResponse.success(response.isSuccess);
  }

  Future<ApiResponse<bool>> rejectSellerRequest(String requestId, {required String remarks}) async {
    final response = await client.post(
      ApiEndpoints.adminRejectSellerRequest(requestId),
      data: {'admin_remarks': remarks},
    );
    return ApiResponse.success(response.isSuccess);
  }

  Future<ApiResponse<bool>> suspendUser(String userId) async {
    final response = await client.patch(ApiEndpoints.adminSuspendUser(userId));
    return ApiResponse.success(response.isSuccess);
  }

  Future<ApiResponse<bool>> activateUser(String userId) async {
    final response = await client.patch(ApiEndpoints.adminActivateUser(userId));
    return ApiResponse.success(response.isSuccess);
  }
}
