import 'package:supabase_flutter/supabase_flutter.dart';

/// Service to manage suggestion feedback persistence (love, neutral, not interested)
class SuggestionFeedbackService {
  static final _supabase = Supabase.instance.client;

  /// Save feedback for a suggestion
  /// feedbackType: 'love', 'neutral', 'not_interested'
  static Future<void> saveFeedback({
    required String householdId,
    required String memberId,
    required String activityName,
    required String feedbackType,
  }) async {
    try {
      // Upsert feedback (insert or update if exists)
      await _supabase.from('suggestion_feedback').upsert({
        'household_id': householdId,
        'member_id': memberId,
        'activity_name': activityName.toLowerCase().trim(),
        'feedback_type': feedbackType,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'household_id,member_id,activity_name');
      
      print('✅ Feedback saved: $activityName -> $feedbackType (member: $memberId)');
    } catch (e) {
      print('❌ Error saving feedback: $e');
      // Don't throw - feedback is non-critical
    }
  }

  /// Load all feedback for a household and member
  /// Returns a map: activityName -> feedbackType
  static Future<Map<String, String>> loadFeedback({
    required String householdId,
    required String memberId,
  }) async {
    try {
      final response = await _supabase
          .from('suggestion_feedback')
          .select('activity_name, feedback_type')
          .eq('household_id', householdId)
          .eq('member_id', memberId);

      final Map<String, String> feedbackMap = {};
      
      for (var row in response) {
        final activityName = row['activity_name'] as String?;
        final feedbackType = row['feedback_type'] as String?;
        
        if (activityName != null && feedbackType != null) {
          feedbackMap[activityName] = feedbackType;
        }
      }

      print('✅ Loaded ${feedbackMap.length} feedback entries for member $memberId');
      return feedbackMap;
    } catch (e) {
      print('❌ Error loading feedback: $e');
      return {};
    }
  }
}

