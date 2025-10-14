import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service to manage the default "Just Me" pod for users
class DefaultPodService {
  static const String defaultPodName = 'Just Me';
  static const String defaultPodDescription = 'On my Merryway';
  static const String defaultPodIcon = '🎒';
  static const String defaultPodColor = '#B4D7E8';

  /// Create the default "Just Me" pod for a household if it doesn't exist
  /// 
  /// This pod is created automatically for new users and can be checked/created
  /// for existing users who may not have it yet.
  /// 
  /// Returns the pod ID if created or found, null if creation failed
  static Future<String?> ensureDefaultPodExists(String householdId) async {
    try {
      final supabase = Supabase.instance.client;

      // Check if "Just Me" pod already exists for this household
      final existingPods = await supabase
          .from('pods')
          .select('id')
          .eq('household_id', householdId)
          .eq('name', defaultPodName)
          .limit(1);

      if (existingPods.isNotEmpty) {
        // Pod already exists
        return existingPods.first['id'] as String;
      }

      // Create the default pod
      final result = await supabase.from('pods').insert({
        'household_id': householdId,
        'name': defaultPodName,
        'description': defaultPodDescription,
        'member_ids': <String>[],
        'icon': defaultPodIcon,
        'color': defaultPodColor,
      }).select('id');

      if (result.isNotEmpty) {
        final podId = result.first['id'] as String;
        debugPrint('✅ Created default "Just Me" pod: $podId');
        return podId;
      }

      return null;
    } catch (e) {
      debugPrint('⚠️ Could not create default "Just Me" pod: $e');
      // Don't throw - we don't want to break the app if pod creation fails
      return null;
    }
  }

  /// Update the "Just Me" pod to include the current user's linked member
  /// 
  /// Call this when a user links their account to a family member
  static Future<void> addCurrentUserToDefaultPod({
    required String householdId,
    required String memberId,
  }) async {
    try {
      final supabase = Supabase.instance.client;

      // Find the "Just Me" pod
      final pods = await supabase
          .from('pods')
          .select('id, member_ids')
          .eq('household_id', householdId)
          .eq('name', defaultPodName)
          .limit(1);

      if (pods.isEmpty) {
        // Pod doesn't exist, create it with the member
        await supabase.from('pods').insert({
          'household_id': householdId,
          'name': defaultPodName,
          'description': defaultPodDescription,
          'member_ids': [memberId],
          'icon': defaultPodIcon,
          'color': defaultPodColor,
        });
        debugPrint('✅ Created "Just Me" pod with member: $memberId');
      } else {
        // Pod exists, add member if not already included
        final pod = pods.first;
        final memberIds = List<String>.from(pod['member_ids'] ?? []);
        
        if (!memberIds.contains(memberId)) {
          memberIds.add(memberId);
          await supabase
              .from('pods')
              .update({'member_ids': memberIds})
              .eq('id', pod['id']);
          debugPrint('✅ Added member to "Just Me" pod: $memberId');
        }
      }
    } catch (e) {
      debugPrint('⚠️ Could not update "Just Me" pod: $e');
    }
  }

  /// Remove a member from the "Just Me" pod
  /// 
  /// Call this when a user unlinks their account from a family member
  static Future<void> removeCurrentUserFromDefaultPod({
    required String householdId,
    required String memberId,
  }) async {
    try {
      final supabase = Supabase.instance.client;

      // Find the "Just Me" pod
      final pods = await supabase
          .from('pods')
          .select('id, member_ids')
          .eq('household_id', householdId)
          .eq('name', defaultPodName)
          .limit(1);

      if (pods.isNotEmpty) {
        final pod = pods.first;
        final memberIds = List<String>.from(pod['member_ids'] ?? []);
        
        if (memberIds.contains(memberId)) {
          memberIds.remove(memberId);
          await supabase
              .from('pods')
              .update({'member_ids': memberIds})
              .eq('id', pod['id']);
          debugPrint('✅ Removed member from "Just Me" pod: $memberId');
        }
      }
    } catch (e) {
      debugPrint('⚠️ Could not update "Just Me" pod: $e');
    }
  }
}

