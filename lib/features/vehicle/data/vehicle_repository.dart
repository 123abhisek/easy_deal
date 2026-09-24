import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import 'models/vehicle_model.dart';

class VehicleRepository {
  final ApiClient client;

  VehicleRepository({required this.client});

  Future<ApiResponse<List<VehicleModel>>> getVehicles({
    int skip = 0,
    int limit = 50,
    String? brand,
    String? location,
  }) async {
    final query = <String, dynamic>{
      'skip': skip,
      'limit': limit,
    };
    if (brand != null && brand.isNotEmpty && brand != 'All') {
      query['brand'] = brand;
    }
    if (location != null && location.isNotEmpty) {
      query['location'] = location;
    }

    final response = await client.get(
      ApiEndpoints.vehicles,
      queryParameters: query,
    );

    if (response.isSuccess && response.data != null) {
      final data = response.data;
      List rawList = [];
      if (data is List) {
        rawList = data;
      } else if (data is Map && data['vehicles'] is List) {
        rawList = data['vehicles'];
      } else if (data is Map && data['data'] is List) {
        rawList = data['data'];
      }

      final items = rawList.map((e) => VehicleModel.fromJson(Map<String, dynamic>.from(e))).toList();
      return ApiResponse.success(items, response.statusCode);
    }

    return ApiResponse.error(response.message ?? 'Failed to load vehicles', response.statusCode);
  }

  Future<ApiResponse<VehicleModel>> getVehicleById(String id) async {
    final response = await client.get(ApiEndpoints.vehicleDetail(id));
    if (response.isSuccess && response.data != null) {
      final data = response.data is Map && response.data['vehicle'] != null
          ? response.data['vehicle']
          : response.data;
      return ApiResponse.success(VehicleModel.fromJson(Map<String, dynamic>.from(data)));
    }

    return ApiResponse.error(response.message ?? 'Vehicle not found', response.statusCode);
  }

  Future<ApiResponse<VehicleModel>> addVehicle(Map<String, dynamic> data) async {
    final response = await client.post(
      ApiEndpoints.addVehicle,
      data: data,
    );

    if (response.isSuccess && response.data != null) {
      final resData = response.data is Map && response.data['vehicle'] != null
          ? response.data['vehicle']
          : response.data;
      return ApiResponse.success(VehicleModel.fromJson(Map<String, dynamic>.from(resData)));
    }

    return ApiResponse.error(response.message ?? 'Failed to add vehicle listing', response.statusCode);
  }

  Future<ApiResponse<List<VehicleModel>>> getMyVehicles() async {
    final response = await client.get(ApiEndpoints.myVehicles);
    if (response.isSuccess && response.data != null) {
      final data = response.data;
      List rawList = [];
      if (data is List) {
        rawList = data;
      } else if (data is Map && data['vehicles'] is List) {
        rawList = data['vehicles'];
      }
      return ApiResponse.success(
        rawList.map((e) => VehicleModel.fromJson(Map<String, dynamic>.from(e))).toList(),
      );
    }
    return ApiResponse.success([]);
  }

  Future<ApiResponse<bool>> deleteVehicle(String id) async {
    final response = await client.delete(ApiEndpoints.deleteVehicle(id));
    return ApiResponse.success(response.isSuccess);
  }

  Future<ApiResponse<bool>> updateStatus(String id, String status) async {
    final response = await client.patch(
      ApiEndpoints.updateVehicleStatus(id),
      data: {'status': status},
    );
    return ApiResponse.success(response.isSuccess);
  }
}
