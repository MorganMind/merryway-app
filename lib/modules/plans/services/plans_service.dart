import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../config/environment.dart';
import '../models/plan_models.dart';

/// Service for Plans API communication
class PlansService {
  static final String _baseUrl = Environment.apiUrl;
  static final _supabase = Supabase.instance.client;

  /// Get auth token
  static Future<String> _getToken() async {
    final session = _supabase.auth.currentSession;
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

  /// Create a new plan
  static Future<Plan> createPlan(CreatePlanRequest request) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/plans/'),
      headers: headers,
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Plan.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create plan: ${response.body}');
    }
  }

  /// Get plan summaries for a household
  static Future<List<PlanSummary>> getPlanSummaries({
    required String householdId,
    String? status,
    String? search,
    int limit = 20,
  }) async {
    final headers = await _getHeaders();
    final queryParams = {
      'household_id': householdId,
      if (status != null) 'status': status,
      if (search != null) 'search': search,
      'limit': limit.toString(),
    };

    final uri = Uri.parse('$_baseUrl/plans/')
        .replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      
      // Handle both array and object responses
      List<dynamic> data;
      if (decoded is List) {
        data = decoded;
      } else if (decoded is Map<String, dynamic>) {
        // If backend returns {plans: [...], ...}, extract the plans array
        data = decoded['plans'] as List<dynamic>? ?? 
               decoded['data'] as List<dynamic>? ?? 
               [decoded]; // If single object, wrap in array
      } else {
        data = [];
      }
      
      return data.map((json) => PlanSummary.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load plans: ${response.body}');
    }
  }

  /// Get a single plan by ID
  static Future<Plan> getPlan(String planId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/plans/$planId/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return Plan.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load plan: ${response.body}');
    }
  }

  /// Get messages for a plan
  static Future<List<PlanMessage>> getPlanMessages({
    required String planId,
    int limit = 50,
    String? before,
  }) async {
    final headers = await _getHeaders();
    final queryParams = {
      'limit': limit.toString(),
      if (before != null) 'before': before,
    };

    final uri = Uri.parse('$_baseUrl/plans/$planId/messages/')
        .replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      List<dynamic> data = decoded is List ? decoded : (decoded['messages'] ?? decoded['data'] ?? [decoded]);
      return data.map((json) => PlanMessage.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load messages: ${response.body}');
    }
  }

  /// Send a message
  static Future<PlanMessage> sendMessage({
    required String planId,
    required SendMessageRequest request,
  }) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/plans/$planId/messages/'),
      headers: headers,
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return PlanMessage.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to send message: ${response.body}');
    }
  }

  /// Get proposals with votes
  static Future<List<ProposalWithVotes>> getProposals({
    required String planId,
    String? voterMemberId,
  }) async {
    final headers = await _getHeaders();
    final queryParams = {
      if (voterMemberId != null) 'voter_member_id': voterMemberId,
    };

    final uri = Uri.parse('$_baseUrl/plans/$planId/proposals/')
        .replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      List<dynamic> data = decoded is List ? decoded : (decoded['proposals'] ?? decoded['data'] ?? [decoded]);
      return data.map((json) => ProposalWithVotes.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load proposals: ${response.body}');
    }
  }

  /// Vote on a proposal
  static Future<PlanVote> voteOnProposal({
    required String proposalId,
    required VoteRequest request,
  }) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/proposals/$proposalId/vote/'),
      headers: headers,
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return PlanVote.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to vote: ${response.body}');
    }
  }

  /// Add a constraint
  static Future<PlanConstraint> addConstraint({
    required String planId,
    required AddConstraintRequest request,
  }) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/plans/$planId/constraints/'),
      headers: headers,
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return PlanConstraint.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add constraint: ${response.body}');
    }
  }

  /// Get constraints
  static Future<List<PlanConstraint>> getConstraints(String planId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/plans/$planId/constraints/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      List<dynamic> data = decoded is List ? decoded : (decoded['constraints'] ?? decoded['data'] ?? [decoded]);
      return data.map((json) => PlanConstraint.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load constraints: ${response.body}');
    }
  }

  /// Create a decision
  static Future<PlanDecision> createDecision({
    required String planId,
    String? proposalId,
    required String summaryMd,
    required String decidedByMemberId,
  }) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/plans/$planId/decision/'),
      headers: headers,
      body: json.encode({
        if (proposalId != null) 'proposal_id': proposalId,
        'summary_md': summaryMd,
        'decided_by_member_id': decidedByMemberId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return PlanDecision.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create decision: ${response.body}');
    }
  }

  /// Create or update itinerary
  static Future<PlanItinerary> createOrUpdateItinerary({
    required String planId,
    required String title,
    required List<dynamic> items,
    required String createdByMemberId,
  }) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/plans/$planId/itinerary/'),
      headers: headers,
      body: json.encode({
        'title': title,
        'items_json': items,
        'created_by_member_id': createdByMemberId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return PlanItinerary.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create/update itinerary: ${response.body}');
    }
  }

  /// Archive a plan
  static Future<void> archivePlan(String planId) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/plans/$planId/archive/'),
      headers: headers,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to archive plan: ${response.body}');
    }
  }

  /// Reopen a plan
  static Future<void> reopenPlan(String planId) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/plans/$planId/reopen/'),
      headers: headers,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to reopen plan: ${response.body}');
    }
  }

  /// Trigger Morgan action
  static Future<PlanMessage> triggerMorganAction({
    required MorganActionRequest request,
  }) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/morgan/act/'),
      headers: headers,
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return PlanMessage.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to trigger Morgan: ${response.body}');
    }
  }
}

