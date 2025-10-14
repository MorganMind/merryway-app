import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../config/environment.dart';
import '../models/idea_models.dart';

class IdeasApiService {
  final String baseUrl = Environment.apiUrl;

  Future<Map<String, String>> _getHeaders() async {
    final supabase = Supabase.instance.client;
    final token = supabase.auth.currentSession?.accessToken ?? '';
    
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  // Create Idea
  Future<Idea> createIdea(Idea idea) async {
    print('🔵 IdeasApiService.createIdea called');
    print('  baseUrl: $baseUrl');
    print('  title: ${idea.title}');
    
    final headers = await _getHeaders();
    final url = '$baseUrl/ideas/';
    print('  POST URL: $url');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(idea.toJson()),
      );

      print('🔵 Response received:');
      print('  statusCode: ${response.statusCode}');
      print('  body: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('✅ Idea created successfully');
        return Idea.fromJson(data);
      } else {
        print('❌ Error creating idea: ${response.statusCode}');
        throw Exception('Failed to create idea: ${response.body}');
      }
    } catch (e) {
      print('❌ Exception: $e');
      rethrow;
    }
  }

  // Update Idea
  Future<Idea> updateIdea(String ideaId, Map<String, dynamic> updates) async {
    print('🔵 IdeasApiService.updateIdea called');
    print('  ideaId: $ideaId');
    print('  updates: $updates');
    
    final headers = await _getHeaders();
    final url = '$baseUrl/ideas/$ideaId/';
    print('  PATCH URL: $url');

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(updates),
      );

      print('🔵 Response received:');
      print('  statusCode: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Idea updated successfully');
        return Idea.fromJson(data);
      } else {
        print('❌ Error updating idea: ${response.statusCode}');
        throw Exception('Failed to update idea: ${response.body}');
      }
    } catch (e) {
      print('❌ Exception: $e');
      rethrow;
    }
  }

  // Get Idea by ID
  Future<Idea> getIdea(String ideaId) async {
    print('🔵 IdeasApiService.getIdea called');
    print('  ideaId: $ideaId');
    
    final headers = await _getHeaders();
    final url = '$baseUrl/ideas/$ideaId/';
    print('  GET URL: $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('🔵 Response received:');
      print('  statusCode: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Idea fetched successfully');
        return Idea.fromJson(data);
      } else {
        print('❌ Error fetching idea: ${response.statusCode}');
        throw Exception('Failed to fetch idea: ${response.body}');
      }
    } catch (e) {
      print('❌ Exception: $e');
      rethrow;
    }
  }

  // List Ideas (with filters)
  Future<List<Idea>> listIdeas({
    required String householdId,
    IdeaState? state,
    IdeaVisibility? visibility,
    String? podId,
    String? search,
    String? creatorMemberId,
  }) async {
    print('🔵 IdeasApiService.listIdeas called');
    print('  householdId: $householdId');
    
    final headers = await _getHeaders();
    final queryParams = <String, String>{
      'household_id': householdId,
    };

    if (state != null) {
      queryParams['state'] = state.toDbString();
    }
    if (visibility != null) {
      queryParams['visibility'] = visibility.toDbString();
    }
    if (podId != null) {
      queryParams['pod_id'] = podId;
    }
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (creatorMemberId != null) {
      queryParams['creator_member_id'] = creatorMemberId;
    }

    final url = Uri.parse('$baseUrl/ideas/').replace(queryParameters: queryParams);
    print('  GET URL: $url');

    try {
      final response = await http.get(
        url,
        headers: headers,
      );

      print('🔵 Response received:');
      print('  statusCode: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        print('✅ Fetched ${data.length} ideas');
        return data.map((json) => Idea.fromJson(json)).toList();
      } else {
        print('❌ Error fetching ideas: ${response.statusCode}');
        throw Exception('Failed to fetch ideas: ${response.body}');
      }
    } catch (e) {
      print('❌ Exception: $e');
      rethrow;
    }
  }

  // Like Idea
  Future<void> likeIdea(String ideaId, String memberId) async {
    print('🔵 IdeasApiService.likeIdea called');
    print('  ideaId: $ideaId');
    
    final headers = await _getHeaders();
    final url = '$baseUrl/ideas/$ideaId/like/';
    print('  POST URL: $url');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({'member_id': memberId}),
      );

      print('🔵 Response received:');
      print('  statusCode: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('✅ Idea liked successfully');
      } else {
        print('❌ Error liking idea: ${response.statusCode}');
        throw Exception('Failed to like idea: ${response.body}');
      }
    } catch (e) {
      print('❌ Exception: $e');
      rethrow;
    }
  }

  // Unlike Idea
  Future<void> unlikeIdea(String ideaId, String memberId) async {
    print('🔵 IdeasApiService.unlikeIdea called');
    print('  ideaId: $ideaId');
    
    final headers = await _getHeaders();
    final url = '$baseUrl/ideas/$ideaId/like/';
    print('  DELETE URL: $url');

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );

      print('🔵 Response received:');
      print('  statusCode: ${response.statusCode}');

      if (response.statusCode == 204 || response.statusCode == 200) {
        print('✅ Idea unliked successfully');
      } else {
        print('❌ Error unliking idea: ${response.statusCode}');
        throw Exception('Failed to unlike idea: ${response.body}');
      }
    } catch (e) {
      print('❌ Exception: $e');
      rethrow;
    }
  }

  // Get Comments
  Future<List<IdeaComment>> getComments(String ideaId) async {
    print('🔵 IdeasApiService.getComments called');
    print('  ideaId: $ideaId');
    
    final headers = await _getHeaders();
    final url = '$baseUrl/ideas/$ideaId/comments/';
    print('  GET URL: $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('🔵 Response received:');
      print('  statusCode: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        print('✅ Fetched ${data.length} comments');
        return data.map((json) => IdeaComment.fromJson(json)).toList();
      } else {
        print('❌ Error fetching comments: ${response.statusCode}');
        throw Exception('Failed to fetch comments: ${response.body}');
      }
    } catch (e) {
      print('❌ Exception: $e');
      rethrow;
    }
  }

  // Post Comment
  Future<IdeaComment> postComment(IdeaComment comment) async {
    print('🔵 IdeasApiService.postComment called');
    print('  ideaId: ${comment.ideaId}');
    
    final headers = await _getHeaders();
    final url = '$baseUrl/ideas/${comment.ideaId}/comments/';
    print('  POST URL: $url');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(comment.toJson()),
      );

      print('🔵 Response received:');
      print('  statusCode: ${response.statusCode}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('✅ Comment posted successfully');
        return IdeaComment.fromJson(data);
      } else {
        print('❌ Error posting comment: ${response.statusCode}');
        throw Exception('Failed to post comment: ${response.body}');
      }
    } catch (e) {
      print('❌ Exception: $e');
      rethrow;
    }
  }

  // Update Comment
  Future<IdeaComment> updateComment(String ideaId, String commentId, String body) async {
    print('🔵 IdeasApiService.updateComment called');
    print('  commentId: $commentId');
    
    final headers = await _getHeaders();
    final url = '$baseUrl/ideas/$ideaId/comments/$commentId/';
    print('  PATCH URL: $url');

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({'body': body}),
      );

      print('🔵 Response received:');
      print('  statusCode: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Comment updated successfully');
        return IdeaComment.fromJson(data);
      } else {
        print('❌ Error updating comment: ${response.statusCode}');
        throw Exception('Failed to update comment: ${response.body}');
      }
    } catch (e) {
      print('❌ Exception: $e');
      rethrow;
    }
  }

  // Delete Comment (soft delete)
  Future<void> deleteComment(String ideaId, String commentId) async {
    print('🔵 IdeasApiService.deleteComment called');
    print('  commentId: $commentId');
    
    final headers = await _getHeaders();
    final url = '$baseUrl/ideas/$ideaId/comments/$commentId/';
    print('  DELETE URL: $url');

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );

      print('🔵 Response received:');
      print('  statusCode: ${response.statusCode}');

      if (response.statusCode == 204 || response.statusCode == 200) {
        print('✅ Comment deleted successfully');
      } else {
        print('❌ Error deleting comment: ${response.statusCode}');
        throw Exception('Failed to delete comment: ${response.body}');
      }
    } catch (e) {
      print('❌ Exception: $e');
      rethrow;
    }
  }

  // Approve Idea (parent action)
  Future<Idea> approveIdea(String ideaId, String approvingMemberId) async {
    print('🔵 IdeasApiService.approveIdea called');
    print('  ideaId: $ideaId');
    
    final headers = await _getHeaders();
    final url = '$baseUrl/ideas/$ideaId/approve/';
    print('  POST URL: $url');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({'approved_by_member_id': approvingMemberId}),
      );

      print('🔵 Response received:');
      print('  statusCode: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Idea approved successfully');
        return Idea.fromJson(data);
      } else {
        print('❌ Error approving idea: ${response.statusCode}');
        throw Exception('Failed to approve idea: ${response.body}');
      }
    } catch (e) {
      print('❌ Exception: $e');
      rethrow;
    }
  }

  // Promote Idea to Experience
  Future<Map<String, dynamic>> promoteToExperience({
    required String ideaId,
    required List<String> participantIds,
    String? startAt,
    String? place,
    String? prepNotes,
  }) async {
    print('🔵 IdeasApiService.promoteToExperience called');
    print('  ideaId: $ideaId');
    print('  participantIds: $participantIds');
    
    final headers = await _getHeaders();
    final url = '$baseUrl/ideas/$ideaId/promote-to-experience/';
    print('  POST URL: $url');

    final body = {
      'participant_ids': participantIds,
      if (startAt != null) 'start_at': startAt,
      if (place != null) 'place': place,
      if (prepNotes != null) 'prep_notes': prepNotes,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      print('🔵 Response received:');
      print('  statusCode: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Idea promoted to experience successfully');
        return data;
      } else {
        print('❌ Error promoting idea: ${response.statusCode}');
        throw Exception('Failed to promote idea: ${response.body}');
      }
    } catch (e) {
      print('❌ Exception: $e');
      rethrow;
    }
  }
}

