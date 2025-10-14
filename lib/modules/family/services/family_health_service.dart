import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/family_health_models.dart';

class FamilyHealthService {
  final String baseUrl;
  final String Function() getToken;

  FamilyHealthService({
    required this.baseUrl,
    required this.getToken,
  });

  Future<FamilyHealthMetrics?> getFamilyHealthMetrics({
    required String householdId,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/family-health/metrics/').replace(
        queryParameters: {
          'household_id': householdId,
        },
      );

      print('🔵 Fetching family health metrics...');
      print('  URL: $uri');
      print('  Token: ${getToken().substring(0, 20)}...');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${getToken()}',
          'Content-Type': 'application/json',
        },
      );

      print('  Response status: ${response.statusCode}');
      print('  Response body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Successfully parsed metrics data');
        return FamilyHealthMetrics.fromJson(data);
      } else {
        print('❌ Error: Status ${response.statusCode}');
        print('   Body: ${response.body}');
        return null;
      }
    } catch (e, stackTrace) {
      print('❌ Exception fetching family health metrics: $e');
      print('   Stack trace: $stackTrace');
      return null;
    }
  }

  Future<List<Achievement>> getAchievements({
    required String householdId,
    bool unlockedOnly = false,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/family-health/achievements/').replace(
        queryParameters: {
          'household_id': householdId,
          'unlocked_only': unlockedOnly.toString(),
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${getToken()}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data
            .map((a) => Achievement.fromJson(a as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching achievements: $e');
      return [];
    }
  }

  Future<List<Milestone>> getMilestones({
    required String householdId,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/family-health/milestones/').replace(
        queryParameters: {
          'household_id': householdId,
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${getToken()}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data
            .map((m) => Milestone.fromJson(m as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching milestones: $e');
      return [];
    }
  }
}

