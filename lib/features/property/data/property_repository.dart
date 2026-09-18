import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import 'models/property_model.dart';

class PropertyRepository {
  final ApiClient client;

  PropertyRepository({required this.client});

  // Mock sample properties for offline fallback
  static final List<PropertyModel> mockProperties = [
    const PropertyModel(
      id: 'prop_01',
      title: 'Luxury 3BHK Apartment at Prestige Ozone',
      propertyType: 'Flat',
      location: 'Whitefield, Bangalore, Karnataka',
      apartmentName: 'Prestige Ozone',
      floor: '4th Floor (out of 14)',
      rooms: 5,
      bedrooms: 3,
      area: 1850,
      price: 8500000,
      rentLease: 'Sale',
      contact: '9876543210',
      facing: 'East',
      furnishing: 'Semi-Furnished',
      parking: '2 Covered Slots',
      status: 'approved',
      ownerName: 'Sunil Kumar (Owner)',
      isFeatured: true,
      images: [
        'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?auto=format&fit=crop&w=1000&q=80',
        'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=1000&q=80',
        'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=1000&q=80',
      ],
    ),
    const PropertyModel(
      id: 'prop_02',
      title: 'Independent 4BHK Luxury Villa with Private Garden',
      propertyType: 'House',
      location: 'Sarjapur Road, Bangalore, Karnataka',
      apartmentName: 'Adarsh Palm Meadows',
      floor: 'G + 2 Floors',
      rooms: 6,
      bedrooms: 4,
      area: 3400,
      price: 24000000,
      rentLease: 'Sale',
      contact: '9845123456',
      facing: 'North-East',
      furnishing: 'Fully Furnished',
      parking: '3 Cars Covered',
      status: 'approved',
      ownerName: 'Rajesh Sharma',
      isFeatured: true,
      images: [
        'https://images.unsplash.com/photo-1613977257363-707ba9348227?auto=format&fit=crop&w=1000&q=80',
        'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?auto=format&fit=crop&w=1000&q=80',
      ],
    ),
    const PropertyModel(
      id: 'prop_03',
      title: 'Commercial Office Space in HSR Sector 1',
      propertyType: 'Commercial',
      location: 'HSR Layout Sector 1, Bangalore',
      floor: '2nd Floor',
      area: 2800,
      price: 180000,
      rentLease: 'Rent',
      contact: '9900112233',
      furnishing: 'Warm Shell with 40 Workstations',
      parking: '4 Cars',
      status: 'approved',
      ownerName: 'Vikas Tech Spaces',
      images: [
        'https://images.unsplash.com/photo-1497366216548-37526070297c?auto=format&fit=crop&w=1000&q=80',
      ],
    ),
    const PropertyModel(
      id: 'prop_04',
      title: '2.5 Acres Red Soil Farm Land with Water Source',
      propertyType: 'Agricultural Land',
      location: 'Doddaballapur, Bangalore Rural',
      landArea: 2.5,
      cropsGrown: 'Mango Orchard & Pomegranate',
      price: 6500000,
      rentLease: 'Sale',
      contact: '9448012345',
      status: 'approved',
      ownerName: 'Narayana Gowda',
      images: [
        'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=1000&q=80',
      ],
    ),
    const PropertyModel(
      id: 'prop_05',
      title: 'Modern 2BHK Ready to Move in Electronic City',
      propertyType: 'Flat',
      location: 'Electronic City Phase 1, Bangalore',
      apartmentName: 'Godrej E-City',
      floor: '7th Floor',
      rooms: 3,
      bedrooms: 2,
      area: 1150,
      price: 5800000,
      rentLease: 'Sale',
      contact: '9731234567',
      facing: 'North',
      furnishing: 'Semi-Furnished',
      parking: '1 Covered',
      status: 'approved',
      ownerName: 'Deepak Nair',
      images: [
        'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?auto=format&fit=crop&w=1000&q=80',
      ],
    ),
  ];

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
      return ApiResponse.success(items.isNotEmpty ? items : mockProperties, response.statusCode);
    }

    // Return mock data fallback for seamless UI development
    return ApiResponse.success(mockProperties);
  }

  Future<ApiResponse<PropertyModel>> getPropertyById(String id) async {
    final response = await client.get(ApiEndpoints.propertyDetail(id));
    if (response.isSuccess && response.data != null) {
      final data = response.data is Map && response.data['property'] != null
          ? response.data['property']
          : response.data;
      return ApiResponse.success(PropertyModel.fromJson(Map<String, dynamic>.from(data)));
    }

    // Fallback to mock
    final found = mockProperties.firstWhere(
      (p) => p.id == id,
      orElse: () => mockProperties.first,
    );
    return ApiResponse.success(found);
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
