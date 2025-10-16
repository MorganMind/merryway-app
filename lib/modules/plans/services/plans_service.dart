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
    // Validate required parameters
    if (request.householdId.isEmpty) {
      throw Exception('Household ID cannot be empty');
    }
    if (request.title.isEmpty) {
      throw Exception('Plan title cannot be empty');
    }
    
    final headers = await _getHeaders();
    
    // Prepare request body with validation
    final requestBody = {
      'household_id': request.householdId,
      'title': request.title,
      'member_ids': request.memberIds.where((id) => id.isNotEmpty).toList(), // Filter out empty IDs
      if (request.seedProposal != null) 'seed_proposal': request.seedProposal,
    };
    
    print('📝 Create Plan Request:');
    print('  Household ID: ${request.householdId}');
    print('  Title: ${request.title}');
    print('  Member IDs: ${request.memberIds}');
    print('  Request Body: $requestBody');
    
    final response = await http.post(
      Uri.parse('$_baseUrl/plans/'),
      headers: headers,
      body: json.encode(requestBody),
    );

    print('📝 Create Plan Response:');
    print('  Status: ${response.statusCode}');
    print('  Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Plan.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create plan: ${response.statusCode} - ${response.body}');
    }
  }

  /// Get plan summaries for a household
  static Future<List<PlanSummary>> getPlanSummaries({
    required String householdId,
    required String memberId,
    String? status,
    String? search,
    int limit = 20,
  }) async {
    // Validate required parameters
    if (householdId.isEmpty) {
      throw Exception('Household ID cannot be empty');
    }
    if (memberId.isEmpty) {
      throw Exception('Member ID cannot be empty');
    }
    
    final headers = await _getHeaders();
    final queryParams = {
      'household_id': householdId,
      'member_id': memberId,
      if (status != null) 'status': status,
      if (search != null) 'search': search,
      'limit': limit.toString(),
    };

    final uri = Uri.parse('$_baseUrl/plans/')
        .replace(queryParameters: queryParams);

    print('📋 Get Plans Request:');
    print('  URL: $uri');
    print('  Household ID: $householdId');
    print('  Member ID: $memberId');
    print('  Status: $status');
    print('  Search: $search');

    final response = await http.get(uri, headers: headers);

    print('📋 Get Plans Response:');
    print('  Status: ${response.statusCode}');
    print('  Body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');

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
      final messages = data.map((json) => PlanMessage.fromJson(json as Map<String, dynamic>)).toList();
      
      // Sort messages by createdAt (oldest first)
      messages.sort((a, b) {
        final aTime = a.createdAt ?? DateTime(1970);
        final bTime = b.createdAt ?? DateTime(1970);
        return aTime.compareTo(bTime);
      });
      
      return messages;
    } else {
      throw Exception('Failed to load messages: ${response.body}');
    }
  }

  /// Invite an existing household member to a plan
  static Future<bool> inviteMemberToPlan({
    required String planId,
    required String memberId,
  }) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$_baseUrl/plans/$planId/invite/');
    final response = await http.post(
      uri,
      headers: headers,
      body: json.encode({ 'invitee_member_id': memberId }),
    );

    // 200 OK or 201 Created; backend may also return success for already-in-plan
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }

    // Pass through error to caller
    throw Exception('Invite failed: ${response.statusCode} - ${response.body}');
  }

  /// Invite an external person by email to a plan
  static Future<bool> externalInviteToPlan({
    required String planId,
    required String email,
  }) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$_baseUrl/plans/$planId/external-invite/');
    final response = await http.post(
      uri,
      headers: headers,
      body: json.encode({ 'email': email }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }
    throw Exception('External invite failed: ${response.statusCode} - ${response.body}');
  }

  /// Get owner share code for a plan
  static Future<String> getShareCode(String planId) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$_baseUrl/plans/$planId/share-code/');
    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      return (body['code'] ?? body['share_code'] ?? '').toString();
    }
    throw Exception('Failed to get share code: ${response.statusCode} - ${response.body}');
  }

  /// Join a plan by code (recipient)
  static Future<bool> joinByCode(String code) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$_baseUrl/plans/join-by-code/');
    final response = await http.post(
      uri,
      headers: headers,
      body: json.encode({ 'code': code }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) return true;
    throw Exception('Failed to join by code: ${response.statusCode} - ${response.body}');
  }

  static Future<List<Map<String, dynamic>>> getPlanParticipants(String planId) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$_baseUrl/plans/$planId/participants/');
    final response = await http.get(uri, headers: headers);
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(data['participants'] ?? []);
    } else if (response.statusCode == 404) {
      // Endpoint doesn't exist yet, return empty list
      print('⚠️ Plan participants endpoint not implemented yet, returning empty list');
      return [];
    }
    throw Exception('Failed to get plan participants: ${response.statusCode} - ${response.body}');
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

  /// Update a plan
  static Future<Plan> updatePlan(String planId, {String? title, String? status}) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$_baseUrl/plans/$planId/');
    
    final requestBody = <String, dynamic>{};
    if (title != null) requestBody['title'] = title;
    if (status != null) requestBody['status'] = status;
    
    print('📝 Update Plan Request:');
    print('  Plan ID: $planId');
    print('  Title: $title');
    print('  Status: $status');
    
    final response = await http.patch(
      uri,
      headers: headers,
      body: json.encode(requestBody),
    );
    
    print('📝 Update Plan Response:');
    print('  Status: ${response.statusCode}');
    print('  Body: ${response.body}');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return Plan.fromJson(data);
    } else {
      // Handle HTML error responses (like 500 errors)
      String errorMessage = 'Failed to update plan: ${response.statusCode}';
      if (response.body.contains('<!DOCTYPE html>')) {
        errorMessage = 'Server error (${response.statusCode}) - please try again later';
      } else {
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['error'] ?? errorData['message'] ?? errorMessage;
        } catch (e) {
          // If response is not JSON, use the raw body (truncated)
          errorMessage = '${response.statusCode}: ${response.body.length > 100 ? response.body.substring(0, 100) + '...' : response.body}';
        }
      }
      throw Exception(errorMessage);
    }
  }

  /// Delete a plan
  static Future<void> deletePlan(String planId) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$_baseUrl/plans/$planId/delete/'),
      headers: headers,
    );

    print('🗑️ Delete Plan Request:');
    print('  Plan ID: $planId');
    print('  Status: ${response.statusCode}');
    print('  Body: ${response.body}');

    if (response.statusCode == 200) {
      print('✅ Plan deleted successfully');
    } else {
      throw Exception('Failed to delete plan: ${response.statusCode} - ${response.body}');
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

  /// Get itinerary for a plan
  static Future<PlanItinerary?> getItinerary(String planId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/plans/$planId/itinerary/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final contentType = response.headers['content-type'] ?? '';
      final raw = response.body;
      // Some backends return HTML error pages; guard before JSON decode
      if (!contentType.contains('application/json') && !(raw.trim().startsWith('{') || raw.trim().startsWith('['))) {
        // Not JSON; treat as no itinerary
        print('getItinerary: non-JSON response, ignoring');
        return null;
      }
      final body = json.decode(raw);
      if (body == null || body.toString() == 'null') return null;
      return PlanItinerary.fromJson(body);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      // Soft-fail: log and return null to avoid breaking UI
      print('Failed to get itinerary (${response.statusCode}): ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
      return null;
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

