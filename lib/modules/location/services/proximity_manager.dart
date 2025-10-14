import 'dart:async';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/location_model.dart';

/// Privacy-first proximity manager
/// 
/// Handles:
/// - Coarse location detection (200m+ accuracy)
/// - Geofence matching
/// - State stability (dwell time)
/// - Cooldown after changes
/// 
/// Privacy:
/// - Raw coordinates NEVER sent to server
/// - Only coarse labels ("near School") are used
/// - All location data stays on device
class ProximityManager {
  // Configuration
  static const int DWELL_TIME_SECONDS = 30;        // Time before state change
  static const int COOLDOWN_SECONDS = 60;           // Cooldown after change
  static const double CONFIDENCE_THRESHOLD = 0.65;  // Min confidence
  
  // Storage keys
  static const String _locationsKey = 'household_locations';
  
  // State
  double? _currentLatitude;
  double? _currentLongitude;
  ProximityState? _currentProximityState;
  DateTime? _lastStateChangeTime;
  
  // Streams
  StreamSubscription<Position>? _locationSubscription;
  Timer? _proximityUpdateTimer;
  
  // Callback
  Function(ProximityState)? onProximityChanged;
  
  bool _isInitialized = false;

  /// Initialize proximity tracking
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Request permission
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final requested = await Geolocator.requestPermission();
      if (requested == LocationPermission.denied ||
          requested == LocationPermission.deniedForever) {
        print('Location permission denied');
        return;
      }
    }
    
    // Start location updates (coarse, battery-efficient)
    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,  // Coarse (~200m)
        distanceFilter: 100,              // Update every 100m
      ),
    ).listen((Position position) {
      _currentLatitude = position.latitude;
      _currentLongitude = position.longitude;
      _updateProximity();
    });
    
    // Periodic proximity check (every 10 seconds)
    _proximityUpdateTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _updateProximity(),
    );
    
    _isInitialized = true;
    
    // Initial update
    _updateProximity();
  }

  /// Update proximity state based on current location
  Future<void> _updateProximity() async {
    if (_currentLatitude == null || _currentLongitude == null) {
      return;
    }
    
    // Gather signals (all on-device)
    final signals = <ProximitySignal>[];
    final nearbyMembers = <String>[];
    double confidence = 0.0;
    String? locationLabel;
    String reason = "";
    
    // Signal 1: Geofencing (check if in defined location radius)
    final geofenceResult = await _checkGeofences();
    if (geofenceResult != null) {
      signals.add(ProximitySignal.geofence);
      locationLabel = geofenceResult['label'];
      confidence += 0.5;
      reason = "Detected in ${geofenceResult['label']}";
    }
    
    // Signal 2: WiFi detection (placeholder - would need platform channels)
    // In production, check WiFi SSID and match to household WiFi
    // For now, simulated based on geofence
    if (geofenceResult != null && geofenceResult['location_type'] == 'home') {
      signals.add(ProximitySignal.wifi);
      confidence += 0.3;
      reason += " (on home WiFi)";
      
      // Simulate: if at home, assume all members
      // In production: query local network or use BLE
      nearbyMembers.addAll(geofenceResult['potential_members'] ?? []);
    }
    
    // Signal 3: Bluetooth detection (placeholder)
    // In production: scan for known BLE devices
    // nearbyMembers.addAll(await _checkBluetooth());
    
    // If no location detected, return early
    if (locationLabel == null) {
      return;
    }
    
    // Deduplicate nearby members
    final uniqueMembers = nearbyMembers.toSet().toList();
    
    // Normalize confidence to 0-1
    confidence = (confidence / 1.0).clamp(0.0, 1.0);
    
    // Create new proximity state
    final newState = ProximityState(
      locationLabel: locationLabel,
      nearbyMemberIds: uniqueMembers,
      confidence: confidence,
      signals: signals,
      reason: reason.isNotEmpty ? reason : "Proximity detected",
      dwellStartTime: _currentProximityState == null ||
              _currentProximityState!.locationLabel != locationLabel
          ? DateTime.now()
          : _currentProximityState!.dwellStartTime,
    );
    
    // Check if state should be updated (stable, not in cooldown)
    if (_shouldUpdateState(newState)) {
      _currentProximityState = newState;
      _lastStateChangeTime = DateTime.now();
      onProximityChanged?.call(newState);
    } else {
      // Update current state but don't trigger callback
      _currentProximityState = newState;
    }
  }

  /// Check if current position is in any defined geofence
  Future<Map<String, dynamic>?> _checkGeofences() async {
    if (_currentLatitude == null || _currentLongitude == null) {
      return null;
    }
    
    // Load locations from device storage
    final locations = await _getStoredLocations();
    
    for (final location in locations) {
      if (location.latitude == null || location.longitude == null) {
        continue;
      }
      
      // Calculate distance
      final distance = Geolocator.distanceBetween(
        _currentLatitude!,
        _currentLongitude!,
        location.latitude!,
        location.longitude!,
      );
      
      // Check if within radius
      if (distance <= location.radiusMeters) {
        return {
          'label': location.label,
          'name': location.name,
          'location_type': location.locationType,
          'distance': distance,
          // Placeholder for member detection
          'potential_members': <String>[],
        };
      }
    }
    
    return null; // Not in any geofence
  }

  /// Load locations from device storage (with coordinates)
  Future<List<HouseholdLocation>> _getStoredLocations() async {
    final prefs = await SharedPreferences.getInstance();
    final locationsJson = prefs.getString(_locationsKey);
    
    if (locationsJson == null) {
      return [];
    }
    
    final List<dynamic> locationsList = jsonDecode(locationsJson);
    return locationsList
        .map((json) => HouseholdLocation.fromLocalJson(json))
        .toList();
  }

  /// Check if state should be updated (dwell time + cooldown)
  bool _shouldUpdateState(ProximityState newState) {
    if (_currentProximityState == null) {
      return true;  // First state
    }
    
    // Check cooldown
    if (_lastStateChangeTime != null) {
      final timeSinceChange =
          DateTime.now().difference(_lastStateChangeTime!).inSeconds;
      if (timeSinceChange < COOLDOWN_SECONDS) {
        return false;  // Still in cooldown
      }
    }
    
    // Check if location changed
    if (newState.locationLabel != _currentProximityState!.locationLabel) {
      // New location, check dwell time
      if (newState.hasValidDwell(DWELL_TIME_SECONDS)) {
        return true;  // New location with sufficient dwell
      }
      return false;  // Not enough dwell time yet
    }
    
    // Check if member set significantly changed (high confidence)
    final oldMembers = _currentProximityState!.nearbyMemberIds.toSet();
    final newMembers = newState.nearbyMemberIds.toSet();
    
    if (oldMembers != newMembers && newState.confidence >= CONFIDENCE_THRESHOLD) {
      final removed = oldMembers.difference(newMembers);
      final added = newMembers.difference(oldMembers);
      
      // Only update if members added (strong signal)
      if (removed.isEmpty && added.isNotEmpty) {
        return true;
      }
      
      // Don't update if single person left (might be offline)
      if (removed.length == 1 && added.isEmpty) {
        return false;
      }
    }
    
    return false;
  }

  /// Store household location (with coordinates, device-only)
  Future<void> storeLocation(HouseholdLocation location) async {
    final prefs = await SharedPreferences.getInstance();
    final locationsJson = prefs.getString(_locationsKey) ?? '[]';
    final List<dynamic> locationsList = jsonDecode(locationsJson);
    
    // Remove existing location with same ID
    if (location.id != null) {
      locationsList.removeWhere((l) => l['id'] == location.id);
    }
    
    // Add new/updated location
    locationsList.add(location.toLocalJson());
    
    await prefs.setString(_locationsKey, jsonEncode(locationsList));
  }

  /// Get current location label (privacy-safe)
  Future<String?> getCurrentLocationLabel() async {
    if (_currentLatitude == null || _currentLongitude == null) {
      return null;
    }
    
    final geofence = await _checkGeofences();
    return geofence?['label'];
  }

  /// Get current proximity state
  ProximityState? get currentState => _currentProximityState;

  /// Clean up resources
  Future<void> dispose() async {
    await _locationSubscription?.cancel();
    _proximityUpdateTimer?.cancel();
    _isInitialized = false;
  }
}

/// Utility functions for location
class LocationUtils {
  /// Request location permission
  static Future<bool> requestLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      final requested = await Geolocator.requestPermission();
      return requested == LocationPermission.whileInUse ||
          requested == LocationPermission.always;
    }
    
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// Check if location permission is granted
  static Future<bool> hasLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// Get current position (coarse)
  static Future<Position?> getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,  // Coarse
      );
    } catch (e) {
      print('Error getting position: $e');
      return null;
    }
  }
}

