import 'package:dio/dio.dart';
import '../models/family_models.dart';
import 'package:get_it/get_it.dart';
import 'package:merryway/config/environment.dart';

class FamilyRepository {
  final Dio dio = GetIt.I<Dio>();
  String get baseUrl => Environment.apiUrl;

  Future<Household> createHousehold(String name) async {
    try {
      final response = await dio.post(
        '$baseUrl/household/create/',
        data: {'name': name},
      );
      return Household.fromJson(response.data);
    } catch (e) {
      throw 'Oh dear! Could not create your family home: $e';
    }
  }

  Future<Household?> getHousehold(String householdId) async {
    try {
      final response = await dio.get(
        '$baseUrl/household/',
        queryParameters: {'id': householdId},
      );
      return Household.fromJson(response.data['household']);
    } catch (e) {
      throw 'Could not find your household: $e';
    }
  }

  Future<FamilyMember> addMember(
    String householdId,
    String name,
    int age,
    String role,
    List<String> favoriteActivities,
  ) async {
    try {
      final response = await dio.post(
        '$baseUrl/household/member/add/',
        data: {
          'household_id': householdId,
          'name': name,
          'age': age,
          'role': role,
          'favorite_activities': favoriteActivities,
        },
      );
      return FamilyMember.fromJson(response.data);
    } catch (e) {
      throw 'Could not add family member: $e';
    }
  }

  Future<SuggestionsResponse> getSuggestions({
    required String householdId,
    required String weather,
    required String timeOfDay,
    required String dayOfWeek,
    String? customPrompt,
    List<String>? participants,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/suggest-activity/',
        data: {
          'household_id': householdId,
          'weather': weather,
          'time_of_day': timeOfDay,
          'day_of_week': dayOfWeek,
          if (customPrompt != null && customPrompt.isNotEmpty)
            'custom_prompt': customPrompt,
          if (participants != null && participants.isNotEmpty)
            'participants': participants,
        },
      );
      
      // Parse the response
      final suggestionsResponse = SuggestionsResponse.fromJson(response.data);
      
      // TEMPORARY: Enrich suggestions with mock data to demonstrate frontend capabilities
      // TODO: Remove this once backend provides these fields
      final enrichedSuggestions = suggestionsResponse.suggestions.map((s) {
        return ActivitySuggestion(
          activity: s.activity,
          rationale: s.rationale,
          durationMinutes: s.durationMinutes ?? 45,
          tags: s.tags,
          // MOCK ENHANCED FIELDS (frontend is ready for these!)
          location: s.location ?? 'Golden Gate Park, San Francisco',
          distanceMiles: s.distanceMiles ?? 2.3,
          attire: s.attire.isNotEmpty ? s.attire : ['comfortable clothes', 'sunscreen', 'water bottle'],
          foodAvailable: s.foodAvailable ?? {
            'available': true,
            'type': 'snacks & drinks available on-site'
          },
          description: s.description ?? 'This is a family-friendly activity perfect for all ages. Expect to spend quality time together with plenty of smiles and laughter. The atmosphere is welcoming and there are facilities nearby.',
          venueType: s.venueType ?? 'outdoor',
          averageRating: s.averageRating ?? 4.7,
          reviewCount: s.reviewCount ?? 234,
        );
      }).toList();
      
      return SuggestionsResponse(
        suggestions: enrichedSuggestions,
        context: suggestionsResponse.context,
      );
    } catch (e) {
      throw 'Could not fetch magical suggestions: $e';
    }
  }
}

