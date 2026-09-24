class PropertyModel {
  final String id;
  final String title;
  final String propertyType;
  final String location;
  final String? apartmentName;
  final String? floor;
  final int? rooms;
  final int? bedrooms;
  final double? area;
  final double? landArea;
  final String? cropsGrown;
  final double price;
  final String rentLease;
  final String? contact;
  final List<String> images;
  final String status;
  final String? ownerId;
  final String? ownerName;
  final String? facing;
  final String? furnishing;
  final String? parking;
  final String? createdAt;
  final bool isFeatured;

  const PropertyModel({
    required this.id,
    required this.title,
    required this.propertyType,
    required this.location,
    this.apartmentName,
    this.floor,
    this.rooms,
    this.bedrooms,
    this.area,
    this.landArea,
    this.cropsGrown,
    required this.price,
    this.rentLease = 'Sale',
    this.contact,
    this.images = const [],
    this.status = 'approved',
    this.ownerId,
    this.ownerName,
    this.facing,
    this.furnishing,
    this.parking,
    this.createdAt,
    this.isFeatured = false,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
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

    final rawPrice = json['price'] ?? json['expectedPrice'] ?? json['expected_price'] ?? json['amount'];
    final parsedPrice = rawPrice is num
        ? rawPrice.toDouble()
        : (double.tryParse(rawPrice?.toString() ?? '0') ?? 0.0);

    return PropertyModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? json['name']?.toString() ?? 'Property Listing',
      propertyType: json['property_type']?.toString() ?? json['propertyType']?.toString() ?? json['category']?.toString() ?? 'Flat',
      location: json['location']?.toString() ?? json['city']?.toString() ?? json['address']?.toString() ?? '',
      apartmentName: json['apartment_name']?.toString() ?? json['apartmentName']?.toString(),
      floor: json['floor']?.toString(),
      rooms: json['rooms'] is int ? json['rooms'] : int.tryParse(json['rooms']?.toString() ?? ''),
      bedrooms: json['bedrooms'] is int ? json['bedrooms'] : int.tryParse(json['bedrooms']?.toString() ?? ''),
      area: json['area'] is num ? (json['area'] as num).toDouble() : double.tryParse(json['area']?.toString() ?? ''),
      landArea: json['land_area'] is num
          ? (json['land_area'] as num).toDouble()
          : (json['landArea'] is num ? (json['landArea'] as num).toDouble() : double.tryParse(json['land_area']?.toString() ?? json['landArea']?.toString() ?? '')),
      cropsGrown: json['crops_grown']?.toString() ?? json['cropsGrown']?.toString(),
      price: parsedPrice,
      rentLease: json['rent_lease']?.toString() ?? json['rentLease']?.toString() ?? 'Sale',
      contact: json['contact']?.toString() ?? json['contactNumber']?.toString() ?? json['contact_number']?.toString(),
      images: parsedImages,
      status: json['status']?.toString() ?? 'approved',
      ownerId: json['owner_id']?.toString() ?? json['user_id']?.toString() ?? json['ownerId']?.toString() ?? json['userId']?.toString(),
      ownerName: json['owner_name']?.toString() ?? json['contact_name']?.toString() ?? json['ownerName']?.toString(),
      facing: json['facing']?.toString(),
      furnishing: json['furnishing']?.toString(),
      parking: json['parking']?.toString(),
      createdAt: json['created_at']?.toString() ?? json['createdAt']?.toString(),
      isFeatured: json['is_featured'] == true || json['isFeatured'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'property_type': propertyType,
      'location': location,
      'apartment_name': apartmentName,
      'floor': floor,
      'rooms': rooms,
      'bedrooms': bedrooms,
      'area': area,
      'land_area': landArea,
      'crops_grown': cropsGrown,
      'price': price,
      'rent_lease': rentLease,
      'contact': contact,
      'images': images,
      'status': status,
      'owner_id': ownerId,
      'owner_name': ownerName,
      'facing': facing,
      'furnishing': furnishing,
      'parking': parking,
      'created_at': createdAt,
      'is_featured': isFeatured,
    };
  }
}
