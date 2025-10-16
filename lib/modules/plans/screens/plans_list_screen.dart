import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/redesign_tokens.dart';
import '../../home/widgets/compact_header.dart';
import '../../family/models/family_models.dart';
import '../../auth/services/user_context_service.dart';
import '../models/plan_models.dart';
import '../services/plans_service.dart';
import '../widgets/plan_card.dart';
import 'plan_thread_screen.dart';
import '../widgets/chat_composer.dart';
import '../services/chat_service.dart';
import '../../auth/widgets/user_switcher.dart';
import '../../core/widgets/sparkle_loading.dart';

/// Main screen showing list of plans
class PlansListScreen extends StatefulWidget {
  final String householdId;

  const PlansListScreen({
    super.key,
    required this.householdId,
  });

  @override
  State<PlansListScreen> createState() => _PlansListScreenState();
}

class _PlansListScreenState extends State<PlansListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _creatingFromSubject = false;
  bool _showLoadingAnimation = false;
  String? _loadingSubject;
  final TextEditingController _inputController = TextEditingController();
  bool _hasText = false;
  final List<String> _starterIdeas = const [
    'Plan a cozy dinner',
    'Weekend family adventure',
    'Birthday surprise',
    'Game night at home',
  ];
  List<PlanSummary> _activePlans = [];
  List<PlanSummary> _archivedPlans = [];
  bool _isLoading = false;
  String? _error;
  String? _currentMemberId;
  List<FamilyMember> _familyMembers = [];
  bool _familyModeEnabled = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPlans();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  String _formatTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'now';
    }
  }

  Future<void> _createFromSubject(String subject) async {
    final trimmed = subject.trim();
    if (trimmed.isEmpty || _creatingFromSubject) return;
    
    // Show loading animation
    setState(() {
      _creatingFromSubject = true;
      _showLoadingAnimation = true;
      _loadingSubject = trimmed;
    });
    
    try {
      // Resolve current member
      final allMembers = await Supabase.instance.client
          .from('family_members')
          .select()
          .eq('household_id', widget.householdId);
      final members = (allMembers as List<dynamic>)
          .map((j) => FamilyMember.fromJson(j))
          .toList();
      final memberId = await UserContextService.getCurrentMemberId(
        allMembers: members,
        familyModeEnabled: true,
      );

      // Create plan with temporary title
      final plan = await PlansService.createPlan(
        CreatePlanRequest(
          householdId: widget.householdId,
          title: 'New Plan', // Temporary title
          memberIds: memberId != null ? [memberId] : const [],
        ),
      );

      // Send initial message to start conversation with Morgan
      if (memberId != null) {
        await ChatService.sendChatMessage(
          planId: plan.id ?? '',
          message: trimmed,
          householdId: widget.householdId,
          participantNames: const [], // Will be populated when we have participant data
          memberId: memberId,
        );
        
        // Generate a proper title based on the subject and Morgan's response
        try {
          final generatedTitle = await _generatePlanTitle(trimmed);
          if (generatedTitle.isNotEmpty && plan.id != null) {
            await PlansService.updatePlan(plan.id!, title: generatedTitle);
          }
        } catch (e) {
          // If title generation fails, use a cleaned version of the subject
          final cleanedTitle = _cleanSubjectForTitle(trimmed);
          if (plan.id != null) {
            await PlansService.updatePlan(plan.id!, title: cleanedTitle);
          }
        }
      }

      if (!mounted) return;
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PlanThreadScreen(
            planId: plan.id!,
            householdId: widget.householdId,
            participantNames: const [],
          ),
        ),
      );
      
      // Refresh plans if a plan was deleted
      if (result == 'plan_deleted') {
        _loadPlans();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to start: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _creatingFromSubject = false;
          _showLoadingAnimation = false;
          _loadingSubject = null;
        });
      }
    }
  }

  Future<void> _loadCurrentMemberId() async {
    try {
      final supabase = Supabase.instance.client;
      
      // Load household data to get family mode status
      final householdData = await supabase
          .from('households')
          .select('family_mode_enabled')
          .eq('id', widget.householdId)
          .maybeSingle();
      
      final isFamilyModeEnabled = householdData?['family_mode_enabled'] ?? false;
      
      // Load family members
      final membersData = await supabase
          .from('family_members')
          .select()
          .eq('household_id', widget.householdId);
      
      final members = (membersData as List<dynamic>)
          .map((json) => FamilyMember.fromJson(json))
          .toList();
      
      // Get current member ID
      final currentMemberId = await UserContextService.getCurrentMemberId(
        allMembers: members,
        familyModeEnabled: isFamilyModeEnabled,
      );
      
      setState(() {
        _currentMemberId = currentMemberId;
        _familyMembers = members;
        _familyModeEnabled = isFamilyModeEnabled;
      });
    } catch (e) {
      print('Error loading current member ID: $e');
    }
  }

  Future<void> _loadPlans() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load family members and get current member ID
      await _loadCurrentMemberId();
      
      if (_currentMemberId == null) {
        throw Exception('Could not determine current member');
      }

      final activePlans = await PlansService.getPlanSummaries(
        householdId: widget.householdId,
        memberId: _currentMemberId!,
        status: 'active',
      );

      final archivedPlans = await PlansService.getPlanSummaries(
        householdId: widget.householdId,
        memberId: _currentMemberId!,
        status: 'archived',
      );

      setState(() {
        _activePlans = activePlans;
        _archivedPlans = archivedPlans;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _createPlan() async {
    // Show dialog to get plan title
    final title = await _showCreatePlanDialog();
    if (title == null || title.isEmpty) return;

    try {
      final request = CreatePlanRequest(
        householdId: widget.householdId,
        title: title,
      );

      final plan = await PlansService.createPlan(request);

      if (mounted) {
        // Navigate to plan thread
        if (plan.id != null) {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PlanThreadScreen(
                planId: plan.id!,
                householdId: widget.householdId,
                participantNames: [], // TODO: Get actual participant names
              ),
            ),
          );
          
          // Refresh plans if a plan was deleted
          if (result == 'plan_deleted') {
            _loadPlans();
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create plan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String?> _showCreatePlanDialog() async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'New Plan',
          style: GoogleFonts.eczar(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: RedesignTokens.ink,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'e.g., Weekend Museum Trip',
            hintStyle: GoogleFonts.spaceGrotesk(
              color: RedesignTokens.slate,
            ),
            filled: true,
            fillColor: RedesignTokens.canvas,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          style: GoogleFonts.spaceGrotesk(
            fontSize: 15,
            color: RedesignTokens.ink,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.spaceGrotesk(
                color: RedesignTokens.slate,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: RedesignTokens.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Create',
              style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;
    
    return Scaffold(
      backgroundColor: RedesignTokens.canvas,
      body: Stack(
        children: [
          Column(
            children: [
              // Full header with navigation
              CompactHeader(
                onIdeas: () => context.go('/home'),
                onPlanner: () {}, // Already on plans page
                onTime: () => context.go('/moments'),
                onMoments: () => context.go('/moments'),
                onSettings: () => context.go('/settings'),
                onHelp: () {
                  // TODO: Implement help
                },
                onLogout: () {
                  // TODO: Implement logout
                },
                isIdeasActive: false,
                isPlannerActive: true,
                isMomentsActive: false,
                userSwitcher: _familyModeEnabled && _familyMembers.isNotEmpty
                    ? UserSwitcher(
                        members: _familyMembers,
                        currentUser: UserContextService.getCurrentMember(
                          _currentMemberId,
                          _familyMembers,
                        ),
                        onUserSelected: (member) {
                          // TODO: Implement user switching
                        },
                      )
                    : null,
              ),
              // Main content area
              Expanded(
                child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
              ),
            ],
          ),
          // Loading animation overlay
          if (_showLoadingAnimation)
            _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        // Tab bar for mobile
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: RedesignTokens.primary,
            unselectedLabelColor: RedesignTokens.slate,
            indicatorColor: RedesignTokens.primary,
            labelStyle: GoogleFonts.spaceGrotesk(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            tabs: const [
              Tab(text: 'Active'),
              Tab(text: 'Archived'),
            ],
          ),
        ),
        // Content
        Expanded(
          child: _isLoading
              ? const Center(child: SparkleLoading())
              : _error != null
                  ? _buildErrorState()
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildPlansList(_activePlans, isActive: true),
                        _buildPlansList(_archivedPlans, isActive: false),
                      ],
                    ),
        ),
        // Floating action button for mobile
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: FloatingActionButton.extended(
            onPressed: _createPlan,
            backgroundColor: RedesignTokens.accentGold,
            icon: const Icon(Icons.add),
            label: Text(
              'New Plan',
              style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Left sidebar for plans list
        Container(
          width: 280, // 20% less than 350 (350 * 0.8 = 280)
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Header row: Plans title + archive icon toggle
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      'Plans',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: RedesignTokens.ink,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: _tabController.index == 1 ? 'Show active' : 'Show archived',
                      onPressed: () {
                        final next = _tabController.index == 1 ? 0 : 1;
                        _tabController.index = next;
                        setState(() {});
                      },
                      icon: Icon(
                        Icons.archive_outlined,
                        color: _tabController.index == 1
                            ? RedesignTokens.primary
                            : RedesignTokens.slate,
                      ),
                    ),
                  ],
                ),
              ),
              // Plans list
              Expanded(
                child: _isLoading
                    ? const Center(child: SparkleLoading())
                    : _error != null
                        ? _buildErrorState()
                        : (_tabController.index == 0
                            ? _buildPlansList(_activePlans, isActive: true)
                            : _buildPlansList(_archivedPlans, isActive: false)),
              ),
              // New plan button for desktop
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _createPlan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RedesignTokens.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.add),
                    label: Text(
                      'New Plan',
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Right side - chat area (placeholder for now)
        Expanded(
          child: Container(
            color: RedesignTokens.canvas,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Large instruction text
                      Text(
                        'What would you like to plan?',
                        style: GoogleFonts.eczar(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: RedesignTokens.ink,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Describe your idea and Morgan will help you plan it',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          color: RedesignTokens.slate,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      // Text input (without suggestions)
                      _buildPlanInput(),
                      const SizedBox(height: 24),
                      // Suggestion tiles below input
                      _buildSuggestionTiles(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlansList(List<PlanSummary> plans, {required bool isActive}) {
    if (plans.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isActive ? Icons.explore : Icons.archive,
                size: 64,
                color: RedesignTokens.slate.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                isActive ? 'No active plans' : 'No archived plans',
                style: GoogleFonts.eczar(
                  fontSize: 20,
                  color: RedesignTokens.slate,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isActive
                    ? 'Tap the button below to start planning!'
                    : 'Completed plans will appear here',
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  color: RedesignTokens.slate,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPlans,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: plans.length,
        itemBuilder: (context, index) {
          final plan = plans[index];
          return ListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            leading: const Icon(Icons.description_outlined, size: 20, color: RedesignTokens.slate),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.title ?? 'Untitled Plan',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.w600,
                    color: RedesignTokens.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Someday soon', // Default time frame
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    color: RedesignTokens.slate,
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (plan.lastMessageSnippet != null)
                    Text(
                      plan.lastMessageSnippet!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.spaceGrotesk(fontSize: 12, color: RedesignTokens.slate),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    'Participants: You', // Placeholder for now
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      color: RedesignTokens.slate.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            trailing: Text(
              _formatTimeAgo(plan.createdAt),
              style: GoogleFonts.spaceGrotesk(fontSize: 11, color: RedesignTokens.slate),
            ),
            onTap: () async {
              if (plan.id != null) {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PlanThreadScreen(
                      planId: plan.id!,
                      householdId: widget.householdId,
                      participantNames: const [],
                    ),
                  ),
                );
                
                // Refresh plans if a plan was deleted
                if (result == 'plan_deleted') {
                  _loadPlans();
                }
              }
            },
          );
        },
      ),
    );
  }

  /// Generate a proper plan title using AI
  Future<String> _generatePlanTitle(String subject) async {
    try {
      // Use a simple AI prompt to generate a better title
      final prompt = 'Generate a concise, engaging plan title (max 6 words) for: "$subject"';
      
      // For now, we'll use a simple heuristic approach
      // In the future, this could call an AI service
      return _cleanSubjectForTitle(subject);
    } catch (e) {
      return _cleanSubjectForTitle(subject);
    }
  }

  /// Clean and format the subject into a proper title
  String _cleanSubjectForTitle(String subject) {
    // Remove common prefixes and clean up the text
    String cleaned = subject.trim();
    
    // Remove common question words and phrases
    final prefixes = [
      'i want to plan',
      'i want to',
      'let\'s plan',
      'let\'s',
      'plan for',
      'plan a',
      'plan',
      'i need to',
      'i would like to',
      'can we',
      'we should',
    ];
    
    for (final prefix in prefixes) {
      if (cleaned.toLowerCase().startsWith(prefix)) {
        cleaned = cleaned.substring(prefix.length).trim();
        break;
      }
    }
    
    // Capitalize first letter
    if (cleaned.isNotEmpty) {
      cleaned = cleaned[0].toUpperCase() + cleaned.substring(1);
    }
    
    // Remove trailing punctuation and add proper ending
    cleaned = cleaned.replaceAll(RegExp(r'[.!?]+$'), '');
    
    // Limit length
    if (cleaned.length > 50) {
      cleaned = cleaned.substring(0, 47) + '...';
    }
    
    return cleaned.isEmpty ? 'New Plan' : cleaned;
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
              size: 64,
              color: Colors.red.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading plans',
              style: GoogleFonts.eczar(
                fontSize: 20,
                color: RedesignTokens.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                color: RedesignTokens.slate,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPlans,
              style: ElevatedButton.styleFrom(
                backgroundColor: RedesignTokens.primary,
              ),
              child: Text(
                'Retry',
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: RedesignTokens.canvas.withOpacity(0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated input field sliding down
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 800),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 200 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: Container(
                      width: 300,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _loadingSubject ?? 'Creating plan...',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 15,
                                color: RedesignTokens.ink,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: RedesignTokens.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.arrow_upward,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            // Morgan thinking animation
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Morgan badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [RedesignTokens.accentGold, RedesignTokens.sparkle],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Morgan',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _SparkleDots(),
                      const SizedBox(width: 8),
                      Text(
                        'Morgan is imagining...',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          color: RedesignTokens.ink,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onSubmitted: (_) => _createFromSubject(_inputController.text),
        controller: _inputController,
        onChanged: (val) {
          setState(() {
            _hasText = val.trim().isNotEmpty;
          });
        },
        decoration: InputDecoration(
          hintText: 'Type your plan idea...',
          hintStyle: GoogleFonts.spaceGrotesk(
            color: RedesignTokens.slate,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 6),
            child: _hasText
                ? IconButton(
                    onPressed: () => _createFromSubject(_inputController.text),
                    icon: const Icon(Icons.arrow_upward),
                    color: Colors.white,
                    style: IconButton.styleFrom(
                      backgroundColor: RedesignTokens.primary,
                      minimumSize: const Size(40, 40),
                    ),
                  )
                : IconButton(
                    onPressed: () {
                      // Voice input placeholder - to be wired later
                    },
                    icon: const Icon(Icons.mic),
                    color: Colors.white,
                    style: IconButton.styleFrom(
                      backgroundColor: RedesignTokens.primary,
                      minimumSize: const Size(40, 40),
                    ),
                  ),
          ),
        ),
        style: GoogleFonts.spaceGrotesk(
          fontSize: 15,
          color: RedesignTokens.ink,
        ),
      ),
    );
  }

  Widget _buildSuggestionTiles() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _starterIdeas.map((idea) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => _createFromSubject(idea),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: RedesignTokens.accentGold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: RedesignTokens.accentGold.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 16,
                      color: RedesignTokens.accentGold,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      idea,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: RedesignTokens.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SparkleDots extends StatefulWidget {
  @override
  State<_SparkleDots> createState() => _SparkleDotsState();
}

class _SparkleDotsState extends State<_SparkleDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final animation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: _controller,
              curve: Interval(
                delay,
                (delay + 0.3).clamp(0.0, 1.0),
                curve: Curves.easeInOut,
              ),
            ));
            
            return Transform.scale(
              scale: 0.5 + (animation.value * 0.5),
              child: Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: RedesignTokens.accentGold,
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

