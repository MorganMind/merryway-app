import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../config/environment.dart';
import '../models/invite_models.dart';

/// Service for invite functionality
class InviteService {
  static final String _baseUrl = Environment.apiUrl;

  /// Get auth token
  static Future<String> _getToken() async {
    final session = Supabase.instance.client.auth.currentSession;
    return session?.accessToken ?? '';
  }

  /// Create an invite
  static Future<Invite> createInvite({
    required String householdId,
    required String invitedEmail,
    required String role,
    String? memberCandidateId,
  }) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$_baseUrl/households/$householdId/invites/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'invited_email': invitedEmail,
        'role': role,
        if (memberCandidateId != null) 'member_candidate_id': memberCandidateId,
      }),
    );

    print('📧 Create Invite Request:');
    print('  Household ID: $householdId');
    print('  Email: $invitedEmail');
    print('  Role: $role');
    print('  Status: ${response.statusCode}');
    print('  Body: ${response.body}');

    if (response.statusCode == 201) {
      return Invite.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create invite: ${response.body}');
    }
  }

  /// Validate an invite token
  static Future<InviteValidation> validateInvite(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/invites/$token/'),
    );

    print('🔍 Validate Invite Request:');
    print('  Token: $token');
    print('  Status: ${response.statusCode}');
    print('  Body: ${response.body}');

    if (response.statusCode == 200) {
      return InviteValidation.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to validate invite: ${response.body}');
    }
  }

  /// Accept an invite
  static Future<Map<String, dynamic>> acceptInvite({
    required String token,
    String? userId,
    String? email,
    required Map<String, dynamic> memberChoice,
    required String role,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/invites/$token/accept/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        if (userId != null) 'user_id': userId,
        if (email != null) 'email': email,
        'member_choice': memberChoice,
        'role': role,
      }),
    );

    print('✅ Accept Invite Request:');
    print('  Token: $token');
    print('  Member Choice: $memberChoice');
    print('  Status: ${response.statusCode}');
    print('  Body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to accept invite: ${response.body}');
    }
  }

  /// Get household invites
  static Future<List<Invite>> getHouseholdInvites({
    required String householdId,
  }) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/households/$householdId/invites/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    print('📋 Get Household Invites:');
    print('  Household ID: $householdId');
    print('  Status: ${response.statusCode}');
    print('  Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['invites'] as List)
          .map((json) => Invite.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to get invites: ${response.body}');
    }
  }

  /// Resend an invite
  static Future<bool> resendInvite({
    required String inviteId,
  }) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$_baseUrl/invites/$inviteId/resend/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    print('🔄 Resend Invite:');
    print('  Invite ID: $inviteId');
    print('  Status: ${response.statusCode}');

    return response.statusCode == 200;
  }

  /// Revoke an invite
  static Future<bool> revokeInvite({
    required String inviteId,
  }) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$_baseUrl/invites/$inviteId/revoke/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    print('🗑️ Revoke Invite:');
    print('  Invite ID: $inviteId');
    print('  Status: ${response.statusCode}');

    return response.statusCode == 200;
  }
}
