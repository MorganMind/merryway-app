import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/redesign_tokens.dart';
import '../../auth/services/user_context_service.dart';
import '../models/plan_models.dart';
import '../services/plans_service.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_composer.dart';
import '../widgets/proposal_card.dart';
import '../widgets/constraint_chip.dart';
import '../widgets/decision_sheet.dart';
import '../widgets/itinerary_drawer.dart';

/// Main plan thread screen with chat, proposals, and actions
class PlanThreadScreen extends StatefulWidget {
  final String planId;

  const PlanThreadScreen({
    super.key,
    required this.planId,
  });

  @override
  State<PlanThreadScreen> createState() => _PlanThreadScreenState();
}

class _PlanThreadScreenState extends State<PlanThreadScreen> {
  Plan? _plan;
  List<PlanMessage> _messages = [];
  List<ProposalWithVotes> _proposals = [];
  List<PlanConstraint> _constraints = [];
  PlanItinerary? _itinerary;
  bool _isLoading = false;
  String? _error;
  String? _currentMemberId;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadCurrentMember();
    _loadPlanData();
  }

  Future<void> _loadCurrentMember() async {
    final memberId = await UserContextService.getSelectedMemberId();
    setState(() {
      _currentMemberId = memberId;
    });
  }

  Future<void> _loadPlanData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final plan = await PlansService.getPlan(widget.planId);
      final messages = await PlansService.getPlanMessages(planId: widget.planId);
      final proposals = await PlansService.getProposals(
        planId: widget.planId,
        voterMemberId: _currentMemberId,
      );
      final constraints = await PlansService.getConstraints(widget.planId);

      setState(() {
        _plan = plan;
        _messages = messages;
        _proposals = proposals;
        _constraints = constraints;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage(String text) async {
    try {
      final request = SendMessageRequest(
        planId: widget.planId,
        authorMemberId: _currentMemberId,
        bodyMd: text,
      );

      await PlansService.sendMessage(planId: widget.planId, request: request);
      _loadPlanData();
    } catch (e) {
      _showError('Failed to send message: $e');
    }
  }

  Future<void> _triggerMorganAction(String action) async {
    try {
      final request = MorganActionRequest(
        planId: widget.planId,
        action: action,
      );

      await PlansService.triggerMorganAction(request: request);
      _loadPlanData();
    } catch (e) {
      _showError('Failed to trigger Morgan: $e');
    }
  }

  Future<void> _voteOnProposal(String proposalId, int value) async {
    try {
      final request = VoteRequest(value: value);
      await PlansService.voteOnProposal(proposalId: proposalId, request: request);
      _loadPlanData();
    } catch (e) {
      _showError('Failed to vote: $e');
    }
  }

  Future<void> _makeDecision(String? proposalId, String summary) async {
    if (_currentMemberId == null) return;

    try {
      await PlansService.createDecision(
        planId: widget.planId,
        proposalId: proposalId,
        summaryMd: summary,
        decidedByMemberId: _currentMemberId!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Decision finalized!'),
            backgroundColor: RedesignTokens.accentGold,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showError('Failed to make decision: $e');
    }
  }

  void _showDecisionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DecisionSheet(
        proposals: _proposals,
        onDecide: _makeDecision,
      ),
    );
  }

  void _showItineraryDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: RedesignTokens.canvas,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: _plan != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _plan!.title,
                    style: GoogleFonts.eczar(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: RedesignTokens.ink,
                    ),
                  ),
                  if (_plan!.status == 'archived')
                    Text(
                      'Archived',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        color: RedesignTokens.slate,
                      ),
                    ),
                ],
              )
            : null,
        actions: [
          // Itinerary button
          IconButton(
            icon: const Icon(Icons.list_alt),
            onPressed: _showItineraryDrawer,
            tooltip: 'View Itinerary',
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
              }
            },
            itemBuilder: (context) => [
              if (_plan?.status == 'active')
                PopupMenuItem(
                  value: 'archive',
                  child: Text('Archive Plan'),
                )
              else
                PopupMenuItem(
                  value: 'reopen',
                  child: Text('Reopen Plan'),
                ),
            ],
          ),
        ],
      ),
      endDrawer: ItineraryDrawer(
        itinerary: _itinerary,
        onEdit: () {
          // TODO: Implement itinerary editor
          Navigator.of(context).pop();
        },
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : Column(
                  children: [
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
                                _voteOnProposal(_proposals[index].proposal.id, value);
                              },
                            );
                          },
                        ),
                      ),

                    // Messages section
                    Expanded(
                      child: _messages.isEmpty
                          ? _buildEmptyMessagesState()
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              itemCount: _messages.length,
                              itemBuilder: (context, index) {
                                final message = _messages[index];
                                return MessageBubble(
                                  message: message,
                                  // TODO: Fetch member name/photo from cache
                                );
                              },
                            ),
                    ),

                    // Chat composer
                    if (_plan?.status == 'active')
                      ChatComposer(
                        onSend: _sendMessage,
                        quickActions: const [
                          'Summarize',
                          'Suggest ideas',
                          'Check feasibility',
                        ],
                        onQuickAction: _triggerMorganAction,
                      ),
                  ],
                ),
    );
  }

  Widget _buildEmptyMessagesState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: RedesignTokens.slate.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Start the conversation!',
              style: GoogleFonts.eczar(
                fontSize: 20,
                color: RedesignTokens.slate,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Share ideas, ask Morgan for help,\nor start planning together',
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
              'Error loading plan',
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

