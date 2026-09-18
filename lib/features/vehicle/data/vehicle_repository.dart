import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import 'models/vehicle_model.dart';

class VehicleRepository {
  final ApiClient client;

  VehicleRepository({required this.client});

  static final List<VehicleModel> mockVehicles = [
    const VehicleModel(
      id: 'veh_01',
      title: '2022 Hyundai Creta SX (O) Turbo Petrol',
      brand: 'Hyundai',
      model: 'Creta SX (O)',
      year: '2022',
      vehicleNumber: 'KA-01-MJ-1234',
      rtoCode: 'KA01 (Koramangala)',
      kmDriven: '28,500',
      fuelType: 'Petrol',
      transmission: 'Automatic (DCT)',
      ownerCount: '1st Owner',
      state: 'Karnataka',
      location: 'Koramangala, Bangalore',
      expectedPrice: 1450000,
      contactNumber: '9876543210',
      status: 'approved',
      ownerName: 'Arjun Reddy (Individual)',
      isFeatured: true,
      images: [
        'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?auto=format&fit=crop&w=1000&q=80',
        'https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=1000&q=80',
      ],
    ),
    const VehicleModel(
      id: 'veh_02',
      title: '2023 Mahindra Thar LX Hard Top 4x4 Diesel',
      brand: 'Mahindra',
      model: 'Thar LX 4x4',
      year: '2023',
      vehicleNumber: 'KA-05-NB-7788',
      rtoCode: 'KA05 (Jayanagar)',
      kmDriven: '16,200',
      fuelType: 'Diesel',
      transmission: 'Manual',
      ownerCount: '1st Owner',
      state: 'Karnataka',
      location: 'Jayanagar, Bangalore',
      expectedPrice: 1680000,
      contactNumber: '9845012345',
      status: 'approved',
      ownerName: 'Karthik Gowda',
      isFeatured: true,
      images: [
        'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?auto=format&fit=crop&w=1000&q=80',
      ],
    ),
    const VehicleModel(
      id: 'veh_03',
      title: '2022 Tata Nexon EV Max XZ Plus Lux',
      brand: 'Tata',
      model: 'Nexon EV Max',
      year: '2022',
      vehicleNumber: 'KA-03-EM-4567',
      rtoCode: 'KA03 (Indiranagar)',
      kmDriven: '32,000',
      fuelType: 'Electric',
      transmission: 'Automatic',
      ownerCount: '1st Owner',
      state: 'Karnataka',
      location: 'Indiranagar, Bangalore',
      expectedPrice: 1320000,
      contactNumber: '9988776655',
      status: 'approved',
      ownerName: 'Green Wheels Auto',
      images: [
        'https://images.unsplash.com/photo-1563720223185-11003d516935?auto=format&fit=crop&w=1000&q=80',
      ],
    ),
    const VehicleModel(
      id: 'veh_04',
      title: '2021 BMW 3 Series 330i M Sport',
      brand: 'BMW',
      model: '330i M Sport',
      year: '2021',
      vehicleNumber: 'KA-04-ZD-0007',
      rtoCode: 'KA04 (Yeshwanthpur)',
      kmDriven: '24,000',
      fuelType: 'Petrol',
      transmission: 'Automatic',
      ownerCount: '1st Owner',
      state: 'Karnataka',
      location: 'Sadashivanagar, Bangalore',
      expectedPrice: 4150000,
      contactNumber: '9876001122',
      status: 'approved',
      ownerName: 'Siddharth Roy',
      images: [
        'https://images.unsplash.com/photo-1555215695-3004980ad54e?auto=format&fit=crop&w=1000&q=80',
      ],
    ),
    const VehicleModel(
      id: 'veh_05',
      title: '2020 Honda City ZX 1.5 i-VTEC Sunroof',
      brand: 'Honda',
      model: 'City ZX',
      year: '2020',
      vehicleNumber: 'KA-51-MD-9900',
      rtoCode: 'KA51 (Electronic City)',
      kmDriven: '42,000',
      fuelType: 'Petrol',
      transmission: 'Manual',
      ownerCount: '2nd Owner',
      state: 'Karnataka',
      location: 'HSR Layout, Bangalore',
      expectedPrice: 890000,
      contactNumber: '9663322110',
      status: 'approved',
      ownerName: 'Rohan Mehta',
      images: [
        'https://images.unsplash.com/photo-1617814076367-b759c7d7e738?auto=format&fit=crop&w=1000&q=80',
      ],
    ),
  ];

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
      return ApiResponse.success(items.isNotEmpty ? items : mockVehicles, response.statusCode);
    }

    return ApiResponse.success(mockVehicles);
  }

  Future<ApiResponse<VehicleModel>> getVehicleById(String id) async {
    final response = await client.get(ApiEndpoints.vehicleDetail(id));
    if (response.isSuccess && response.data != null) {
      final data = response.data is Map && response.data['vehicle'] != null
          ? response.data['vehicle']
          : response.data;
      return ApiResponse.success(VehicleModel.fromJson(Map<String, dynamic>.from(data)));
    }

    final found = mockVehicles.firstWhere(
      (v) => v.id == id,
      orElse: () => mockVehicles.first,
    );
    return ApiResponse.success(found);
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
