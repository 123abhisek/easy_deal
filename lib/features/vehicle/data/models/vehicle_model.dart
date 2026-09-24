class VehicleModel {
  final String id;
  final String title;
  final String? vehicleNumber;
  final String brand;
  final String model;
  final String year;
  final String? rtoCode;
  final String? kmDriven;
  final String? fuelType;
  final String? transmission;
  final String? ownerCount;
  final String? state;
  final String location;
  final double expectedPrice;
  final String? contactNumber;
  final List<String> images;
  final String status;
  final String? ownerId;
  final String? ownerName;
  final String? createdAt;
  final bool isFeatured;

  const VehicleModel({
    required this.id,
    required this.title,
    this.vehicleNumber,
    required this.brand,
    required this.model,
    required this.year,
    this.rtoCode,
    this.kmDriven,
    this.fuelType,
    this.transmission,
    this.ownerCount,
    this.state,
    required this.location,
    required this.expectedPrice,
    this.contactNumber,
    this.images = const [],
    this.status = 'approved',
    this.ownerId,
    this.ownerName,
    this.createdAt,
    this.isFeatured = false,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedImages = [];
    if (json['images'] is List) {
      parsedImages = (json['images'] as List).map((e) => e.toString()).toList();
    } else if (json['images_list'] is List) {
      parsedImages = (json['images_list'] as List).map((e) => e.toString()).toList();
    } else if (json['image_url'] != null) {
      parsedImages = [json['image_url'].toString()];
    } else if (json['thumbnail'] != null) {
      parsedImages = [json['thumbnail'].toString()];
    } else if (json['image'] != null) {
      parsedImages = [json['image'].toString()];
    }

    final rawPrice = json['expectedPrice'] ?? json['expected_price'] ?? json['price'] ?? json['amount'];
    final parsedPrice = rawPrice is num
        ? rawPrice.toDouble()
        : (double.tryParse(rawPrice?.toString() ?? '0') ?? 0.0);

    return VehicleModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? json['name']?.toString() ?? 'Vehicle Listing',
      vehicleNumber: json['vehicleNumber']?.toString() ?? json['vehicle_number']?.toString(),
      brand: json['brand']?.toString() ?? json['make']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      year: json['year']?.toString() ?? '',
      rtoCode: json['rtoCode']?.toString() ?? json['rto_code']?.toString(),
      kmDriven: json['kmDriven']?.toString() ?? json['km_driven']?.toString(),
      fuelType: json['fuelType']?.toString() ?? json['fuel_type']?.toString() ?? json['category']?.toString() ?? 'Petrol',
      transmission: json['transmission']?.toString() ?? 'Manual',
      ownerCount: json['ownerCount']?.toString() ?? json['owner_count']?.toString() ?? '1st Owner',
      state: json['state']?.toString(),
      location: json['location']?.toString() ?? json['city']?.toString() ?? '',
      expectedPrice: parsedPrice,
      contactNumber: json['contactNumber']?.toString() ?? json['contact_number']?.toString() ?? json['contact']?.toString(),
      images: parsedImages,
      status: json['status']?.toString() ?? 'approved',
      ownerId: json['owner_id']?.toString() ?? json['user_id']?.toString() ?? json['ownerId']?.toString() ?? json['userId']?.toString(),
      ownerName: json['owner_name']?.toString() ?? json['contact_name']?.toString() ?? json['ownerName']?.toString(),
      createdAt: json['created_at']?.toString() ?? json['createdAt']?.toString(),
      isFeatured: json['is_featured'] == true || json['isFeatured'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'vehicleNumber': vehicleNumber,
      'brand': brand,
      'model': model,
      'year': year,
      'rtoCode': rtoCode,
      'kmDriven': kmDriven,
      'fuelType': fuelType,
      'transmission': transmission,
      'ownerCount': ownerCount,
      'state': state,
      'location': location,
      'expectedPrice': expectedPrice,
      'contactNumber': contactNumber,
      'images': images,
      'status': status,
      'owner_id': ownerId,
      'owner_name': ownerName,
      'created_at': createdAt,
      'is_featured': isFeatured,
    };
  }
}
