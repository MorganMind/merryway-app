import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../config/environment.dart';
import '../models/invite_models.dart';

/// Service for user preferences functionality
class UserPreferencesService {
  static final String _baseUrl = Environment.apiUrl;

  /// Get auth token
  static Future<String> _getToken() async {
    final session = Supabase.instance.client.auth.currentSession;
    return session?.accessToken ?? '';
  }

  /// Get user preferences
  static Future<UserPreferences> getUserPreferences() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/user-preferences/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    print('⚙️ Get User Preferences:');
    print('  Status: ${response.statusCode}');
    print('  Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserPreferences.fromJson(data['preferences']);
    } else {
      throw Exception('Failed to get preferences: ${response.body}');
    }
  }

  /// Update user preferences
  static Future<UserPreferences> updateUserPreferences({
    TravelRadius? travelRadius,
    MessTolerance? messTolerance,
    CostCeiling? costCeiling,
    bool? quietHoursEnabled,
    List<String>? interests,
  }) async {
    final token = await _getToken();
    final response = await http.patch(
      Uri.parse('$_baseUrl/user-preferences/update/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        if (travelRadius != null) 'travel_radius': travelRadius.name,
        if (messTolerance != null) 'mess_tolerance': messTolerance.name,
        if (costCeiling != null) 'cost_ceiling': costCeiling.name,
        if (quietHoursEnabled != null) 'quiet_hours_enabled': quietHoursEnabled,
        if (interests != null) 'interests': interests,
      }),
    );

    print('💾 Update User Preferences:');
    print('  Travel Radius: $travelRadius');
    print('  Mess Tolerance: $messTolerance');
    print('  Cost Ceiling: $costCeiling');
    print('  Quiet Hours: $quietHoursEnabled');
    print('  Interests: $interests');
    print('  Status: ${response.statusCode}');
    print('  Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserPreferences.fromJson(data['preferences']);
    } else {
      throw Exception('Failed to update preferences: ${response.body}');
    }
  }
}
