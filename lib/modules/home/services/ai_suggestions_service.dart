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

  /// Save AI suggestions to backend
  static Future<String> saveAISuggestions({
    required String householdId,
    required String? podId,
    required String prompt,
    required Map<String, dynamic> context,
    required List<String>? participantIds,
    required List<ActivitySuggestion> suggestions,
    required String modelUsed,
  }) async {
    try {
      final headers = await _getHeaders();
      
      // Prepare suggestions data for JSON storage
      final suggestionsJson = suggestions.map((s) => {
        'activity': s.activity,
        'rationale': s.rationale,
        'duration_minutes': s.durationMinutes,
        'tags': s.tags,
        'location': s.location,
        'distance_miles': s.distanceMiles,
        'venue_type': s.venueType,
        'description': s.description,
        'attire': s.attire,
        'food_available': s.foodAvailable,
        'average_rating': s.averageRating,
        'review_count': s.reviewCount,
      }).toList();

      final requestBody = {
        'household_id': householdId,
        'pod_id': podId,
        'prompt': prompt,
        'context': context,
        'participant_ids': participantIds,
        'suggestions': suggestionsJson,
        'model_used': modelUsed,
      };

      print('🤖 Save AI Suggestions Request:');
      print('  Household ID: $householdId');
      print('  Pod ID: $podId');
      print('  Prompt: $prompt');
      print('  Suggestions count: ${suggestions.length}');

      final response = await http.post(
        Uri.parse('$_baseUrl/ai-suggestions/'),
        headers: headers,
        body: json.encode(requestBody),
      );

      print('🤖 Save AI Suggestions Response:');
      print('  Status: ${response.statusCode}');
      print('  Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['id'] ?? data['log_id'] ?? 'unknown';
      } else {
        throw Exception('Failed to save AI suggestions: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error saving AI suggestions: $e');
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
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final headers = await _getHeaders();
      
      final uri = Uri.parse('$_baseUrl/ai-suggestions/').replace(
        queryParameters: {
          'household_id': householdId,
          'limit': limit.toString(),
          'offset': offset.toString(),
        },
      );

      print('📋 Get AI Suggestion Logs Request:');
      print('  Household ID: $householdId');
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
