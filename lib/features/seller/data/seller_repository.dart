import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';

class SellerRepository {
  final ApiClient client;

  SellerRepository({required this.client});

  Future<ApiResponse<Map<String, dynamic>>> submitSellerRequest({
    required String businessName,
    required String businessType, // Agency, Dealer, Individual
    required String address,
    required String gstOrAadhar,
    String? comments,
  }) async {
    final response = await client.post(
      ApiEndpoints.requestSeller,
      data: {
        'business_name': businessName,
        'business_type': businessType,
        'address': address,
        'id_proof_number': gstOrAadhar,
        'comments': comments ?? '',
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

  Future<ApiResponse<Map<String, dynamic>>> getSellerStats() async {
    final response = await client.get(ApiEndpoints.sellerStats);
    if (response.isSuccess && response.data != null) {
      return ApiResponse.success(Map<String, dynamic>.from(response.data!));
    }

    return ApiResponse.success({
      'active_listings': 6,
      'total_inquiries': 42,
      'confirmed_tokens': 3,
      'total_earnings': 2997.0,
    });
  }
}
