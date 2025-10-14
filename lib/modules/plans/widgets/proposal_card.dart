import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/redesign_tokens.dart';
import '../models/plan_models.dart';
import 'vote_buttons.dart';

/// Card displaying a proposal with voting
class ProposalCard extends StatelessWidget {
  final ProposalWithVotes proposalWithVotes;
  final Function(int) onVote;

  const ProposalCard({
    super.key,
    required this.proposalWithVotes,
    required this.onVote,
  });

  @override
  Widget build(BuildContext context) {
    final proposal = proposalWithVotes.proposal;
    final feasibility = proposalWithVotes.feasibility;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getFeasibilityColor(feasibility).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              Expanded(
                child: Text(
                  proposal.activityName,
                  style: GoogleFonts.eczar(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: RedesignTokens.ink,
                  ),
                ),
              ),
              if (feasibility != null) _buildFeasibilityBadge(feasibility),
            ],
          ),

          // Reasoning
          if (proposal.reasoning != null && proposal.reasoning!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              proposal.reasoning!,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                color: RedesignTokens.slate,
                height: 1.4,
              ),
            ),
          ],

          // Tags
          if (proposal.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: proposal.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: RedesignTokens.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tag,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: RedesignTokens.primary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          // Vote stats and buttons
          const SizedBox(height: 16),
          Row(
            children: [
              // Vote counts
              _buildVoteCount(Icons.thumb_up, proposalWithVotes.upvotes,
                  RedesignTokens.accentGold),
              const SizedBox(width: 12),
              _buildVoteCount(Icons.remove_circle_outline,
                  proposalWithVotes.neutral, RedesignTokens.slate),
              const SizedBox(width: 12),
              _buildVoteCount(
                  Icons.thumb_down, proposalWithVotes.downvotes, Colors.red[400]!),
              const Spacer(),
            ],
          ),

          const SizedBox(height: 12),
          VoteButtons(
            currentVote: proposalWithVotes.userVote,
            onVote: onVote,
          ),
        ],
      ),
    );
  }

  Widget _buildVoteCount(IconData icon, int count, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          count.toString(),
          style: GoogleFonts.spaceGrotesk(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildFeasibilityBadge(Map<String, dynamic> feasibility) {
    final status = feasibility['status'] ?? 'fits';
    final color = _getFeasibilityColor(feasibility);
    final icon = _getFeasibilityIcon(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            status == 'fits'
                ? 'Fits'
                : status == 'stretch'
                    ? 'Stretch'
                    : 'Blocked',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getFeasibilityColor(Map<String, dynamic>? feasibility) {
    if (feasibility == null) return RedesignTokens.accentGold;
    final status = feasibility['status'] ?? 'fits';
    switch (status) {
      case 'fits':
        return RedesignTokens.accentGold;
      case 'stretch':
        return Colors.orange;
      case 'blocked':
        return Colors.red;
      default:
        return RedesignTokens.slate;
    }
  }

  IconData _getFeasibilityIcon(String status) {
    switch (status) {
      case 'fits':
        return Icons.check_circle;
      case 'stretch':
        return Icons.warning_amber;
      case 'blocked':
        return Icons.block;
      default:
        return Icons.help_outline;
    }
  }
}

