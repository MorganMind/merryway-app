// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'plan_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Plan _$PlanFromJson(Map<String, dynamic> json) {
  return _Plan.fromJson(json);
}

/// @nodoc
mixin _$Plan {
  String? get id => throw _privateConstructorUsedError;
  String? get householdId => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Plan to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Plan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlanCopyWith<Plan> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlanCopyWith<$Res> {
  factory $PlanCopyWith(Plan value, $Res Function(Plan) then) =
      _$PlanCopyWithImpl<$Res, Plan>;
  @useResult
  $Res call(
      {String? id,
      String? householdId,
      String? title,
      String status,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$PlanCopyWithImpl<$Res, $Val extends Plan>
    implements $PlanCopyWith<$Res> {
  _$PlanCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Plan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? householdId = freezed,
    Object? title = freezed,
    Object? status = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      householdId: freezed == householdId
          ? _value.householdId
          : householdId // ignore: cast_nullable_to_non_nullable
              as String?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlanImplCopyWith<$Res> implements $PlanCopyWith<$Res> {
  factory _$$PlanImplCopyWith(
          _$PlanImpl value, $Res Function(_$PlanImpl) then) =
      __$$PlanImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String? householdId,
      String? title,
      String status,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$PlanImplCopyWithImpl<$Res>
    extends _$PlanCopyWithImpl<$Res, _$PlanImpl>
    implements _$$PlanImplCopyWith<$Res> {
  __$$PlanImplCopyWithImpl(_$PlanImpl _value, $Res Function(_$PlanImpl) _then)
      : super(_value, _then);

  /// Create a copy of Plan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? householdId = freezed,
    Object? title = freezed,
    Object? status = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$PlanImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      householdId: freezed == householdId
          ? _value.householdId
          : householdId // ignore: cast_nullable_to_non_nullable
              as String?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlanImpl implements _Plan {
  const _$PlanImpl(
      {this.id,
      this.householdId,
      this.title,
      this.status = 'active',
      this.createdAt,
      this.updatedAt});

  factory _$PlanImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlanImplFromJson(json);

  @override
  final String? id;
  @override
  final String? householdId;
  @override
  final String? title;
  @override
  @JsonKey()
  final String status;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Plan(id: $id, householdId: $householdId, title: $title, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlanImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.householdId, householdId) ||
                other.householdId == householdId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, householdId, title, status, createdAt, updatedAt);

  /// Create a copy of Plan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlanImplCopyWith<_$PlanImpl> get copyWith =>
      __$$PlanImplCopyWithImpl<_$PlanImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlanImplToJson(
      this,
    );
  }
}

abstract class _Plan implements Plan {
  const factory _Plan(
      {final String? id,
      final String? householdId,
      final String? title,
      final String status,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$PlanImpl;

  factory _Plan.fromJson(Map<String, dynamic> json) = _$PlanImpl.fromJson;

  @override
  String? get id;
  @override
  String? get householdId;
  @override
  String? get title;
  @override
  String get status;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of Plan
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlanImplCopyWith<_$PlanImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PlanMember _$PlanMemberFromJson(Map<String, dynamic> json) {
  return _PlanMember.fromJson(json);
}

/// @nodoc
mixin _$PlanMember {
  String get id => throw _privateConstructorUsedError;
  String get planId => throw _privateConstructorUsedError;
  String get memberId => throw _privateConstructorUsedError;
  String get role => throw _privateConstructorUsedError;
  bool get canDecide => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this PlanMember to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlanMember
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlanMemberCopyWith<PlanMember> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlanMemberCopyWith<$Res> {
  factory $PlanMemberCopyWith(
          PlanMember value, $Res Function(PlanMember) then) =
      _$PlanMemberCopyWithImpl<$Res, PlanMember>;
  @useResult
  $Res call(
      {String id,
      String planId,
      String memberId,
      String role,
      bool canDecide,
      DateTime? createdAt});
}

/// @nodoc
class _$PlanMemberCopyWithImpl<$Res, $Val extends PlanMember>
    implements $PlanMemberCopyWith<$Res> {
  _$PlanMemberCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlanMember
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? planId = null,
    Object? memberId = null,
    Object? role = null,
    Object? canDecide = null,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      planId: null == planId
          ? _value.planId
          : planId // ignore: cast_nullable_to_non_nullable
              as String,
      memberId: null == memberId
          ? _value.memberId
          : memberId // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      canDecide: null == canDecide
          ? _value.canDecide
          : canDecide // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlanMemberImplCopyWith<$Res>
    implements $PlanMemberCopyWith<$Res> {
  factory _$$PlanMemberImplCopyWith(
          _$PlanMemberImpl value, $Res Function(_$PlanMemberImpl) then) =
      __$$PlanMemberImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String planId,
      String memberId,
      String role,
      bool canDecide,
      DateTime? createdAt});
}

/// @nodoc
class __$$PlanMemberImplCopyWithImpl<$Res>
    extends _$PlanMemberCopyWithImpl<$Res, _$PlanMemberImpl>
    implements _$$PlanMemberImplCopyWith<$Res> {
  __$$PlanMemberImplCopyWithImpl(
      _$PlanMemberImpl _value, $Res Function(_$PlanMemberImpl) _then)
      : super(_value, _then);

  /// Create a copy of PlanMember
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? planId = null,
    Object? memberId = null,
    Object? role = null,
    Object? canDecide = null,
    Object? createdAt = freezed,
  }) {
    return _then(_$PlanMemberImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      planId: null == planId
          ? _value.planId
          : planId // ignore: cast_nullable_to_non_nullable
              as String,
      memberId: null == memberId
          ? _value.memberId
          : memberId // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      canDecide: null == canDecide
          ? _value.canDecide
          : canDecide // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlanMemberImpl implements _PlanMember {
  const _$PlanMemberImpl(
      {required this.id,
      required this.planId,
      required this.memberId,
      this.role = 'kid',
      this.canDecide = false,
      this.createdAt});

  factory _$PlanMemberImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlanMemberImplFromJson(json);

  @override
  final String id;
  @override
  final String planId;
  @override
  final String memberId;
  @override
  @JsonKey()
  final String role;
  @override
  @JsonKey()
  final bool canDecide;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'PlanMember(id: $id, planId: $planId, memberId: $memberId, role: $role, canDecide: $canDecide, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlanMemberImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.planId, planId) || other.planId == planId) &&
            (identical(other.memberId, memberId) ||
                other.memberId == memberId) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.canDecide, canDecide) ||
                other.canDecide == canDecide) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, planId, memberId, role, canDecide, createdAt);

  /// Create a copy of PlanMember
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlanMemberImplCopyWith<_$PlanMemberImpl> get copyWith =>
      __$$PlanMemberImplCopyWithImpl<_$PlanMemberImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlanMemberImplToJson(
      this,
    );
  }
}

abstract class _PlanMember implements PlanMember {
  const factory _PlanMember(
      {required final String id,
      required final String planId,
      required final String memberId,
      final String role,
      final bool canDecide,
      final DateTime? createdAt}) = _$PlanMemberImpl;

  factory _PlanMember.fromJson(Map<String, dynamic> json) =
      _$PlanMemberImpl.fromJson;

  @override
  String get id;
  @override
  String get planId;
  @override
  String get memberId;
  @override
  String get role;
  @override
  bool get canDecide;
  @override
  DateTime? get createdAt;

  /// Create a copy of PlanMember
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlanMemberImplCopyWith<_$PlanMemberImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PlanMessage _$PlanMessageFromJson(Map<String, dynamic> json) {
  return _PlanMessage.fromJson(json);
}

/// @nodoc
mixin _$PlanMessage {
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'plan_id')
  String? get planId => throw _privateConstructorUsedError;
  @JsonKey(name: 'author_type')
  String? get authorType =>
      throw _privateConstructorUsedError; // 'member' or 'morgan'
  @JsonKey(name: 'author_member_id')
  String? get authorMemberId => throw _privateConstructorUsedError;
  @JsonKey(name: 'body_md')
  String? get bodyMd => throw _privateConstructorUsedError;
  @JsonKey(name: 'time_ago')
  String? get timeAgo =>
      throw _privateConstructorUsedError; // Human-readable timestamp from backend
  List<dynamic> get attachments => throw _privateConstructorUsedError;
  @JsonKey(name: 'reply_to_id')
  String? get replyToId => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this PlanMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlanMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlanMessageCopyWith<PlanMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlanMessageCopyWith<$Res> {
  factory $PlanMessageCopyWith(
          PlanMessage value, $Res Function(PlanMessage) then) =
      _$PlanMessageCopyWithImpl<$Res, PlanMessage>;
  @useResult
  $Res call(
      {String? id,
      @JsonKey(name: 'plan_id') String? planId,
      @JsonKey(name: 'author_type') String? authorType,
      @JsonKey(name: 'author_member_id') String? authorMemberId,
      @JsonKey(name: 'body_md') String? bodyMd,
      @JsonKey(name: 'time_ago') String? timeAgo,
      List<dynamic> attachments,
      @JsonKey(name: 'reply_to_id') String? replyToId,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class _$PlanMessageCopyWithImpl<$Res, $Val extends PlanMessage>
    implements $PlanMessageCopyWith<$Res> {
  _$PlanMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlanMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? planId = freezed,
    Object? authorType = freezed,
    Object? authorMemberId = freezed,
    Object? bodyMd = freezed,
    Object? timeAgo = freezed,
    Object? attachments = null,
    Object? replyToId = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      planId: freezed == planId
          ? _value.planId
          : planId // ignore: cast_nullable_to_non_nullable
              as String?,
      authorType: freezed == authorType
          ? _value.authorType
          : authorType // ignore: cast_nullable_to_non_nullable
              as String?,
      authorMemberId: freezed == authorMemberId
          ? _value.authorMemberId
          : authorMemberId // ignore: cast_nullable_to_non_nullable
              as String?,
      bodyMd: freezed == bodyMd
          ? _value.bodyMd
          : bodyMd // ignore: cast_nullable_to_non_nullable
              as String?,
      timeAgo: freezed == timeAgo
          ? _value.timeAgo
          : timeAgo // ignore: cast_nullable_to_non_nullable
              as String?,
      attachments: null == attachments
          ? _value.attachments
          : attachments // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      replyToId: freezed == replyToId
          ? _value.replyToId
          : replyToId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlanMessageImplCopyWith<$Res>
    implements $PlanMessageCopyWith<$Res> {
  factory _$$PlanMessageImplCopyWith(
          _$PlanMessageImpl value, $Res Function(_$PlanMessageImpl) then) =
      __$$PlanMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      @JsonKey(name: 'plan_id') String? planId,
      @JsonKey(name: 'author_type') String? authorType,
      @JsonKey(name: 'author_member_id') String? authorMemberId,
      @JsonKey(name: 'body_md') String? bodyMd,
      @JsonKey(name: 'time_ago') String? timeAgo,
      List<dynamic> attachments,
      @JsonKey(name: 'reply_to_id') String? replyToId,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class __$$PlanMessageImplCopyWithImpl<$Res>
    extends _$PlanMessageCopyWithImpl<$Res, _$PlanMessageImpl>
    implements _$$PlanMessageImplCopyWith<$Res> {
  __$$PlanMessageImplCopyWithImpl(
      _$PlanMessageImpl _value, $Res Function(_$PlanMessageImpl) _then)
      : super(_value, _then);

  /// Create a copy of PlanMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? planId = freezed,
    Object? authorType = freezed,
    Object? authorMemberId = freezed,
    Object? bodyMd = freezed,
    Object? timeAgo = freezed,
    Object? attachments = null,
    Object? replyToId = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$PlanMessageImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      planId: freezed == planId
          ? _value.planId
          : planId // ignore: cast_nullable_to_non_nullable
              as String?,
      authorType: freezed == authorType
          ? _value.authorType
          : authorType // ignore: cast_nullable_to_non_nullable
              as String?,
      authorMemberId: freezed == authorMemberId
          ? _value.authorMemberId
          : authorMemberId // ignore: cast_nullable_to_non_nullable
              as String?,
      bodyMd: freezed == bodyMd
          ? _value.bodyMd
          : bodyMd // ignore: cast_nullable_to_non_nullable
              as String?,
      timeAgo: freezed == timeAgo
          ? _value.timeAgo
          : timeAgo // ignore: cast_nullable_to_non_nullable
              as String?,
      attachments: null == attachments
          ? _value._attachments
          : attachments // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      replyToId: freezed == replyToId
          ? _value.replyToId
          : replyToId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlanMessageImpl implements _PlanMessage {
  const _$PlanMessageImpl(
      {this.id,
      @JsonKey(name: 'plan_id') this.planId,
      @JsonKey(name: 'author_type') this.authorType,
      @JsonKey(name: 'author_member_id') this.authorMemberId,
      @JsonKey(name: 'body_md') this.bodyMd,
      @JsonKey(name: 'time_ago') this.timeAgo,
      final List<dynamic> attachments = const [],
      @JsonKey(name: 'reply_to_id') this.replyToId,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt})
      : _attachments = attachments;

  factory _$PlanMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlanMessageImplFromJson(json);

  @override
  final String? id;
  @override
  @JsonKey(name: 'plan_id')
  final String? planId;
  @override
  @JsonKey(name: 'author_type')
  final String? authorType;
// 'member' or 'morgan'
  @override
  @JsonKey(name: 'author_member_id')
  final String? authorMemberId;
  @override
  @JsonKey(name: 'body_md')
  final String? bodyMd;
  @override
  @JsonKey(name: 'time_ago')
  final String? timeAgo;
// Human-readable timestamp from backend
  final List<dynamic> _attachments;
// Human-readable timestamp from backend
  @override
  @JsonKey()
  List<dynamic> get attachments {
    if (_attachments is EqualUnmodifiableListView) return _attachments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_attachments);
  }

  @override
  @JsonKey(name: 'reply_to_id')
  final String? replyToId;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'PlanMessage(id: $id, planId: $planId, authorType: $authorType, authorMemberId: $authorMemberId, bodyMd: $bodyMd, timeAgo: $timeAgo, attachments: $attachments, replyToId: $replyToId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlanMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.planId, planId) || other.planId == planId) &&
            (identical(other.authorType, authorType) ||
                other.authorType == authorType) &&
            (identical(other.authorMemberId, authorMemberId) ||
                other.authorMemberId == authorMemberId) &&
            (identical(other.bodyMd, bodyMd) || other.bodyMd == bodyMd) &&
            (identical(other.timeAgo, timeAgo) || other.timeAgo == timeAgo) &&
            const DeepCollectionEquality()
                .equals(other._attachments, _attachments) &&
            (identical(other.replyToId, replyToId) ||
                other.replyToId == replyToId) &&
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
      planId,
      authorType,
      authorMemberId,
      bodyMd,
      timeAgo,
      const DeepCollectionEquality().hash(_attachments),
      replyToId,
      createdAt,
      updatedAt);

  /// Create a copy of PlanMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlanMessageImplCopyWith<_$PlanMessageImpl> get copyWith =>
      __$$PlanMessageImplCopyWithImpl<_$PlanMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlanMessageImplToJson(
      this,
    );
  }
}

abstract class _PlanMessage implements PlanMessage {
  const factory _PlanMessage(
          {final String? id,
          @JsonKey(name: 'plan_id') final String? planId,
          @JsonKey(name: 'author_type') final String? authorType,
          @JsonKey(name: 'author_member_id') final String? authorMemberId,
          @JsonKey(name: 'body_md') final String? bodyMd,
          @JsonKey(name: 'time_ago') final String? timeAgo,
          final List<dynamic> attachments,
          @JsonKey(name: 'reply_to_id') final String? replyToId,
          @JsonKey(name: 'created_at') final DateTime? createdAt,
          @JsonKey(name: 'updated_at') final DateTime? updatedAt}) =
      _$PlanMessageImpl;

  factory _PlanMessage.fromJson(Map<String, dynamic> json) =
      _$PlanMessageImpl.fromJson;

  @override
  String? get id;
  @override
  @JsonKey(name: 'plan_id')
  String? get planId;
  @override
  @JsonKey(name: 'author_type')
  String? get authorType; // 'member' or 'morgan'
  @override
  @JsonKey(name: 'author_member_id')
  String? get authorMemberId;
  @override
  @JsonKey(name: 'body_md')
  String? get bodyMd;
  @override
  @JsonKey(name: 'time_ago')
  String? get timeAgo; // Human-readable timestamp from backend
  @override
  List<dynamic> get attachments;
  @override
  @JsonKey(name: 'reply_to_id')
  String? get replyToId;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;

  /// Create a copy of PlanMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlanMessageImplCopyWith<_$PlanMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PlanProposal _$PlanProposalFromJson(Map<String, dynamic> json) {
  return _PlanProposal.fromJson(json);
}

/// @nodoc
mixin _$PlanProposal {
  String? get id => throw _privateConstructorUsedError;
  String? get planId => throw _privateConstructorUsedError;
  String? get activityName => throw _privateConstructorUsedError;
  String? get activityId => throw _privateConstructorUsedError;
  String? get proposedByMemberId => throw _privateConstructorUsedError;
  String? get reasoning => throw _privateConstructorUsedError;
  int? get durationMin => throw _privateConstructorUsedError;
  String? get costBand => throw _privateConstructorUsedError;
  String? get indoorOutdoor => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  Map<String, dynamic>? get detailsJson => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this PlanProposal to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlanProposal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlanProposalCopyWith<PlanProposal> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlanProposalCopyWith<$Res> {
  factory $PlanProposalCopyWith(
          PlanProposal value, $Res Function(PlanProposal) then) =
      _$PlanProposalCopyWithImpl<$Res, PlanProposal>;
  @useResult
  $Res call(
      {String? id,
      String? planId,
      String? activityName,
      String? activityId,
      String? proposedByMemberId,
      String? reasoning,
      int? durationMin,
      String? costBand,
      String? indoorOutdoor,
      String? location,
      List<String> tags,
      Map<String, dynamic>? detailsJson,
      DateTime? createdAt});
}

/// @nodoc
class _$PlanProposalCopyWithImpl<$Res, $Val extends PlanProposal>
    implements $PlanProposalCopyWith<$Res> {
  _$PlanProposalCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlanProposal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? planId = freezed,
    Object? activityName = freezed,
    Object? activityId = freezed,
    Object? proposedByMemberId = freezed,
    Object? reasoning = freezed,
    Object? durationMin = freezed,
    Object? costBand = freezed,
    Object? indoorOutdoor = freezed,
    Object? location = freezed,
    Object? tags = null,
    Object? detailsJson = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      planId: freezed == planId
          ? _value.planId
          : planId // ignore: cast_nullable_to_non_nullable
              as String?,
      activityName: freezed == activityName
          ? _value.activityName
          : activityName // ignore: cast_nullable_to_non_nullable
              as String?,
      activityId: freezed == activityId
          ? _value.activityId
          : activityId // ignore: cast_nullable_to_non_nullable
              as String?,
      proposedByMemberId: freezed == proposedByMemberId
          ? _value.proposedByMemberId
          : proposedByMemberId // ignore: cast_nullable_to_non_nullable
              as String?,
      reasoning: freezed == reasoning
          ? _value.reasoning
          : reasoning // ignore: cast_nullable_to_non_nullable
              as String?,
      durationMin: freezed == durationMin
          ? _value.durationMin
          : durationMin // ignore: cast_nullable_to_non_nullable
              as int?,
      costBand: freezed == costBand
          ? _value.costBand
          : costBand // ignore: cast_nullable_to_non_nullable
              as String?,
      indoorOutdoor: freezed == indoorOutdoor
          ? _value.indoorOutdoor
          : indoorOutdoor // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      detailsJson: freezed == detailsJson
          ? _value.detailsJson
          : detailsJson // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlanProposalImplCopyWith<$Res>
    implements $PlanProposalCopyWith<$Res> {
  factory _$$PlanProposalImplCopyWith(
          _$PlanProposalImpl value, $Res Function(_$PlanProposalImpl) then) =
      __$$PlanProposalImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String? planId,
      String? activityName,
      String? activityId,
      String? proposedByMemberId,
      String? reasoning,
      int? durationMin,
      String? costBand,
      String? indoorOutdoor,
      String? location,
      List<String> tags,
      Map<String, dynamic>? detailsJson,
      DateTime? createdAt});
}

/// @nodoc
class __$$PlanProposalImplCopyWithImpl<$Res>
    extends _$PlanProposalCopyWithImpl<$Res, _$PlanProposalImpl>
    implements _$$PlanProposalImplCopyWith<$Res> {
  __$$PlanProposalImplCopyWithImpl(
      _$PlanProposalImpl _value, $Res Function(_$PlanProposalImpl) _then)
      : super(_value, _then);

  /// Create a copy of PlanProposal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? planId = freezed,
    Object? activityName = freezed,
    Object? activityId = freezed,
    Object? proposedByMemberId = freezed,
    Object? reasoning = freezed,
    Object? durationMin = freezed,
    Object? costBand = freezed,
    Object? indoorOutdoor = freezed,
    Object? location = freezed,
    Object? tags = null,
    Object? detailsJson = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_$PlanProposalImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      planId: freezed == planId
          ? _value.planId
          : planId // ignore: cast_nullable_to_non_nullable
              as String?,
      activityName: freezed == activityName
          ? _value.activityName
          : activityName // ignore: cast_nullable_to_non_nullable
              as String?,
      activityId: freezed == activityId
          ? _value.activityId
          : activityId // ignore: cast_nullable_to_non_nullable
              as String?,
      proposedByMemberId: freezed == proposedByMemberId
          ? _value.proposedByMemberId
          : proposedByMemberId // ignore: cast_nullable_to_non_nullable
              as String?,
      reasoning: freezed == reasoning
          ? _value.reasoning
          : reasoning // ignore: cast_nullable_to_non_nullable
              as String?,
      durationMin: freezed == durationMin
          ? _value.durationMin
          : durationMin // ignore: cast_nullable_to_non_nullable
              as int?,
      costBand: freezed == costBand
          ? _value.costBand
          : costBand // ignore: cast_nullable_to_non_nullable
              as String?,
      indoorOutdoor: freezed == indoorOutdoor
          ? _value.indoorOutdoor
          : indoorOutdoor // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      detailsJson: freezed == detailsJson
          ? _value._detailsJson
          : detailsJson // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlanProposalImpl implements _PlanProposal {
  const _$PlanProposalImpl(
      {this.id,
      this.planId,
      this.activityName,
      this.activityId,
      this.proposedByMemberId,
      this.reasoning,
      this.durationMin,
      this.costBand,
      this.indoorOutdoor,
      this.location,
      final List<String> tags = const [],
      final Map<String, dynamic>? detailsJson,
      this.createdAt})
      : _tags = tags,
        _detailsJson = detailsJson;

  factory _$PlanProposalImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlanProposalImplFromJson(json);

  @override
  final String? id;
  @override
  final String? planId;
  @override
  final String? activityName;
  @override
  final String? activityId;
  @override
  final String? proposedByMemberId;
  @override
  final String? reasoning;
  @override
  final int? durationMin;
  @override
  final String? costBand;
  @override
  final String? indoorOutdoor;
  @override
  final String? location;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  final Map<String, dynamic>? _detailsJson;
  @override
  Map<String, dynamic>? get detailsJson {
    final value = _detailsJson;
    if (value == null) return null;
    if (_detailsJson is EqualUnmodifiableMapView) return _detailsJson;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'PlanProposal(id: $id, planId: $planId, activityName: $activityName, activityId: $activityId, proposedByMemberId: $proposedByMemberId, reasoning: $reasoning, durationMin: $durationMin, costBand: $costBand, indoorOutdoor: $indoorOutdoor, location: $location, tags: $tags, detailsJson: $detailsJson, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlanProposalImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.planId, planId) || other.planId == planId) &&
            (identical(other.activityName, activityName) ||
                other.activityName == activityName) &&
            (identical(other.activityId, activityId) ||
                other.activityId == activityId) &&
            (identical(other.proposedByMemberId, proposedByMemberId) ||
                other.proposedByMemberId == proposedByMemberId) &&
            (identical(other.reasoning, reasoning) ||
                other.reasoning == reasoning) &&
            (identical(other.durationMin, durationMin) ||
                other.durationMin == durationMin) &&
            (identical(other.costBand, costBand) ||
                other.costBand == costBand) &&
            (identical(other.indoorOutdoor, indoorOutdoor) ||
                other.indoorOutdoor == indoorOutdoor) &&
            (identical(other.location, location) ||
                other.location == location) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            const DeepCollectionEquality()
                .equals(other._detailsJson, _detailsJson) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      planId,
      activityName,
      activityId,
      proposedByMemberId,
      reasoning,
      durationMin,
      costBand,
      indoorOutdoor,
      location,
      const DeepCollectionEquality().hash(_tags),
      const DeepCollectionEquality().hash(_detailsJson),
      createdAt);

  /// Create a copy of PlanProposal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlanProposalImplCopyWith<_$PlanProposalImpl> get copyWith =>
      __$$PlanProposalImplCopyWithImpl<_$PlanProposalImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlanProposalImplToJson(
      this,
    );
  }
}

abstract class _PlanProposal implements PlanProposal {
  const factory _PlanProposal(
      {final String? id,
      final String? planId,
      final String? activityName,
      final String? activityId,
      final String? proposedByMemberId,
      final String? reasoning,
      final int? durationMin,
      final String? costBand,
      final String? indoorOutdoor,
      final String? location,
      final List<String> tags,
      final Map<String, dynamic>? detailsJson,
      final DateTime? createdAt}) = _$PlanProposalImpl;

  factory _PlanProposal.fromJson(Map<String, dynamic> json) =
      _$PlanProposalImpl.fromJson;

  @override
  String? get id;
  @override
  String? get planId;
  @override
  String? get activityName;
  @override
  String? get activityId;
  @override
  String? get proposedByMemberId;
  @override
  String? get reasoning;
  @override
  int? get durationMin;
  @override
  String? get costBand;
  @override
  String? get indoorOutdoor;
  @override
  String? get location;
  @override
  List<String> get tags;
  @override
  Map<String, dynamic>? get detailsJson;
  @override
  DateTime? get createdAt;

  /// Create a copy of PlanProposal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlanProposalImplCopyWith<_$PlanProposalImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PlanVote _$PlanVoteFromJson(Map<String, dynamic> json) {
  return _PlanVote.fromJson(json);
}

/// @nodoc
mixin _$PlanVote {
  String? get id => throw _privateConstructorUsedError;
  String? get proposalId => throw _privateConstructorUsedError;
  String? get voterMemberId => throw _privateConstructorUsedError;
  int get value => throw _privateConstructorUsedError; // +1, 0, -1
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this PlanVote to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlanVote
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlanVoteCopyWith<PlanVote> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlanVoteCopyWith<$Res> {
  factory $PlanVoteCopyWith(PlanVote value, $Res Function(PlanVote) then) =
      _$PlanVoteCopyWithImpl<$Res, PlanVote>;
  @useResult
  $Res call(
      {String? id,
      String? proposalId,
      String? voterMemberId,
      int value,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$PlanVoteCopyWithImpl<$Res, $Val extends PlanVote>
    implements $PlanVoteCopyWith<$Res> {
  _$PlanVoteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlanVote
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? proposalId = freezed,
    Object? voterMemberId = freezed,
    Object? value = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      proposalId: freezed == proposalId
          ? _value.proposalId
          : proposalId // ignore: cast_nullable_to_non_nullable
              as String?,
      voterMemberId: freezed == voterMemberId
          ? _value.voterMemberId
          : voterMemberId // ignore: cast_nullable_to_non_nullable
              as String?,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlanVoteImplCopyWith<$Res>
    implements $PlanVoteCopyWith<$Res> {
  factory _$$PlanVoteImplCopyWith(
          _$PlanVoteImpl value, $Res Function(_$PlanVoteImpl) then) =
      __$$PlanVoteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String? proposalId,
      String? voterMemberId,
      int value,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$PlanVoteImplCopyWithImpl<$Res>
    extends _$PlanVoteCopyWithImpl<$Res, _$PlanVoteImpl>
    implements _$$PlanVoteImplCopyWith<$Res> {
  __$$PlanVoteImplCopyWithImpl(
      _$PlanVoteImpl _value, $Res Function(_$PlanVoteImpl) _then)
      : super(_value, _then);

  /// Create a copy of PlanVote
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? proposalId = freezed,
    Object? voterMemberId = freezed,
    Object? value = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$PlanVoteImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      proposalId: freezed == proposalId
          ? _value.proposalId
          : proposalId // ignore: cast_nullable_to_non_nullable
              as String?,
      voterMemberId: freezed == voterMemberId
          ? _value.voterMemberId
          : voterMemberId // ignore: cast_nullable_to_non_nullable
              as String?,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlanVoteImpl implements _PlanVote {
  const _$PlanVoteImpl(
      {this.id,
      this.proposalId,
      this.voterMemberId,
      this.value = 0,
      this.createdAt,
      this.updatedAt});

  factory _$PlanVoteImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlanVoteImplFromJson(json);

  @override
  final String? id;
  @override
  final String? proposalId;
  @override
  final String? voterMemberId;
  @override
  @JsonKey()
  final int value;
// +1, 0, -1
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'PlanVote(id: $id, proposalId: $proposalId, voterMemberId: $voterMemberId, value: $value, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlanVoteImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.proposalId, proposalId) ||
                other.proposalId == proposalId) &&
            (identical(other.voterMemberId, voterMemberId) ||
                other.voterMemberId == voterMemberId) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, proposalId, voterMemberId, value, createdAt, updatedAt);

  /// Create a copy of PlanVote
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlanVoteImplCopyWith<_$PlanVoteImpl> get copyWith =>
      __$$PlanVoteImplCopyWithImpl<_$PlanVoteImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlanVoteImplToJson(
      this,
    );
  }
}

abstract class _PlanVote implements PlanVote {
  const factory _PlanVote(
      {final String? id,
      final String? proposalId,
      final String? voterMemberId,
      final int value,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$PlanVoteImpl;

  factory _PlanVote.fromJson(Map<String, dynamic> json) =
      _$PlanVoteImpl.fromJson;

  @override
  String? get id;
  @override
  String? get proposalId;
  @override
  String? get voterMemberId;
  @override
  int get value; // +1, 0, -1
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of PlanVote
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlanVoteImplCopyWith<_$PlanVoteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PlanConstraint _$PlanConstraintFromJson(Map<String, dynamic> json) {
  return _PlanConstraint.fromJson(json);
}

/// @nodoc
mixin _$PlanConstraint {
  String? get id => throw _privateConstructorUsedError;
  String? get planId => throw _privateConstructorUsedError;
  String? get type => throw _privateConstructorUsedError;
  Map<String, dynamic>? get valueJson => throw _privateConstructorUsedError;
  String? get addedByMemberId => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this PlanConstraint to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlanConstraint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlanConstraintCopyWith<PlanConstraint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlanConstraintCopyWith<$Res> {
  factory $PlanConstraintCopyWith(
          PlanConstraint value, $Res Function(PlanConstraint) then) =
      _$PlanConstraintCopyWithImpl<$Res, PlanConstraint>;
  @useResult
  $Res call(
      {String? id,
      String? planId,
      String? type,
      Map<String, dynamic>? valueJson,
      String? addedByMemberId,
      DateTime? createdAt});
}

/// @nodoc
class _$PlanConstraintCopyWithImpl<$Res, $Val extends PlanConstraint>
    implements $PlanConstraintCopyWith<$Res> {
  _$PlanConstraintCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlanConstraint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? planId = freezed,
    Object? type = freezed,
    Object? valueJson = freezed,
    Object? addedByMemberId = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      planId: freezed == planId
          ? _value.planId
          : planId // ignore: cast_nullable_to_non_nullable
              as String?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      valueJson: freezed == valueJson
          ? _value.valueJson
          : valueJson // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      addedByMemberId: freezed == addedByMemberId
          ? _value.addedByMemberId
          : addedByMemberId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlanConstraintImplCopyWith<$Res>
    implements $PlanConstraintCopyWith<$Res> {
  factory _$$PlanConstraintImplCopyWith(_$PlanConstraintImpl value,
          $Res Function(_$PlanConstraintImpl) then) =
      __$$PlanConstraintImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String? planId,
      String? type,
      Map<String, dynamic>? valueJson,
      String? addedByMemberId,
      DateTime? createdAt});
}

/// @nodoc
class __$$PlanConstraintImplCopyWithImpl<$Res>
    extends _$PlanConstraintCopyWithImpl<$Res, _$PlanConstraintImpl>
    implements _$$PlanConstraintImplCopyWith<$Res> {
  __$$PlanConstraintImplCopyWithImpl(
      _$PlanConstraintImpl _value, $Res Function(_$PlanConstraintImpl) _then)
      : super(_value, _then);

  /// Create a copy of PlanConstraint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? planId = freezed,
    Object? type = freezed,
    Object? valueJson = freezed,
    Object? addedByMemberId = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_$PlanConstraintImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      planId: freezed == planId
          ? _value.planId
          : planId // ignore: cast_nullable_to_non_nullable
              as String?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      valueJson: freezed == valueJson
          ? _value._valueJson
          : valueJson // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      addedByMemberId: freezed == addedByMemberId
          ? _value.addedByMemberId
          : addedByMemberId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlanConstraintImpl implements _PlanConstraint {
  const _$PlanConstraintImpl(
      {this.id,
      this.planId,
      this.type,
      final Map<String, dynamic>? valueJson,
      this.addedByMemberId,
      this.createdAt})
      : _valueJson = valueJson;

  factory _$PlanConstraintImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlanConstraintImplFromJson(json);

  @override
  final String? id;
  @override
  final String? planId;
  @override
  final String? type;
  final Map<String, dynamic>? _valueJson;
  @override
  Map<String, dynamic>? get valueJson {
    final value = _valueJson;
    if (value == null) return null;
    if (_valueJson is EqualUnmodifiableMapView) return _valueJson;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? addedByMemberId;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'PlanConstraint(id: $id, planId: $planId, type: $type, valueJson: $valueJson, addedByMemberId: $addedByMemberId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlanConstraintImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.planId, planId) || other.planId == planId) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality()
                .equals(other._valueJson, _valueJson) &&
            (identical(other.addedByMemberId, addedByMemberId) ||
                other.addedByMemberId == addedByMemberId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      planId,
      type,
      const DeepCollectionEquality().hash(_valueJson),
      addedByMemberId,
      createdAt);

  /// Create a copy of PlanConstraint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlanConstraintImplCopyWith<_$PlanConstraintImpl> get copyWith =>
      __$$PlanConstraintImplCopyWithImpl<_$PlanConstraintImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlanConstraintImplToJson(
      this,
    );
  }
}

abstract class _PlanConstraint implements PlanConstraint {
  const factory _PlanConstraint(
      {final String? id,
      final String? planId,
      final String? type,
      final Map<String, dynamic>? valueJson,
      final String? addedByMemberId,
      final DateTime? createdAt}) = _$PlanConstraintImpl;

  factory _PlanConstraint.fromJson(Map<String, dynamic> json) =
      _$PlanConstraintImpl.fromJson;

  @override
  String? get id;
  @override
  String? get planId;
  @override
  String? get type;
  @override
  Map<String, dynamic>? get valueJson;
  @override
  String? get addedByMemberId;
  @override
  DateTime? get createdAt;

  /// Create a copy of PlanConstraint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlanConstraintImplCopyWith<_$PlanConstraintImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PlanDecision _$PlanDecisionFromJson(Map<String, dynamic> json) {
  return _PlanDecision.fromJson(json);
}

/// @nodoc
mixin _$PlanDecision {
  String? get id => throw _privateConstructorUsedError;
  String? get planId => throw _privateConstructorUsedError;
  String? get proposalId => throw _privateConstructorUsedError;
  String get summaryMd => throw _privateConstructorUsedError;
  String? get decidedByMemberId => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this PlanDecision to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlanDecision
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlanDecisionCopyWith<PlanDecision> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlanDecisionCopyWith<$Res> {
  factory $PlanDecisionCopyWith(
          PlanDecision value, $Res Function(PlanDecision) then) =
      _$PlanDecisionCopyWithImpl<$Res, PlanDecision>;
  @useResult
  $Res call(
      {String? id,
      String? planId,
      String? proposalId,
      String summaryMd,
      String? decidedByMemberId,
      DateTime? createdAt});
}

/// @nodoc
class _$PlanDecisionCopyWithImpl<$Res, $Val extends PlanDecision>
    implements $PlanDecisionCopyWith<$Res> {
  _$PlanDecisionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlanDecision
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? planId = freezed,
    Object? proposalId = freezed,
    Object? summaryMd = null,
    Object? decidedByMemberId = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      planId: freezed == planId
          ? _value.planId
          : planId // ignore: cast_nullable_to_non_nullable
              as String?,
      proposalId: freezed == proposalId
          ? _value.proposalId
          : proposalId // ignore: cast_nullable_to_non_nullable
              as String?,
      summaryMd: null == summaryMd
          ? _value.summaryMd
          : summaryMd // ignore: cast_nullable_to_non_nullable
              as String,
      decidedByMemberId: freezed == decidedByMemberId
          ? _value.decidedByMemberId
          : decidedByMemberId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlanDecisionImplCopyWith<$Res>
    implements $PlanDecisionCopyWith<$Res> {
  factory _$$PlanDecisionImplCopyWith(
          _$PlanDecisionImpl value, $Res Function(_$PlanDecisionImpl) then) =
      __$$PlanDecisionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String? planId,
      String? proposalId,
      String summaryMd,
      String? decidedByMemberId,
      DateTime? createdAt});
}

/// @nodoc
class __$$PlanDecisionImplCopyWithImpl<$Res>
    extends _$PlanDecisionCopyWithImpl<$Res, _$PlanDecisionImpl>
    implements _$$PlanDecisionImplCopyWith<$Res> {
  __$$PlanDecisionImplCopyWithImpl(
      _$PlanDecisionImpl _value, $Res Function(_$PlanDecisionImpl) _then)
      : super(_value, _then);

  /// Create a copy of PlanDecision
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? planId = freezed,
    Object? proposalId = freezed,
    Object? summaryMd = null,
    Object? decidedByMemberId = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_$PlanDecisionImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      planId: freezed == planId
          ? _value.planId
          : planId // ignore: cast_nullable_to_non_nullable
              as String?,
      proposalId: freezed == proposalId
          ? _value.proposalId
          : proposalId // ignore: cast_nullable_to_non_nullable
              as String?,
      summaryMd: null == summaryMd
          ? _value.summaryMd
          : summaryMd // ignore: cast_nullable_to_non_nullable
              as String,
      decidedByMemberId: freezed == decidedByMemberId
          ? _value.decidedByMemberId
          : decidedByMemberId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlanDecisionImpl implements _PlanDecision {
  const _$PlanDecisionImpl(
      {this.id,
      this.planId,
      this.proposalId,
      this.summaryMd = '',
      this.decidedByMemberId,
      this.createdAt});

  factory _$PlanDecisionImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlanDecisionImplFromJson(json);

  @override
  final String? id;
  @override
  final String? planId;
  @override
  final String? proposalId;
  @override
  @JsonKey()
  final String summaryMd;
  @override
  final String? decidedByMemberId;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'PlanDecision(id: $id, planId: $planId, proposalId: $proposalId, summaryMd: $summaryMd, decidedByMemberId: $decidedByMemberId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlanDecisionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.planId, planId) || other.planId == planId) &&
            (identical(other.proposalId, proposalId) ||
                other.proposalId == proposalId) &&
            (identical(other.summaryMd, summaryMd) ||
                other.summaryMd == summaryMd) &&
            (identical(other.decidedByMemberId, decidedByMemberId) ||
                other.decidedByMemberId == decidedByMemberId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, planId, proposalId,
      summaryMd, decidedByMemberId, createdAt);

  /// Create a copy of PlanDecision
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlanDecisionImplCopyWith<_$PlanDecisionImpl> get copyWith =>
      __$$PlanDecisionImplCopyWithImpl<_$PlanDecisionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlanDecisionImplToJson(
      this,
    );
  }
}

abstract class _PlanDecision implements PlanDecision {
  const factory _PlanDecision(
      {final String? id,
      final String? planId,
      final String? proposalId,
      final String summaryMd,
      final String? decidedByMemberId,
      final DateTime? createdAt}) = _$PlanDecisionImpl;

  factory _PlanDecision.fromJson(Map<String, dynamic> json) =
      _$PlanDecisionImpl.fromJson;

  @override
  String? get id;
  @override
  String? get planId;
  @override
  String? get proposalId;
  @override
  String get summaryMd;
  @override
  String? get decidedByMemberId;
  @override
  DateTime? get createdAt;

  /// Create a copy of PlanDecision
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlanDecisionImplCopyWith<_$PlanDecisionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PlanItinerary _$PlanItineraryFromJson(Map<String, dynamic> json) {
  return _PlanItinerary.fromJson(json);
}

/// @nodoc
mixin _$PlanItinerary {
  String? get id => throw _privateConstructorUsedError;
  String? get planId => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  List<dynamic> get itemsJson => throw _privateConstructorUsedError;
  String? get createdByMemberId => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this PlanItinerary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlanItinerary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlanItineraryCopyWith<PlanItinerary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlanItineraryCopyWith<$Res> {
  factory $PlanItineraryCopyWith(
          PlanItinerary value, $Res Function(PlanItinerary) then) =
      _$PlanItineraryCopyWithImpl<$Res, PlanItinerary>;
  @useResult
  $Res call(
      {String? id,
      String? planId,
      String? title,
      List<dynamic> itemsJson,
      String? createdByMemberId,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$PlanItineraryCopyWithImpl<$Res, $Val extends PlanItinerary>
    implements $PlanItineraryCopyWith<$Res> {
  _$PlanItineraryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlanItinerary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? planId = freezed,
    Object? title = freezed,
    Object? itemsJson = null,
    Object? createdByMemberId = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      planId: freezed == planId
          ? _value.planId
          : planId // ignore: cast_nullable_to_non_nullable
              as String?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      itemsJson: null == itemsJson
          ? _value.itemsJson
          : itemsJson // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      createdByMemberId: freezed == createdByMemberId
          ? _value.createdByMemberId
          : createdByMemberId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlanItineraryImplCopyWith<$Res>
    implements $PlanItineraryCopyWith<$Res> {
  factory _$$PlanItineraryImplCopyWith(
          _$PlanItineraryImpl value, $Res Function(_$PlanItineraryImpl) then) =
      __$$PlanItineraryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String? planId,
      String? title,
      List<dynamic> itemsJson,
      String? createdByMemberId,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$PlanItineraryImplCopyWithImpl<$Res>
    extends _$PlanItineraryCopyWithImpl<$Res, _$PlanItineraryImpl>
    implements _$$PlanItineraryImplCopyWith<$Res> {
  __$$PlanItineraryImplCopyWithImpl(
      _$PlanItineraryImpl _value, $Res Function(_$PlanItineraryImpl) _then)
      : super(_value, _then);

  /// Create a copy of PlanItinerary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? planId = freezed,
    Object? title = freezed,
    Object? itemsJson = null,
    Object? createdByMemberId = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$PlanItineraryImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      planId: freezed == planId
          ? _value.planId
          : planId // ignore: cast_nullable_to_non_nullable
              as String?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      itemsJson: null == itemsJson
          ? _value._itemsJson
          : itemsJson // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      createdByMemberId: freezed == createdByMemberId
          ? _value.createdByMemberId
          : createdByMemberId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlanItineraryImpl implements _PlanItinerary {
  const _$PlanItineraryImpl(
      {this.id,
      this.planId,
      this.title,
      final List<dynamic> itemsJson = const [],
      this.createdByMemberId,
      this.createdAt,
      this.updatedAt})
      : _itemsJson = itemsJson;

  factory _$PlanItineraryImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlanItineraryImplFromJson(json);

  @override
  final String? id;
  @override
  final String? planId;
  @override
  final String? title;
  final List<dynamic> _itemsJson;
  @override
  @JsonKey()
  List<dynamic> get itemsJson {
    if (_itemsJson is EqualUnmodifiableListView) return _itemsJson;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_itemsJson);
  }

  @override
  final String? createdByMemberId;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'PlanItinerary(id: $id, planId: $planId, title: $title, itemsJson: $itemsJson, createdByMemberId: $createdByMemberId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlanItineraryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.planId, planId) || other.planId == planId) &&
            (identical(other.title, title) || other.title == title) &&
            const DeepCollectionEquality()
                .equals(other._itemsJson, _itemsJson) &&
            (identical(other.createdByMemberId, createdByMemberId) ||
                other.createdByMemberId == createdByMemberId) &&
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
      planId,
      title,
      const DeepCollectionEquality().hash(_itemsJson),
      createdByMemberId,
      createdAt,
      updatedAt);

  /// Create a copy of PlanItinerary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlanItineraryImplCopyWith<_$PlanItineraryImpl> get copyWith =>
      __$$PlanItineraryImplCopyWithImpl<_$PlanItineraryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlanItineraryImplToJson(
      this,
    );
  }
}

abstract class _PlanItinerary implements PlanItinerary {
  const factory _PlanItinerary(
      {final String? id,
      final String? planId,
      final String? title,
      final List<dynamic> itemsJson,
      final String? createdByMemberId,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$PlanItineraryImpl;

  factory _PlanItinerary.fromJson(Map<String, dynamic> json) =
      _$PlanItineraryImpl.fromJson;

  @override
  String? get id;
  @override
  String? get planId;
  @override
  String? get title;
  @override
  List<dynamic> get itemsJson;
  @override
  String? get createdByMemberId;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of PlanItinerary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlanItineraryImplCopyWith<_$PlanItineraryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PlanSummary _$PlanSummaryFromJson(Map<String, dynamic> json) {
  return _PlanSummary.fromJson(json);
}

/// @nodoc
mixin _$PlanSummary {
  String? get id => throw _privateConstructorUsedError;
  String? get householdId => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  List<MemberFacepileItem> get memberFacepile =>
      throw _privateConstructorUsedError;
  String? get lastMessageSnippet => throw _privateConstructorUsedError;
  String? get lastMessageAuthor => throw _privateConstructorUsedError;
  int get proposalCount => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this PlanSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlanSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlanSummaryCopyWith<PlanSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlanSummaryCopyWith<$Res> {
  factory $PlanSummaryCopyWith(
          PlanSummary value, $Res Function(PlanSummary) then) =
      _$PlanSummaryCopyWithImpl<$Res, PlanSummary>;
  @useResult
  $Res call(
      {String? id,
      String? householdId,
      String? title,
      String status,
      List<MemberFacepileItem> memberFacepile,
      String? lastMessageSnippet,
      String? lastMessageAuthor,
      int proposalCount,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$PlanSummaryCopyWithImpl<$Res, $Val extends PlanSummary>
    implements $PlanSummaryCopyWith<$Res> {
  _$PlanSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlanSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? householdId = freezed,
    Object? title = freezed,
    Object? status = null,
    Object? memberFacepile = null,
    Object? lastMessageSnippet = freezed,
    Object? lastMessageAuthor = freezed,
    Object? proposalCount = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      householdId: freezed == householdId
          ? _value.householdId
          : householdId // ignore: cast_nullable_to_non_nullable
              as String?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      memberFacepile: null == memberFacepile
          ? _value.memberFacepile
          : memberFacepile // ignore: cast_nullable_to_non_nullable
              as List<MemberFacepileItem>,
      lastMessageSnippet: freezed == lastMessageSnippet
          ? _value.lastMessageSnippet
          : lastMessageSnippet // ignore: cast_nullable_to_non_nullable
              as String?,
      lastMessageAuthor: freezed == lastMessageAuthor
          ? _value.lastMessageAuthor
          : lastMessageAuthor // ignore: cast_nullable_to_non_nullable
              as String?,
      proposalCount: null == proposalCount
          ? _value.proposalCount
          : proposalCount // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlanSummaryImplCopyWith<$Res>
    implements $PlanSummaryCopyWith<$Res> {
  factory _$$PlanSummaryImplCopyWith(
          _$PlanSummaryImpl value, $Res Function(_$PlanSummaryImpl) then) =
      __$$PlanSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String? householdId,
      String? title,
      String status,
      List<MemberFacepileItem> memberFacepile,
      String? lastMessageSnippet,
      String? lastMessageAuthor,
      int proposalCount,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$PlanSummaryImplCopyWithImpl<$Res>
    extends _$PlanSummaryCopyWithImpl<$Res, _$PlanSummaryImpl>
    implements _$$PlanSummaryImplCopyWith<$Res> {
  __$$PlanSummaryImplCopyWithImpl(
      _$PlanSummaryImpl _value, $Res Function(_$PlanSummaryImpl) _then)
      : super(_value, _then);

  /// Create a copy of PlanSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? householdId = freezed,
    Object? title = freezed,
    Object? status = null,
    Object? memberFacepile = null,
    Object? lastMessageSnippet = freezed,
    Object? lastMessageAuthor = freezed,
    Object? proposalCount = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$PlanSummaryImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      householdId: freezed == householdId
          ? _value.householdId
          : householdId // ignore: cast_nullable_to_non_nullable
              as String?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      memberFacepile: null == memberFacepile
          ? _value._memberFacepile
          : memberFacepile // ignore: cast_nullable_to_non_nullable
              as List<MemberFacepileItem>,
      lastMessageSnippet: freezed == lastMessageSnippet
          ? _value.lastMessageSnippet
          : lastMessageSnippet // ignore: cast_nullable_to_non_nullable
              as String?,
      lastMessageAuthor: freezed == lastMessageAuthor
          ? _value.lastMessageAuthor
          : lastMessageAuthor // ignore: cast_nullable_to_non_nullable
              as String?,
      proposalCount: null == proposalCount
          ? _value.proposalCount
          : proposalCount // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlanSummaryImpl implements _PlanSummary {
  const _$PlanSummaryImpl(
      {this.id,
      this.householdId,
      this.title,
      this.status = 'active',
      final List<MemberFacepileItem> memberFacepile = const [],
      this.lastMessageSnippet,
      this.lastMessageAuthor,
      this.proposalCount = 0,
      this.createdAt,
      this.updatedAt})
      : _memberFacepile = memberFacepile;

  factory _$PlanSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlanSummaryImplFromJson(json);

  @override
  final String? id;
  @override
  final String? householdId;
  @override
  final String? title;
  @override
  @JsonKey()
  final String status;
  final List<MemberFacepileItem> _memberFacepile;
  @override
  @JsonKey()
  List<MemberFacepileItem> get memberFacepile {
    if (_memberFacepile is EqualUnmodifiableListView) return _memberFacepile;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_memberFacepile);
  }

  @override
  final String? lastMessageSnippet;
  @override
  final String? lastMessageAuthor;
  @override
  @JsonKey()
  final int proposalCount;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'PlanSummary(id: $id, householdId: $householdId, title: $title, status: $status, memberFacepile: $memberFacepile, lastMessageSnippet: $lastMessageSnippet, lastMessageAuthor: $lastMessageAuthor, proposalCount: $proposalCount, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlanSummaryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.householdId, householdId) ||
                other.householdId == householdId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality()
                .equals(other._memberFacepile, _memberFacepile) &&
            (identical(other.lastMessageSnippet, lastMessageSnippet) ||
                other.lastMessageSnippet == lastMessageSnippet) &&
            (identical(other.lastMessageAuthor, lastMessageAuthor) ||
                other.lastMessageAuthor == lastMessageAuthor) &&
            (identical(other.proposalCount, proposalCount) ||
                other.proposalCount == proposalCount) &&
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
      householdId,
      title,
      status,
      const DeepCollectionEquality().hash(_memberFacepile),
      lastMessageSnippet,
      lastMessageAuthor,
      proposalCount,
      createdAt,
      updatedAt);

  /// Create a copy of PlanSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlanSummaryImplCopyWith<_$PlanSummaryImpl> get copyWith =>
      __$$PlanSummaryImplCopyWithImpl<_$PlanSummaryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlanSummaryImplToJson(
      this,
    );
  }
}

abstract class _PlanSummary implements PlanSummary {
  const factory _PlanSummary(
      {final String? id,
      final String? householdId,
      final String? title,
      final String status,
      final List<MemberFacepileItem> memberFacepile,
      final String? lastMessageSnippet,
      final String? lastMessageAuthor,
      final int proposalCount,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$PlanSummaryImpl;

  factory _PlanSummary.fromJson(Map<String, dynamic> json) =
      _$PlanSummaryImpl.fromJson;

  @override
  String? get id;
  @override
  String? get householdId;
  @override
  String? get title;
  @override
  String get status;
  @override
  List<MemberFacepileItem> get memberFacepile;
  @override
  String? get lastMessageSnippet;
  @override
  String? get lastMessageAuthor;
  @override
  int get proposalCount;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of PlanSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlanSummaryImplCopyWith<_$PlanSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MemberFacepileItem _$MemberFacepileItemFromJson(Map<String, dynamic> json) {
  return _MemberFacepileItem.fromJson(json);
}

/// @nodoc
mixin _$MemberFacepileItem {
  String get memberId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get photoUrl => throw _privateConstructorUsedError;

  /// Serializes this MemberFacepileItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MemberFacepileItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MemberFacepileItemCopyWith<MemberFacepileItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MemberFacepileItemCopyWith<$Res> {
  factory $MemberFacepileItemCopyWith(
          MemberFacepileItem value, $Res Function(MemberFacepileItem) then) =
      _$MemberFacepileItemCopyWithImpl<$Res, MemberFacepileItem>;
  @useResult
  $Res call({String memberId, String name, String? photoUrl});
}

/// @nodoc
class _$MemberFacepileItemCopyWithImpl<$Res, $Val extends MemberFacepileItem>
    implements $MemberFacepileItemCopyWith<$Res> {
  _$MemberFacepileItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MemberFacepileItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? memberId = null,
    Object? name = null,
    Object? photoUrl = freezed,
  }) {
    return _then(_value.copyWith(
      memberId: null == memberId
          ? _value.memberId
          : memberId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MemberFacepileItemImplCopyWith<$Res>
    implements $MemberFacepileItemCopyWith<$Res> {
  factory _$$MemberFacepileItemImplCopyWith(_$MemberFacepileItemImpl value,
          $Res Function(_$MemberFacepileItemImpl) then) =
      __$$MemberFacepileItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String memberId, String name, String? photoUrl});
}

/// @nodoc
class __$$MemberFacepileItemImplCopyWithImpl<$Res>
    extends _$MemberFacepileItemCopyWithImpl<$Res, _$MemberFacepileItemImpl>
    implements _$$MemberFacepileItemImplCopyWith<$Res> {
  __$$MemberFacepileItemImplCopyWithImpl(_$MemberFacepileItemImpl _value,
      $Res Function(_$MemberFacepileItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of MemberFacepileItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? memberId = null,
    Object? name = null,
    Object? photoUrl = freezed,
  }) {
    return _then(_$MemberFacepileItemImpl(
      memberId: null == memberId
          ? _value.memberId
          : memberId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MemberFacepileItemImpl implements _MemberFacepileItem {
  const _$MemberFacepileItemImpl(
      {required this.memberId, required this.name, this.photoUrl});

  factory _$MemberFacepileItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$MemberFacepileItemImplFromJson(json);

  @override
  final String memberId;
  @override
  final String name;
  @override
  final String? photoUrl;

  @override
  String toString() {
    return 'MemberFacepileItem(memberId: $memberId, name: $name, photoUrl: $photoUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MemberFacepileItemImpl &&
            (identical(other.memberId, memberId) ||
                other.memberId == memberId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, memberId, name, photoUrl);

  /// Create a copy of MemberFacepileItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MemberFacepileItemImplCopyWith<_$MemberFacepileItemImpl> get copyWith =>
      __$$MemberFacepileItemImplCopyWithImpl<_$MemberFacepileItemImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MemberFacepileItemImplToJson(
      this,
    );
  }
}

abstract class _MemberFacepileItem implements MemberFacepileItem {
  const factory _MemberFacepileItem(
      {required final String memberId,
      required final String name,
      final String? photoUrl}) = _$MemberFacepileItemImpl;

  factory _MemberFacepileItem.fromJson(Map<String, dynamic> json) =
      _$MemberFacepileItemImpl.fromJson;

  @override
  String get memberId;
  @override
  String get name;
  @override
  String? get photoUrl;

  /// Create a copy of MemberFacepileItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MemberFacepileItemImplCopyWith<_$MemberFacepileItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProposalWithVotes _$ProposalWithVotesFromJson(Map<String, dynamic> json) {
  return _ProposalWithVotes.fromJson(json);
}

/// @nodoc
mixin _$ProposalWithVotes {
  PlanProposal get proposal => throw _privateConstructorUsedError;
  int get upvotes => throw _privateConstructorUsedError;
  int get downvotes => throw _privateConstructorUsedError;
  int get neutral => throw _privateConstructorUsedError;
  int get score => throw _privateConstructorUsedError;
  int? get userVote => throw _privateConstructorUsedError;
  Map<String, dynamic>? get feasibility => throw _privateConstructorUsedError;

  /// Serializes this ProposalWithVotes to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProposalWithVotes
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProposalWithVotesCopyWith<ProposalWithVotes> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProposalWithVotesCopyWith<$Res> {
  factory $ProposalWithVotesCopyWith(
          ProposalWithVotes value, $Res Function(ProposalWithVotes) then) =
      _$ProposalWithVotesCopyWithImpl<$Res, ProposalWithVotes>;
  @useResult
  $Res call(
      {PlanProposal proposal,
      int upvotes,
      int downvotes,
      int neutral,
      int score,
      int? userVote,
      Map<String, dynamic>? feasibility});

  $PlanProposalCopyWith<$Res> get proposal;
}

/// @nodoc
class _$ProposalWithVotesCopyWithImpl<$Res, $Val extends ProposalWithVotes>
    implements $ProposalWithVotesCopyWith<$Res> {
  _$ProposalWithVotesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProposalWithVotes
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? proposal = null,
    Object? upvotes = null,
    Object? downvotes = null,
    Object? neutral = null,
    Object? score = null,
    Object? userVote = freezed,
    Object? feasibility = freezed,
  }) {
    return _then(_value.copyWith(
      proposal: null == proposal
          ? _value.proposal
          : proposal // ignore: cast_nullable_to_non_nullable
              as PlanProposal,
      upvotes: null == upvotes
          ? _value.upvotes
          : upvotes // ignore: cast_nullable_to_non_nullable
              as int,
      downvotes: null == downvotes
          ? _value.downvotes
          : downvotes // ignore: cast_nullable_to_non_nullable
              as int,
      neutral: null == neutral
          ? _value.neutral
          : neutral // ignore: cast_nullable_to_non_nullable
              as int,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      userVote: freezed == userVote
          ? _value.userVote
          : userVote // ignore: cast_nullable_to_non_nullable
              as int?,
      feasibility: freezed == feasibility
          ? _value.feasibility
          : feasibility // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }

  /// Create a copy of ProposalWithVotes
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PlanProposalCopyWith<$Res> get proposal {
    return $PlanProposalCopyWith<$Res>(_value.proposal, (value) {
      return _then(_value.copyWith(proposal: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ProposalWithVotesImplCopyWith<$Res>
    implements $ProposalWithVotesCopyWith<$Res> {
  factory _$$ProposalWithVotesImplCopyWith(_$ProposalWithVotesImpl value,
          $Res Function(_$ProposalWithVotesImpl) then) =
      __$$ProposalWithVotesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {PlanProposal proposal,
      int upvotes,
      int downvotes,
      int neutral,
      int score,
      int? userVote,
      Map<String, dynamic>? feasibility});

  @override
  $PlanProposalCopyWith<$Res> get proposal;
}

/// @nodoc
class __$$ProposalWithVotesImplCopyWithImpl<$Res>
    extends _$ProposalWithVotesCopyWithImpl<$Res, _$ProposalWithVotesImpl>
    implements _$$ProposalWithVotesImplCopyWith<$Res> {
  __$$ProposalWithVotesImplCopyWithImpl(_$ProposalWithVotesImpl _value,
      $Res Function(_$ProposalWithVotesImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProposalWithVotes
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? proposal = null,
    Object? upvotes = null,
    Object? downvotes = null,
    Object? neutral = null,
    Object? score = null,
    Object? userVote = freezed,
    Object? feasibility = freezed,
  }) {
    return _then(_$ProposalWithVotesImpl(
      proposal: null == proposal
          ? _value.proposal
          : proposal // ignore: cast_nullable_to_non_nullable
              as PlanProposal,
      upvotes: null == upvotes
          ? _value.upvotes
          : upvotes // ignore: cast_nullable_to_non_nullable
              as int,
      downvotes: null == downvotes
          ? _value.downvotes
          : downvotes // ignore: cast_nullable_to_non_nullable
              as int,
      neutral: null == neutral
          ? _value.neutral
          : neutral // ignore: cast_nullable_to_non_nullable
              as int,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      userVote: freezed == userVote
          ? _value.userVote
          : userVote // ignore: cast_nullable_to_non_nullable
              as int?,
      feasibility: freezed == feasibility
          ? _value._feasibility
          : feasibility // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProposalWithVotesImpl implements _ProposalWithVotes {
  const _$ProposalWithVotesImpl(
      {required this.proposal,
      this.upvotes = 0,
      this.downvotes = 0,
      this.neutral = 0,
      this.score = 0,
      this.userVote,
      final Map<String, dynamic>? feasibility})
      : _feasibility = feasibility;

  factory _$ProposalWithVotesImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProposalWithVotesImplFromJson(json);

  @override
  final PlanProposal proposal;
  @override
  @JsonKey()
  final int upvotes;
  @override
  @JsonKey()
  final int downvotes;
  @override
  @JsonKey()
  final int neutral;
  @override
  @JsonKey()
  final int score;
  @override
  final int? userVote;
  final Map<String, dynamic>? _feasibility;
  @override
  Map<String, dynamic>? get feasibility {
    final value = _feasibility;
    if (value == null) return null;
    if (_feasibility is EqualUnmodifiableMapView) return _feasibility;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'ProposalWithVotes(proposal: $proposal, upvotes: $upvotes, downvotes: $downvotes, neutral: $neutral, score: $score, userVote: $userVote, feasibility: $feasibility)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProposalWithVotesImpl &&
            (identical(other.proposal, proposal) ||
                other.proposal == proposal) &&
            (identical(other.upvotes, upvotes) || other.upvotes == upvotes) &&
            (identical(other.downvotes, downvotes) ||
                other.downvotes == downvotes) &&
            (identical(other.neutral, neutral) || other.neutral == neutral) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.userVote, userVote) ||
                other.userVote == userVote) &&
            const DeepCollectionEquality()
                .equals(other._feasibility, _feasibility));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      proposal,
      upvotes,
      downvotes,
      neutral,
      score,
      userVote,
      const DeepCollectionEquality().hash(_feasibility));

  /// Create a copy of ProposalWithVotes
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProposalWithVotesImplCopyWith<_$ProposalWithVotesImpl> get copyWith =>
      __$$ProposalWithVotesImplCopyWithImpl<_$ProposalWithVotesImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProposalWithVotesImplToJson(
      this,
    );
  }
}

abstract class _ProposalWithVotes implements ProposalWithVotes {
  const factory _ProposalWithVotes(
      {required final PlanProposal proposal,
      final int upvotes,
      final int downvotes,
      final int neutral,
      final int score,
      final int? userVote,
      final Map<String, dynamic>? feasibility}) = _$ProposalWithVotesImpl;

  factory _ProposalWithVotes.fromJson(Map<String, dynamic> json) =
      _$ProposalWithVotesImpl.fromJson;

  @override
  PlanProposal get proposal;
  @override
  int get upvotes;
  @override
  int get downvotes;
  @override
  int get neutral;
  @override
  int get score;
  @override
  int? get userVote;
  @override
  Map<String, dynamic>? get feasibility;

  /// Create a copy of ProposalWithVotes
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProposalWithVotesImplCopyWith<_$ProposalWithVotesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FeasibilityReason _$FeasibilityReasonFromJson(Map<String, dynamic> json) {
  return _FeasibilityReason.fromJson(json);
}

/// @nodoc
mixin _$FeasibilityReason {
  String get type => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  String? get fixSuggestion => throw _privateConstructorUsedError;

  /// Serializes this FeasibilityReason to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FeasibilityReason
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FeasibilityReasonCopyWith<FeasibilityReason> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeasibilityReasonCopyWith<$Res> {
  factory $FeasibilityReasonCopyWith(
          FeasibilityReason value, $Res Function(FeasibilityReason) then) =
      _$FeasibilityReasonCopyWithImpl<$Res, FeasibilityReason>;
  @useResult
  $Res call({String type, String message, String? fixSuggestion});
}

/// @nodoc
class _$FeasibilityReasonCopyWithImpl<$Res, $Val extends FeasibilityReason>
    implements $FeasibilityReasonCopyWith<$Res> {
  _$FeasibilityReasonCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FeasibilityReason
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? message = null,
    Object? fixSuggestion = freezed,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      fixSuggestion: freezed == fixSuggestion
          ? _value.fixSuggestion
          : fixSuggestion // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FeasibilityReasonImplCopyWith<$Res>
    implements $FeasibilityReasonCopyWith<$Res> {
  factory _$$FeasibilityReasonImplCopyWith(_$FeasibilityReasonImpl value,
          $Res Function(_$FeasibilityReasonImpl) then) =
      __$$FeasibilityReasonImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String type, String message, String? fixSuggestion});
}

/// @nodoc
class __$$FeasibilityReasonImplCopyWithImpl<$Res>
    extends _$FeasibilityReasonCopyWithImpl<$Res, _$FeasibilityReasonImpl>
    implements _$$FeasibilityReasonImplCopyWith<$Res> {
  __$$FeasibilityReasonImplCopyWithImpl(_$FeasibilityReasonImpl _value,
      $Res Function(_$FeasibilityReasonImpl) _then)
      : super(_value, _then);

  /// Create a copy of FeasibilityReason
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? message = null,
    Object? fixSuggestion = freezed,
  }) {
    return _then(_$FeasibilityReasonImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      fixSuggestion: freezed == fixSuggestion
          ? _value.fixSuggestion
          : fixSuggestion // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FeasibilityReasonImpl implements _FeasibilityReason {
  const _$FeasibilityReasonImpl(
      {required this.type, required this.message, this.fixSuggestion});

  factory _$FeasibilityReasonImpl.fromJson(Map<String, dynamic> json) =>
      _$$FeasibilityReasonImplFromJson(json);

  @override
  final String type;
  @override
  final String message;
  @override
  final String? fixSuggestion;

  @override
  String toString() {
    return 'FeasibilityReason(type: $type, message: $message, fixSuggestion: $fixSuggestion)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeasibilityReasonImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.fixSuggestion, fixSuggestion) ||
                other.fixSuggestion == fixSuggestion));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, type, message, fixSuggestion);

  /// Create a copy of FeasibilityReason
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeasibilityReasonImplCopyWith<_$FeasibilityReasonImpl> get copyWith =>
      __$$FeasibilityReasonImplCopyWithImpl<_$FeasibilityReasonImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FeasibilityReasonImplToJson(
      this,
    );
  }
}

abstract class _FeasibilityReason implements FeasibilityReason {
  const factory _FeasibilityReason(
      {required final String type,
      required final String message,
      final String? fixSuggestion}) = _$FeasibilityReasonImpl;

  factory _FeasibilityReason.fromJson(Map<String, dynamic> json) =
      _$FeasibilityReasonImpl.fromJson;

  @override
  String get type;
  @override
  String get message;
  @override
  String? get fixSuggestion;

  /// Create a copy of FeasibilityReason
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeasibilityReasonImplCopyWith<_$FeasibilityReasonImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProposalFeasibility _$ProposalFeasibilityFromJson(Map<String, dynamic> json) {
  return _ProposalFeasibility.fromJson(json);
}

/// @nodoc
mixin _$ProposalFeasibility {
  String get proposalId => throw _privateConstructorUsedError;
  FeasibilityStatus get status => throw _privateConstructorUsedError;
  List<FeasibilityReason> get reasons => throw _privateConstructorUsedError;
  double get score => throw _privateConstructorUsedError;

  /// Serializes this ProposalFeasibility to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProposalFeasibility
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProposalFeasibilityCopyWith<ProposalFeasibility> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProposalFeasibilityCopyWith<$Res> {
  factory $ProposalFeasibilityCopyWith(
          ProposalFeasibility value, $Res Function(ProposalFeasibility) then) =
      _$ProposalFeasibilityCopyWithImpl<$Res, ProposalFeasibility>;
  @useResult
  $Res call(
      {String proposalId,
      FeasibilityStatus status,
      List<FeasibilityReason> reasons,
      double score});
}

/// @nodoc
class _$ProposalFeasibilityCopyWithImpl<$Res, $Val extends ProposalFeasibility>
    implements $ProposalFeasibilityCopyWith<$Res> {
  _$ProposalFeasibilityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProposalFeasibility
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? proposalId = null,
    Object? status = null,
    Object? reasons = null,
    Object? score = null,
  }) {
    return _then(_value.copyWith(
      proposalId: null == proposalId
          ? _value.proposalId
          : proposalId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as FeasibilityStatus,
      reasons: null == reasons
          ? _value.reasons
          : reasons // ignore: cast_nullable_to_non_nullable
              as List<FeasibilityReason>,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProposalFeasibilityImplCopyWith<$Res>
    implements $ProposalFeasibilityCopyWith<$Res> {
  factory _$$ProposalFeasibilityImplCopyWith(_$ProposalFeasibilityImpl value,
          $Res Function(_$ProposalFeasibilityImpl) then) =
      __$$ProposalFeasibilityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String proposalId,
      FeasibilityStatus status,
      List<FeasibilityReason> reasons,
      double score});
}

/// @nodoc
class __$$ProposalFeasibilityImplCopyWithImpl<$Res>
    extends _$ProposalFeasibilityCopyWithImpl<$Res, _$ProposalFeasibilityImpl>
    implements _$$ProposalFeasibilityImplCopyWith<$Res> {
  __$$ProposalFeasibilityImplCopyWithImpl(_$ProposalFeasibilityImpl _value,
      $Res Function(_$ProposalFeasibilityImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProposalFeasibility
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? proposalId = null,
    Object? status = null,
    Object? reasons = null,
    Object? score = null,
  }) {
    return _then(_$ProposalFeasibilityImpl(
      proposalId: null == proposalId
          ? _value.proposalId
          : proposalId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as FeasibilityStatus,
      reasons: null == reasons
          ? _value._reasons
          : reasons // ignore: cast_nullable_to_non_nullable
              as List<FeasibilityReason>,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProposalFeasibilityImpl implements _ProposalFeasibility {
  const _$ProposalFeasibilityImpl(
      {required this.proposalId,
      required this.status,
      final List<FeasibilityReason> reasons = const [],
      this.score = 1.0})
      : _reasons = reasons;

  factory _$ProposalFeasibilityImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProposalFeasibilityImplFromJson(json);

  @override
  final String proposalId;
  @override
  final FeasibilityStatus status;
  final List<FeasibilityReason> _reasons;
  @override
  @JsonKey()
  List<FeasibilityReason> get reasons {
    if (_reasons is EqualUnmodifiableListView) return _reasons;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_reasons);
  }

  @override
  @JsonKey()
  final double score;

  @override
  String toString() {
    return 'ProposalFeasibility(proposalId: $proposalId, status: $status, reasons: $reasons, score: $score)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProposalFeasibilityImpl &&
            (identical(other.proposalId, proposalId) ||
                other.proposalId == proposalId) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._reasons, _reasons) &&
            (identical(other.score, score) || other.score == score));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, proposalId, status,
      const DeepCollectionEquality().hash(_reasons), score);

  /// Create a copy of ProposalFeasibility
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProposalFeasibilityImplCopyWith<_$ProposalFeasibilityImpl> get copyWith =>
      __$$ProposalFeasibilityImplCopyWithImpl<_$ProposalFeasibilityImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProposalFeasibilityImplToJson(
      this,
    );
  }
}

abstract class _ProposalFeasibility implements ProposalFeasibility {
  const factory _ProposalFeasibility(
      {required final String proposalId,
      required final FeasibilityStatus status,
      final List<FeasibilityReason> reasons,
      final double score}) = _$ProposalFeasibilityImpl;

  factory _ProposalFeasibility.fromJson(Map<String, dynamic> json) =
      _$ProposalFeasibilityImpl.fromJson;

  @override
  String get proposalId;
  @override
  FeasibilityStatus get status;
  @override
  List<FeasibilityReason> get reasons;
  @override
  double get score;

  /// Create a copy of ProposalFeasibility
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProposalFeasibilityImplCopyWith<_$ProposalFeasibilityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
