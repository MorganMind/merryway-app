// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invite_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Invite _$InviteFromJson(Map<String, dynamic> json) {
  return _Invite.fromJson(json);
}

/// @nodoc
mixin _$Invite {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'household_id')
  String get householdId => throw _privateConstructorUsedError;
  @JsonKey(name: 'invited_email')
  String get invitedEmail => throw _privateConstructorUsedError;
  String get role => throw _privateConstructorUsedError;
  @JsonKey(name: 'member_candidate_id')
  String? get memberCandidateId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'expires_at')
  DateTime get expiresAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'inviter_name')
  String? get inviterName => throw _privateConstructorUsedError;
  @JsonKey(name: 'suggested_member')
  Map<String, dynamic>? get suggestedMember =>
      throw _privateConstructorUsedError;
  String? get token => throw _privateConstructorUsedError;

  /// Serializes this Invite to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Invite
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InviteCopyWith<Invite> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InviteCopyWith<$Res> {
  factory $InviteCopyWith(Invite value, $Res Function(Invite) then) =
      _$InviteCopyWithImpl<$Res, Invite>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'household_id') String householdId,
      @JsonKey(name: 'invited_email') String invitedEmail,
      String role,
      @JsonKey(name: 'member_candidate_id') String? memberCandidateId,
      String status,
      @JsonKey(name: 'expires_at') DateTime expiresAt,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'inviter_name') String? inviterName,
      @JsonKey(name: 'suggested_member') Map<String, dynamic>? suggestedMember,
      String? token});
}

/// @nodoc
class _$InviteCopyWithImpl<$Res, $Val extends Invite>
    implements $InviteCopyWith<$Res> {
  _$InviteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Invite
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? householdId = null,
    Object? invitedEmail = null,
    Object? role = null,
    Object? memberCandidateId = freezed,
    Object? status = null,
    Object? expiresAt = null,
    Object? createdAt = null,
    Object? inviterName = freezed,
    Object? suggestedMember = freezed,
    Object? token = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      householdId: null == householdId
          ? _value.householdId
          : householdId // ignore: cast_nullable_to_non_nullable
              as String,
      invitedEmail: null == invitedEmail
          ? _value.invitedEmail
          : invitedEmail // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      memberCandidateId: freezed == memberCandidateId
          ? _value.memberCandidateId
          : memberCandidateId // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      expiresAt: null == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      inviterName: freezed == inviterName
          ? _value.inviterName
          : inviterName // ignore: cast_nullable_to_non_nullable
              as String?,
      suggestedMember: freezed == suggestedMember
          ? _value.suggestedMember
          : suggestedMember // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      token: freezed == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InviteImplCopyWith<$Res> implements $InviteCopyWith<$Res> {
  factory _$$InviteImplCopyWith(
          _$InviteImpl value, $Res Function(_$InviteImpl) then) =
      __$$InviteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'household_id') String householdId,
      @JsonKey(name: 'invited_email') String invitedEmail,
      String role,
      @JsonKey(name: 'member_candidate_id') String? memberCandidateId,
      String status,
      @JsonKey(name: 'expires_at') DateTime expiresAt,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'inviter_name') String? inviterName,
      @JsonKey(name: 'suggested_member') Map<String, dynamic>? suggestedMember,
      String? token});
}

/// @nodoc
class __$$InviteImplCopyWithImpl<$Res>
    extends _$InviteCopyWithImpl<$Res, _$InviteImpl>
    implements _$$InviteImplCopyWith<$Res> {
  __$$InviteImplCopyWithImpl(
      _$InviteImpl _value, $Res Function(_$InviteImpl) _then)
      : super(_value, _then);

  /// Create a copy of Invite
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? householdId = null,
    Object? invitedEmail = null,
    Object? role = null,
    Object? memberCandidateId = freezed,
    Object? status = null,
    Object? expiresAt = null,
    Object? createdAt = null,
    Object? inviterName = freezed,
    Object? suggestedMember = freezed,
    Object? token = freezed,
  }) {
    return _then(_$InviteImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      householdId: null == householdId
          ? _value.householdId
          : householdId // ignore: cast_nullable_to_non_nullable
              as String,
      invitedEmail: null == invitedEmail
          ? _value.invitedEmail
          : invitedEmail // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      memberCandidateId: freezed == memberCandidateId
          ? _value.memberCandidateId
          : memberCandidateId // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      expiresAt: null == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      inviterName: freezed == inviterName
          ? _value.inviterName
          : inviterName // ignore: cast_nullable_to_non_nullable
              as String?,
      suggestedMember: freezed == suggestedMember
          ? _value._suggestedMember
          : suggestedMember // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      token: freezed == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$InviteImpl implements _Invite {
  const _$InviteImpl(
      {required this.id,
      @JsonKey(name: 'household_id') required this.householdId,
      @JsonKey(name: 'invited_email') required this.invitedEmail,
      required this.role,
      @JsonKey(name: 'member_candidate_id') this.memberCandidateId,
      required this.status,
      @JsonKey(name: 'expires_at') required this.expiresAt,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'inviter_name') this.inviterName,
      @JsonKey(name: 'suggested_member')
      final Map<String, dynamic>? suggestedMember,
      this.token})
      : _suggestedMember = suggestedMember;

  factory _$InviteImpl.fromJson(Map<String, dynamic> json) =>
      _$$InviteImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'household_id')
  final String householdId;
  @override
  @JsonKey(name: 'invited_email')
  final String invitedEmail;
  @override
  final String role;
  @override
  @JsonKey(name: 'member_candidate_id')
  final String? memberCandidateId;
  @override
  final String status;
  @override
  @JsonKey(name: 'expires_at')
  final DateTime expiresAt;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'inviter_name')
  final String? inviterName;
  final Map<String, dynamic>? _suggestedMember;
  @override
  @JsonKey(name: 'suggested_member')
  Map<String, dynamic>? get suggestedMember {
    final value = _suggestedMember;
    if (value == null) return null;
    if (_suggestedMember is EqualUnmodifiableMapView) return _suggestedMember;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? token;

  @override
  String toString() {
    return 'Invite(id: $id, householdId: $householdId, invitedEmail: $invitedEmail, role: $role, memberCandidateId: $memberCandidateId, status: $status, expiresAt: $expiresAt, createdAt: $createdAt, inviterName: $inviterName, suggestedMember: $suggestedMember, token: $token)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InviteImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.householdId, householdId) ||
                other.householdId == householdId) &&
            (identical(other.invitedEmail, invitedEmail) ||
                other.invitedEmail == invitedEmail) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.memberCandidateId, memberCandidateId) ||
                other.memberCandidateId == memberCandidateId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.inviterName, inviterName) ||
                other.inviterName == inviterName) &&
            const DeepCollectionEquality()
                .equals(other._suggestedMember, _suggestedMember) &&
            (identical(other.token, token) || other.token == token));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      householdId,
      invitedEmail,
      role,
      memberCandidateId,
      status,
      expiresAt,
      createdAt,
      inviterName,
      const DeepCollectionEquality().hash(_suggestedMember),
      token);

  /// Create a copy of Invite
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InviteImplCopyWith<_$InviteImpl> get copyWith =>
      __$$InviteImplCopyWithImpl<_$InviteImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InviteImplToJson(
      this,
    );
  }
}

abstract class _Invite implements Invite {
  const factory _Invite(
      {required final String id,
      @JsonKey(name: 'household_id') required final String householdId,
      @JsonKey(name: 'invited_email') required final String invitedEmail,
      required final String role,
      @JsonKey(name: 'member_candidate_id') final String? memberCandidateId,
      required final String status,
      @JsonKey(name: 'expires_at') required final DateTime expiresAt,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      @JsonKey(name: 'inviter_name') final String? inviterName,
      @JsonKey(name: 'suggested_member')
      final Map<String, dynamic>? suggestedMember,
      final String? token}) = _$InviteImpl;

  factory _Invite.fromJson(Map<String, dynamic> json) = _$InviteImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'household_id')
  String get householdId;
  @override
  @JsonKey(name: 'invited_email')
  String get invitedEmail;
  @override
  String get role;
  @override
  @JsonKey(name: 'member_candidate_id')
  String? get memberCandidateId;
  @override
  String get status;
  @override
  @JsonKey(name: 'expires_at')
  DateTime get expiresAt;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'inviter_name')
  String? get inviterName;
  @override
  @JsonKey(name: 'suggested_member')
  Map<String, dynamic>? get suggestedMember;
  @override
  String? get token;

  /// Create a copy of Invite
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InviteImplCopyWith<_$InviteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

InviteValidation _$InviteValidationFromJson(Map<String, dynamic> json) {
  return _InviteValidation.fromJson(json);
}

/// @nodoc
mixin _$InviteValidation {
  @JsonKey(name: 'is_valid')
  bool get isValid => throw _privateConstructorUsedError;
  @JsonKey(name: 'household_id')
  String? get householdId => throw _privateConstructorUsedError;
  @JsonKey(name: 'household_name')
  String? get householdName => throw _privateConstructorUsedError;
  @JsonKey(name: 'invited_email')
  String? get invitedEmail => throw _privateConstructorUsedError;
  @JsonKey(name: 'member_candidate')
  Map<String, dynamic>? get memberCandidate =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'suggested_members')
  List<Map<String, dynamic>> get suggestedMembers =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'error_message')
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Serializes this InviteValidation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InviteValidation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InviteValidationCopyWith<InviteValidation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InviteValidationCopyWith<$Res> {
  factory $InviteValidationCopyWith(
          InviteValidation value, $Res Function(InviteValidation) then) =
      _$InviteValidationCopyWithImpl<$Res, InviteValidation>;
  @useResult
  $Res call(
      {@JsonKey(name: 'is_valid') bool isValid,
      @JsonKey(name: 'household_id') String? householdId,
      @JsonKey(name: 'household_name') String? householdName,
      @JsonKey(name: 'invited_email') String? invitedEmail,
      @JsonKey(name: 'member_candidate') Map<String, dynamic>? memberCandidate,
      @JsonKey(name: 'suggested_members')
      List<Map<String, dynamic>> suggestedMembers,
      @JsonKey(name: 'error_message') String? errorMessage});
}

/// @nodoc
class _$InviteValidationCopyWithImpl<$Res, $Val extends InviteValidation>
    implements $InviteValidationCopyWith<$Res> {
  _$InviteValidationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InviteValidation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isValid = null,
    Object? householdId = freezed,
    Object? householdName = freezed,
    Object? invitedEmail = freezed,
    Object? memberCandidate = freezed,
    Object? suggestedMembers = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      isValid: null == isValid
          ? _value.isValid
          : isValid // ignore: cast_nullable_to_non_nullable
              as bool,
      householdId: freezed == householdId
          ? _value.householdId
          : householdId // ignore: cast_nullable_to_non_nullable
              as String?,
      householdName: freezed == householdName
          ? _value.householdName
          : householdName // ignore: cast_nullable_to_non_nullable
              as String?,
      invitedEmail: freezed == invitedEmail
          ? _value.invitedEmail
          : invitedEmail // ignore: cast_nullable_to_non_nullable
              as String?,
      memberCandidate: freezed == memberCandidate
          ? _value.memberCandidate
          : memberCandidate // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      suggestedMembers: null == suggestedMembers
          ? _value.suggestedMembers
          : suggestedMembers // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InviteValidationImplCopyWith<$Res>
    implements $InviteValidationCopyWith<$Res> {
  factory _$$InviteValidationImplCopyWith(_$InviteValidationImpl value,
          $Res Function(_$InviteValidationImpl) then) =
      __$$InviteValidationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'is_valid') bool isValid,
      @JsonKey(name: 'household_id') String? householdId,
      @JsonKey(name: 'household_name') String? householdName,
      @JsonKey(name: 'invited_email') String? invitedEmail,
      @JsonKey(name: 'member_candidate') Map<String, dynamic>? memberCandidate,
      @JsonKey(name: 'suggested_members')
      List<Map<String, dynamic>> suggestedMembers,
      @JsonKey(name: 'error_message') String? errorMessage});
}

/// @nodoc
class __$$InviteValidationImplCopyWithImpl<$Res>
    extends _$InviteValidationCopyWithImpl<$Res, _$InviteValidationImpl>
    implements _$$InviteValidationImplCopyWith<$Res> {
  __$$InviteValidationImplCopyWithImpl(_$InviteValidationImpl _value,
      $Res Function(_$InviteValidationImpl) _then)
      : super(_value, _then);

  /// Create a copy of InviteValidation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isValid = null,
    Object? householdId = freezed,
    Object? householdName = freezed,
    Object? invitedEmail = freezed,
    Object? memberCandidate = freezed,
    Object? suggestedMembers = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_$InviteValidationImpl(
      isValid: null == isValid
          ? _value.isValid
          : isValid // ignore: cast_nullable_to_non_nullable
              as bool,
      householdId: freezed == householdId
          ? _value.householdId
          : householdId // ignore: cast_nullable_to_non_nullable
              as String?,
      householdName: freezed == householdName
          ? _value.householdName
          : householdName // ignore: cast_nullable_to_non_nullable
              as String?,
      invitedEmail: freezed == invitedEmail
          ? _value.invitedEmail
          : invitedEmail // ignore: cast_nullable_to_non_nullable
              as String?,
      memberCandidate: freezed == memberCandidate
          ? _value._memberCandidate
          : memberCandidate // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      suggestedMembers: null == suggestedMembers
          ? _value._suggestedMembers
          : suggestedMembers // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$InviteValidationImpl implements _InviteValidation {
  const _$InviteValidationImpl(
      {@JsonKey(name: 'is_valid') required this.isValid,
      @JsonKey(name: 'household_id') this.householdId,
      @JsonKey(name: 'household_name') this.householdName,
      @JsonKey(name: 'invited_email') this.invitedEmail,
      @JsonKey(name: 'member_candidate')
      final Map<String, dynamic>? memberCandidate,
      @JsonKey(name: 'suggested_members')
      final List<Map<String, dynamic>> suggestedMembers = const [],
      @JsonKey(name: 'error_message') this.errorMessage})
      : _memberCandidate = memberCandidate,
        _suggestedMembers = suggestedMembers;

  factory _$InviteValidationImpl.fromJson(Map<String, dynamic> json) =>
      _$$InviteValidationImplFromJson(json);

  @override
  @JsonKey(name: 'is_valid')
  final bool isValid;
  @override
  @JsonKey(name: 'household_id')
  final String? householdId;
  @override
  @JsonKey(name: 'household_name')
  final String? householdName;
  @override
  @JsonKey(name: 'invited_email')
  final String? invitedEmail;
  final Map<String, dynamic>? _memberCandidate;
  @override
  @JsonKey(name: 'member_candidate')
  Map<String, dynamic>? get memberCandidate {
    final value = _memberCandidate;
    if (value == null) return null;
    if (_memberCandidate is EqualUnmodifiableMapView) return _memberCandidate;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final List<Map<String, dynamic>> _suggestedMembers;
  @override
  @JsonKey(name: 'suggested_members')
  List<Map<String, dynamic>> get suggestedMembers {
    if (_suggestedMembers is EqualUnmodifiableListView)
      return _suggestedMembers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_suggestedMembers);
  }

  @override
  @JsonKey(name: 'error_message')
  final String? errorMessage;

  @override
  String toString() {
    return 'InviteValidation(isValid: $isValid, householdId: $householdId, householdName: $householdName, invitedEmail: $invitedEmail, memberCandidate: $memberCandidate, suggestedMembers: $suggestedMembers, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InviteValidationImpl &&
            (identical(other.isValid, isValid) || other.isValid == isValid) &&
            (identical(other.householdId, householdId) ||
                other.householdId == householdId) &&
            (identical(other.householdName, householdName) ||
                other.householdName == householdName) &&
            (identical(other.invitedEmail, invitedEmail) ||
                other.invitedEmail == invitedEmail) &&
            const DeepCollectionEquality()
                .equals(other._memberCandidate, _memberCandidate) &&
            const DeepCollectionEquality()
                .equals(other._suggestedMembers, _suggestedMembers) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      isValid,
      householdId,
      householdName,
      invitedEmail,
      const DeepCollectionEquality().hash(_memberCandidate),
      const DeepCollectionEquality().hash(_suggestedMembers),
      errorMessage);

  /// Create a copy of InviteValidation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InviteValidationImplCopyWith<_$InviteValidationImpl> get copyWith =>
      __$$InviteValidationImplCopyWithImpl<_$InviteValidationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InviteValidationImplToJson(
      this,
    );
  }
}

abstract class _InviteValidation implements InviteValidation {
  const factory _InviteValidation(
          {@JsonKey(name: 'is_valid') required final bool isValid,
          @JsonKey(name: 'household_id') final String? householdId,
          @JsonKey(name: 'household_name') final String? householdName,
          @JsonKey(name: 'invited_email') final String? invitedEmail,
          @JsonKey(name: 'member_candidate')
          final Map<String, dynamic>? memberCandidate,
          @JsonKey(name: 'suggested_members')
          final List<Map<String, dynamic>> suggestedMembers,
          @JsonKey(name: 'error_message') final String? errorMessage}) =
      _$InviteValidationImpl;

  factory _InviteValidation.fromJson(Map<String, dynamic> json) =
      _$InviteValidationImpl.fromJson;

  @override
  @JsonKey(name: 'is_valid')
  bool get isValid;
  @override
  @JsonKey(name: 'household_id')
  String? get householdId;
  @override
  @JsonKey(name: 'household_name')
  String? get householdName;
  @override
  @JsonKey(name: 'invited_email')
  String? get invitedEmail;
  @override
  @JsonKey(name: 'member_candidate')
  Map<String, dynamic>? get memberCandidate;
  @override
  @JsonKey(name: 'suggested_members')
  List<Map<String, dynamic>> get suggestedMembers;
  @override
  @JsonKey(name: 'error_message')
  String? get errorMessage;

  /// Create a copy of InviteValidation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InviteValidationImplCopyWith<_$InviteValidationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MemberWithClaim _$MemberWithClaimFromJson(Map<String, dynamic> json) {
  return _MemberWithClaim.fromJson(json);
}

/// @nodoc
mixin _$MemberWithClaim {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get age => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_adult')
  bool get isAdult => throw _privateConstructorUsedError;
  @JsonKey(name: 'claimed_user_id')
  String? get claimedUserId => throw _privateConstructorUsedError;
  @JsonKey(name: 'preferred_name')
  String? get preferredName => throw _privateConstructorUsedError;
  @JsonKey(name: 'email_hint')
  String? get emailHint => throw _privateConstructorUsedError;

  /// Serializes this MemberWithClaim to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MemberWithClaim
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MemberWithClaimCopyWith<MemberWithClaim> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MemberWithClaimCopyWith<$Res> {
  factory $MemberWithClaimCopyWith(
          MemberWithClaim value, $Res Function(MemberWithClaim) then) =
      _$MemberWithClaimCopyWithImpl<$Res, MemberWithClaim>;
  @useResult
  $Res call(
      {String id,
      String name,
      int age,
      @JsonKey(name: 'is_adult') bool isAdult,
      @JsonKey(name: 'claimed_user_id') String? claimedUserId,
      @JsonKey(name: 'preferred_name') String? preferredName,
      @JsonKey(name: 'email_hint') String? emailHint});
}

/// @nodoc
class _$MemberWithClaimCopyWithImpl<$Res, $Val extends MemberWithClaim>
    implements $MemberWithClaimCopyWith<$Res> {
  _$MemberWithClaimCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MemberWithClaim
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? age = null,
    Object? isAdult = null,
    Object? claimedUserId = freezed,
    Object? preferredName = freezed,
    Object? emailHint = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      age: null == age
          ? _value.age
          : age // ignore: cast_nullable_to_non_nullable
              as int,
      isAdult: null == isAdult
          ? _value.isAdult
          : isAdult // ignore: cast_nullable_to_non_nullable
              as bool,
      claimedUserId: freezed == claimedUserId
          ? _value.claimedUserId
          : claimedUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      preferredName: freezed == preferredName
          ? _value.preferredName
          : preferredName // ignore: cast_nullable_to_non_nullable
              as String?,
      emailHint: freezed == emailHint
          ? _value.emailHint
          : emailHint // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MemberWithClaimImplCopyWith<$Res>
    implements $MemberWithClaimCopyWith<$Res> {
  factory _$$MemberWithClaimImplCopyWith(_$MemberWithClaimImpl value,
          $Res Function(_$MemberWithClaimImpl) then) =
      __$$MemberWithClaimImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      int age,
      @JsonKey(name: 'is_adult') bool isAdult,
      @JsonKey(name: 'claimed_user_id') String? claimedUserId,
      @JsonKey(name: 'preferred_name') String? preferredName,
      @JsonKey(name: 'email_hint') String? emailHint});
}

/// @nodoc
class __$$MemberWithClaimImplCopyWithImpl<$Res>
    extends _$MemberWithClaimCopyWithImpl<$Res, _$MemberWithClaimImpl>
    implements _$$MemberWithClaimImplCopyWith<$Res> {
  __$$MemberWithClaimImplCopyWithImpl(
      _$MemberWithClaimImpl _value, $Res Function(_$MemberWithClaimImpl) _then)
      : super(_value, _then);

  /// Create a copy of MemberWithClaim
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? age = null,
    Object? isAdult = null,
    Object? claimedUserId = freezed,
    Object? preferredName = freezed,
    Object? emailHint = freezed,
  }) {
    return _then(_$MemberWithClaimImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      age: null == age
          ? _value.age
          : age // ignore: cast_nullable_to_non_nullable
              as int,
      isAdult: null == isAdult
          ? _value.isAdult
          : isAdult // ignore: cast_nullable_to_non_nullable
              as bool,
      claimedUserId: freezed == claimedUserId
          ? _value.claimedUserId
          : claimedUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      preferredName: freezed == preferredName
          ? _value.preferredName
          : preferredName // ignore: cast_nullable_to_non_nullable
              as String?,
      emailHint: freezed == emailHint
          ? _value.emailHint
          : emailHint // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MemberWithClaimImpl implements _MemberWithClaim {
  const _$MemberWithClaimImpl(
      {required this.id,
      required this.name,
      required this.age,
      @JsonKey(name: 'is_adult') required this.isAdult,
      @JsonKey(name: 'claimed_user_id') this.claimedUserId,
      @JsonKey(name: 'preferred_name') this.preferredName,
      @JsonKey(name: 'email_hint') this.emailHint});

  factory _$MemberWithClaimImpl.fromJson(Map<String, dynamic> json) =>
      _$$MemberWithClaimImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final int age;
  @override
  @JsonKey(name: 'is_adult')
  final bool isAdult;
  @override
  @JsonKey(name: 'claimed_user_id')
  final String? claimedUserId;
  @override
  @JsonKey(name: 'preferred_name')
  final String? preferredName;
  @override
  @JsonKey(name: 'email_hint')
  final String? emailHint;

  @override
  String toString() {
    return 'MemberWithClaim(id: $id, name: $name, age: $age, isAdult: $isAdult, claimedUserId: $claimedUserId, preferredName: $preferredName, emailHint: $emailHint)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MemberWithClaimImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.age, age) || other.age == age) &&
            (identical(other.isAdult, isAdult) || other.isAdult == isAdult) &&
            (identical(other.claimedUserId, claimedUserId) ||
                other.claimedUserId == claimedUserId) &&
            (identical(other.preferredName, preferredName) ||
                other.preferredName == preferredName) &&
            (identical(other.emailHint, emailHint) ||
                other.emailHint == emailHint));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, age, isAdult,
      claimedUserId, preferredName, emailHint);

  /// Create a copy of MemberWithClaim
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MemberWithClaimImplCopyWith<_$MemberWithClaimImpl> get copyWith =>
      __$$MemberWithClaimImplCopyWithImpl<_$MemberWithClaimImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MemberWithClaimImplToJson(
      this,
    );
  }
}

abstract class _MemberWithClaim implements MemberWithClaim {
  const factory _MemberWithClaim(
          {required final String id,
          required final String name,
          required final int age,
          @JsonKey(name: 'is_adult') required final bool isAdult,
          @JsonKey(name: 'claimed_user_id') final String? claimedUserId,
          @JsonKey(name: 'preferred_name') final String? preferredName,
          @JsonKey(name: 'email_hint') final String? emailHint}) =
      _$MemberWithClaimImpl;

  factory _MemberWithClaim.fromJson(Map<String, dynamic> json) =
      _$MemberWithClaimImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  int get age;
  @override
  @JsonKey(name: 'is_adult')
  bool get isAdult;
  @override
  @JsonKey(name: 'claimed_user_id')
  String? get claimedUserId;
  @override
  @JsonKey(name: 'preferred_name')
  String? get preferredName;
  @override
  @JsonKey(name: 'email_hint')
  String? get emailHint;

  /// Create a copy of MemberWithClaim
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MemberWithClaimImplCopyWith<_$MemberWithClaimImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UnclaimedAdultMember _$UnclaimedAdultMemberFromJson(Map<String, dynamic> json) {
  return _UnclaimedAdultMember.fromJson(json);
}

/// @nodoc
mixin _$UnclaimedAdultMember {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'preferred_name')
  String? get preferredName => throw _privateConstructorUsedError;
  @JsonKey(name: 'email_hint')
  String? get emailHint => throw _privateConstructorUsedError;

  /// Serializes this UnclaimedAdultMember to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UnclaimedAdultMember
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UnclaimedAdultMemberCopyWith<UnclaimedAdultMember> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UnclaimedAdultMemberCopyWith<$Res> {
  factory $UnclaimedAdultMemberCopyWith(UnclaimedAdultMember value,
          $Res Function(UnclaimedAdultMember) then) =
      _$UnclaimedAdultMemberCopyWithImpl<$Res, UnclaimedAdultMember>;
  @useResult
  $Res call(
      {String id,
      String name,
      @JsonKey(name: 'preferred_name') String? preferredName,
      @JsonKey(name: 'email_hint') String? emailHint});
}

/// @nodoc
class _$UnclaimedAdultMemberCopyWithImpl<$Res,
        $Val extends UnclaimedAdultMember>
    implements $UnclaimedAdultMemberCopyWith<$Res> {
  _$UnclaimedAdultMemberCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UnclaimedAdultMember
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? preferredName = freezed,
    Object? emailHint = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      preferredName: freezed == preferredName
          ? _value.preferredName
          : preferredName // ignore: cast_nullable_to_non_nullable
              as String?,
      emailHint: freezed == emailHint
          ? _value.emailHint
          : emailHint // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UnclaimedAdultMemberImplCopyWith<$Res>
    implements $UnclaimedAdultMemberCopyWith<$Res> {
  factory _$$UnclaimedAdultMemberImplCopyWith(_$UnclaimedAdultMemberImpl value,
          $Res Function(_$UnclaimedAdultMemberImpl) then) =
      __$$UnclaimedAdultMemberImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      @JsonKey(name: 'preferred_name') String? preferredName,
      @JsonKey(name: 'email_hint') String? emailHint});
}

/// @nodoc
class __$$UnclaimedAdultMemberImplCopyWithImpl<$Res>
    extends _$UnclaimedAdultMemberCopyWithImpl<$Res, _$UnclaimedAdultMemberImpl>
    implements _$$UnclaimedAdultMemberImplCopyWith<$Res> {
  __$$UnclaimedAdultMemberImplCopyWithImpl(_$UnclaimedAdultMemberImpl _value,
      $Res Function(_$UnclaimedAdultMemberImpl) _then)
      : super(_value, _then);

  /// Create a copy of UnclaimedAdultMember
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? preferredName = freezed,
    Object? emailHint = freezed,
  }) {
    return _then(_$UnclaimedAdultMemberImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      preferredName: freezed == preferredName
          ? _value.preferredName
          : preferredName // ignore: cast_nullable_to_non_nullable
              as String?,
      emailHint: freezed == emailHint
          ? _value.emailHint
          : emailHint // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UnclaimedAdultMemberImpl implements _UnclaimedAdultMember {
  const _$UnclaimedAdultMemberImpl(
      {required this.id,
      required this.name,
      @JsonKey(name: 'preferred_name') this.preferredName,
      @JsonKey(name: 'email_hint') this.emailHint});

  factory _$UnclaimedAdultMemberImpl.fromJson(Map<String, dynamic> json) =>
      _$$UnclaimedAdultMemberImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  @JsonKey(name: 'preferred_name')
  final String? preferredName;
  @override
  @JsonKey(name: 'email_hint')
  final String? emailHint;

  @override
  String toString() {
    return 'UnclaimedAdultMember(id: $id, name: $name, preferredName: $preferredName, emailHint: $emailHint)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnclaimedAdultMemberImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.preferredName, preferredName) ||
                other.preferredName == preferredName) &&
            (identical(other.emailHint, emailHint) ||
                other.emailHint == emailHint));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, preferredName, emailHint);

  /// Create a copy of UnclaimedAdultMember
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UnclaimedAdultMemberImplCopyWith<_$UnclaimedAdultMemberImpl>
      get copyWith =>
          __$$UnclaimedAdultMemberImplCopyWithImpl<_$UnclaimedAdultMemberImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UnclaimedAdultMemberImplToJson(
      this,
    );
  }
}

abstract class _UnclaimedAdultMember implements UnclaimedAdultMember {
  const factory _UnclaimedAdultMember(
          {required final String id,
          required final String name,
          @JsonKey(name: 'preferred_name') final String? preferredName,
          @JsonKey(name: 'email_hint') final String? emailHint}) =
      _$UnclaimedAdultMemberImpl;

  factory _UnclaimedAdultMember.fromJson(Map<String, dynamic> json) =
      _$UnclaimedAdultMemberImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  @JsonKey(name: 'preferred_name')
  String? get preferredName;
  @override
  @JsonKey(name: 'email_hint')
  String? get emailHint;

  /// Create a copy of UnclaimedAdultMember
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UnclaimedAdultMemberImplCopyWith<_$UnclaimedAdultMemberImpl>
      get copyWith => throw _privateConstructorUsedError;
}

UserPreferences _$UserPreferencesFromJson(Map<String, dynamic> json) {
  return _UserPreferences.fromJson(json);
}

/// @nodoc
mixin _$UserPreferences {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'travel_radius')
  TravelRadius? get travelRadius => throw _privateConstructorUsedError;
  @JsonKey(name: 'mess_tolerance')
  MessTolerance? get messTolerance => throw _privateConstructorUsedError;
  @JsonKey(name: 'cost_ceiling')
  CostCeiling? get costCeiling => throw _privateConstructorUsedError;
  @JsonKey(name: 'quiet_hours_enabled')
  bool get quietHoursEnabled => throw _privateConstructorUsedError;
  List<String> get interests => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this UserPreferences to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserPreferencesCopyWith<UserPreferences> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserPreferencesCopyWith<$Res> {
  factory $UserPreferencesCopyWith(
          UserPreferences value, $Res Function(UserPreferences) then) =
      _$UserPreferencesCopyWithImpl<$Res, UserPreferences>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'travel_radius') TravelRadius? travelRadius,
      @JsonKey(name: 'mess_tolerance') MessTolerance? messTolerance,
      @JsonKey(name: 'cost_ceiling') CostCeiling? costCeiling,
      @JsonKey(name: 'quiet_hours_enabled') bool quietHoursEnabled,
      List<String> interests,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt});
}

/// @nodoc
class _$UserPreferencesCopyWithImpl<$Res, $Val extends UserPreferences>
    implements $UserPreferencesCopyWith<$Res> {
  _$UserPreferencesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? travelRadius = freezed,
    Object? messTolerance = freezed,
    Object? costCeiling = freezed,
    Object? quietHoursEnabled = null,
    Object? interests = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      travelRadius: freezed == travelRadius
          ? _value.travelRadius
          : travelRadius // ignore: cast_nullable_to_non_nullable
              as TravelRadius?,
      messTolerance: freezed == messTolerance
          ? _value.messTolerance
          : messTolerance // ignore: cast_nullable_to_non_nullable
              as MessTolerance?,
      costCeiling: freezed == costCeiling
          ? _value.costCeiling
          : costCeiling // ignore: cast_nullable_to_non_nullable
              as CostCeiling?,
      quietHoursEnabled: null == quietHoursEnabled
          ? _value.quietHoursEnabled
          : quietHoursEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      interests: null == interests
          ? _value.interests
          : interests // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserPreferencesImplCopyWith<$Res>
    implements $UserPreferencesCopyWith<$Res> {
  factory _$$UserPreferencesImplCopyWith(_$UserPreferencesImpl value,
          $Res Function(_$UserPreferencesImpl) then) =
      __$$UserPreferencesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'travel_radius') TravelRadius? travelRadius,
      @JsonKey(name: 'mess_tolerance') MessTolerance? messTolerance,
      @JsonKey(name: 'cost_ceiling') CostCeiling? costCeiling,
      @JsonKey(name: 'quiet_hours_enabled') bool quietHoursEnabled,
      List<String> interests,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt});
}

/// @nodoc
class __$$UserPreferencesImplCopyWithImpl<$Res>
    extends _$UserPreferencesCopyWithImpl<$Res, _$UserPreferencesImpl>
    implements _$$UserPreferencesImplCopyWith<$Res> {
  __$$UserPreferencesImplCopyWithImpl(
      _$UserPreferencesImpl _value, $Res Function(_$UserPreferencesImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? travelRadius = freezed,
    Object? messTolerance = freezed,
    Object? costCeiling = freezed,
    Object? quietHoursEnabled = null,
    Object? interests = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$UserPreferencesImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      travelRadius: freezed == travelRadius
          ? _value.travelRadius
          : travelRadius // ignore: cast_nullable_to_non_nullable
              as TravelRadius?,
      messTolerance: freezed == messTolerance
          ? _value.messTolerance
          : messTolerance // ignore: cast_nullable_to_non_nullable
              as MessTolerance?,
      costCeiling: freezed == costCeiling
          ? _value.costCeiling
          : costCeiling // ignore: cast_nullable_to_non_nullable
              as CostCeiling?,
      quietHoursEnabled: null == quietHoursEnabled
          ? _value.quietHoursEnabled
          : quietHoursEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      interests: null == interests
          ? _value._interests
          : interests // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserPreferencesImpl implements _UserPreferences {
  const _$UserPreferencesImpl(
      {required this.id,
      @JsonKey(name: 'user_id') required this.userId,
      @JsonKey(name: 'travel_radius') this.travelRadius,
      @JsonKey(name: 'mess_tolerance') this.messTolerance,
      @JsonKey(name: 'cost_ceiling') this.costCeiling,
      @JsonKey(name: 'quiet_hours_enabled') this.quietHoursEnabled = false,
      final List<String> interests = const [],
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt})
      : _interests = interests;

  factory _$UserPreferencesImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserPreferencesImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'travel_radius')
  final TravelRadius? travelRadius;
  @override
  @JsonKey(name: 'mess_tolerance')
  final MessTolerance? messTolerance;
  @override
  @JsonKey(name: 'cost_ceiling')
  final CostCeiling? costCeiling;
  @override
  @JsonKey(name: 'quiet_hours_enabled')
  final bool quietHoursEnabled;
  final List<String> _interests;
  @override
  @JsonKey()
  List<String> get interests {
    if (_interests is EqualUnmodifiableListView) return _interests;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_interests);
  }

  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @override
  String toString() {
    return 'UserPreferences(id: $id, userId: $userId, travelRadius: $travelRadius, messTolerance: $messTolerance, costCeiling: $costCeiling, quietHoursEnabled: $quietHoursEnabled, interests: $interests, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserPreferencesImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.travelRadius, travelRadius) ||
                other.travelRadius == travelRadius) &&
            (identical(other.messTolerance, messTolerance) ||
                other.messTolerance == messTolerance) &&
            (identical(other.costCeiling, costCeiling) ||
                other.costCeiling == costCeiling) &&
            (identical(other.quietHoursEnabled, quietHoursEnabled) ||
                other.quietHoursEnabled == quietHoursEnabled) &&
            const DeepCollectionEquality()
                .equals(other._interests, _interests) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      travelRadius,
      messTolerance,
      costCeiling,
      quietHoursEnabled,
      const DeepCollectionEquality().hash(_interests),
      createdAt,
      updatedAt);

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserPreferencesImplCopyWith<_$UserPreferencesImpl> get copyWith =>
      __$$UserPreferencesImplCopyWithImpl<_$UserPreferencesImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserPreferencesImplToJson(
      this,
    );
  }
}

abstract class _UserPreferences implements UserPreferences {
  const factory _UserPreferences(
          {required final String id,
          @JsonKey(name: 'user_id') required final String userId,
          @JsonKey(name: 'travel_radius') final TravelRadius? travelRadius,
          @JsonKey(name: 'mess_tolerance') final MessTolerance? messTolerance,
          @JsonKey(name: 'cost_ceiling') final CostCeiling? costCeiling,
          @JsonKey(name: 'quiet_hours_enabled') final bool quietHoursEnabled,
          final List<String> interests,
          @JsonKey(name: 'created_at') required final DateTime createdAt,
          @JsonKey(name: 'updated_at') required final DateTime updatedAt}) =
      _$UserPreferencesImpl;

  factory _UserPreferences.fromJson(Map<String, dynamic> json) =
      _$UserPreferencesImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'travel_radius')
  TravelRadius? get travelRadius;
  @override
  @JsonKey(name: 'mess_tolerance')
  MessTolerance? get messTolerance;
  @override
  @JsonKey(name: 'cost_ceiling')
  CostCeiling? get costCeiling;
  @override
  @JsonKey(name: 'quiet_hours_enabled')
  bool get quietHoursEnabled;
  @override
  List<String> get interests;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserPreferencesImplCopyWith<_$UserPreferencesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
