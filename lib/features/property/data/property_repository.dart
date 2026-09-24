import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import 'models/property_model.dart';

class PropertyRepository {
  final ApiClient client;

  PropertyRepository({required this.client});

  Future<ApiResponse<List<PropertyModel>>> getProperties({
    int skip = 0,
    int limit = 50,
    String? propertyType,
    String? location,
  }) async {
    final query = <String, dynamic>{
      'skip': skip,
      'limit': limit,
    };
    if (propertyType != null && propertyType.isNotEmpty && propertyType != 'All') {
      query['property_type'] = propertyType;
    }
    if (location != null && location.isNotEmpty) {
      query['location'] = location;
    }

    final response = await client.get(
      ApiEndpoints.properties,
      queryParameters: query,
    );

    if (response.isSuccess && response.data != null) {
      final data = response.data;
      List rawList = [];
      if (data is List) {
        rawList = data;
      } else if (data is Map && data['properties'] is List) {
        rawList = data['properties'];
      } else if (data is Map && data['data'] is List) {
        rawList = data['data'];
      }

      final items = rawList.map((e) => PropertyModel.fromJson(Map<String, dynamic>.from(e))).toList();
      return ApiResponse.success(items, response.statusCode);
    }

    return ApiResponse.error(response.message ?? 'Failed to load properties', response.statusCode);
  }

  Future<ApiResponse<PropertyModel>> getPropertyById(String id) async {
    final response = await client.get(ApiEndpoints.propertyDetail(id));
    if (response.isSuccess && response.data != null) {
      final data = response.data is Map && response.data['property'] != null
          ? response.data['property']
          : response.data;
      return ApiResponse.success(PropertyModel.fromJson(Map<String, dynamic>.from(data)));
    }

    return ApiResponse.error(response.message ?? 'Property not found', response.statusCode);
  }

  Future<ApiResponse<PropertyModel>> addProperty(Map<String, dynamic> data) async {
    final response = await client.post(
      ApiEndpoints.addProperty,
      data: data,
    );

    if (response.isSuccess && response.data != null) {
      final resData = response.data is Map && response.data['property'] != null
          ? response.data['property']
          : response.data;
      return ApiResponse.success(PropertyModel.fromJson(Map<String, dynamic>.from(resData)));
    }

    return ApiResponse.error(response.message ?? 'Failed to add property listing', response.statusCode);
  }

  Future<ApiResponse<List<PropertyModel>>> getMyProperties() async {
    final response = await client.get(ApiEndpoints.myProperties);
    if (response.isSuccess && response.data != null) {
      final data = response.data;
      List rawList = [];
      if (data is List) {
        rawList = data;
      } else if (data is Map && data['properties'] is List) {
        rawList = data['properties'];
      }
      return ApiResponse.success(
        rawList.map((e) => PropertyModel.fromJson(Map<String, dynamic>.from(e))).toList(),
      );
    }
    return ApiResponse.success([]);
  }

  Future<ApiResponse<bool>> deleteProperty(String id) async {
    final response = await client.delete(ApiEndpoints.deleteProperty(id));
    return ApiResponse.success(response.isSuccess);
  }

  Future<ApiResponse<bool>> updateStatus(String id, String status) async {
    final response = await client.patch(
      ApiEndpoints.updatePropertyStatus(id),
      data: {'status': status},
    );
    return ApiResponse.success(response.isSuccess);
  }
}
