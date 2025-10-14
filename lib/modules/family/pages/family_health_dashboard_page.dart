import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../models/family_health_models.dart';
import '../models/family_models.dart';
import '../services/family_health_service.dart';
import '../../core/theme/merryway_theme.dart';
import '../../core/theme/redesign_tokens.dart';
import '../../home/widgets/compact_header.dart';
import '../../auth/services/user_context_service.dart';
import '../../auth/widgets/user_switcher.dart';
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
  String? _errorMessage;
  late AnimationController _animController;
  
  // User context state
  List<FamilyMember> _familyMembers = [];
  bool _familyModeEnabled = false;
  String? _currentMemberId;

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
    _loadHouseholdData();
    _loadMetrics();
  }
  
  Future<void> _loadHouseholdData() async {
    final supabase = Supabase.instance.client;
    try {
      // Load household data
      final householdData = await supabase
          .from('households')
          .select('family_mode_enabled')
          .eq('id', widget.householdId)
          .maybeSingle();
      
      final isFamilyModeEnabled = householdData?['family_mode_enabled'] ?? false;
      
      // Load family members
      final membersData = await supabase
          .from('household_members')
          .select()
          .eq('household_id', widget.householdId);
      
      final members = (membersData as List<dynamic>)
          .map((json) => FamilyMember.fromJson(json))
          .toList();
      
      // Get current member ID
      final memberId = await UserContextService.getCurrentMemberId(
        allMembers: members,
        familyModeEnabled: isFamilyModeEnabled,
      );
      
      setState(() {
        _familyMembers = members;
        _familyModeEnabled = isFamilyModeEnabled;
        _currentMemberId = memberId;
      });
    } catch (e) {
      print('Error loading household data: $e');
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadMetrics() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      print('🔵 Dashboard: Loading metrics for household ${widget.householdId}');
      
      final result = await _service.getFamilyHealthMetrics(
        householdId: widget.householdId,
      );

      setState(() {
        _metrics = result;
        _loading = false;
        if (result == null) {
          _errorMessage = 'No data received from backend. Check console logs for details.';
        }
      });

      if (result != null) {
        _animController.forward();
        print('✅ Dashboard: Metrics loaded successfully');
      } else {
        print('❌ Dashboard: No metrics data returned');
      }
    } catch (e) {
      print('❌ Dashboard: Error loading metrics: $e');
      setState(() {
        _loading = false;
        _errorMessage = 'Error loading dashboard: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RedesignTokens.canvas,
      body: Column(
        children: [
          // Compact Header
          CompactHeader(
            isIdeasActive: false,
            isPlannerActive: false,
            isMomentsActive: false,
            onIdeas: () => context.go('/'),
            onPlanner: () {
              context.push('/plans', extra: {
                'householdId': widget.householdId,
              });
            },
            onTime: () {
              // Already on Time/Trails page
            },
            onMoments: () {
              if (_familyMembers.isNotEmpty) {
                context.push('/moments', extra: {
                  'householdId': widget.householdId,
                  'allMembers': _familyMembers,
                });
              }
            },
            onSettings: () => context.go('/settings'),
            onHelp: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Help coming soon!')),
              );
            },
            onLogout: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
              
              if (confirmed == true && context.mounted) {
                await Supabase.instance.client.auth.signOut();
                if (context.mounted) {
                  context.go('/login');
                }
              }
            },
            userSwitcher: _familyModeEnabled && _familyMembers.isNotEmpty
                ? UserSwitcher(
                    members: _familyMembers,
                    currentUser: UserContextService.getCurrentMember(
                      _currentMemberId,
                      _familyMembers,
                    ),
                    onUserSelected: (member) async {
                      await UserContextService.setSelectedMember(member.id!);
                      setState(() {
                        _currentMemberId = member.id;
                      });
                      // Reload metrics for new user context
                      _loadMetrics();
                    },
                  )
                : null,
          ),
          
          // Content
          Expanded(
            child: _buildContent(context),
          ),
        ],
      ),
    );
  }
  
  Widget _buildContent(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_errorMessage != null) {
      return _buildErrorState();
    }
    
    if (_metrics == null) {
      return _buildEmptyState();
    }
    
    return SingleChildScrollView(
      child: _buildDashboard(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red[300],
            ),
            const SizedBox(height: 24),
            const Text(
              'Unable to Load Dashboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadMetrics,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: RedesignTokens.primary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                print('📋 Debug Info:');
                print('  Household ID: ${widget.householdId}');
                print('  API URL: ${Environment.apiUrl}');
                print('  Full endpoint: ${Environment.apiUrl}/family-health/metrics/?household_id=${widget.householdId}');
              },
              child: const Text('Show Debug Info'),
            ),
          ],
        ),
      ),
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
              color: RedesignTokens.accentGold.withOpacity(0.3),
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
            if (metrics.connectionScore != null) ...[
              _buildConnectionScoreCard(metrics.connectionScore!),
              const SizedBox(height: 16),
            ],
            _buildStreakCard(metrics),
            const SizedBox(height: 16),
            _buildQuickStatsGrid(metrics),
            const SizedBox(height: 16),
            if (metrics.weeklyTrend != null) ...[
              _buildWeeklyTrendCard(metrics.weeklyTrend!),
              const SizedBox(height: 16),
            ],
            if (metrics.mostActivePod != null) ...[
              _buildMostActivePodCard(metrics.mostActivePod!),
              const SizedBox(height: 16),
            ],
            if (metrics.mostActiveInviter != null) ...[
              _buildMostActiveInviterCard(metrics.mostActiveInviter!),
              const SizedBox(height: 16),
            ],
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
            RedesignTokens.primary,
            RedesignTokens.accentSage,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: RedesignTokens.primary.withOpacity(0.3),
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
    final isStreakActive = metrics.lastActivityDate != null && metrics.daysSinceLastActivity <= 1;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isStreakActive
              ? [RedesignTokens.accentGold, Colors.orange[400]!]
              : [Colors.grey[300]!, Colors.grey[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isStreakActive
                    ? RedesignTokens.accentGold
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
                                : metrics.lastActivityDate == null
                                    ? 'Start your first activity!'
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
                                RedesignTokens.primary,
                                RedesignTokens.accentSage,
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
                  color: RedesignTokens.primary.withOpacity(0.1),
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
                  color: RedesignTokens.accentGold.withOpacity(0.2),
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
        return RedesignTokens.accentGold;
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
                            RedesignTokens.accentGold,
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
                    color: RedesignTokens.accentGold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.card_giftcard,
                        color: RedesignTokens.accentGold,
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
