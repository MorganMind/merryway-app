// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invite_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InviteImpl _$$InviteImplFromJson(Map<String, dynamic> json) => _$InviteImpl(
      id: json['id'] as String,
      householdId: json['household_id'] as String,
      invitedEmail: json['invited_email'] as String,
      role: json['role'] as String,
      memberCandidateId: json['member_candidate_id'] as String?,
      status: json['status'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      inviterName: json['inviter_name'] as String?,
      suggestedMember: json['suggested_member'] as Map<String, dynamic>?,
      token: json['token'] as String?,
    );

Map<String, dynamic> _$$InviteImplToJson(_$InviteImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'household_id': instance.householdId,
      'invited_email': instance.invitedEmail,
      'role': instance.role,
      'member_candidate_id': instance.memberCandidateId,
      'status': instance.status,
      'expires_at': instance.expiresAt.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'inviter_name': instance.inviterName,
      'suggested_member': instance.suggestedMember,
      'token': instance.token,
    };

_$InviteValidationImpl _$$InviteValidationImplFromJson(
        Map<String, dynamic> json) =>
    _$InviteValidationImpl(
      isValid: json['is_valid'] as bool,
      householdId: json['household_id'] as String?,
      householdName: json['household_name'] as String?,
      invitedEmail: json['invited_email'] as String?,
      memberCandidate: json['member_candidate'] as Map<String, dynamic>?,
      suggestedMembers: (json['suggested_members'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
      errorMessage: json['error_message'] as String?,
    );

Map<String, dynamic> _$$InviteValidationImplToJson(
        _$InviteValidationImpl instance) =>
    <String, dynamic>{
      'is_valid': instance.isValid,
      'household_id': instance.householdId,
      'household_name': instance.householdName,
      'invited_email': instance.invitedEmail,
      'member_candidate': instance.memberCandidate,
      'suggested_members': instance.suggestedMembers,
      'error_message': instance.errorMessage,
    };

_$MemberWithClaimImpl _$$MemberWithClaimImplFromJson(
        Map<String, dynamic> json) =>
    _$MemberWithClaimImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      age: (json['age'] as num).toInt(),
      isAdult: json['is_adult'] as bool,
      claimedUserId: json['claimed_user_id'] as String?,
      preferredName: json['preferred_name'] as String?,
      emailHint: json['email_hint'] as String?,
    );

Map<String, dynamic> _$$MemberWithClaimImplToJson(
        _$MemberWithClaimImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'age': instance.age,
      'is_adult': instance.isAdult,
      'claimed_user_id': instance.claimedUserId,
      'preferred_name': instance.preferredName,
      'email_hint': instance.emailHint,
    };

_$UnclaimedAdultMemberImpl _$$UnclaimedAdultMemberImplFromJson(
        Map<String, dynamic> json) =>
    _$UnclaimedAdultMemberImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      preferredName: json['preferred_name'] as String?,
      emailHint: json['email_hint'] as String?,
    );

Map<String, dynamic> _$$UnclaimedAdultMemberImplToJson(
        _$UnclaimedAdultMemberImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'preferred_name': instance.preferredName,
      'email_hint': instance.emailHint,
    };

_$UserPreferencesImpl _$$UserPreferencesImplFromJson(
        Map<String, dynamic> json) =>
    _$UserPreferencesImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      travelRadius:
          $enumDecodeNullable(_$TravelRadiusEnumMap, json['travel_radius']),
      messTolerance:
          $enumDecodeNullable(_$MessToleranceEnumMap, json['mess_tolerance']),
      costCeiling:
          $enumDecodeNullable(_$CostCeilingEnumMap, json['cost_ceiling']),
      quietHoursEnabled: json['quiet_hours_enabled'] as bool? ?? false,
      interests: (json['interests'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$UserPreferencesImplToJson(
        _$UserPreferencesImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'travel_radius': _$TravelRadiusEnumMap[instance.travelRadius],
      'mess_tolerance': _$MessToleranceEnumMap[instance.messTolerance],
      'cost_ceiling': _$CostCeilingEnumMap[instance.costCeiling],
      'quiet_hours_enabled': instance.quietHoursEnabled,
      'interests': instance.interests,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$TravelRadiusEnumMap = {
  TravelRadius.walkable: 'walkable',
  TravelRadius.shortDrive: 'shortDrive',
  TravelRadius.noTravel: 'noTravel',
};

const _$MessToleranceEnumMap = {
  MessTolerance.low: 'low',
  MessTolerance.medium: 'medium',
  MessTolerance.high: 'high',
};

const _$CostCeilingEnumMap = {
  CostCeiling.low: 'low',
  CostCeiling.medium: 'medium',
  CostCeiling.high: 'high',
};
