import 'package:freezed_annotation/freezed_annotation.dart';

part 'plan_models.freezed.dart';
part 'plan_models.g.dart';

/// Main plan entity
@freezed
class Plan with _$Plan {
  const factory Plan({
    String? id,
    String? householdId,
    String? title,
    @Default('active') String status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Plan;

  factory Plan.fromJson(Map<String, dynamic> json) => _$PlanFromJson(json);
}

/// Plan member (participant)
@freezed
class PlanMember with _$PlanMember {
  const factory PlanMember({
    required String id,
    required String planId,
    required String memberId,
    @Default('kid') String role,
    @Default(false) bool canDecide,
    DateTime? createdAt,
  }) = _PlanMember;

  factory PlanMember.fromJson(Map<String, dynamic> json) =>
      _$PlanMemberFromJson(json);
}

/// Plan message (chat)
@freezed
class PlanMessage with _$PlanMessage {
  const factory PlanMessage({
    String? id,
    @JsonKey(name: 'plan_id') String? planId,
    @JsonKey(name: 'author_type') String? authorType, // 'member' or 'morgan'
    @JsonKey(name: 'author_member_id') String? authorMemberId,
    @JsonKey(name: 'body_md') String? bodyMd,
    @JsonKey(name: 'time_ago') String? timeAgo, // Human-readable timestamp from backend
    @Default([]) List<dynamic> attachments,
    @JsonKey(name: 'reply_to_id') String? replyToId,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _PlanMessage;

  factory PlanMessage.fromJson(Map<String, dynamic> json) =>
      _$PlanMessageFromJson(json);
}

/// Plan proposal (activity suggestion)
@freezed
class PlanProposal with _$PlanProposal {
  const factory PlanProposal({
    String? id,
    String? planId,
    String? activityName,
    String? activityId,
    String? proposedByMemberId,
    String? reasoning,
    int? durationMin,
    String? costBand,
    String? indoorOutdoor,
    String? location,
    @Default([]) List<String> tags,
    Map<String, dynamic>? detailsJson,
    DateTime? createdAt,
  }) = _PlanProposal;

  factory PlanProposal.fromJson(Map<String, dynamic> json) =>
      _$PlanProposalFromJson(json);
}

/// Plan vote
@freezed
class PlanVote with _$PlanVote {
  const factory PlanVote({
    String? id,
    String? proposalId,
    String? voterMemberId,
    @Default(0) int value, // +1, 0, -1
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _PlanVote;

  factory PlanVote.fromJson(Map<String, dynamic> json) =>
      _$PlanVoteFromJson(json);
}

/// Plan constraint
@freezed
class PlanConstraint with _$PlanConstraint {
  const factory PlanConstraint({
    String? id,
    String? planId,
    String? type,
    Map<String, dynamic>? valueJson,
    String? addedByMemberId,
    DateTime? createdAt,
  }) = _PlanConstraint;

  factory PlanConstraint.fromJson(Map<String, dynamic> json) =>
      _$PlanConstraintFromJson(json);
}

/// Plan decision
@freezed
class PlanDecision with _$PlanDecision {
  const factory PlanDecision({
    String? id,
    String? planId,
    String? proposalId,
    @Default('') String summaryMd,
    String? decidedByMemberId,
    DateTime? createdAt,
  }) = _PlanDecision;

  factory PlanDecision.fromJson(Map<String, dynamic> json) =>
      _$PlanDecisionFromJson(json);
}

/// Plan itinerary
@freezed
class PlanItinerary with _$PlanItinerary {
  const factory PlanItinerary({
    String? id,
    String? planId,
    String? title,
    @Default([]) List<dynamic> itemsJson,
    String? createdByMemberId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _PlanItinerary;

  factory PlanItinerary.fromJson(Map<String, dynamic> json) =>
      _$PlanItineraryFromJson(json);
}

/// Plan summary for list view
@freezed
class PlanSummary with _$PlanSummary {
  const factory PlanSummary({
    String? id,
    String? householdId,
    String? title,
    @Default('active') String status,
    @Default([]) List<MemberFacepileItem> memberFacepile,
    String? lastMessageSnippet,
    String? lastMessageAuthor,
    @Default(0) int proposalCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _PlanSummary;

  factory PlanSummary.fromJson(Map<String, dynamic> json) =>
      _$PlanSummaryFromJson(json);
}

/// Member facepile item
@freezed
class MemberFacepileItem with _$MemberFacepileItem {
  const factory MemberFacepileItem({
    required String memberId,
    required String name,
    String? photoUrl,
  }) = _MemberFacepileItem;

  factory MemberFacepileItem.fromJson(Map<String, dynamic> json) =>
      _$MemberFacepileItemFromJson(json);
}

/// Proposal with votes (for display)
@freezed
class ProposalWithVotes with _$ProposalWithVotes {
  const factory ProposalWithVotes({
    required PlanProposal proposal,
    @Default(0) int upvotes,
    @Default(0) int downvotes,
    @Default(0) int neutral,
    @Default(0) int score,
    int? userVote,
    Map<String, dynamic>? feasibility,
  }) = _ProposalWithVotes;

  factory ProposalWithVotes.fromJson(Map<String, dynamic> json) =>
      _$ProposalWithVotesFromJson(json);
}

/// Request models
class CreatePlanRequest {
  final String householdId;
  final String title;
  final List<String> memberIds;
  final Map<String, dynamic>? seedProposal;

  const CreatePlanRequest({
    required this.householdId,
    required this.title,
    this.memberIds = const [],
    this.seedProposal,
  });

  Map<String, dynamic> toJson() => {
        'household_id': householdId,
        'title': title,
        'member_ids': memberIds,
        if (seedProposal != null) 'seed_proposal': seedProposal,
      };
}

class SendMessageRequest {
  final String planId;
  final String? authorMemberId;
  final String bodyMd;
  final List<dynamic> attachments;
  final String? replyToId;

  const SendMessageRequest({
    required this.planId,
    this.authorMemberId,
    required this.bodyMd,
    this.attachments = const [],
    this.replyToId,
  });

  Map<String, dynamic> toJson() => {
        'author_member_id': authorMemberId,
        'body_md': bodyMd,
        'attachments': attachments,
        if (replyToId != null) 'reply_to_id': replyToId,
      };
}

class VoteRequest {
  final int value;

  const VoteRequest({
    required this.value,
  });

  Map<String, dynamic> toJson() => {
        'value': value,
      };
}

class AddConstraintRequest {
  final String type;
  final Map<String, dynamic> valueJson;
  final String? addedByMemberId;

  const AddConstraintRequest({
    required this.type,
    required this.valueJson,
    this.addedByMemberId,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        'value_json': valueJson,
        if (addedByMemberId != null) 'added_by_member_id': addedByMemberId,
      };
}

class MorganActionRequest {
  final String planId;
  final String action;
  final Map<String, dynamic>? context;

  const MorganActionRequest({
    required this.planId,
    required this.action,
    this.context,
  });

  Map<String, dynamic> toJson() => {
        'plan_id': planId,
        'action': action,
        if (context != null) 'context': context,
      };
}

/// Feasibility status
enum FeasibilityStatus {
  @JsonValue('fits')
  fits,
  @JsonValue('stretch')
  stretch,
  @JsonValue('blocked')
  blocked,
}

/// Feasibility reason
@freezed
class FeasibilityReason with _$FeasibilityReason {
  const factory FeasibilityReason({
    required String type,
    required String message,
    String? fixSuggestion,
  }) = _FeasibilityReason;

  factory FeasibilityReason.fromJson(Map<String, dynamic> json) =>
      _$FeasibilityReasonFromJson(json);
}

/// Proposal feasibility
@freezed
class ProposalFeasibility with _$ProposalFeasibility {
  const factory ProposalFeasibility({
    required String proposalId,
    required FeasibilityStatus status,
    @Default([]) List<FeasibilityReason> reasons,
    @Default(1.0) double score,
  }) = _ProposalFeasibility;

  factory ProposalFeasibility.fromJson(Map<String, dynamic> json) =>
      _$ProposalFeasibilityFromJson(json);
}

