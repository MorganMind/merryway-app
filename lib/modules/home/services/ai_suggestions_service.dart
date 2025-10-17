import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../config/environment.dart';
import '../../family/models/family_models.dart';

/// Service for AI suggestions API communication
class AISuggestionsService {
  static final String _baseUrl = Environment.apiUrl;

  /// Get auth token
  static Future<String> _getToken() async {
    final session = Supabase.instance.client.auth.currentSession;
    return session?.accessToken ?? '';
  }

  /// Get auth headers
  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  /// Get AI suggestions from backend
  static Future<Map<String, dynamic>> getAISuggestions({
    required String householdId,
    required String prompt,
    required Map<String, dynamic> context,
    List<String>? participants,
    String? podId,
  }) async {
    try {
      final headers = await _getHeaders();
      
      final requestBody = {
        'household_id': householdId,
        'prompt': prompt,
        'context': context,
        if (participants != null) 'participants': participants,
        if (podId != null) 'pod_id': podId,
      };

      print('🤖 Get AI Suggestions Request:');
      print('  Household ID: $householdId');
      print('  Pod ID: $podId');
      print('  Prompt: $prompt');
      print('  Participants: $participants');

      final response = await http.post(
        Uri.parse('$_baseUrl/ai-suggestions/'),
        headers: headers,
        body: json.encode(requestBody),
      );

      print('📨 Get AI Suggestions Response:');
      print('  Status: ${response.statusCode}');
      print('  Body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to get AI suggestions: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error getting AI suggestions: $e');
      rethrow;
    }
  }

  /// Track AI suggestion acceptance
  static Future<void> trackSuggestionAccepted({
    required String logId,
    required String suggestionName,
    required String householdId,
    required String memberId,
  }) async {
    try {
      final headers = await _getHeaders();
      
      final requestBody = {
        'log_id': logId,
        'suggestion_name': suggestionName,
        'household_id': householdId,
        'member_id': memberId,
      };

      print('✅ Track Suggestion Accepted Request:');
      print('  Log ID: $logId');
      print('  Suggestion: $suggestionName');
      print('  Member ID: $memberId');

      final response = await http.post(
        Uri.parse('$_baseUrl/ai-suggestions/accept/'),
        headers: headers,
        body: json.encode(requestBody),
      );

      print('✅ Track Suggestion Accepted Response:');
      print('  Status: ${response.statusCode}');
      print('  Body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to track suggestion acceptance: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error tracking suggestion acceptance: $e');
      // Don't rethrow - this is background tracking, shouldn't break UI
    }
  }

  /// Get AI suggestion logs from backend
  static Future<List<Map<String, dynamic>>> getAISuggestionLogs({
    required String householdId,
    required String memberId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final headers = await _getHeaders();
      
      final uri = Uri.parse('$_baseUrl/ai-suggestions/').replace(
        queryParameters: {
          'household_id': householdId,
          'member_id': memberId,
          'limit': limit.toString(),
          'offset': offset.toString(),
        },
      );

      print('📋 Get AI Suggestion Logs Request:');
      print('  Household ID: $householdId');
      print('  Member ID: $memberId');
      print('  Limit: $limit, Offset: $offset');

      final response = await http.get(uri, headers: headers);

      print('📋 Get AI Suggestion Logs Response:');
      print('  Status: ${response.statusCode}');
      print('  Body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        } else if (data is Map<String, dynamic> && data.containsKey('results')) {
          return List<Map<String, dynamic>>.from(data['results']);
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to get AI suggestion logs: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error getting AI suggestion logs: $e');
      rethrow;
    }
  }
}
