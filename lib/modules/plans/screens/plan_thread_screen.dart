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
import '../services/chat_service.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_composer.dart';
import '../widgets/proposal_card.dart';
import '../widgets/constraint_chip.dart';
import '../widgets/decision_sheet.dart';
import '../widgets/itinerary_drawer.dart';
import '../widgets/morgan_badge.dart';
import 'plans_list_screen.dart';
import '../../core/widgets/sparkle_loading.dart';

/// Main plan thread screen with chat, proposals, and actions
class PlanThreadScreen extends StatefulWidget {
  final String planId;
  final String householdId;
  final List<String> participantNames;

  const PlanThreadScreen({
    super.key,
    required this.planId,
    required this.householdId,
    required this.participantNames,
  });

  @override
  State<PlanThreadScreen> createState() => _PlanThreadScreenState();
}

class _PlanThreadScreenState extends State<PlanThreadScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  Plan? _plan;
  List<PlanMessage> _messages = [];
  List<ProposalWithVotes> _proposals = [];
  List<PlanConstraint> _constraints = [];
  PlanItinerary? _itinerary;
  bool _isItineraryExpanded = true; // Open by default
  bool _showItinerary = true; // Inline itinerary visible by default
  final ScrollController _listController = ScrollController();
  bool _isMorganThinking = false;
  String _streamingMorganText = '';
  bool _isEditingTitle = false;
  late TextEditingController _titleController;
  bool _didInitialScroll = false;
  List<Map<String, dynamic>> _planParticipants = [];
  
  // Member data for avatars
  List<FamilyMember> _familyMembers = [];
  Map<String, String> _memberPhotoUrls = {}; // memberId -> photoUrl
  String? _currentMemberId;
  bool _familyModeEnabled = false;
  
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _loadPlanData();
    // Scroll to bottom on first frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _listController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!_listController.hasClients) return;
    final target = _listController.position.maxScrollExtent + 72; // composer height padding
    _listController.animateTo(
      target,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
    // Run again next frame in case content height grows (e.g., long/streamed message)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_listController.hasClients) {
        final nextTarget = _listController.position.maxScrollExtent + 72;
        _listController.jumpTo(nextTarget);
      }
    });
    // And once more shortly after to catch late layouts
    Future.delayed(const Duration(milliseconds: 60), () {
      if (_listController.hasClients) {
        final nextTarget = _listController.position.maxScrollExtent + 72;
        _listController.jumpTo(nextTarget);
      }
    });
  }

  // Optional hook for streaming chunks (call this as chunks arrive)
  void _appendMorganChunk(String chunk) {
    setState(() {
      _isMorganThinking = true;
      _streamingMorganText += chunk;
    });
    _scrollToBottom();
  }

  void _showInviteToPlan() {
    showDialog(
      context: context,
      builder: (context) => _InviteToPlanDialog(
        householdId: widget.householdId,
        planId: widget.planId,
        onMemberInvited: () {
          _loadPlanData(); // Refresh participants
        },
      ),
    );
  }

  Widget _buildParticipantAvatars() {
    print('🎯 _buildParticipantAvatars: ${_planParticipants.length} participants');
    if (_planParticipants.isEmpty) {
      print('🎯 No participants to show');
      return const SizedBox.shrink();
    }
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: _planParticipants.take(5).toList().asMap().entries.map((entry) {
        final index = entry.key;
        final participant = entry.value;
        final memberId = participant['member_id'] as String?;
        print('🎯 Looking for member: $memberId');
        print('🎯 Available family members: ${_familyMembers.map((m) => '${m.id}: ${m.name}').join(', ')}');
        final member = _familyMembers.firstWhere(
          (m) => m.id == memberId,
          orElse: () {
            print('🎯 Member not found, creating fallback');
            return FamilyMember(
              id: memberId, 
              name: 'Unknown',
              age: 0,
              role: MemberRole.parent,
            );
          },
        );
        
        return Transform.translate(
          offset: Offset(-8.0 * index, 0.0), // Slight overlap using Transform
          child: CircleAvatar(
            radius: 16,
            backgroundImage: (member.photoUrl != null && member.photoUrl!.isNotEmpty)
                ? NetworkImage(member.photoUrl!)
                : null,
            backgroundColor: RedesignTokens.primary.withOpacity(0.1),
            child: (member.photoUrl == null || member.photoUrl!.isEmpty)
                ? Text(
                    (member.name ?? '?').substring(0, 1).toUpperCase(),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: RedesignTokens.primary,
                    ),
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }

  Future<void> _loadPlanData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load family members first so they're available when messages are displayed
      await _loadFamilyMembers();
      
      final plan = await PlansService.getPlan(widget.planId);
      final messages = await PlansService.getPlanMessages(planId: widget.planId);
      final proposals = await PlansService.getProposals(planId: widget.planId);
      final constraints = await PlansService.getConstraints(widget.planId);
      final itinerary = await PlansService.getItinerary(widget.planId);
      
      // Load participants (optional - endpoint may not exist yet)
      List<Map<String, dynamic>> participants = [];
      try {
        participants = await PlansService.getPlanParticipants(widget.planId);
        print('👥 Loaded ${participants.length} plan participants:');
        for (final p in participants) {
          print('  - ${p['member_id']}: ${p}');
        }
      } catch (e) {
        print('⚠️ Could not load plan participants: $e');
        // Continue without participant data
      }
      
      // If no participants found, create a default one with the current member
      if (participants.isEmpty && _currentMemberId != null) {
        print('👑 No participants found, creating default with current member');
        participants = [
          {
            'member_id': _currentMemberId,
            'role': 'owner',
            'can_decide': true,
          }
        ];
      }
      
      // Ensure the plan owner is always included in participants
      if (_currentMemberId != null) {
        final ownerInParticipants = participants.any((p) => p['member_id'] == _currentMemberId);
        if (!ownerInParticipants) {
          print('👑 Adding plan owner to participants list');
          participants.insert(0, {
            'member_id': _currentMemberId,
            'role': 'owner',
            'can_decide': true,
          });
        }
      }
      
      print('📨 Loaded ${messages.length} messages from database:');
      for (int i = 0; i < messages.length; i++) {
        final message = messages[i];
        print('  [$i] ${message.authorType}: ${message.authorMemberId} - "${message.bodyMd?.substring(0, message.bodyMd!.length > 50 ? 50 : message.bodyMd!.length)}..."');
        print('      ID: ${message.id}, Plan: ${message.planId}');
      }
      
      // Deduplicate messages by ID
      final uniqueMessages = <String, PlanMessage>{};
      for (final message in messages) {
        if (message.id != null) {
          uniqueMessages[message.id!] = message;
        }
      }
      final deduplicatedMessages = uniqueMessages.values.toList();
      
      print('🔄 Deduplicated from ${messages.length} to ${deduplicatedMessages.length} messages');
      
      // Defensive fix: remove Morgan messages that exactly duplicate the
      // immediately preceding member message body (backend echo edge case)
      final List<PlanMessage> cleaned = [];
      for (final msg in deduplicatedMessages) {
        if (cleaned.isNotEmpty) {
          final prev = cleaned.last;
          final isEcho = (msg.authorType == 'morgan') &&
              (prev.authorType == 'member') &&
              ((msg.bodyMd ?? '').trim() == (prev.bodyMd ?? '').trim());
          if (isEcho) {
            print('🧹 Removed echoed Morgan message: "${msg.bodyMd}"');
            continue;
          }
        }
        cleaned.add(msg);
      }
      
      // Note: getItinerary method doesn't exist, will need to be implemented

      setState(() {
        _plan = plan;
        _messages = cleaned;
        _proposals = proposals;
        _constraints = constraints;
        _itinerary = itinerary;
        _planParticipants = participants;
        _isLoading = false;
      });
      
      print('🎯 Final participants count: ${_planParticipants.length}');
      for (final p in _planParticipants) {
        print('  - ${p['member_id']}: ${p}');
      }

      // Ensure we scroll to the bottom after data loads
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadFamilyMembers() async {
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
      
      // Create map of member ID to photo URL
      final photoUrls = <String, String>{};
      for (final member in members) {
        if (member.id != null && member.photoUrl != null) {
          photoUrls[member.id!] = member.photoUrl!;
        }
      }
      
      print('👥 Loaded ${members.length} family members:');
      for (final member in members) {
        print('  - ${member.id}: ${member.name} (photo: ${member.photoUrl != null ? 'yes' : 'no'})');
      }
      print('🎯 Current member ID: $currentMemberId');
      print('🏠 Family mode enabled: $isFamilyModeEnabled');
      
      setState(() {
        _familyMembers = members;
        _memberPhotoUrls = photoUrls;
        _currentMemberId = currentMemberId;
        _familyModeEnabled = isFamilyModeEnabled;
      });
    } catch (e) {
      print('Error loading family members: $e');
    }
  }

  void _sendMessage(String content) async {
    try {
      // Add user message immediately to UI
      final userMessage = PlanMessage(
        id: 'user-${DateTime.now().millisecondsSinceEpoch}',
        planId: widget.planId,
        authorType: 'member',
        authorMemberId: _currentMemberId,
        bodyMd: content,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      print('📤 Sending message with member ID: $_currentMemberId');
      final idempotencyKey = userMessage.id;
      
      setState(() {
        _messages.add(userMessage);
        _isMorganThinking = true;
      });
      _scrollToBottom();
      
      // Get Morgan response
      final morganResponse = await ChatService.sendChatMessage(
        planId: widget.planId,
        message: content,
        householdId: widget.householdId,
        participantNames: widget.participantNames,
        memberId: _currentMemberId,
        idempotencyKey: idempotencyKey,
      );
      
      // Add Morgan response to UI
      setState(() {
        _messages.add(morganResponse);
        _isMorganThinking = false;
      });
      _scrollToBottom();
      
      // Do not save locally; backend already persists via chat endpoint
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    }
  }

  void _saveMessagesToDatabase(PlanMessage userMessage, PlanMessage morganResponse) async {}

  Future<Map<String, dynamic>> _gatherChatContext() async {
    try {
      // Get family members
      final familyMembers = <String>[];
      // TODO: Fetch from family service
      
      // Get active pods
      final activePods = <String>[];
      // TODO: Fetch from pod service
      
      // Get member interests
      final memberInterests = <String>[];
      // TODO: Fetch from member profiles
      
      // Get learning data (recent activity patterns, preferences, etc.)
      final learningData = <String, dynamic>{
        'recent_activities': [],
        'preferred_times': [],
        'weather_preferences': [],
        'activity_success_rates': {},
      };
      // TODO: Fetch from learning/analytics service
      
      return {
        'familyMembers': familyMembers,
        'activePods': activePods,
        'memberInterests': memberInterests,
        'learningData': learningData,
      };
    } catch (e) {
      print('Failed to gather context: $e');
      return {
        'familyMembers': <String>[],
        'activePods': <String>[],
        'memberInterests': <String>[],
        'learningData': <String, dynamic>{},
      };
    }
  }


  void _voteOnProposal(String proposalId, String vote) async {
    try {
      await PlansService.voteOnProposal(
        proposalId: proposalId,
        request: VoteRequest(value: int.parse(vote)),
      );
      _loadPlanData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to vote: $e')),
      );
    }
  }


  void _showDecisionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DecisionSheet(
        proposals: _proposals,
        onDecide: (proposalId, decision) async {
          // TODO: Implement decision logic
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showDeleteConfirmation() {
    // Check if current member is the plan owner
    final isOwner = _planParticipants.any((p) => 
      p['member_id'] == _currentMemberId && p['role'] == 'owner');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          isOwner ? 'Delete Plan' : 'Leave Plan',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: RedesignTokens.ink,
          ),
        ),
        content: Text(
          isOwner 
            ? 'Are you sure you want to delete this plan? This action cannot be undone.'
            : 'Are you sure you want to leave this plan? You can rejoin later if invited.',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            color: RedesignTokens.slate,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: RedesignTokens.slate,
            ),
            child: Text(
              'Cancel',
              style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                if (isOwner) {
                  await PlansService.deletePlan(widget.planId);
                } else {
                  // TODO: Implement leave plan functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Leave plan functionality coming soon')),
                  );
                  Navigator.of(context).pop();
                  return;
                }
                Navigator.of(context).pop();
                Navigator.of(context).pop('plan_deleted');
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to ${isOwner ? 'delete' : 'leave'} plan: $e')),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: isOwner ? Colors.red : RedesignTokens.slate,
            ),
            child: Text(
              isOwner ? 'Delete' : 'Leave',
              style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.w500,
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
      key: _scaffoldKey,
      backgroundColor: RedesignTokens.canvas,
      endDrawer: ItineraryDrawer(
        itinerary: _itinerary,
        onEdit: () {},
      ),
      body: Column(
        children: [
          // Full header with navigation
          CompactHeader(
            onIdeas: () => context.go('/home'),
            onPlanner: () => context.go('/plans', extra: {
              'householdId': widget.householdId,
            }),
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
          ),
          // Plan title bar
          Stack(
            children: [
              Container(
                color: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
        // Sidebar icon for plans navigation
        IconButton(
          icon: const Icon(Icons.dashboard, color: RedesignTokens.ink),
          tooltip: 'Plans List',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PlansListScreen(
                  householdId: widget.householdId,
                ),
              ),
            );
          },
        ),
                if (isMobile) ...[
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: RedesignTokens.ink),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: _plan != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _isEditingTitle
                                      ? TextField(
                                          controller: _titleController,
                                          autofocus: true,
                                          style: GoogleFonts.eczar(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                            color: RedesignTokens.ink,
                                          ),
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: BorderSide(color: RedesignTokens.primary),
                                            ),
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          ),
                                          onSubmitted: (value) => _saveTitle(),
                                          onTapOutside: (_) => _saveTitle(),
                                        )
                                      : GestureDetector(
                                          onTap: () => _startEditingTitle(),
                                          child: Text(
                                            _plan?.title ?? 'Untitled Plan',
                                            style: GoogleFonts.eczar(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                              color: RedesignTokens.ink,
                                            ),
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 12),
                                // Participant avatars
                                _buildParticipantAvatars(),
                              ],
                            ),
                            if (_plan?.status == 'archived')
                              Text(
                                'Archived',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 12,
                                  color: RedesignTokens.slate,
                                ),
                              ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
                // Action buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Center invite to plan button in title area
                    TextButton.icon(
                      onPressed: _showInviteToPlan,
                      icon: const Icon(Icons.person_add_alt_1, color: RedesignTokens.ink),
                      label: Text(
                        'Invite to Plan',
                        style: GoogleFonts.spaceGrotesk(
                          color: RedesignTokens.ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    // Itinerary button opens overlay drawer (original behavior)
                    IconButton(
                      icon: const Icon(Icons.list_alt, color: RedesignTokens.ink),
                      tooltip: 'Itinerary',
                      onPressed: () {
                        _scaffoldKey.currentState?.openEndDrawer();
                      },
                    ),
                    // More menu
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'archive':
                            PlansService.archivePlan(widget.planId).then((_) {
                              _loadPlanData();
                            });
                            break;
                          case 'reopen':
                            PlansService.reopenPlan(widget.planId).then((_) {
                              _loadPlanData();
                            });
                            break;
                          case 'delete':
                            _showDeleteConfirmation();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        if (_plan?.status == 'active')
                          const PopupMenuItem(
                            value: 'archive',
                            child: Text('Archive Plan'),
                          )
                        else
                          const PopupMenuItem(
                            value: 'reopen',
                            child: Text('Reopen Plan'),
                          ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete Plan'),
                        ),
                      ],
                    ),
                    // Decision button (if proposals exist)
                    if (_proposals.isNotEmpty && _plan?.status == 'active')
                      IconButton(
                        icon: Icon(
                          Icons.check_circle,
                          color: RedesignTokens.accentGold,
                        ),
                        onPressed: _showDecisionSheet,
                        tooltip: 'Make Decision',
                      ),
                  ],
                ),
                  ],
                ),
              ),
            ],
          ),
          // Main content area
          Expanded(
            child: _buildMainContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    if (_isLoading) {
      return const Center(child: SparkleLoading());
    }
    
    if (_error != null) {
      return _buildErrorState();
    }
    
    return Column(
      children: [
        // (Inline itinerary removed; overlay drawer will be used)
        
        // Constraints section
        if (_constraints.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _constraints.map((c) {
                return ConstraintChip(constraint: c);
              }).toList(),
            ),
          ),

        // Proposals section
        if (_proposals.isNotEmpty)
          Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.3,
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _proposals.length,
              itemBuilder: (context, index) {
                return ProposalCard(
                  proposalWithVotes: _proposals[index],
                  onVote: (value) {
                    _voteOnProposal(_proposals[index].proposal.id.toString(), value.toString());
                  },
                );
              },
            ),
          ),

        // Chat section
        Expanded(
          child: Stack(
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    children: [
                      // Messages
                      Expanded(
                        child: _messages.isEmpty
                            ? const Center(child: Text('No messages yet'))
                            : ListView.builder(
                                controller: _listController,
                                padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + 72),
                                itemCount: _messages.length + ((_isMorganThinking || _streamingMorganText.isNotEmpty) ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if ((_isMorganThinking || _streamingMorganText.isNotEmpty) && index == _messages.length) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(top: 20),
                                            child: Container(
                                              width: 43,
                                              height: 43,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(12),
                                                gradient: const LinearGradient(colors: [
                                                  RedesignTokens.accentGold,
                                                  RedesignTokens.sparkle,
                                                ]),
                                              ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(12),
                                                child: Image.asset('assets/img/morgan-avatar.png', fit: BoxFit.cover),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                // Morgan badge above the bubble
                                                const Padding(
                                                  padding: EdgeInsets.only(bottom: 6),
                                                  child: MorganBadge(size: 16),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: _streamingMorganText.isEmpty
                                                      ? Row(
                                                          children: [
                                                            // Sparkle animation (simple pulsing dots)
                                                            _SparkleDots(),
                                                            const SizedBox(width: 8),
                                                            const Text('Morgan is imagining...'),
                                                          ],
                                                        )
                                                      : Text(_streamingMorganText),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  final message = _messages[index];
                                  // Get member name and photo URL
                                  String? memberName;
                                  String? memberPhotoUrl;
                                  print('🔍 Message ${index}: authorType=${message.authorType}, authorMemberId=${message.authorMemberId}');
                                  
                                  if (message.authorType == 'member' && message.authorMemberId != null) {
                                    print('🔍 Looking up member: ${message.authorMemberId}');
                                    print('🔍 Available members: ${_familyMembers.map((m) => '${m.id}: ${m.name}').join(', ')}');
                                    
                                    final member = _familyMembers.firstWhere(
                                      (m) => m.id == message.authorMemberId,
                                      orElse: () {
                                        print('❌ Member not found: ${message.authorMemberId}');
                                        return FamilyMember(
                                          name: 'You',
                                          age: 0,
                                          role: MemberRole.parent,
                                        );
                                      },
                                    );
                                    memberName = member.name;
                                    memberPhotoUrl = _memberPhotoUrls[message.authorMemberId!];
                                    print('✅ Found member: $memberName, photo: $memberPhotoUrl');
                                  } else if (message.authorType == 'member') {
                                    print('⚠️ Member message but no authorMemberId');
                                    memberName = 'You';
                                  }

                                  return MessageBubble(
                                    message: message,
                                    memberName: memberName,
                                    memberPhotoUrl: memberPhotoUrl,
                                  );
                                },
                              ),
                      ),
                      // Chat composer
                      if (_plan?.status == 'active')
                        ChatComposer(
                          onSend: _sendMessage,
                        ),
                    ],
                  ),
                ),
              ),
              // Floating new plan button - positioned at screen edge, not constrained by chat width
              Positioned(
                bottom: 20,
                left: 20,
                child: FloatingActionButton(
                  onPressed: _createNewPlan,
                  backgroundColor: RedesignTokens.primary,
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _createNewPlan() async {
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
        // Navigate to the new plan
        if (plan.id != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => PlanThreadScreen(
                planId: plan.id!,
                householdId: widget.householdId,
                participantNames: [],
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create plan: $e')),
        );
      }
    }
  }

  Future<String?> _showCreatePlanDialog() async {
    final controller = TextEditingController();
    final List<String> suggestions = [
      'Weekend Museum Trip',
      'Family Game Night',
      'Beach Day Adventure',
      'Movie Night at Home',
      'Hiking Trail Exploration',
      'Cooking Class Together',
    ];

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'New Plan',
          style: GoogleFonts.eczar(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: RedesignTokens.ink,
          ),
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom input with create button
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'What would you like to plan?',
                        hintStyle: GoogleFonts.spaceGrotesk(
                          color: RedesignTokens.slate.withOpacity(0.6),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: RedesignTokens.slate.withOpacity(0.3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: RedesignTokens.slate.withOpacity(0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: RedesignTokens.primary, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        color: RedesignTokens.ink,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(controller.text.trim()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RedesignTokens.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Create',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Plan suggestions - secondary
              Text(
                'Or choose from suggestions:',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  color: RedesignTokens.slate,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: suggestions.map((suggestion) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop(suggestion);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: RedesignTokens.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: RedesignTokens.primary.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        suggestion,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          color: RedesignTokens.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startEditingTitle() {
    setState(() {
      _isEditingTitle = true;
      _titleController.text = _plan?.title ?? 'Untitled Plan';
    });
  }

  Future<void> _saveTitle() async {
    if (_titleController.text.trim().isEmpty) {
      setState(() {
        _isEditingTitle = false;
      });
      return;
    }

    final newTitle = _titleController.text.trim();
    if (newTitle == _plan?.title) {
      // No change, just exit edit mode
      setState(() {
        _isEditingTitle = false;
      });
      return;
    }

    try {
      // Update the plan title via API
      final updatedPlan = await PlansService.updatePlan(
        widget.planId,
        title: newTitle,
      );
      
      setState(() {
        _isEditingTitle = false;
        _plan = updatedPlan;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plan title updated successfully')),
      );
    } catch (e) {
      // Revert the text field to the original title
      _titleController.text = _plan?.title ?? 'Untitled Plan';
      setState(() {
        _isEditingTitle = false;
      });
      
      // Show user-friendly error message
      String errorMessage = 'Failed to update title';
      if (e.toString().contains('500')) {
        errorMessage = 'Server error - please try again later';
      } else if (e.toString().contains('404')) {
        errorMessage = 'Plan not found';
      } else if (e.toString().contains('403')) {
        errorMessage = 'You don\'t have permission to edit this plan';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
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
              color: RedesignTokens.slate,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: RedesignTokens.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                color: RedesignTokens.slate,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPlanData,
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
      builder: (_, __) {
        final t = _controller.value;
        final op1 = (0.3 + (t)).clamp(0.3, 1.0);
        final op2 = (0.3 + ((t + 0.33) % 1.0)).clamp(0.3, 1.0);
        final op3 = (0.3 + ((t + 0.66) % 1.0)).clamp(0.3, 1.0);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Opacity(opacity: op1, child: const Icon(Icons.auto_awesome, size: 14, color: RedesignTokens.accentGold)),
            const SizedBox(width: 2),
            Opacity(opacity: op2, child: const Icon(Icons.auto_awesome, size: 14, color: RedesignTokens.accentGold)),
            const SizedBox(width: 2),
            Opacity(opacity: op3, child: const Icon(Icons.auto_awesome, size: 14, color: RedesignTokens.accentGold)),
          ],
        );
      },
    );
  }
}

class _InviteToPlanDialog extends StatefulWidget {
  final String householdId;
  final String planId;
  final VoidCallback? onMemberInvited;

  const _InviteToPlanDialog({
    required this.householdId,
    required this.planId,
    this.onMemberInvited,
  });

  @override
  State<_InviteToPlanDialog> createState() => _InviteToPlanDialogState();
}

class _InviteToPlanDialogState extends State<_InviteToPlanDialog> {
  int _tabIndex = 0; // 0 = My household, 1 = Other household
  List<FamilyMember> _members = [];
  final Set<String> _selectedMemberIds = {};
  Set<String> _invitedMemberIds = {}; // Track who's already invited
  bool _loading = true;
  String? _error;
  String? _currentMemberId;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentMember() async {
    try {
      _currentMemberId = await UserContextService.getCurrentMemberId(
        allMembers: _members,
        familyModeEnabled: true,
      );
    } catch (e) {
      print('Failed to get current member: $e');
    }
  }

  Future<void> _loadMembers() async {
    try {
      final supabase = Supabase.instance.client;
      final membersData = await supabase
          .from('family_members')
          .select()
          .eq('household_id', widget.householdId);
      final members = (membersData as List<dynamic>)
          .map((json) => FamilyMember.fromJson(json))
          .toList();
      
      // Load current member after we have family members
      await _loadCurrentMember();
      
      // Load plan participants to mark who's already invited (optional)
      Set<String> invitedIds = {};
      try {
        final planParticipants = await PlansService.getPlanParticipants(widget.planId);
        invitedIds = planParticipants.map((p) => p['member_id'] as String?).where((id) => id != null).cast<String>().toSet();
      } catch (e) {
        print('⚠️ Could not load plan participants: $e');
        // Continue without participant data
      }
      
      setState(() {
        _members = members;
        // Owner is always selected and can't be deselected
        if (_currentMemberId != null) {
          _selectedMemberIds.add(_currentMemberId!);
        }
        _loading = false;
      });
      
      // Update invited member IDs after state is set
      setState(() {
        _invitedMemberIds = invitedIds;
        print('🎯 Invite dialog - loaded ${invitedIds.length} invited members: $invitedIds');
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load members: $e';
        _loading = false;
      });
    }
  }

  Future<void> _inviteSelected() async {
    if (_selectedMemberIds.isEmpty) return;
    try {
      for (final id in _selectedMemberIds) {
        await PlansService.inviteMemberToPlan(planId: widget.planId, memberId: id);
      }
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Member added to plan')),
        );
        widget.onMemberInvited?.call(); // Refresh participants
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _externalInvite() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;
    try {
      final ok = await PlansService.externalInviteToPlan(planId: widget.planId, email: email);
      if (ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invite sent')));
        _emailController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _generateCode() async {
    try {
      final code = await PlansService.getShareCode(widget.planId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Share code: $code')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _joinByCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;
    try {
      final ok = await PlansService.joinByCode(code);
      if (ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Joined plan')));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      insetPadding: const EdgeInsets.all(16),
      child: SizedBox(
        width: 600,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header tabs
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('My household'),
                    selected: _tabIndex == 0,
                    onSelected: (_) => setState(() => _tabIndex = 0),
                    selectedColor: RedesignTokens.primary,
                    backgroundColor: Colors.transparent,
                    labelStyle: GoogleFonts.spaceGrotesk(
                      color: _tabIndex == 0 ? Colors.white : RedesignTokens.slate,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Other household'),
                    selected: _tabIndex == 1,
                    onSelected: (_) => setState(() => _tabIndex = 1),
                    selectedColor: RedesignTokens.primary,
                    backgroundColor: Colors.transparent,
                    labelStyle: GoogleFonts.spaceGrotesk(
                      color: _tabIndex == 1 ? Colors.white : RedesignTokens.slate,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            if (_tabIndex == 1)
              _buildExternalTab()
            else
              _buildHouseholdTab(),

            // Footer
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _selectedMemberIds.isEmpty ? null : _inviteSelected,
                    icon: const Icon(Icons.person_add_alt_1),
                    label: const Text('Invite'),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHouseholdTab() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: CircularProgressIndicator(),
      );
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(_error!),
      );
    }
    return SizedBox(
      height: 360,
      child: Row(
        children: [
          // Members list
          Expanded(
            child: ListView.builder(
              itemCount: _members.length,
              itemBuilder: (context, index) {
                final m = _members[index];
                final isOwner = m.id == _currentMemberId;
                final isInvited = _invitedMemberIds.contains(m.id);
                final selected = _selectedMemberIds.contains(m.id);
                
                print('🎯 Member ${m.name}: isOwner=$isOwner, isInvited=$isInvited, selected=$selected');
                
                return CheckboxListTile(
                  value: selected,
                  onChanged: isOwner ? null : (v) { // Owner can't be deselected
                    setState(() {
                      if (v == true) {
                        if (m.id != null) _selectedMemberIds.add(m.id!);
                      } else {
                        if (m.id != null) _selectedMemberIds.remove(m.id!);
                      }
                    });
                  },
                  secondary: CircleAvatar(
                    backgroundImage: (m.photoUrl != null && m.photoUrl!.isNotEmpty)
                        ? NetworkImage(m.photoUrl!)
                        : null,
                    child: (m.photoUrl == null || m.photoUrl!.isEmpty)
                        ? Text((m.name ?? '?').substring(0, 1).toUpperCase())
                        : null,
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(m.name ?? 'Member'),
                          if (isOwner) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: RedesignTokens.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Owner',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                          if (isInvited) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: RedesignTokens.accentGold,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Invited',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      // Debug info
                      if (isOwner || isInvited)
                        Text(
                          'DEBUG: isOwner=$isOwner, isInvited=$isInvited',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 8,
                            color: Colors.red,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Pods placeholder for quick group adding (uses existing data later)
          const VerticalDivider(width: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Pods (coming soon)'),
                  SizedBox(height: 8),
                  Text('Select a pod to quickly add that group to the plan.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExternalTab() {
    return SizedBox(
      height: 360,
      child: Row(
        children: [
          // Email invite section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Invite by email',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: RedesignTokens.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'name@email.com',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _externalInvite,
                    icon: const Icon(Icons.send, size: 18),
                    label: const Text('Send invite'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RedesignTokens.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          // Code section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Share code (owner)',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: RedesignTokens.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _generateCode,
                    icon: const Icon(Icons.qr_code, size: 18),
                    label: const Text('Generate code'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RedesignTokens.accentGold,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Join by code (recipient)',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: RedesignTokens.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _codeController,
                    decoration: InputDecoration(
                      hintText: 'Enter code',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _joinByCode,
                    icon: const Icon(Icons.login, size: 18),
                    label: const Text('Join'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RedesignTokens.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}