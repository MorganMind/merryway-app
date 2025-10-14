import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../config/environment.dart';
import '../models/experience_models.dart';

class ExperienceRepository {
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
  // EXPERIENCES
  // =============================================

  /// Create a new experience
  Future<Experience> createExperience(Experience experience) async {
    final headers = await _getHeaders();
    
    final response = await http.post(
      Uri.parse('$baseUrl/experiences/'),
      headers: headers,
      body: jsonEncode(experience.toJson()),
    );

    if (response.statusCode == 201) {
      return Experience.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create experience: ${response.body}');
    }
  }

  /// Update an experience
  Future<Experience> updateExperience(String experienceId, Map<String, dynamic> updates) async {
    final headers = await _getHeaders();
    
    final response = await http.patch(
      Uri.parse('$baseUrl/experiences/$experienceId/'),
      headers: headers,
      body: jsonEncode(updates),
    );

    if (response.statusCode == 200) {
      return Experience.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update experience: ${response.body}');
    }
  }

  /// Delete an experience
  Future<void> deleteExperience(String experienceId) async {
    final headers = await _getHeaders();
    
    final response = await http.delete(
      Uri.parse('$baseUrl/experiences/$experienceId/'),
      headers: headers,
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to delete experience: ${response.body}');
    }
  }

  /// Get single experience
  Future<Experience> getExperience(String experienceId) async {
    final headers = await _getHeaders();
    
    final response = await http.get(
      Uri.parse('$baseUrl/experiences/$experienceId/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return Experience.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get experience: ${response.body}');
    }
  }

  /// List experiences (using Supabase directly for performance)
  Future<List<Experience>> listExperiences(String householdId, {String? status}) async {
    final response = status != null
        ? await _supabase
            .from('experiences')
            .select()
            .eq('household_id', householdId)
            .eq('status', status)
            .order('created_at', ascending: false)
        : await _supabase
            .from('experiences')
            .select()
            .eq('household_id', householdId)
            .order('created_at', ascending: false);

    return (response as List).map((json) => Experience.fromJson(json)).toList();
  }

  // =============================================
  // REVIEWS
  // =============================================

  /// Create a review for an experience
  Future<ExperienceReview> createReview(ExperienceReview review) async {
    final headers = await _getHeaders();
    
    final response = await http.post(
      Uri.parse('$baseUrl/experiences/${review.experienceId}/reviews/'),
      headers: headers,
      body: jsonEncode(review.toJson()),
    );

    if (response.statusCode == 201) {
      return ExperienceReview.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create review: ${response.body}');
    }
  }

  /// Get reviews for an experience (using Supabase directly for performance)
  Future<List<ExperienceReview>> getReviews(String experienceId) async {
    final response = await _supabase
        .from('experience_reviews')
        .select()
        .eq('experience_id', experienceId)
        .order('created_at', ascending: false);

    return (response as List).map((json) => ExperienceReview.fromJson(json)).toList();
  }

  // =============================================
  // MERRY MOMENTS
  // =============================================

  /// Create a merry moment
  Future<MerryMoment> createMerryMoment(MerryMoment moment) async {
    print('🔵 ExperienceRepository.createMerryMoment called');
    print('  household_id: ${moment.householdId}');
    print('  title: ${moment.title}');
    
    final headers = await _getHeaders();
    final body = jsonEncode(moment.toJson());
    
    print('  Request body: $body');
    print('  POST URL: $baseUrl/merry-moments/');
    
    final response = await http.post(
      Uri.parse('$baseUrl/merry-moments/'),
      headers: headers,
      body: body,
    );

    print('🔵 Response received:');
    print('  statusCode: ${response.statusCode}');
    print('  body: ${response.body}');

    if (response.statusCode == 201) {
      print('✅ Merry moment created successfully');
      return MerryMoment.fromJson(jsonDecode(response.body));
    } else {
      print('❌ Error creating merry moment: ${response.statusCode}');
      throw Exception('Failed to create merry moment: ${response.body}');
    }
  }

  /// List merry moments (using Supabase directly for performance)
  Future<List<MerryMoment>> listMerryMoments(String householdId) async {
    final response = await _supabase
        .from('merry_moments')
        .select()
        .eq('household_id', householdId)
        .order('occurred_at', ascending: false);

    return (response as List).map((json) => MerryMoment.fromJson(json)).toList();
  }

  /// Get single merry moment (using Supabase directly)
  Future<MerryMoment> getMerryMoment(String momentId) async {
    final response = await _supabase
        .from('merry_moments')
        .select()
        .eq('id', momentId)
        .single();

    return MerryMoment.fromJson(response);
  }

  // =============================================
  // MEDIA
  // =============================================

  /// Upload media (multipart form data)
  Future<MediaItem> uploadMedia({
    required String householdId,
    required String filePath,
    String? merryMomentId,
    String? experienceId,
    String? caption,
  }) async {
    final token = await _getAuthToken();
    
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/media/upload/'),
    );

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.fields['household_id'] = householdId;
    if (merryMomentId != null) request.fields['merry_moment_id'] = merryMomentId;
    if (experienceId != null) request.fields['experience_id'] = experienceId;
    if (caption != null) request.fields['caption'] = caption;

    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      return MediaItem.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to upload media: ${response.body}');
    }
  }

  // Web-compatible upload using bytes
  Future<MediaItem> uploadMediaBytes({
    required String householdId,
    required List<int> fileBytes,
    required String fileName,
    String? merryMomentId,
    String? experienceId,
    String? caption,
  }) async {
    final token = await _getAuthToken();
    
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/media/upload/'),
    );

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.fields['household_id'] = householdId;
    if (merryMomentId != null) request.fields['merry_moment_id'] = merryMomentId;
    if (experienceId != null) request.fields['experience_id'] = experienceId;
    if (caption != null) request.fields['caption'] = caption;

    // Use fromBytes instead of fromPath - works on web
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      fileBytes,
      filename: fileName,
    ));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      return MediaItem.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to upload media: ${response.body}');
    }
  }
}

