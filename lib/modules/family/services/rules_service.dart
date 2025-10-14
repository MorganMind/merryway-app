import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../config/environment.dart';
import '../models/rule_models.dart';

class RulesService {
  final String baseUrl = Environment.apiUrl;
  final _supabase = Supabase.instance.client;

  /// Get auth token for API requests
  Future<String?> _getAuthToken() async {
    final session = _supabase.auth.currentSession;
    return session?.accessToken;
  }

  /// Get auth headers
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // =============================================
  // MEMBER RULES
  // =============================================

  /// Get all rules for a member
  Future<List<MemberRule>> getMemberRules(String memberId) async {
    final headers = await _getHeaders();

    final response = await http.get(
      Uri.parse('$baseUrl/rules/member/?member_id=$memberId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return (data['rules'] as List)
          .map((r) => MemberRule.fromJson(r))
          .toList();
    } else {
      throw Exception('Failed to get member rules: ${response.body}');
    }
  }

  /// Add a rule for a member
  Future<MemberRule> addMemberRule({
    required String memberId,
    required String ruleText,
    String? category,
  }) async {
    final headers = await _getHeaders();

    final response = await http.post(
      Uri.parse('$baseUrl/rules/member/add/'),
      headers: headers,
      body: jsonEncode({
        'member_id': memberId,
        'rule_text': ruleText,
        if (category != null) 'category': category,
      }),
    );

    if (response.statusCode == 201) {
      return MemberRule.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add member rule: ${response.body}');
    }
  }

  /// Delete a member rule
  Future<void> deleteMemberRule(String ruleId) async {
    final headers = await _getHeaders();

    final response = await http.delete(
      Uri.parse('$baseUrl/rules/member/delete/?rule_id=$ruleId'),
      headers: headers,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete rule: ${response.body}');
    }
  }

  // =============================================
  // POD RULES
  // =============================================

  /// Get all rules for a pod
  Future<List<PodRule>> getPodRules(String podId) async {
    final headers = await _getHeaders();

    final response = await http.get(
      Uri.parse('$baseUrl/rules/pod/?pod_id=$podId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return (data['rules'] as List).map((r) => PodRule.fromJson(r)).toList();
    } else {
      throw Exception('Failed to get pod rules: ${response.body}');
    }
  }

  /// Add a rule for a pod
  Future<PodRule> addPodRule({
    required String podId,
    required String ruleText,
    String? category,
  }) async {
    final headers = await _getHeaders();

    final response = await http.post(
      Uri.parse('$baseUrl/rules/pod/add/'),
      headers: headers,
      body: jsonEncode({
        'pod_id': podId,
        'rule_text': ruleText,
        if (category != null) 'category': category,
      }),
    );

    if (response.statusCode == 201) {
      return PodRule.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add pod rule: ${response.body}');
    }
  }

  /// Delete a pod rule
  Future<void> deletePodRule(String ruleId) async {
    final headers = await _getHeaders();

    final response = await http.delete(
      Uri.parse('$baseUrl/rules/pod/delete/?rule_id=$ruleId'),
      headers: headers,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete rule: ${response.body}');
    }
  }

  // =============================================
  // POD-AWARE SUGGESTIONS
  // =============================================

  /// Get suggestions for a specific pod
  Future<Map<String, dynamic>> getSuggestionsForPod({
    required String householdId,
    required List<String> podMemberIds,
    required String weather,
    required String timeBucket,
    required String dayOfWeek,
    String? customPrompt,
    String? podId,
  }) async {
    final headers = await _getHeaders();

    final response = await http.post(
      Uri.parse('$baseUrl/suggestions/pod/'),
      headers: headers,
      body: jsonEncode({
        'household_id': householdId,
        'pod_member_ids': podMemberIds,
        'weather': weather,
        'time_bucket': timeBucket,
        'day_of_week': dayOfWeek,
        if (customPrompt != null) 'custom_prompt': customPrompt,
        if (podId != null) 'pod_id': podId,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to get pod suggestions: ${response.body}');
    }
  }

  // =============================================
  // SMART LOCATION SUGGESTIONS
  // =============================================

  /// Get smart suggestion feed (fetch existing suggestions)
  Future<Map<String, dynamic>?> getSmartSuggestion({
    required String householdId,
    required String locationLabel,
    required List<String> nearbyMemberIds,
    required String timeBucket,
    required String dayType,
    required String dayOfWeek,
    required double confidence,
    required List<String> signalsUsed,
    required String reason,
    required String weather,
  }) async {
    print('🔵 RulesService.getSmartSuggestion called');
    print('  baseUrl: $baseUrl');
    print('  householdId: $householdId');
    
    final headers = await _getHeaders();
    print('  headers: $headers');

    try {
      // GET existing smart suggestions from feed
      final url = '$baseUrl/smart-suggestion/feed/?household_id=$householdId&limit=10';
      print('  GET URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('🔵 Response received:');
      print('  statusCode: ${response.statusCode}');
      print('  body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('  decoded data: $data');
        
        // Check if response has "suggestions" array
        if (data is Map && data.containsKey('suggestions')) {
          final suggestions = data['suggestions'] as List;
          
          if (suggestions.isNotEmpty) {
            final firstSuggestion = suggestions[0] as Map<String, dynamic>;
            print('✅ Found ${suggestions.length} suggestions, returning first one');
            print('  First suggestion: $firstSuggestion');
            
            // Format it to match expected structure
            return {
              'success': true,
              'activity': {
                'activity': firstSuggestion['suggested_activity_title'] ?? firstSuggestion['activity_title'] ?? 'Activity',
                'rationale': firstSuggestion['reason'] ?? 'Smart suggestion based on your context',
                'tags': [],
                'duration_minutes': 30,
              },
              'location_label': firstSuggestion['location_label'] ?? locationLabel,
              'member_ids': List<String>.from(firstSuggestion['member_ids'] ?? nearbyMemberIds),
              'reason': firstSuggestion['reason'] ?? reason,
              'log_id': firstSuggestion['id'],
            };
          } else {
            print('❌ Suggestions array is empty');
            return null;
          }
        } else if (data is List && data.isNotEmpty) {
          // Direct list of suggestions
          final firstSuggestion = data[0] as Map<String, dynamic>;
          print('✅ Found ${data.length} suggestions (direct list), returning first one');
          
          return {
            'success': true,
            'activity': {
              'activity': firstSuggestion['suggested_activity_title'] ?? firstSuggestion['activity_title'] ?? 'Activity',
              'rationale': firstSuggestion['reason'] ?? 'Smart suggestion based on your context',
              'tags': [],
              'duration_minutes': 30,
            },
            'location_label': firstSuggestion['location_label'] ?? locationLabel,
            'member_ids': List<String>.from(firstSuggestion['member_ids'] ?? nearbyMemberIds),
            'reason': firstSuggestion['reason'] ?? reason,
            'log_id': firstSuggestion['id'],
          };
        } else if (data is Map && data['success'] == true) {
          // Backend returned success with data
          print('✅ Success response from backend');
          return data as Map<String, dynamic>;
        } else {
          print('❌ No suggestions found in feed');
          return null;
        }
      } else {
        print('❌ Status code not 200: ${response.statusCode}');
        throw Exception('Failed to get smart suggestion: ${response.body}');
      }
    } catch (e) {
      print('❌ Exception caught: $e');
      rethrow;
    }
  }

  /// Log user action on smart suggestion
  Future<void> logSmartSuggestionAction({
    required String logId,
    required String action, // 'dismissed' or 'activated'
  }) async {
    final headers = await _getHeaders();

    final response = await http.post(
      Uri.parse('$baseUrl/smart-suggestion/action/'),
      headers: headers,
      body: jsonEncode({
        'log_id': logId,
        'action': action,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to log action: ${response.body}');
    }
  }

  // =============================================
  // LOCATION PRIVACY SETTINGS
  // =============================================

  /// Get location privacy settings for a member
  Future<Map<String, dynamic>> getLocationPrivacy(String memberId) async {
    final headers = await _getHeaders();

    final response = await http.get(
      Uri.parse('$baseUrl/location/privacy/?member_id=$memberId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to get privacy settings: ${response.body}');
    }
  }

  /// Update location privacy settings for a member
  Future<void> setLocationPrivacy({
    required String memberId,
    required bool locationSharingEnabled,
    required bool bluetoothDetectionEnabled,
    required bool wifiDetectionEnabled,
    required bool autoSuggestionsEnabled,
  }) async {
    final headers = await _getHeaders();

    final response = await http.post(
      Uri.parse('$baseUrl/location/privacy/'),
      headers: headers,
      body: jsonEncode({
        'member_id': memberId,
        'location_sharing_enabled': locationSharingEnabled,
        'bluetooth_detection_enabled': bluetoothDetectionEnabled,
        'wifi_detection_enabled': wifiDetectionEnabled,
        'auto_suggestions_enabled': autoSuggestionsEnabled,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to set privacy settings: ${response.body}');
    }
  }
}

