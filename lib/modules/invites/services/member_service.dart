import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../config/environment.dart';

/// Service for member functionality
class MemberService {
  static final String _baseUrl = Environment.apiUrl;

  /// Get auth token
  static Future<String> _getToken() async {
    final session = Supabase.instance.client.auth.currentSession;
    return session?.accessToken ?? '';
  }

  /// Get household members
  static Future<Map<String, dynamic>> getHouseholdMembers({
    required String householdId,
  }) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/households/$householdId/members/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    print('👥 Get Household Members:');
    print('  Household ID: $householdId');
    print('  Status: ${response.statusCode}');
    print('  Body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get household members: ${response.body}');
    }
  }

  /// Claim a member
  static Future<bool> claimMember({
    required String memberId,
  }) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$_baseUrl/members/$memberId/claim/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('🎯 Claim Member:');
    print('  Member ID: $memberId');
    print('  Status: ${response.statusCode}');

    return response.statusCode == 200;
  }
}
