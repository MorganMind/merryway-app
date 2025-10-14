import 'package:equatable/equatable.dart';

class Location extends Equatable {
  final String? id;
  final String householdId;
  final String name; // "Home", "School", "Work", etc.
  final String address;
  final double? latitude;
  final double? longitude;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Location({
    this.id,
    required this.householdId,
    required this.name,
    required this.address,
    this.latitude,
    this.longitude,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        householdId,
        name,
        address,
        latitude,
        longitude,
        notes,
        createdAt,
        updatedAt,
      ];

  Map<String, dynamic> toJson() => {
        'household_id': householdId,
        'name': name,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'notes': notes,
      };

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      householdId: json['household_id'],
      name: json['name'],
      address: json['address'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      notes: json['notes'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Location copyWith({
    String? id,
    String? householdId,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Location(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

