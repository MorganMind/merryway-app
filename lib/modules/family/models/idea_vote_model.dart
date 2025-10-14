import 'package:equatable/equatable.dart';

enum VoteType { 
  love, 
  neutral, 
  notInterested;

  /// Convert to database format (snake_case)
  String toDbString() {
    switch (this) {
      case VoteType.love:
        return 'love';
      case VoteType.neutral:
        return 'neutral';
      case VoteType.notInterested:
        return 'not_interested';
    }
  }

  /// Parse from database format (snake_case)
  static VoteType fromDbString(String value) {
    switch (value) {
      case 'love':
        return VoteType.love;
      case 'neutral':
        return VoteType.neutral;
      case 'not_interested':
        return VoteType.notInterested;
      default:
        return VoteType.neutral;
    }
  }
}

class IdeaVote extends Equatable {
  final String? id;
  final String householdId;
  final String memberId;
  final String activityName;
  final String category;
  final VoteType voteType;
  final Map<String, dynamic>? context;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const IdeaVote({
    this.id,
    required this.householdId,
    required this.memberId,
    required this.activityName,
    this.category = 'today',
    required this.voteType,
    this.context,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        householdId,
        memberId,
        activityName,
        category,
        voteType,
        context,
        createdAt,
        updatedAt,
      ];

  Map<String, dynamic> toJson() => {
        'household_id': householdId,
        'member_id': memberId,
        'activity_name': activityName,
        'category': category,
        'vote_type': voteType.toDbString(),
        if (context != null) 'context': context,
      };

  factory IdeaVote.fromJson(Map<String, dynamic> json) {
    return IdeaVote(
      id: json['id'],
      householdId: json['household_id'],
      memberId: json['member_id'],
      activityName: json['activity_name'],
      category: json['category'] ?? 'today',
      voteType: VoteType.fromDbString(json['vote_type'] ?? 'neutral'),
      context: json['context'] != null
          ? Map<String, dynamic>.from(json['context'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }
}

/// Result of vote aggregation for an activity
class VoteAggregation {
  final int loveCount;
  final int neutralCount;
  final int notInterestedCount;
  final int totalVotes;
  final int totalMembers;
  final List<String> loveVoters; // Member IDs
  final List<String> neutralVoters;
  final List<String> notInterestedVoters;

  VoteAggregation({
    required this.loveCount,
    required this.neutralCount,
    required this.notInterestedCount,
    required this.totalVotes,
    required this.totalMembers,
    required this.loveVoters,
    required this.neutralVoters,
    required this.notInterestedVoters,
  });

  /// Check if activity should be hidden (everyone voted not interested)
  bool get shouldHide => notInterestedCount == totalMembers && totalMembers > 0;

  /// Check if this is a "Just for X" situation
  /// (Everyone not interested except one person who loves it)
  bool get isJustForOne =>
      loveCount == 1 && notInterestedCount == totalMembers - 1 && totalMembers > 1;

  /// Get the member ID who loves it (for "Just for X" badge)
  String? get soloLover => isJustForOne && loveVoters.isNotEmpty ? loveVoters.first : null;

  /// Check if we should prompt a neutral voter
  /// (Everyone not interested except one neutral)
  bool get shouldPromptNeutral =>
      neutralCount == 1 && notInterestedCount == totalMembers - 1 && totalMembers > 1;

  /// Get the neutral voter to prompt
  String? get neutralVoterToPrompt =>
      shouldPromptNeutral && neutralVoters.isNotEmpty ? neutralVoters.first : null;
}

