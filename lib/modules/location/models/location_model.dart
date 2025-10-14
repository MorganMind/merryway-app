import 'package:equatable/equatable.dart';

/// Household location (coordinates stored on device only)
class HouseholdLocation extends Equatable {
  final String? id;
  final String householdId;
  final String name;           // "Home", "School"
  final String label;          // "near Home", "near School"
  final String locationType;   // "home", "school", "work", "park", "custom"
  final double radiusMeters;
  final double? latitude;      // STORED ON DEVICE ONLY
  final double? longitude;     // STORED ON DEVICE ONLY
  final DateTime? createdAt;

  const HouseholdLocation({
    this.id,
    required this.householdId,
    required this.name,
    required this.label,
    required this.locationType,
    this.radiusMeters = 200,
    this.latitude,
    this.longitude,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, householdId, name, label, locationType];

  /// Convert to JSON for server (WITHOUT coordinates)
  Map<String, dynamic> toServerJson() => {
    'household_id': householdId,
    'name': name,
    'label': label,
    'location_type': locationType,
    'radius_meters': radiusMeters,
  };

  /// Convert to JSON for local storage (WITH coordinates)
  Map<String, dynamic> toLocalJson() => {
    ...toServerJson(),
    'id': id,
    'latitude': latitude,
    'longitude': longitude,
    'created_at': createdAt?.toIso8601String(),
  };

  factory HouseholdLocation.fromLocalJson(Map<String, dynamic> json) {
    return HouseholdLocation(
      id: json['id'],
      householdId: json['household_id'],
      name: json['name'],
      label: json['label'],
      locationType: json['location_type'],
      radiusMeters: (json['radius_meters'] as num?)?.toDouble() ?? 200,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  factory HouseholdLocation.fromServerJson(Map<String, dynamic> json) {
    return HouseholdLocation(
      id: json['id'],
      householdId: json['household_id'],
      name: json['name'],
      label: json['label'],
      locationType: json['location_type'],
      radiusMeters: (json['radius_meters'] as num?)?.toDouble() ?? 200,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }
}

/// Proximity detection signal types
enum ProximitySignal {
  geofence,
  wifi,
  bluetooth,
}

/// Proximity state (who's nearby and where)
class ProximityState extends Equatable {
  final String locationLabel;
  final List<String> nearbyMemberIds;
  final double confidence;  // 0-1
  final List<ProximitySignal> signals;
  final String reason;
  final DateTime dwellStartTime;

  const ProximityState({
    required this.locationLabel,
    required this.nearbyMemberIds,
    required this.confidence,
    required this.signals,
    required this.reason,
    required this.dwellStartTime,
  });

  @override
  List<Object?> get props => [
    locationLabel,
    nearbyMemberIds,
    confidence,
    signals,
    reason,
    dwellStartTime,
  ];

  Duration get dwellDuration => DateTime.now().difference(dwellStartTime);

  bool hasValidDwell(int dwellSeconds) {
    return dwellDuration.inSeconds >= dwellSeconds;
  }

  ProximityState copyWith({
    String? locationLabel,
    List<String>? nearbyMemberIds,
    double? confidence,
    List<ProximitySignal>? signals,
    String? reason,
    DateTime? dwellStartTime,
  }) {
    return ProximityState(
      locationLabel: locationLabel ?? this.locationLabel,
      nearbyMemberIds: nearbyMemberIds ?? this.nearbyMemberIds,
      confidence: confidence ?? this.confidence,
      signals: signals ?? this.signals,
      reason: reason ?? this.reason,
      dwellStartTime: dwellStartTime ?? this.dwellStartTime,
    );
  }
}

/// Location privacy settings for a member
class LocationPrivacySettings extends Equatable {
  final String memberId;
  final bool locationSharingEnabled;
  final bool bluetoothDetectionEnabled;
  final bool wifiDetectionEnabled;
  final bool autoSuggestionsEnabled;

  const LocationPrivacySettings({
    required this.memberId,
    this.locationSharingEnabled = false,
    this.bluetoothDetectionEnabled = false,
    this.wifiDetectionEnabled = false,
    this.autoSuggestionsEnabled = false,
  });

  @override
  List<Object?> get props => [
    memberId,
    locationSharingEnabled,
    bluetoothDetectionEnabled,
    wifiDetectionEnabled,
    autoSuggestionsEnabled,
  ];

  Map<String, dynamic> toJson() => {
    'member_id': memberId,
    'location_sharing_enabled': locationSharingEnabled,
    'bluetooth_detection_enabled': bluetoothDetectionEnabled,
    'wifi_detection_enabled': wifiDetectionEnabled,
    'auto_suggestions_enabled': autoSuggestionsEnabled,
  };

  factory LocationPrivacySettings.fromJson(Map<String, dynamic> json) {
    return LocationPrivacySettings(
      memberId: json['member_id'],
      locationSharingEnabled: json['location_sharing_enabled'] ?? false,
      bluetoothDetectionEnabled: json['bluetooth_detection_enabled'] ?? false,
      wifiDetectionEnabled: json['wifi_detection_enabled'] ?? false,
      autoSuggestionsEnabled: json['auto_suggestions_enabled'] ?? false,
    );
  }

  LocationPrivacySettings copyWith({
    String? memberId,
    bool? locationSharingEnabled,
    bool? bluetoothDetectionEnabled,
    bool? wifiDetectionEnabled,
    bool? autoSuggestionsEnabled,
  }) {
    return LocationPrivacySettings(
      memberId: memberId ?? this.memberId,
      locationSharingEnabled: locationSharingEnabled ?? this.locationSharingEnabled,
      bluetoothDetectionEnabled: bluetoothDetectionEnabled ?? this.bluetoothDetectionEnabled,
      wifiDetectionEnabled: wifiDetectionEnabled ?? this.wifiDetectionEnabled,
      autoSuggestionsEnabled: autoSuggestionsEnabled ?? this.autoSuggestionsEnabled,
    );
  }
}

