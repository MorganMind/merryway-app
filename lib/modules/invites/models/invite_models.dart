import 'package:freezed_annotation/freezed_annotation.dart';

part 'invite_models.freezed.dart';
part 'invite_models.g.dart';

/// Invite model for household invitations
@freezed
class Invite with _$Invite {
  const factory Invite({
    required String id,
    @JsonKey(name: 'household_id') required String householdId,
    @JsonKey(name: 'invited_email') required String invitedEmail,
    required String role,
    @JsonKey(name: 'member_candidate_id') String? memberCandidateId,
    required String status,
    @JsonKey(name: 'expires_at') required DateTime expiresAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'inviter_name') String? inviterName,
    @JsonKey(name: 'suggested_member') Map<String, dynamic>? suggestedMember,
    String? token, // For magic links
  }) = _Invite;

  factory Invite.fromJson(Map<String, dynamic> json) => _$InviteFromJson(json);
}

/// Invite validation response
@freezed
class InviteValidation with _$InviteValidation {
  const factory InviteValidation({
    @JsonKey(name: 'is_valid') required bool isValid,
    @JsonKey(name: 'household_id') String? householdId,
    @JsonKey(name: 'household_name') String? householdName,
    @JsonKey(name: 'invited_email') String? invitedEmail,
    @JsonKey(name: 'member_candidate') Map<String, dynamic>? memberCandidate,
    @JsonKey(name: 'suggested_members') @Default([]) List<Map<String, dynamic>> suggestedMembers,
    @JsonKey(name: 'error_message') String? errorMessage,
  }) = _InviteValidation;

  factory InviteValidation.fromJson(Map<String, dynamic> json) => _$InviteValidationFromJson(json);
}

/// Member with claim information
@freezed
class MemberWithClaim with _$MemberWithClaim {
  const factory MemberWithClaim({
    required String id,
    required String name,
    required int age,
    @JsonKey(name: 'is_adult') required bool isAdult,
    @JsonKey(name: 'claimed_user_id') String? claimedUserId,
    @JsonKey(name: 'preferred_name') String? preferredName,
    @JsonKey(name: 'email_hint') String? emailHint,
  }) = _MemberWithClaim;

  factory MemberWithClaim.fromJson(Map<String, dynamic> json) => _$MemberWithClaimFromJson(json);
}

/// Unclaimed adult member
@freezed
class UnclaimedAdultMember with _$UnclaimedAdultMember {
  const factory UnclaimedAdultMember({
    required String id,
    required String name,
    @JsonKey(name: 'preferred_name') String? preferredName,
    @JsonKey(name: 'email_hint') String? emailHint,
  }) = _UnclaimedAdultMember;

  factory UnclaimedAdultMember.fromJson(Map<String, dynamic> json) => _$UnclaimedAdultMemberFromJson(json);
}

/// User preferences enums
enum TravelRadius { walkable, shortDrive, noTravel }
enum MessTolerance { low, medium, high }
enum CostCeiling { low, medium, high }

/// User preferences model
@freezed
class UserPreferences with _$UserPreferences {
  const factory UserPreferences({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'travel_radius') TravelRadius? travelRadius,
    @JsonKey(name: 'mess_tolerance') MessTolerance? messTolerance,
    @JsonKey(name: 'cost_ceiling') CostCeiling? costCeiling,
    @JsonKey(name: 'quiet_hours_enabled') @Default(false) bool quietHoursEnabled,
    @Default([]) List<String> interests,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _UserPreferences;

  factory UserPreferences.fromJson(Map<String, dynamic> json) => _$UserPreferencesFromJson(json);
}
