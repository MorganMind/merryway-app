import 'package:shared_preferences/shared_preferences.dart';
import '../../family/models/family_models.dart';

/// Service to manage the currently active family member
/// 
/// Used for:
/// - User switcher (Netflix-style profile selection)
/// - Determining who's using the device
/// - Permission checks based on current user's role
class UserContextService {
  static const String _currentMemberIdKey = 'current_member_id';

  /// Save the current member ID to local storage
  static Future<void> saveCurrentMemberId(String memberId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentMemberIdKey, memberId);
  }

  /// Load the current member ID from local storage
  static Future<String?> loadCurrentMemberId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentMemberIdKey);
  }

  /// Clear the current member ID (logout)
  static Future<void> clearCurrentMemberId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentMemberIdKey);
  }

  /// Get the current member object from a list of family members
  static FamilyMember? getCurrentMember(
    String? currentMemberId,
    List<FamilyMember> allMembers,
  ) {
    if (currentMemberId == null) return null;
    
    try {
      return allMembers.firstWhere(
        (member) => member.id == currentMemberId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Check if a member is a parent or caregiver (has admin permissions)
  static bool isParentOrCaregiver(FamilyMember? member) {
    if (member == null) return false;
    return member.role == MemberRole.parent || 
           member.role == MemberRole.caregiver;
  }

  /// Check if a member is a child
  static bool isChild(FamilyMember? member) {
    if (member == null) return false;
    return member.role == MemberRole.child;
  }
}

