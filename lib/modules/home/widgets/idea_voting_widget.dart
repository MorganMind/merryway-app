import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../family/models/family_models.dart';
import '../../family/models/idea_vote_model.dart';
import '../../core/theme/merryway_theme.dart';

/// Compact voting pill that shows just vote icons
/// Taps open a modal with full voting grid
class IdeaVotingWidget extends StatefulWidget {
  final String activityName;
  final String householdId;
  final List<FamilyMember> allMembers;
  final String? currentMemberId;  // Who is voting?
  final String category;
  final VoidCallback? onVoteChanged;

  const IdeaVotingWidget({
    super.key,
    required this.activityName,
    required this.householdId,
    required this.allMembers,
    this.currentMemberId,
    this.category = 'today',
    this.onVoteChanged,
  });

  @override
  State<IdeaVotingWidget> createState() => _IdeaVotingWidgetState();
}

class _IdeaVotingWidgetState extends State<IdeaVotingWidget> {
  Map<String, VoteType> memberVotes = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVotes();
  }

  Future<void> _loadVotes() async {
    setState(() => _isLoading = true);
    
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('idea_votes')
          .select()
          .eq('household_id', widget.householdId)
          .eq('activity_name', widget.activityName)
          .eq('category', widget.category);

      final votes = (response as List).map((json) => IdeaVote.fromJson(json)).toList();
      
      setState(() {
        memberVotes = {
          for (var vote in votes) vote.memberId: vote.voteType
        };
      });
    } catch (e) {
      print('Error loading votes: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _castVote(String memberId, VoteType voteType) async {
    try {
      final supabase = Supabase.instance.client;
      
      // Upsert vote (insert or update if exists)
      // Specify onConflict to use the unique constraint columns
      await supabase.from('idea_votes').upsert(
        {
          'household_id': widget.householdId,
          'member_id': memberId,
          'activity_name': widget.activityName,
          'category': widget.category,
          'vote_type': voteType.toDbString(),
        },
        onConflict: 'household_id,member_id,activity_name,category',
      );

      setState(() {
        memberVotes[memberId] = voteType;
      });

      widget.onVoteChanged?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error casting vote: $e')),
        );
      }
    }
  }

  VoteAggregation _aggregateVotes() {
    int loveCount = 0;
    int neutralCount = 0;
    int notInterestedCount = 0;
    List<String> loveVoters = [];
    List<String> neutralVoters = [];
    List<String> notInterestedVoters = [];

    for (var member in widget.allMembers) {
      final vote = memberVotes[member.id];
      if (vote == VoteType.love) {
        loveCount++;
        loveVoters.add(member.id!);
      } else if (vote == VoteType.neutral) {
        neutralCount++;
        neutralVoters.add(member.id!);
      } else if (vote == VoteType.notInterested) {
        notInterestedCount++;
        notInterestedVoters.add(member.id!);
      }
    }

    return VoteAggregation(
      loveCount: loveCount,
      neutralCount: neutralCount,
      notInterestedCount: notInterestedCount,
      totalVotes: loveCount + neutralCount + notInterestedCount,
      totalMembers: widget.allMembers.length,
      loveVoters: loveVoters,
      neutralVoters: neutralVoters,
      notInterestedVoters: notInterestedVoters,
    );
  }

  String _getMemberName(String memberId) {
    final member = widget.allMembers.firstWhere(
      (m) => m.id == memberId,
      orElse: () => const FamilyMember(name: 'Unknown', age: 0, role: MemberRole.child),
    );
    return member.name;
  }

  void _showVotingModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return _buildFullVotingModal(context, setModalState);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox.shrink();
    }

    final aggregation = _aggregateVotes();
    
    // Use passed currentMemberId, or fallback to first member
    final currentMemberId = widget.currentMemberId ?? 
        (widget.allMembers.isNotEmpty ? widget.allMembers.first.id : null);

    // Compact pill UI - icons clickable, arrow opens modal
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF4A4A4A).withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Love icon - clickable
          GestureDetector(
            onTap: () {
              if (currentMemberId != null) {
                _castVote(currentMemberId, VoteType.love);
              }
            },
            child: _buildCompactVoteIcon(Icons.favorite, Colors.red.shade300, aggregation.loveCount),
          ),
          const SizedBox(width: 12),
          
          // Neutral icon - clickable
          GestureDetector(
            onTap: () {
              if (currentMemberId != null) {
                _castVote(currentMemberId, VoteType.neutral);
              }
            },
            child: _buildCompactVoteIcon(Icons.horizontal_rule, Colors.grey.shade300, aggregation.neutralCount),
          ),
          const SizedBox(width: 12),
          
          // Not Interested icon - clickable
          GestureDetector(
            onTap: () {
              if (currentMemberId != null) {
                _castVote(currentMemberId, VoteType.notInterested);
              }
            },
            child: _buildCompactVoteIcon(Icons.close, Colors.orange.shade300, aggregation.notInterestedCount),
          ),
          const SizedBox(width: 8),
          
          // Up arrow - opens modal
          GestureDetector(
            onTap: () => _showVotingModal(context),
            child: const Icon(Icons.keyboard_arrow_up, color: Colors.white70, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactVoteIcon(IconData icon, Color color, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18),
        if (count > 0) ...[
          const SizedBox(width: 4),
          Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFullVotingModal(BuildContext context, StateSetter setModalState) {
    final aggregation = _aggregateVotes();

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF2D2D2D),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'What does everyone think?',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          
          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vote buttons for each member
                  ...widget.allMembers.map((member) {
                    final memberVote = memberVotes[member.id];
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member.name,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _buildVoteButton(
                                icon: Icons.favorite,
                                label: 'Love',
                                isSelected: memberVote == VoteType.love,
                                color: Colors.red.shade300,
                                onTap: () async {
                                  await _castVote(member.id!, VoteType.love);
                                  setModalState(() {}); // Update modal UI
                                },
                              ),
                              const SizedBox(width: 8),
                              _buildVoteButton(
                                icon: Icons.horizontal_rule,
                                label: 'Neutral',
                                isSelected: memberVote == VoteType.neutral,
                                color: Colors.grey.shade300,
                                onTap: () async {
                                  await _castVote(member.id!, VoteType.neutral);
                                  setModalState(() {}); // Update modal UI
                                },
                              ),
                              const SizedBox(width: 8),
                              _buildVoteButton(
                                icon: Icons.close,
                                label: 'Not Interested',
                                isSelected: memberVote == VoteType.notInterested,
                                color: Colors.orange.shade300,
                                onTap: () async {
                                  await _castVote(member.id!, VoteType.notInterested);
                                  setModalState(() {}); // Update modal UI
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),

                  // Special badges
                  if (aggregation.isJustForOne && aggregation.soloLover != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.pink.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.pink.shade200, width: 2),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.favorite, color: Colors.pink, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Just for ${_getMemberName(aggregation.soloLover!)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Prompt for neutral voter
                  if (aggregation.shouldPromptNeutral && aggregation.neutralVoterToPrompt != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.shade300, width: 2),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.help_outline, color: Colors.amber, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${_getMemberName(aggregation.neutralVoterToPrompt!)}, would you love this or pass?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Vote summary
                  if (aggregation.totalVotes > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (aggregation.loveCount > 0) ...[
                          Icon(Icons.favorite, size: 14, color: Colors.red.shade300),
                          const SizedBox(width: 4),
                          Text(
                            '${aggregation.loveCount}',
                            style: const TextStyle(fontSize: 12, color: Colors.white70),
                          ),
                          const SizedBox(width: 12),
                        ],
                        if (aggregation.neutralCount > 0) ...[
                          Icon(Icons.horizontal_rule, size: 14, color: Colors.grey.shade300),
                          const SizedBox(width: 4),
                          Text(
                            '${aggregation.neutralCount}',
                            style: const TextStyle(fontSize: 12, color: Colors.white70),
                          ),
                          const SizedBox(width: 12),
                        ],
                        if (aggregation.notInterestedCount > 0) ...[
                          Icon(Icons.close, size: 14, color: Colors.orange.shade300),
                          const SizedBox(width: 4),
                          Text(
                            '${aggregation.notInterestedCount}',
                            style: const TextStyle(fontSize: 12, color: Colors.white70),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoteButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? color : Colors.white.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : Colors.white70,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

