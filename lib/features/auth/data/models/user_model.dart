class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final bool isPremium;
  final bool isAdmin;
  final bool isSeller;
  final String? avatarUrl;
  final String? gender;
  final String? dob;
  final String? occupation;
  final String? location;
  final String? state;
  final String? city;
  final String? pincode;
  final String? createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.role = 'user',
    this.isPremium = false,
    this.isAdmin = false,
    this.isSeller = false,
    this.avatarUrl,
    this.gender,
    this.dob,
    this.occupation,
    this.location,
    this.state,
    this.city,
    this.pincode,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      role: json['role']?.toString() ?? 'user',
      isPremium: json['is_premium'] == true || json['role'] == 'premium',
      isAdmin: json['is_admin'] == true || json['role'] == 'admin',
      isSeller: json['is_seller'] == true || json['role'] == 'seller',
      avatarUrl: json['avatar_url']?.toString(),
      gender: json['gender']?.toString(),
      dob: json['dob']?.toString(),
      occupation: json['occupation']?.toString(),
      location: json['location']?.toString(),
      state: json['state']?.toString(),
      city: json['city']?.toString(),
      pincode: json['pincode']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'is_premium': isPremium,
      'is_admin': isAdmin,
      'is_seller': isSeller,
      'avatar_url': avatarUrl,
      'gender': gender,
      'dob': dob,
      'occupation': occupation,
      'location': location,
      'state': state,
      'city': city,
      'pincode': pincode,
      'created_at': createdAt,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    bool? isPremium,
    bool? isAdmin,
    bool? isSeller,
    String? avatarUrl,
    String? gender,
    String? dob,
    String? occupation,
    String? location,
    String? state,
    String? city,
    String? pincode,
    String? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isPremium: isPremium ?? this.isPremium,
      isAdmin: isAdmin ?? this.isAdmin,
      isSeller: isSeller ?? this.isSeller,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      occupation: occupation ?? this.occupation,
      location: location ?? this.location,
      state: state ?? this.state,
      city: city ?? this.city,
      pincode: pincode ?? this.pincode,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
