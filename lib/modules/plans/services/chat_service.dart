import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../config/environment.dart';
import '../models/plan_models.dart';

/// Service for chat functionality with OpenAI integration
class ChatService {
  static final String _baseUrl = Environment.apiUrl;

  /// Get auth token
  static Future<String> _getToken() async {
    final session = Supabase.instance.client.auth.currentSession;
    return session?.accessToken ?? '';
  }

  /// Send a chat message to OpenAI and get a response
  static Future<PlanMessage> sendChatMessage({
    required String planId,
    required String message,
    required String householdId,
    required List<String> participantNames,
    String? memberId,
    String? idempotencyKey,
  }) async {
    try {
      // Validate required parameters
      if (planId.isEmpty) {
        throw Exception('Plan ID cannot be empty');
      }
      if (message.isEmpty) {
        throw Exception('Message cannot be empty');
      }
      if (householdId.isEmpty) {
        throw Exception('Household ID cannot be empty');
      }
      
      final token = await _getToken();
      if (token.isEmpty) {
        throw Exception('Authentication token is missing');
      }
      
      final url = '$_baseUrl/morgan/chat/';
      
      final requestBody = {
        'plan_id': planId,
        'message': message,
        'member_id': memberId,
        'household_id': householdId,
        'participant_names': participantNames,
        if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      };
      
      print('💬 Chat Request:');
      print('  URL: $url');
      print('  Plan ID: $planId');
      print('  Message: $message');
      print('  Member ID: $memberId');
      if (idempotencyKey != null) print('  Idempotency: $idempotencyKey');
      print('  Participants: $participantNames');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      print('📨 Chat Response:');
      print('  Status: ${response.statusCode}');
      print('  Body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Return Morgan's response directly
        return PlanMessage(
          id: 'morgan-${DateTime.now().millisecondsSinceEpoch}',
          planId: planId,
          authorType: 'morgan',
          bodyMd: data['message_body'] ?? 'No response from Morgan',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      } else {
        throw Exception('Failed to send chat message: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error sending chat message: $e');
      rethrow;
    }
  }

  /// Get chat history for a plan
  static Future<List<PlanMessage>> getChatHistory({
    required String planId,
    int limit = 50,
  }) async {
    try {
      final token = await _getToken();
      final url = '$_baseUrl/morgan/suggestions/';
      
      final response = await http.get(
        Uri.parse('$url?plan_id=$planId&limit=$limit'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Morgan suggestions endpoint returns different format, 
        // so we'll return empty list for now since chat history 
        // might be stored differently
        return [];
      } else {
        throw Exception('Failed to get chat history: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error getting chat history: $e');
      rethrow;
    }
  }
}
