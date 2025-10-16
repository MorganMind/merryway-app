import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../config/environment.dart';

/// Service for "Why This?" voice persuasion feature
class WhyThisService {
  static final String _baseUrl = Environment.apiUrl;

  /// Generate "Why This?" rationale for a suggestion
  static Future<WhyThisResponse> generateRationale({
    required String suggestionId,
    required String shownSetId,
    required String householdId,
    required List<ParticipantInfo> participants,
    required bool kidMode,
    Map<String, dynamic>? contextOverride,
  }) async {
    try {
      final token = await _getToken();
      final url = '$_baseUrl/suggestions/$suggestionId/why-this/';
      final requestBody = {
        'shown_set_id': shownSetId,
        'household_id': householdId,
        'participants': participants.map((p) => p.toJson()).toList(),
        'kid_mode': kidMode,
        if (contextOverride != null) 'context_override': contextOverride,
      };
      
      print('🌐 Why This Request:');
      print('  URL: $url');
      print('  Suggestion ID: $suggestionId');
      print('  Household ID: $householdId');
      print('  Participants: ${participants.length}');
      print('  Kid Mode: $kidMode');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      print('📨 Why This Response:');
      print('  Status: ${response.statusCode}');
      print('  Body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WhyThisResponse.fromJson(data);
      } else {
        throw Exception('Failed to generate rationale: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error generating rationale: $e');
      rethrow;
    }
  }

  /// Log user action for analytics
  static Future<void> logAction({
    required String suggestionId,
    required String action,
    required String shownSetId,
    String? podId,
    bool? kidMode,
    int? durationPlayedMs,
  }) async {
    try {
      final token = await _getToken();
      await http.post(
        Uri.parse('$_baseUrl/suggestions/$suggestionId/why-this/action/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'action': action,
          'shown_set_id': shownSetId,
          if (podId != null) 'pod_id': podId,
          if (kidMode != null) 'kid_mode': kidMode,
          if (durationPlayedMs != null) 'duration_played_ms': durationPlayedMs,
        }),
      );
    } catch (e) {
      print('Error logging action: $e');
      // Don't rethrow - analytics failures shouldn't block UI
    }
  }

  /// Retry "Why This?" rationale generation
  static Future<WhyThisResponse> retryRationale({
    required String suggestionId,
    required String shownSetId,
    required String householdId,
    required List<ParticipantInfo> participants,
    required bool kidMode,
    Map<String, dynamic>? contextOverride,
  }) async {
    try {
      final token = await _getToken();
      final url = '$_baseUrl/suggestions/$suggestionId/why-this-retry/';
      final requestBody = {
        'shown_set_id': shownSetId,
        'household_id': householdId,
        'participants': participants.map((p) => p.toJson()).toList(),
        'kid_mode': kidMode,
        if (contextOverride != null) 'context_override': contextOverride,
      };
      
      print('🔄 Why This Retry Request:');
      print('  URL: $url');
      print('  Suggestion ID: $suggestionId');
      print('  Household ID: $householdId');
      print('  Participants: ${participants.length}');
      print('  Kid Mode: $kidMode');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      print('📨 Why This Retry Response:');
      print('  Status: ${response.statusCode}');
      print('  Body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WhyThisResponse.fromJson(data);
      } else {
        throw Exception('Failed to retry rationale: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error retrying rationale: $e');
      rethrow;
    }
  }

  static Future<String> _getToken() async {
    final session = Supabase.instance.client.auth.currentSession;
    return session?.accessToken ?? '';
  }
}

/// Response from "Why This?" API
class WhyThisResponse {
  final String? audioUrl;
  final String transcript;
  final String rationaleLine;
  final String? altSuggestionId;

  WhyThisResponse({
    required this.audioUrl,
    required this.transcript,
    required this.rationaleLine,
    this.altSuggestionId,
  });

  factory WhyThisResponse.fromJson(Map<String, dynamic> json) {
    return WhyThisResponse(
      audioUrl: json['audio_url'],
      transcript: json['transcript'] ?? '',
      rationaleLine: json['rationale_line'] ?? '',
      altSuggestionId: json['alt_suggestion_id'],
    );
  }
}

/// Participant information for "Why This?" generation
class ParticipantInfo {
  final String memberId;
  final String ageRange;
  final String role;

  ParticipantInfo({
    required this.memberId,
    required this.ageRange,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'member_id': memberId,
      'age_range': ageRange,
      'role': role,
    };
  }
}

/// Action types for analytics logging
class WhyThisAction {
  static const String opened = 'why_opened';
  static const String audioStarted = 'why_audio_started';
  static const String audioCompleted = 'why_audio_completed';
  static const String actionStart = 'why_action_start';
  static const String actionSave = 'why_action_save';
  static const String actionAlt = 'why_action_alt';
  static const String dismissed = 'why_dismissed';
  static const String regret = 'why_regret';
}

