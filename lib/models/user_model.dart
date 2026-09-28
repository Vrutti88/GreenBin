import 'package:cloud_firestore/cloud_firestore.dart';

/// User model representing a GreenBin resident or community team member.
/// Maps directly to the Firestore `users/{userId}` document schema:
/// - name: String
/// - email: String
/// - phone: String
/// - community: String
/// - address: String
/// - role: String ('resident', 'collector', 'admin')
/// - createdAt: Timestamp / DateTime
class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String community;
  final String address;
  final String role; // 'resident', 'collector', 'admin'
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? profileImageUrl;
  final int totalPickups;
  final double kgRecycled;
  final String city;
  final String postalCode;
  final String landmark;

  const UserModel({
    required this.id,
    required this.email,
    String? name,
    String? fullName,
    String? phone,
    String? phoneNumber,
    this.community = '',
    String? address,
    String? street,
    this.city = '',
    this.postalCode = '',
    this.landmark = '',
    this.role = 'resident',
    this.profileImageUrl,
    this.totalPickups = 0,
    this.kgRecycled = 0.0,
    required this.createdAt,
    DateTime? updatedAt,
  })  : name = name ?? fullName ?? '',
        phone = phone ?? phoneNumber ?? '',
        address = address ?? street ?? '',
        updatedAt = updatedAt ?? createdAt;

  // Backward-compatible getters
  String get fullName => name;
  String get phoneNumber => phone;
  String get street => address;

  /// Convenient formatted address string
  String get fullAddress {
    if (address.isNotEmpty) {
      if (city.isEmpty || address.contains(city)) {
        return address;
      }
      return [
        address,
        if (landmark.isNotEmpty) 'Near $landmark',
        if (city.isNotEmpty) city,
        if (postalCode.isNotEmpty) postalCode,
      ].join(', ');
    }
    final parts = [
      if (landmark.isNotEmpty) 'Near $landmark',
      if (city.isNotEmpty) city,
      if (postalCode.isNotEmpty) postalCode,
    ];
    return parts.isEmpty ? 'No address set' : parts.join(', ');
  }

  /// Check if user has completed minimum profile setup
  bool get isProfileComplete {
    return name.isNotEmpty && phone.isNotEmpty && address.isNotEmpty;
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? fullName,
    String? phone,
    String? phoneNumber,
    String? community,
    String? address,
    String? street,
    String? city,
    String? postalCode,
    String? landmark,
    String? role,
    String? profileImageUrl,
    int? totalPickups,
    double? kgRecycled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? fullName ?? this.name,
      phone: phone ?? phoneNumber ?? this.phone,
      community: community ?? this.community,
      address: address ?? street ?? this.address,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      landmark: landmark ?? this.landmark,
      role: role ?? this.role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      totalPickups: totalPickups ?? this.totalPickups,
      kgRecycled: kgRecycled ?? this.kgRecycled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'community': community,
      'address': address.isNotEmpty ? address : fullAddress,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
      // Backward-compatible keys for existing views
      'fullName': name,
      'phoneNumber': phone,
      'street': address,
      'city': city,
      'postalCode': postalCode,
      'landmark': landmark,
      'profileImageUrl': profileImageUrl,
      'totalPickups': totalPickups,
      'kgRecycled': kgRecycled,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, {String? documentId}) {
    DateTime parseDateTime(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    final name = map['name'] as String? ?? map['fullName'] as String? ?? '';
    final phone = map['phone'] as String? ?? map['phoneNumber'] as String? ?? '';
    final address = map['address'] as String? ?? map['street'] as String? ?? '';
    final community = map['community'] as String? ?? '';

    return UserModel(
      id: documentId ?? map['id'] ?? '',
      email: map['email'] ?? '',
      name: name,
      phone: phone,
      community: community,
      address: address,
      city: map['city'] ?? '',
      postalCode: map['postalCode'] ?? '',
      landmark: map['landmark'] ?? '',
      role: map['role'] ?? 'resident',
      profileImageUrl: map['profileImageUrl'],
      totalPickups: (map['totalPickups'] as num?)?.toInt() ?? 0,
      kgRecycled: (map['kgRecycled'] as num?)?.toDouble() ?? 0.0,
      createdAt: parseDateTime(map['createdAt']),
      updatedAt: parseDateTime(map['updatedAt'] ?? map['createdAt']),
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel.fromMap(data, documentId: doc.id);
  }
}
