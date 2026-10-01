import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Enum representing the lifecycle of a recycling pickup.
/// Supported Firestore statuses:
/// - New pickups: "Scheduled"
/// - Later status: "Collected"
enum PickupStatus {
  scheduled,
  collected,
  pending,
  confirmed,
  inTransit,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case PickupStatus.scheduled:
        return 'Scheduled';
      case PickupStatus.collected:
        return 'Collected';
      case PickupStatus.pending:
        return 'Pending';
      case PickupStatus.confirmed:
        return 'Confirmed';
      case PickupStatus.inTransit:
        return 'In Transit';
      case PickupStatus.completed:
        return 'Completed';
      case PickupStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// Exact Firestore status string
  String get firestoreValue {
    switch (this) {
      case PickupStatus.collected:
      case PickupStatus.completed:
        return 'Collected';
      case PickupStatus.cancelled:
        return 'Cancelled';
      case PickupStatus.inTransit:
        return 'In Transit';
      case PickupStatus.scheduled:
      case PickupStatus.pending:
      case PickupStatus.confirmed:
        return 'Scheduled';
    }
  }

  Color get color {
    switch (this) {
      case PickupStatus.scheduled:
      case PickupStatus.pending:
      case PickupStatus.confirmed:
        return AppColors.statusConfirmed;
      case PickupStatus.collected:
      case PickupStatus.completed:
        return AppColors.statusCompleted;
      case PickupStatus.inTransit:
        return AppColors.statusInTransit;
      case PickupStatus.cancelled:
        return AppColors.statusCancelled;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case PickupStatus.scheduled:
      case PickupStatus.pending:
      case PickupStatus.confirmed:
        return AppColors.statusConfirmedBg;
      case PickupStatus.collected:
      case PickupStatus.completed:
        return AppColors.statusCompletedBg;
      case PickupStatus.inTransit:
        return AppColors.statusInTransitBg;
      case PickupStatus.cancelled:
        return AppColors.statusCancelledBg;
    }
  }

  bool get isScheduled =>
      this == PickupStatus.scheduled ||
      this == PickupStatus.pending ||
      this == PickupStatus.confirmed ||
      this == PickupStatus.inTransit;

  bool get isCollected =>
      this == PickupStatus.collected || this == PickupStatus.completed;

  static PickupStatus fromString(String? value) {
    final clean = value?.toLowerCase().replaceAll('_', ' ').replaceAll('-', ' ').trim();
    switch (clean) {
      case 'scheduled':
      case 'pending':
      case 'confirmed':
        return PickupStatus.scheduled;
      case 'collected':
      case 'completed':
        return PickupStatus.collected;
      case 'intransit':
      case 'in transit':
        return PickupStatus.inTransit;
      case 'cancelled':
        return PickupStatus.cancelled;
      default:
        return PickupStatus.scheduled;
    }
  }
}

/// Represents a single waste category item in the guide and scheduling flow.
class WasteCategoryItem {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> acceptedItems;
  final List<String> rejectedItems;
  final List<String> preparationTips;

  const WasteCategoryItem({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.acceptedItems,
    required this.rejectedItems,
    required this.preparationTips,
  });

  /// Standard community recyclable waste categories
  static const List<WasteCategoryItem> defaultCategories = [
    WasteCategoryItem(
      id: 'plastic',
      name: 'Plastic',
      description: 'Clean bottles, containers, and rigid plastic packaging.',
      icon: Icons.recycling_rounded,
      color: AppColors.plasticCategory,
      acceptedItems: [
        'Beverage bottles (PET)',
        'Milk & detergent jugs (HDPE)',
        'Clean plastic tubs & trays',
        'Shampoo & soap containers',
      ],
      rejectedItems: [
        'Plastic wrap & plastic bags',
        'Styrofoam cups/containers',
        'Unwashed food containers',
        'Toothpaste tubes',
      ],
      preparationTips: [
        'Empty and thoroughly rinse all containers.',
        'Crush bottles to save space.',
        'Leave plastic bottle caps attached.',
      ],
    ),
    WasteCategoryItem(
      id: 'paper',
      name: 'Paper & Cardboard',
      description: 'Newspapers, corrugated boxes, cartons, and office paper.',
      icon: Icons.article_rounded,
      color: AppColors.paperCategory,
      acceptedItems: [
        'Flattened cardboard boxes',
        'Newspapers & magazines',
        'Clean office paper & notebooks',
        'Paper bags & cereal boxes',
      ],
      rejectedItems: [
        'Greasy pizza boxes',
        'Wax-coated paper cups',
        'Paper towels & used tissues',
        'Thermal receipt paper',
      ],
      preparationTips: [
        'Flatten all cardboard boxes before pickup.',
        'Keep dry and free from food stains.',
        'Remove plastic wrap and excessive tape.',
      ],
    ),
    WasteCategoryItem(
      id: 'glass',
      name: 'Glass',
      description: 'Clear, green, and brown glass jars and beverage bottles.',
      icon: Icons.wine_bar_rounded,
      color: AppColors.glassCategory,
      acceptedItems: [
        'Beverage glass bottles',
        'Food & sauce glass jars',
        'Cosmetic glass bottles',
      ],
      rejectedItems: [
        'Window panes & mirrors',
        'Light bulbs & fluorescent tubes',
        'Ceramics, porcelain & Pyrex',
        'Drinking glasses & crystal',
      ],
      preparationTips: [
        'Rinse containers thoroughly.',
        'Remove metal or plastic caps.',
        'Do not break glass before collection.',
      ],
    ),
    WasteCategoryItem(
      id: 'metal',
      name: 'Metal',
      description: 'Aluminum drink cans, steel food tins, and clean foil.',
      icon: Icons.inventory_2_rounded,
      color: AppColors.metalCategory,
      acceptedItems: [
        'Aluminum soda & beverage cans',
        'Steel & tin food cans',
        'Clean aluminum baking foil',
        'Metal jar lids',
      ],
      rejectedItems: [
        'Pressurized aerosol spray cans',
        'Paint cans with wet paint',
        'Pesticide containers',
        'Batteries or electronic parts',
      ],
      preparationTips: [
        'Rinse cans to prevent odors and insects.',
        'Push sharp metal lids inside the cans.',
        'Crush aluminum cans if convenient.',
      ],
    ),
    WasteCategoryItem(
      id: 'ewaste',
      name: 'E-Waste',
      description: 'Small household electronics, chargers, batteries, cords.',
      icon: Icons.devices_other_rounded,
      color: AppColors.ewasteCategory,
      acceptedItems: [
        'Smartphones, tablets & laptops',
        'Cables, power adapters & chargers',
        'Small kitchen gadgets & clocks',
        'Keyboards, mice & headphones',
      ],
      rejectedItems: [
        'Large commercial appliances',
        'CRT televisions & monitors',
        'Leaking lead-acid car batteries',
      ],
      preparationTips: [
        'Factory reset devices to protect personal data.',
        'Tape ends of rechargeable lithium batteries.',
        'Bundle cables with rubber bands.',
      ],
    ),
  ];

  /// Find a category by id or name, with fallback to default if not matched
  static WasteCategoryItem? findByNameOrId(String? query) {
    if (query == null || query.trim().isEmpty) return null;
    final q = query.toLowerCase().trim();
    for (final cat in defaultCategories) {
      if (cat.id.toLowerCase() == q ||
          cat.name.toLowerCase() == q ||
          cat.name.toLowerCase().contains(q) ||
          q.contains(cat.id.toLowerCase())) {
        return cat;
      }
    }
    return defaultCategories.first;
  }
}

/// Pickup model stored in Cloud Firestore `pickups/{pickupId}`:
/// - userId: String
/// - wasteCategory: String
/// - pickupDate: Timestamp / DateTime
/// - timeSlot: String
/// - address: String
/// - notes: String?
/// - status: "Scheduled" (new) or "Collected"
/// - createdAt: Timestamp / DateTime
class PickupModel {
  final String id;
  final String userId;
  final String residentName;
  final String residentPhone;
  final String wasteCategory;
  final List<String> subCategories;
  final DateTime pickupDate;
  final String timeSlot;
  final String address;
  final String street;
  final String city;
  final String postalCode;
  final String landmark;
  final String? notes;
  final PickupStatus status;
  final String? assignedTeam;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PickupModel({
    required this.id,
    required this.userId,
    this.residentName = '',
    this.residentPhone = '',
    String? wasteCategory,
    String? category,
    this.subCategories = const [],
    required this.pickupDate,
    required this.timeSlot,
    String? address,
    this.street = '',
    this.city = '',
    this.postalCode = '',
    this.landmark = '',
    this.notes,
    this.status = PickupStatus.scheduled,
    this.assignedTeam,
    required this.createdAt,
    DateTime? updatedAt,
  })  : wasteCategory = wasteCategory ?? category ?? '',
        address = address ?? street,
        updatedAt = updatedAt ?? createdAt;

  // Backward-compatible getters
  String get category => wasteCategory;

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
      if (street.isNotEmpty) street,
      if (landmark.isNotEmpty) 'Near $landmark',
      if (city.isNotEmpty) city,
      if (postalCode.isNotEmpty) postalCode,
    ];
    return parts.isEmpty ? 'Address not specified' : parts.join(', ');
  }

  PickupModel copyWith({
    String? id,
    String? userId,
    String? residentName,
    String? residentPhone,
    String? wasteCategory,
    String? category,
    List<String>? subCategories,
    DateTime? pickupDate,
    String? timeSlot,
    String? address,
    String? street,
    String? city,
    String? postalCode,
    String? landmark,
    String? notes,
    PickupStatus? status,
    String? assignedTeam,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PickupModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      residentName: residentName ?? this.residentName,
      residentPhone: residentPhone ?? this.residentPhone,
      wasteCategory: wasteCategory ?? category ?? this.wasteCategory,
      subCategories: subCategories ?? this.subCategories,
      pickupDate: pickupDate ?? this.pickupDate,
      timeSlot: timeSlot ?? this.timeSlot,
      address: address ?? street ?? this.address,
      street: street ?? this.street,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      landmark: landmark ?? this.landmark,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      assignedTeam: assignedTeam ?? this.assignedTeam,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'wasteCategory': wasteCategory,
      'pickupDate': Timestamp.fromDate(pickupDate),
      'timeSlot': timeSlot,
      'address': address.isNotEmpty ? address : fullAddress,
      'notes': notes ?? '',
      'status': status.firestoreValue, // "Scheduled" or "Collected"
      'createdAt': Timestamp.fromDate(createdAt),
      // Backward-compatible keys:
      'category': wasteCategory,
      'street': address.isNotEmpty ? address : street,
      'residentName': residentName,
      'residentPhone': residentPhone,
      'city': city,
      'postalCode': postalCode,
      'landmark': landmark,
      'subCategories': subCategories,
      'assignedTeam': assignedTeam,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory PickupModel.fromMap(Map<String, dynamic> map, {String? documentId}) {
    DateTime parseDateTime(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    final wasteCategory = (map['wasteCategory'] as String?)?.isNotEmpty == true
        ? map['wasteCategory'] as String
        : (map['category'] as String? ?? '');

    final address = (map['address'] as String?)?.isNotEmpty == true
        ? map['address'] as String
        : (map['street'] as String? ?? '');

    return PickupModel(
      id: documentId ?? map['id'] ?? '',
      userId: map['userId'] ?? '',
      residentName: map['residentName'] ?? '',
      residentPhone: map['residentPhone'] ?? '',
      wasteCategory: wasteCategory,
      subCategories: List<String>.from(map['subCategories'] ?? []),
      pickupDate: parseDateTime(map['pickupDate']),
      timeSlot: map['timeSlot'] ?? '',
      address: address,
      street: map['street'] ?? address,
      city: map['city'] ?? '',
      postalCode: map['postalCode'] ?? '',
      landmark: map['landmark'] ?? '',
      notes: map['notes'],
      status: PickupStatus.fromString(map['status']),
      assignedTeam: map['assignedTeam'],
      createdAt: parseDateTime(map['createdAt']),
      updatedAt: parseDateTime(map['updatedAt'] ?? map['createdAt']),
    );
  }

  factory PickupModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return PickupModel.fromMap(data, documentId: doc.id);
  }
}
