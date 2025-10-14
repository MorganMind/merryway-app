# Family Time Health Dashboard - Complete Implementation

## File: `lib/modules/family/models/family_health_models.dart`

```dart
import 'package:equatable/equatable.dart';

class FamilyHealthMetrics extends Equatable {
  final String householdId;
  final DateTime lastActivityDate;
  final int daysSinceLastActivity;
  final int currentStreak;
  final int longestStreak;
  final int totalActivitiesThisWeek;
  final int totalActivitiesThisMonth;
  final int totalActivitiesAllTime;
  final double totalHoursTogetherThisWeek;
  final double totalHoursTogetherThisMonth;
  final double averageRating;
  final PodStats mostActivePod;
  final MemberStats mostActiveInviter;
  final List<Achievement> recentAchievements;
  final List<Milestone> milestones;
  final ActivityTrend weeklyTrend;
  final int daysActiveThisWeek;
  final int daysActiveThisMonth;
  final ConnectionScore connectionScore;

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
        lastActivityDate: DateTime.parse(json['last_activity_date'] as String),
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
        mostActivePod: PodStats.fromJson(json['most_active_pod'] as Map<String, dynamic>),
        mostActiveInviter:
            MemberStats.fromJson(json['most_active_inviter'] as Map<String, dynamic>),
        recentAchievements: (json['recent_achievements'] as List)
            .map((a) => Achievement.fromJson(a as Map<String, dynamic>))
            .toList(),
        milestones: (json['milestones'] as List)
            .map((m) => Milestone.fromJson(m as Map<String, dynamic>))
            .toList(),
        weeklyTrend: ActivityTrend.fromJson(json['weekly_trend'] as Map<String, dynamic>),
        daysActiveThisWeek: json['days_active_this_week'] as int,
        daysActiveThisMonth: json['days_active_this_month'] as int,
        connectionScore:
            ConnectionScore.fromJson(json['connection_score'] as Map<String, dynamic>),
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
```

## File: `lib/modules/family/services/family_health_service.dart`

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/family_health_models.dart';

class FamilyHealthService {
  final String baseUrl;
  final String Function() getToken;

  FamilyHealthService({
    required this.baseUrl,
    required this.getToken,
  });

  Future<FamilyHealthMetrics?> getFamilyHealthMetrics({
    required String householdId,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/family-health/metrics/').replace(
        queryParameters: {
          'household_id': householdId,
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${getToken()}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return FamilyHealthMetrics.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error fetching family health metrics: $e');
      return null;
    }
  }

  Future<List<Achievement>> getAchievements({
    required String householdId,
    bool unlockedOnly = false,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/family-health/achievements/').replace(
        queryParameters: {
          'household_id': householdId,
          'unlocked_only': unlockedOnly.toString(),
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${getToken()}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data
            .map((a) => Achievement.fromJson(a as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching achievements: $e');
      return [];
    }
  }

  Future<List<Milestone>> getMilestones({
    required String householdId,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/family-health/milestones/').replace(
        queryParameters: {
          'household_id': householdId,
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${getToken()}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data
            .map((m) => Milestone.fromJson(m as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching milestones: $e');
      return [];
    }
  }
}
```

## File: `lib/modules/family/pages/family_health_dashboard_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/family_health_models.dart';
import '../services/family_health_service.dart';
import '../../core/theme/merryway_theme.dart';
import '../../../config/environment.dart';

class FamilyHealthDashboardPage extends StatefulWidget {
  final String householdId;

  const FamilyHealthDashboardPage({
    Key? key,
    required this.householdId,
  }) : super(key: key);

  @override
  State<FamilyHealthDashboardPage> createState() =>
      _FamilyHealthDashboardPageState();
}

class _FamilyHealthDashboardPageState extends State<FamilyHealthDashboardPage>
    with SingleTickerProviderStateMixin {
  late FamilyHealthService _service;
  FamilyHealthMetrics? _metrics;
  bool _loading = false;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _service = FamilyHealthService(
      baseUrl: Environment.apiUrl,
      getToken: () {
        final token = Supabase.instance.client.auth.currentSession?.accessToken;
        return token ?? '';
      },
    );
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _loadMetrics();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadMetrics() async {
    setState(() => _loading = true);

    final result = await _service.getFamilyHealthMetrics(
      householdId: widget.householdId,
    );

    setState(() {
      _metrics = result;
      _loading = false;
    });

    if (result != null) {
      _animController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MerryWayTheme.softBg,
      appBar: AppBar(
        title: const Text('Family Time Health'),
        backgroundColor: MerryWayTheme.primarySoftBlue,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMetrics,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _metrics == null
              ? _buildEmptyState()
              : _buildDashboard(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome,
              size: 80,
              color: MerryWayTheme.accentGolden.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            const Text(
              'Start Your Journey!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Complete your first activity together to unlock your family health dashboard.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    final metrics = _metrics!;

    return RefreshIndicator(
      onRefresh: _loadMetrics,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConnectionScoreCard(metrics.connectionScore),
            const SizedBox(height: 16),
            _buildStreakCard(metrics),
            const SizedBox(height: 16),
            _buildQuickStatsGrid(metrics),
            const SizedBox(height: 16),
            _buildWeeklyTrendCard(metrics.weeklyTrend),
            const SizedBox(height: 16),
            _buildMostActivePodCard(metrics.mostActivePod),
            const SizedBox(height: 16),
            _buildMostActiveInviterCard(metrics.mostActiveInviter),
            const SizedBox(height: 16),
            _buildRecentAchievements(metrics.recentAchievements),
            const SizedBox(height: 16),
            _buildMilestones(metrics.milestones),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionScoreCard(ConnectionScore score) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MerryWayTheme.primarySoftBlue,
            MerryWayTheme.accentLavender,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: MerryWayTheme.primarySoftBlue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${score.score}',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      score.level,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      score.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              score.encouragement,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(FamilyHealthMetrics metrics) {
    final isStreakActive = metrics.daysSinceLastActivity <= 1;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isStreakActive
              ? [MerryWayTheme.accentGolden, Colors.orange[400]!]
              : [Colors.grey[300]!, Colors.grey[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isStreakActive
                    ? MerryWayTheme.accentGolden
                    : Colors.grey[400]!)
                .withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        isStreakActive ? '🔥' : '⏰',
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isStreakActive
                                ? '${metrics.currentStreak} Day Streak!'
                                : 'Streak Paused',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            isStreakActive
                                ? 'Keep the magic going!'
                                : '${metrics.daysSinceLastActivity} days since last activity',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStreakStat(
                  'Current',
                  '${metrics.currentStreak}',
                  Icons.local_fire_department,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStreakStat(
                  'Best Ever',
                  '${metrics.longestStreak}',
                  Icons.emoji_events,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreakStat(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsGrid(FamilyHealthMetrics metrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Stats',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: [
            _buildStatCard(
              'This Week',
              '${metrics.totalActivitiesThisWeek}',
              'Activities',
              Icons.calendar_today,
              Colors.blue,
            ),
            _buildStatCard(
              'This Month',
              '${metrics.totalActivitiesThisMonth}',
              'Activities',
              Icons.calendar_month,
              Colors.purple,
            ),
            _buildStatCard(
              'Time Together',
              '${metrics.totalHoursTogetherThisWeek.toStringAsFixed(1)}h',
              'This Week',
              Icons.access_time,
              Colors.green,
            ),
            _buildStatCard(
              'Avg Rating',
              '${metrics.averageRating.toStringAsFixed(1)} ⭐',
              'Quality Score',
              Icons.star,
              Colors.amber,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyTrendCard(ActivityTrend trend) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Weekly Activity Trend',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getTrendColor(trend.direction).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getTrendIcon(trend.direction),
                      color: _getTrendColor(trend.direction),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${trend.percentChange.abs().toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: _getTrendColor(trend.direction),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final count = trend.dailyCounts[index];
                final maxCount =
                    trend.dailyCounts.reduce((a, b) => a > b ? a : b);
                final height = maxCount > 0 ? (count / maxCount) * 100 : 0;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (count > 0)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '$count',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOut,
                          height: height.toDouble(),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                MerryWayTheme.primarySoftBlue,
                                MerryWayTheme.accentLavender,
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getDayLabel(index),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  String _getDayLabel(int index) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[index];
  }

  Color _getTrendColor(TrendDirection direction) {
    switch (direction) {
      case TrendDirection.up:
        return Colors.green;
      case TrendDirection.down:
        return Colors.red;
      case TrendDirection.stable:
        return Colors.grey;
    }
  }

  IconData _getTrendIcon(TrendDirection direction) {
    switch (direction) {
      case TrendDirection.up:
        return Icons.trending_up;
      case TrendDirection.down:
        return Icons.trending_down;
      case TrendDirection.stable:
        return Icons.trending_flat;
    }
  }

  Widget _buildMostActivePodCard(PodStats pod) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Most Active Group 🏆',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: MerryWayTheme.primarySoftBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    pod.icon,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pod.podName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${pod.activityCount} activities • ${pod.totalHours.toStringAsFixed(1)} hours',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMostActiveInviterCard(MemberStats member) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Activity Champion 🌟',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: MerryWayTheme.accentGolden.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    member.avatarEmoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.memberName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Initiated ${member.initiatedCount} activities',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAchievements(List<Achievement> achievements) {
    if (achievements.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Achievements 🎉',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...achievements.take(3).map((achievement) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getTierColor(achievement.tier).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    achievement.icon,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              title: Text(
                achievement.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  achievement.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getTierColor(achievement.tier).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '+${achievement.points}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _getTierColor(achievement.tier),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Color _getTierColor(AchievementTier tier) {
    switch (tier) {
      case AchievementTier.bronze:
        return Colors.brown;
      case AchievementTier.silver:
        return Colors.grey;
      case AchievementTier.gold:
        return MerryWayTheme.accentGolden;
      case AchievementTier.platinum:
        return Colors.cyan;
      case AchievementTier.diamond:
        return Colors.blue;
    }
  }

  Widget _buildMilestones(List<Milestone> milestones) {
    if (milestones.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Active Milestones 🎯',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...milestones.where((m) => !m.completed).take(3).map((milestone) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      milestone.icon,
                      style: const TextStyle(fontSize: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            milestone.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            milestone.description,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: milestone.progress,
                          minHeight: 10,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            MerryWayTheme.accentGolden,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${milestone.currentValue}/${milestone.targetValue}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: MerryWayTheme.accentGolden.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.card_giftcard,
                        color: MerryWayTheme.accentGolden,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Reward: ${milestone.rewardDescription}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
```

