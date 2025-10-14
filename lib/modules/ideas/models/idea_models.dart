import 'package:equatable/equatable.dart';

// Enums
enum IdeaState {
  draft,
  pendingApproval,
  active,
  archived,
}

extension IdeaStateExtension on IdeaState {
  String toDbString() {
    switch (this) {
      case IdeaState.draft:
        return 'draft';
      case IdeaState.pendingApproval:
        return 'pending_approval';
      case IdeaState.active:
        return 'active';
      case IdeaState.archived:
        return 'archived';
    }
  }

  static IdeaState fromDbString(String value) {
    switch (value) {
      case 'draft':
        return IdeaState.draft;
      case 'pending_approval':
        return IdeaState.pendingApproval;
      case 'active':
        return IdeaState.active;
      case 'archived':
        return IdeaState.archived;
      default:
        return IdeaState.draft;
    }
  }

  String get displayName {
    switch (this) {
      case IdeaState.draft:
        return 'Draft';
      case IdeaState.pendingApproval:
        return 'Awaiting Parent Approval';
      case IdeaState.active:
        return 'Active';
      case IdeaState.archived:
        return 'Archived';
    }
  }
}

enum IdeaVisibility {
  household,
  private,
  podOnly,
}

extension IdeaVisibilityExtension on IdeaVisibility {
  String toDbString() {
    switch (this) {
      case IdeaVisibility.household:
        return 'household';
      case IdeaVisibility.private:
        return 'private';
      case IdeaVisibility.podOnly:
        return 'pod_only';
    }
  }

  static IdeaVisibility fromDbString(String value) {
    switch (value) {
      case 'household':
        return IdeaVisibility.household;
      case 'private':
        return IdeaVisibility.private;
      case 'pod_only':
        return IdeaVisibility.podOnly;
      default:
        return IdeaVisibility.household;
    }
  }

  String get displayName {
    switch (this) {
      case IdeaVisibility.household:
        return 'Everyone in Family';
      case IdeaVisibility.private:
        return 'Just Me';
      case IdeaVisibility.podOnly:
        return 'Specific Groups';
    }
  }
}

enum RecurrenceUnit {
  daily,
  weekly,
  monthly,
}

extension RecurrenceUnitExtension on RecurrenceUnit {
  String toDbString() {
    switch (this) {
      case RecurrenceUnit.daily:
        return 'daily';
      case RecurrenceUnit.weekly:
        return 'weekly';
      case RecurrenceUnit.monthly:
        return 'monthly';
    }
  }

  static RecurrenceUnit? fromDbString(String? value) {
    if (value == null) return null;
    switch (value) {
      case 'daily':
        return RecurrenceUnit.daily;
      case 'weekly':
        return RecurrenceUnit.weekly;
      case 'monthly':
        return RecurrenceUnit.monthly;
      default:
        return null;
    }
  }
}

// Main Idea Model
class Idea extends Equatable {
  final String? id;
  final String householdId;
  final String creatorMemberId;

  // Presentation
  final String title;
  final String? summary;
  final String? detailsMd;
  final List<String> tags;
  final List<String> mediaUrls;
  final String? locationHint;

  // Feasibility hints
  final String? indoorOutdoor; // 'indoor', 'outdoor', 'either'
  final int? minAge;
  final bool needsAdult;
  final int? durationMinutes;
  final int? setupMinutes;
  final String? messLevel; // 'low', 'medium', 'high'
  final String? costBand; // 'free', 'low', 'medium', 'high'

  // Pod/Visibility
  final String? defaultPodId;
  final IdeaVisibility visibility;
  final List<String> visiblePodIds;

  // State & moderation
  final IdeaState state;
  final bool requiresParentApproval;
  final String? approvedByMemberId;
  final DateTime? approvedAt;

  // Recurrence
  final RecurrenceUnit? recurrenceUnit;
  final int? recurrenceEvery;
  final List<int>? recurrenceDaysOfWeek; // 0=Mon, 6=Sun
  final DateTime? nextDueAt;
  final DateTime? lastCompletedAt;

  // Learning (read-only from backend)
  final Map<String, dynamic>? features;
  final List<double>? embedding;

  // Metadata
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Computed (from backend)
  final int likesCount;
  final int commentsCount;
  final bool isLikedByMe;

  const Idea({
    this.id,
    required this.householdId,
    required this.creatorMemberId,
    required this.title,
    this.summary,
    this.detailsMd,
    this.tags = const [],
    this.mediaUrls = const [],
    this.locationHint,
    this.indoorOutdoor,
    this.minAge,
    this.needsAdult = false,
    this.durationMinutes,
    this.setupMinutes,
    this.messLevel,
    this.costBand,
    this.defaultPodId,
    this.visibility = IdeaVisibility.household,
    this.visiblePodIds = const [],
    this.state = IdeaState.draft,
    this.requiresParentApproval = false,
    this.approvedByMemberId,
    this.approvedAt,
    this.recurrenceUnit,
    this.recurrenceEvery,
    this.recurrenceDaysOfWeek,
    this.nextDueAt,
    this.lastCompletedAt,
    this.features,
    this.embedding,
    this.createdAt,
    this.updatedAt,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLikedByMe = false,
  });

  @override
  List<Object?> get props => [
        id,
        householdId,
        creatorMemberId,
        title,
        summary,
        detailsMd,
        tags,
        mediaUrls,
        locationHint,
        indoorOutdoor,
        minAge,
        needsAdult,
        durationMinutes,
        setupMinutes,
        messLevel,
        costBand,
        defaultPodId,
        visibility,
        visiblePodIds,
        state,
        requiresParentApproval,
        approvedByMemberId,
        approvedAt,
        recurrenceUnit,
        recurrenceEvery,
        recurrenceDaysOfWeek,
        nextDueAt,
        lastCompletedAt,
        createdAt,
        updatedAt,
        likesCount,
        commentsCount,
        isLikedByMe,
      ];

  factory Idea.fromJson(Map<String, dynamic> json) => Idea(
        id: json['id'],
        householdId: json['household_id'],
        creatorMemberId: json['creator_member_id'],
        title: json['title'],
        summary: json['summary'],
        detailsMd: json['details_md'],
        tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
        mediaUrls: json['media_urls'] != null ? List<String>.from(json['media_urls']) : [],
        locationHint: json['location_hint'],
        indoorOutdoor: json['indoor_outdoor'],
        minAge: json['min_age'],
        needsAdult: json['needs_adult'] ?? false,
        durationMinutes: json['duration_minutes'],
        setupMinutes: json['setup_minutes'],
        messLevel: json['mess_level'],
        costBand: json['cost_band'],
        defaultPodId: json['default_pod_id'],
        visibility: IdeaVisibilityExtension.fromDbString(json['visibility'] ?? 'household'),
        visiblePodIds: json['visible_pod_ids'] != null
            ? List<String>.from(json['visible_pod_ids'])
            : [],
        state: IdeaStateExtension.fromDbString(json['state'] ?? 'draft'),
        requiresParentApproval: json['requires_parent_approval'] ?? false,
        approvedByMemberId: json['approved_by_member_id'],
        approvedAt:
            json['approved_at'] != null ? DateTime.parse(json['approved_at']) : null,
        recurrenceUnit: RecurrenceUnitExtension.fromDbString(json['recurrence_unit']),
        recurrenceEvery: json['recurrence_every'],
        recurrenceDaysOfWeek: json['recurrence_days_of_week'] != null
            ? List<int>.from(json['recurrence_days_of_week'])
            : null,
        nextDueAt:
            json['next_due_at'] != null ? DateTime.parse(json['next_due_at']) : null,
        lastCompletedAt: json['last_completed_at'] != null
            ? DateTime.parse(json['last_completed_at'])
            : null,
        features: json['features'],
        embedding: json['embedding'] != null
            ? List<double>.from(json['embedding'].map((e) => e.toDouble()))
            : null,
        createdAt:
            json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
        updatedAt:
            json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
        likesCount: json['likes_count'] ?? 0,
        commentsCount: json['comments_count'] ?? 0,
        isLikedByMe: json['is_liked_by_me'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'household_id': householdId,
        'creator_member_id': creatorMemberId,
        'title': title,
        if (summary != null) 'summary': summary,
        if (detailsMd != null) 'details_md': detailsMd,
        'tags': tags,
        'media_urls': mediaUrls,
        if (locationHint != null) 'location_hint': locationHint,
        if (indoorOutdoor != null) 'indoor_outdoor': indoorOutdoor,
        if (minAge != null) 'min_age': minAge,
        'needs_adult': needsAdult,
        if (durationMinutes != null) 'duration_minutes': durationMinutes,
        if (setupMinutes != null) 'setup_minutes': setupMinutes,
        if (messLevel != null) 'mess_level': messLevel,
        if (costBand != null) 'cost_band': costBand,
        if (defaultPodId != null) 'default_pod_id': defaultPodId,
        'visibility': visibility.toDbString(),
        'visible_pod_ids': visiblePodIds,
        'state': state.toDbString(),
        'requires_parent_approval': requiresParentApproval,
        if (approvedByMemberId != null) 'approved_by_member_id': approvedByMemberId,
        if (approvedAt != null) 'approved_at': approvedAt!.toIso8601String(),
        if (recurrenceUnit != null) 'recurrence_unit': recurrenceUnit!.toDbString(),
        if (recurrenceEvery != null) 'recurrence_every': recurrenceEvery,
        if (recurrenceDaysOfWeek != null) 'recurrence_days_of_week': recurrenceDaysOfWeek,
        if (nextDueAt != null) 'next_due_at': nextDueAt!.toIso8601String(),
        if (lastCompletedAt != null)
          'last_completed_at': lastCompletedAt!.toIso8601String(),
      };

  Idea copyWith({
    String? id,
    String? title,
    String? summary,
    String? detailsMd,
    List<String>? tags,
    List<String>? mediaUrls,
    String? locationHint,
    String? indoorOutdoor,
    int? minAge,
    bool? needsAdult,
    int? durationMinutes,
    int? setupMinutes,
    String? messLevel,
    String? costBand,
    String? defaultPodId,
    IdeaVisibility? visibility,
    List<String>? visiblePodIds,
    IdeaState? state,
    bool? isLikedByMe,
  }) {
    return Idea(
      id: id ?? this.id,
      householdId: householdId,
      creatorMemberId: creatorMemberId,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      detailsMd: detailsMd ?? this.detailsMd,
      tags: tags ?? this.tags,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      locationHint: locationHint ?? this.locationHint,
      indoorOutdoor: indoorOutdoor ?? this.indoorOutdoor,
      minAge: minAge ?? this.minAge,
      needsAdult: needsAdult ?? this.needsAdult,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      setupMinutes: setupMinutes ?? this.setupMinutes,
      messLevel: messLevel ?? this.messLevel,
      costBand: costBand ?? this.costBand,
      defaultPodId: defaultPodId ?? this.defaultPodId,
      visibility: visibility ?? this.visibility,
      visiblePodIds: visiblePodIds ?? this.visiblePodIds,
      state: state ?? this.state,
      requiresParentApproval: requiresParentApproval,
      approvedByMemberId: approvedByMemberId,
      approvedAt: approvedAt,
      recurrenceUnit: recurrenceUnit,
      recurrenceEvery: recurrenceEvery,
      recurrenceDaysOfWeek: recurrenceDaysOfWeek,
      nextDueAt: nextDueAt,
      lastCompletedAt: lastCompletedAt,
      features: features,
      embedding: embedding,
      createdAt: createdAt,
      updatedAt: updatedAt,
      likesCount: likesCount,
      commentsCount: commentsCount,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
    );
  }
}

// Comment Model
class IdeaComment extends Equatable {
  final String? id;
  final String ideaId;
  final String memberId;
  final String body;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isDeleted;

  const IdeaComment({
    this.id,
    required this.ideaId,
    required this.memberId,
    required this.body,
    this.createdAt,
    this.updatedAt,
    this.isDeleted = false,
  });

  @override
  List<Object?> get props => [id, ideaId, memberId, body, createdAt, updatedAt, isDeleted];

  factory IdeaComment.fromJson(Map<String, dynamic> json) => IdeaComment(
        id: json['id'],
        ideaId: json['idea_id'],
        memberId: json['member_id'],
        body: json['body'],
        createdAt:
            json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
        updatedAt:
            json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
        isDeleted: json['is_deleted'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'idea_id': ideaId,
        'member_id': memberId,
        'body': body,
        'is_deleted': isDeleted,
      };
}

// Like Model
class IdeaLike extends Equatable {
  final String? id;
  final String ideaId;
  final String memberId;
  final DateTime? createdAt;

  const IdeaLike({
    this.id,
    required this.ideaId,
    required this.memberId,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, ideaId, memberId, createdAt];

  factory IdeaLike.fromJson(Map<String, dynamic> json) => IdeaLike(
        id: json['id'],
        ideaId: json['idea_id'],
        memberId: json['member_id'],
        createdAt:
            json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'idea_id': ideaId,
        'member_id': memberId,
      };
}

