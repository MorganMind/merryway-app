import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../family/models/family_models.dart';

/// Manages the current active member context
/// - If user has auth-linked member: uses that
/// - If family mode enabled: uses switcher selection
/// - Persists switcher selection across sessions
class UserContextService {
  static const String _switcherKey = 'selected_member_id';
  
  /// Get the current active member ID
  /// Priority:
  /// 1. Auth-linked member (member.user_id = auth.uid)
  /// 2. Switcher selection (if family mode enabled)
  /// 3. Null (no active member)
  static Future<String?> getCurrentMemberId({
    required List<FamilyMember> allMembers,
    required bool familyModeEnabled,
  }) async {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    
    if (currentUserId == null) return null;
    
    // Priority 1: Check if current auth user is linked to a member
    final linkedMember = allMembers.firstWhere(
      (m) => m.userId == currentUserId,
      orElse: () => const FamilyMember(name: '', age: 0, role: MemberRole.child),
    );
    
    if (linkedMember.id != null) {
      return linkedMember.id;
    }
    
    // Priority 2: If family mode enabled, use switcher selection
    if (familyModeEnabled) {
      final prefs = await SharedPreferences.getInstance();
      final selectedId = prefs.getString(_switcherKey);
      
      // Verify the selected member still exists
      if (selectedId != null && allMembers.any((m) => m.id == selectedId)) {
        return selectedId;
      }
    }
    
    // Priority 3: Default to null (caller can handle fallback)
    return null;
  }
  
  /// Set the active member via switcher (family mode only)
  static Future<void> setSelectedMember(String memberId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_switcherKey, memberId);
  }
  
  /// Get the currently selected member from switcher (persisted)
  static Future<String?> getSelectedMemberId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_switcherKey);
  }
  
  /// Clear switcher selection
  static Future<void> clearSelectedMember() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_switcherKey);
  }
  
  /// Check if current user is a parent (for permission checks)
  static bool isCurrentUserParent(
    String? currentMemberId,
    List<FamilyMember> allMembers,
  ) {
    if (currentMemberId == null) return false;
    
    final member = allMembers.firstWhere(
      (m) => m.id == currentMemberId,
      orElse: () => const FamilyMember(name: '', age: 0, role: MemberRole.child),
    );
    
    return member.isParent();
  }
  
  /// Get the current member object
  static FamilyMember? getCurrentMember(
    String? currentMemberId,
    List<FamilyMember> allMembers,
  ) {
    if (currentMemberId == null) return null;
    
    try {
      return allMembers.firstWhere((m) => m.id == currentMemberId);
    } catch (e) {
      return null;
    }
  }
}

