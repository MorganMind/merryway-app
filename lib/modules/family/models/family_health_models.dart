import 'package:equatable/equatable.dart';

class FamilyHealthMetrics extends Equatable {
  final String householdId;
  final DateTime? lastActivityDate;  // Made nullable - can be null if no activities yet
  final int daysSinceLastActivity;
  final int currentStreak;
  final int longestStreak;
  final int totalActivitiesThisWeek;
  final int totalActivitiesThisMonth;
  final int totalActivitiesAllTime;
  final double totalHoursTogetherThisWeek;
  final double totalHoursTogetherThisMonth;
  final double averageRating;
  final PodStats? mostActivePod;  // Nullable - null if no activities yet
  final MemberStats? mostActiveInviter;  // Nullable - null if no activities yet
  final List<Achievement> recentAchievements;
  final List<Milestone> milestones;
  final ActivityTrend? weeklyTrend;  // Nullable - null if no activities yet
  final int daysActiveThisWeek;
  final int daysActiveThisMonth;
  final ConnectionScore? connectionScore;  // Nullable - null if no activities yet

  const FamilyHealthMetrics({
    required this.householdId,
    required this.lastActivityDate,
    required this.daysSinceLastActivity,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalActivitiesThisWeek,
    required this.totalActivitiesThisMonth,
    required this.totalActivitiesAllTime,
    required this.totalHoursTogetherThisWeek,
    required this.totalHoursTogetherThisMonth,
    required this.averageRating,
    required this.mostActivePod,
    required this.mostActiveInviter,
    required this.recentAchievements,
    required this.milestones,
    required this.weeklyTrend,
    required this.daysActiveThisWeek,
    required this.daysActiveThisMonth,
    required this.connectionScore,
  });

  @override
  List<Object?> get props => [
        householdId,
        lastActivityDate,
        daysSinceLastActivity,
        currentStreak,
        longestStreak,
        totalActivitiesThisWeek,
        totalActivitiesThisMonth,
        totalActivitiesAllTime,
        totalHoursTogetherThisWeek,
        totalHoursTogetherThisMonth,
        averageRating,
        mostActivePod,
        mostActiveInviter,
        recentAchievements,
        milestones,
        weeklyTrend,
        daysActiveThisWeek,
        daysActiveThisMonth,
        connectionScore,
      ];

  factory FamilyHealthMetrics.fromJson(Map<String, dynamic> json) =>
      FamilyHealthMetrics(
        householdId: json['household_id'] as String,
        lastActivityDate: json['last_activity_date'] != null 
            ? DateTime.parse(json['last_activity_date'] as String)
            : null,
        daysSinceLastActivity: json['days_since_last_activity'] as int,
        currentStreak: json['current_streak'] as int,
        longestStreak: json['longest_streak'] as int,
        totalActivitiesThisWeek: json['total_activities_this_week'] as int,
        totalActivitiesThisMonth: json['total_activities_this_month'] as int,
        totalActivitiesAllTime: json['total_activities_all_time'] as int,
        totalHoursTogetherThisWeek:
            (json['total_hours_together_this_week'] as num).toDouble(),
        totalHoursTogetherThisMonth:
            (json['total_hours_together_this_month'] as num).toDouble(),
        averageRating: (json['average_rating'] as num).toDouble(),
        mostActivePod: json['most_active_pod'] != null
            ? PodStats.fromJson(json['most_active_pod'] as Map<String, dynamic>)
            : null,
        mostActiveInviter: json['most_active_inviter'] != null
            ? MemberStats.fromJson(json['most_active_inviter'] as Map<String, dynamic>)
            : null,
        recentAchievements: (json['recent_achievements'] as List)
            .map((a) => Achievement.fromJson(a as Map<String, dynamic>))
            .toList(),
        milestones: (json['milestones'] as List)
            .map((m) => Milestone.fromJson(m as Map<String, dynamic>))
            .toList(),
        weeklyTrend: json['weekly_trend'] != null
            ? ActivityTrend.fromJson(json['weekly_trend'] as Map<String, dynamic>)
            : null,
        daysActiveThisWeek: json['days_active_this_week'] as int,
        daysActiveThisMonth: json['days_active_this_month'] as int,
        connectionScore: json['connection_score'] != null
            ? ConnectionScore.fromJson(json['connection_score'] as Map<String, dynamic>)
            : null,
      );
}

class PodStats extends Equatable {
  final String podId;
  final String podName;
  final String icon;
  final int activityCount;
  final double totalHours;

  const PodStats({
    required this.podId,
    required this.podName,
    required this.icon,
    required this.activityCount,
    required this.totalHours,
  });

  @override
  List<Object?> get props => [podId, podName, icon, activityCount, totalHours];

  factory PodStats.fromJson(Map<String, dynamic> json) => PodStats(
        podId: json['pod_id'] as String,
        podName: json['pod_name'] as String,
        icon: json['icon'] as String,
        activityCount: json['activity_count'] as int,
        totalHours: (json['total_hours'] as num).toDouble(),
      );
}

class MemberStats extends Equatable {
  final String memberId;
  final String memberName;
  final String avatarEmoji;
  final int initiatedCount;
  final int participatedCount;

  const MemberStats({
    required this.memberId,
    required this.memberName,
    required this.avatarEmoji,
    required this.initiatedCount,
    required this.participatedCount,
  });

  @override
  List<Object?> get props =>
      [memberId, memberName, avatarEmoji, initiatedCount, participatedCount];

  factory MemberStats.fromJson(Map<String, dynamic> json) => MemberStats(
        memberId: json['member_id'] as String,
        memberName: json['member_name'] as String,
        avatarEmoji: json['avatar_emoji'] as String,
        initiatedCount: json['initiated_count'] as int,
        participatedCount: json['participated_count'] as int,
      );
}

class Achievement extends Equatable {
  final String id;
  final String title;
  final String description;
  final String icon;
  final DateTime unlockedAt;
  final AchievementTier tier;
  final int points;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.unlockedAt,
    required this.tier,
    required this.points,
  });

  @override
  List<Object?> get props =>
      [id, title, description, icon, unlockedAt, tier, points];

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        icon: json['icon'] as String,
        unlockedAt: DateTime.parse(json['unlocked_at'] as String),
        tier: AchievementTier.values
            .firstWhere((t) => t.name == json['tier'] as String),
        points: json['points'] as int,
      );
}

enum AchievementTier { bronze, silver, gold, platinum, diamond }

class Milestone extends Equatable {
  final String id;
  final String title;
  final String description;
  final int targetValue;
  final int currentValue;
  final bool completed;
  final String rewardDescription;
  final String icon;

  const Milestone({
    required this.id,
    required this.title,
    required this.description,
    required this.targetValue,
    required this.currentValue,
    required this.completed,
    required this.rewardDescription,
    required this.icon,
  });

  double get progress => currentValue / targetValue;

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        targetValue,
        currentValue,
        completed,
        rewardDescription,
        icon,
      ];

  factory Milestone.fromJson(Map<String, dynamic> json) => Milestone(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        targetValue: json['target_value'] as int,
        currentValue: json['current_value'] as int,
        completed: json['completed'] as bool,
        rewardDescription: json['reward_description'] as String,
        icon: json['icon'] as String,
      );
}

class ActivityTrend extends Equatable {
  final List<int> dailyCounts;
  final double percentChange;
  final TrendDirection direction;

  const ActivityTrend({
    required this.dailyCounts,
    required this.percentChange,
    required this.direction,
  });

  @override
  List<Object?> get props => [dailyCounts, percentChange, direction];

  factory ActivityTrend.fromJson(Map<String, dynamic> json) => ActivityTrend(
        dailyCounts: List<int>.from(json['daily_counts'] as List),
        percentChange: (json['percent_change'] as num).toDouble(),
        direction: TrendDirection.values
            .firstWhere((d) => d.name == json['direction'] as String),
      );
}

enum TrendDirection { up, down, stable }

class ConnectionScore extends Equatable {
  final int score;
  final String level;
  final String description;
  final String encouragement;
  final List<String> strengths;
  final List<String> suggestions;

  const ConnectionScore({
    required this.score,
    required this.level,
    required this.description,
    required this.encouragement,
    required this.strengths,
    required this.suggestions,
  });

  @override
  List<Object?> get props =>
      [score, level, description, encouragement, strengths, suggestions];

  factory ConnectionScore.fromJson(Map<String, dynamic> json) =>
      ConnectionScore(
        score: json['score'] as int,
        level: json['level'] as String,
        description: json['description'] as String,
        encouragement: json['encouragement'] as String,
        strengths: List<String>.from(json['strengths'] as List),
        suggestions: List<String>.from(json['suggestions'] as List),
      );
}

