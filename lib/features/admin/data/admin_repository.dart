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

    // Default mock stats
    return ApiResponse.success({
      'total_users': 1420,
      'total_sellers': 84,
      'total_properties': 312,
      'total_vehicles': 195,
      'pending_approvals': 4,
      'total_revenue': 148500.0,
    });
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

    // Default mock pending listings for admin review demo
    return ApiResponse.success([
      {
        'id': 'pend_01',
        'type': 'property',
        'title': 'New 3BHK Apartment in Bellandur Outer Ring Road',
        'location': 'Bellandur, Bangalore',
        'price': 9200000.0,
        'contact': '9845001122',
        'created_at': '2026-09-18T10:00:00Z',
        'status': 'pending',
      },
      {
        'id': 'pend_02',
        'type': 'vehicle',
        'title': '2023 Kia Seltos GTX Plus Diesel AT',
        'location': 'Indiranagar, Bangalore',
        'price': 1890000.0,
        'contact': '9876543210',
        'created_at': '2026-09-18T11:20:00Z',
        'status': 'pending',
      },
    ]);
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
}
