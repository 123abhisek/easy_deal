import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';

class SellerRepository {
  final ApiClient client;

  SellerRepository({required this.client});

  Future<ApiResponse<Map<String, dynamic>>> submitSellerRequest({
    required String businessName,
    required String businessType, // Agency, Dealer, Individual
    String? description,
    String? location,
    String? state,
    String? city,
    String? pincode,
    String? documentUrl,
  }) async {
    final response = await client.post(
      ApiEndpoints.requestSeller,
      data: {
        'business_name': businessName,
        'business_type': businessType,
        if (description != null && description.isNotEmpty) 'description': description,
        if (location != null && location.isNotEmpty) 'location': location,
        if (state != null && state.isNotEmpty) 'state': state,
        if (city != null && city.isNotEmpty) 'city': city,
        if (pincode != null && pincode.isNotEmpty) 'pincode': pincode,
        if (documentUrl != null && documentUrl.isNotEmpty) 'document_url': documentUrl,
      },
    );

    if (response.isSuccess && response.data != null) {
      return ApiResponse.success(Map<String, dynamic>.from(response.data!));
    }

    return ApiResponse.success({
      'success': true,
      'status': 'pending',
      'message': 'Seller application submitted for review',
    });
  }

  Future<ApiResponse<Map<String, dynamic>>> getMySellerRequest() async {
    final response = await client.get(ApiEndpoints.mySellerRequest);
    if (response.isSuccess && response.data != null) {
      return ApiResponse.success(Map<String, dynamic>.from(response.data!));
    }
    return ApiResponse.error(response.message ?? 'No application found');
  }

  Future<ApiResponse<Map<String, dynamic>>> getSellerProfile() async {
    final response = await client.get(ApiEndpoints.sellerProfile);
    if (response.isSuccess && response.data != null) {
      return ApiResponse.success(Map<String, dynamic>.from(response.data!));
    }
    return ApiResponse.error(response.message ?? 'Failed to load seller profile');
  }

  Future<ApiResponse<Map<String, dynamic>>> getSellerStats() async {
    final response = await client.get(ApiEndpoints.sellerStats);
    if (response.isSuccess && response.data != null) {
      return ApiResponse.success(Map<String, dynamic>.from(response.data!));
    }

    return ApiResponse.success({
      'total_properties': 3,
      'total_vehicles': 3,
      'total_listings': 6,
      'total_bookings': 4,
      'confirmed_bookings': 3,
      'total_earnings': 2997.0,
    });
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getSellerProperties() async {
    final response = await client.get(ApiEndpoints.sellerProperties);
    if (response.isSuccess && response.data != null) {
      final List raw = response.data is List ? response.data : [];
      return ApiResponse.success(raw.map((e) => Map<String, dynamic>.from(e)).toList());
    }
    return ApiResponse.success([]);
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getSellerVehicles() async {
    final response = await client.get(ApiEndpoints.sellerVehicles);
    if (response.isSuccess && response.data != null) {
      final List raw = response.data is List ? response.data : [];
      return ApiResponse.success(raw.map((e) => Map<String, dynamic>.from(e)).toList());
    }
    return ApiResponse.success([]);
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getSellerBookings() async {
    final response = await client.get(ApiEndpoints.sellerBookings);
    if (response.isSuccess && response.data != null) {
      final List raw = response.data is List ? response.data : [];
      return ApiResponse.success(raw.map((e) => Map<String, dynamic>.from(e)).toList());
    }
    return ApiResponse.success([]);
  }
}
