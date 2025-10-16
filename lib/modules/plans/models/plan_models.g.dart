// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlanImpl _$$PlanImplFromJson(Map<String, dynamic> json) => _$PlanImpl(
      id: json['id'] as String?,
      householdId: json['householdId'] as String?,
      title: json['title'] as String?,
      status: json['status'] as String? ?? 'active',
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$PlanImplToJson(_$PlanImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'householdId': instance.householdId,
      'title': instance.title,
      'status': instance.status,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_$PlanMemberImpl _$$PlanMemberImplFromJson(Map<String, dynamic> json) =>
    _$PlanMemberImpl(
      id: json['id'] as String,
      planId: json['planId'] as String,
      memberId: json['memberId'] as String,
      role: json['role'] as String? ?? 'kid',
      canDecide: json['canDecide'] as bool? ?? false,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$PlanMemberImplToJson(_$PlanMemberImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'planId': instance.planId,
      'memberId': instance.memberId,
      'role': instance.role,
      'canDecide': instance.canDecide,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

_$PlanMessageImpl _$$PlanMessageImplFromJson(Map<String, dynamic> json) =>
    _$PlanMessageImpl(
      id: json['id'] as String?,
      planId: json['plan_id'] as String?,
      authorType: json['author_type'] as String?,
      authorMemberId: json['author_member_id'] as String?,
      bodyMd: json['body_md'] as String?,
      timeAgo: json['time_ago'] as String?,
      attachments: json['attachments'] as List<dynamic>? ?? const [],
      replyToId: json['reply_to_id'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$PlanMessageImplToJson(_$PlanMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'plan_id': instance.planId,
      'author_type': instance.authorType,
      'author_member_id': instance.authorMemberId,
      'body_md': instance.bodyMd,
      'time_ago': instance.timeAgo,
      'attachments': instance.attachments,
      'reply_to_id': instance.replyToId,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

_$PlanProposalImpl _$$PlanProposalImplFromJson(Map<String, dynamic> json) =>
    _$PlanProposalImpl(
      id: json['id'] as String?,
      planId: json['planId'] as String?,
      activityName: json['activityName'] as String?,
      activityId: json['activityId'] as String?,
      proposedByMemberId: json['proposedByMemberId'] as String?,
      reasoning: json['reasoning'] as String?,
      durationMin: (json['durationMin'] as num?)?.toInt(),
      costBand: json['costBand'] as String?,
      indoorOutdoor: json['indoorOutdoor'] as String?,
      location: json['location'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      detailsJson: json['detailsJson'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$PlanProposalImplToJson(_$PlanProposalImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'planId': instance.planId,
      'activityName': instance.activityName,
      'activityId': instance.activityId,
      'proposedByMemberId': instance.proposedByMemberId,
      'reasoning': instance.reasoning,
      'durationMin': instance.durationMin,
      'costBand': instance.costBand,
      'indoorOutdoor': instance.indoorOutdoor,
      'location': instance.location,
      'tags': instance.tags,
      'detailsJson': instance.detailsJson,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

_$PlanVoteImpl _$$PlanVoteImplFromJson(Map<String, dynamic> json) =>
    _$PlanVoteImpl(
      id: json['id'] as String?,
      proposalId: json['proposalId'] as String?,
      voterMemberId: json['voterMemberId'] as String?,
      value: (json['value'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$PlanVoteImplToJson(_$PlanVoteImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'proposalId': instance.proposalId,
      'voterMemberId': instance.voterMemberId,
      'value': instance.value,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_$PlanConstraintImpl _$$PlanConstraintImplFromJson(Map<String, dynamic> json) =>
    _$PlanConstraintImpl(
      id: json['id'] as String?,
      planId: json['planId'] as String?,
      type: json['type'] as String?,
      valueJson: json['valueJson'] as Map<String, dynamic>?,
      addedByMemberId: json['addedByMemberId'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$PlanConstraintImplToJson(
        _$PlanConstraintImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'planId': instance.planId,
      'type': instance.type,
      'valueJson': instance.valueJson,
      'addedByMemberId': instance.addedByMemberId,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

_$PlanDecisionImpl _$$PlanDecisionImplFromJson(Map<String, dynamic> json) =>
    _$PlanDecisionImpl(
      id: json['id'] as String?,
      planId: json['planId'] as String?,
      proposalId: json['proposalId'] as String?,
      summaryMd: json['summaryMd'] as String? ?? '',
      decidedByMemberId: json['decidedByMemberId'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$PlanDecisionImplToJson(_$PlanDecisionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'planId': instance.planId,
      'proposalId': instance.proposalId,
      'summaryMd': instance.summaryMd,
      'decidedByMemberId': instance.decidedByMemberId,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

_$PlanItineraryImpl _$$PlanItineraryImplFromJson(Map<String, dynamic> json) =>
    _$PlanItineraryImpl(
      id: json['id'] as String?,
      planId: json['planId'] as String?,
      title: json['title'] as String?,
      itemsJson: json['itemsJson'] as List<dynamic>? ?? const [],
      createdByMemberId: json['createdByMemberId'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$PlanItineraryImplToJson(_$PlanItineraryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'planId': instance.planId,
      'title': instance.title,
      'itemsJson': instance.itemsJson,
      'createdByMemberId': instance.createdByMemberId,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_$PlanSummaryImpl _$$PlanSummaryImplFromJson(Map<String, dynamic> json) =>
    _$PlanSummaryImpl(
      id: json['id'] as String?,
      householdId: json['householdId'] as String?,
      title: json['title'] as String?,
      status: json['status'] as String? ?? 'active',
      memberFacepile: (json['memberFacepile'] as List<dynamic>?)
              ?.map(
                  (e) => MemberFacepileItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      lastMessageSnippet: json['lastMessageSnippet'] as String?,
      lastMessageAuthor: json['lastMessageAuthor'] as String?,
      proposalCount: (json['proposalCount'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$PlanSummaryImplToJson(_$PlanSummaryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'householdId': instance.householdId,
      'title': instance.title,
      'status': instance.status,
      'memberFacepile': instance.memberFacepile,
      'lastMessageSnippet': instance.lastMessageSnippet,
      'lastMessageAuthor': instance.lastMessageAuthor,
      'proposalCount': instance.proposalCount,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_$MemberFacepileItemImpl _$$MemberFacepileItemImplFromJson(
        Map<String, dynamic> json) =>
    _$MemberFacepileItemImpl(
      memberId: json['memberId'] as String,
      name: json['name'] as String,
      photoUrl: json['photoUrl'] as String?,
    );

Map<String, dynamic> _$$MemberFacepileItemImplToJson(
        _$MemberFacepileItemImpl instance) =>
    <String, dynamic>{
      'memberId': instance.memberId,
      'name': instance.name,
      'photoUrl': instance.photoUrl,
    };

_$ProposalWithVotesImpl _$$ProposalWithVotesImplFromJson(
        Map<String, dynamic> json) =>
    _$ProposalWithVotesImpl(
      proposal: PlanProposal.fromJson(json['proposal'] as Map<String, dynamic>),
      upvotes: (json['upvotes'] as num?)?.toInt() ?? 0,
      downvotes: (json['downvotes'] as num?)?.toInt() ?? 0,
      neutral: (json['neutral'] as num?)?.toInt() ?? 0,
      score: (json['score'] as num?)?.toInt() ?? 0,
      userVote: (json['userVote'] as num?)?.toInt(),
      feasibility: json['feasibility'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$ProposalWithVotesImplToJson(
        _$ProposalWithVotesImpl instance) =>
    <String, dynamic>{
      'proposal': instance.proposal,
      'upvotes': instance.upvotes,
      'downvotes': instance.downvotes,
      'neutral': instance.neutral,
      'score': instance.score,
      'userVote': instance.userVote,
      'feasibility': instance.feasibility,
    };

_$FeasibilityReasonImpl _$$FeasibilityReasonImplFromJson(
        Map<String, dynamic> json) =>
    _$FeasibilityReasonImpl(
      type: json['type'] as String,
      message: json['message'] as String,
      fixSuggestion: json['fixSuggestion'] as String?,
    );

Map<String, dynamic> _$$FeasibilityReasonImplToJson(
        _$FeasibilityReasonImpl instance) =>
    <String, dynamic>{
      'type': instance.type,
      'message': instance.message,
      'fixSuggestion': instance.fixSuggestion,
    };

_$ProposalFeasibilityImpl _$$ProposalFeasibilityImplFromJson(
        Map<String, dynamic> json) =>
    _$ProposalFeasibilityImpl(
      proposalId: json['proposalId'] as String,
      status: $enumDecode(_$FeasibilityStatusEnumMap, json['status']),
      reasons: (json['reasons'] as List<dynamic>?)
              ?.map(
                  (e) => FeasibilityReason.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      score: (json['score'] as num?)?.toDouble() ?? 1.0,
    );

Map<String, dynamic> _$$ProposalFeasibilityImplToJson(
        _$ProposalFeasibilityImpl instance) =>
    <String, dynamic>{
      'proposalId': instance.proposalId,
      'status': _$FeasibilityStatusEnumMap[instance.status]!,
      'reasons': instance.reasons,
      'score': instance.score,
    };

const _$FeasibilityStatusEnumMap = {
  FeasibilityStatus.fits: 'fits',
  FeasibilityStatus.stretch: 'stretch',
  FeasibilityStatus.blocked: 'blocked',
};
