import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../core/theme/redesign_tokens.dart';
import '../models/plan_models.dart';
import 'member_facepile.dart';
import 'morgan_badge.dart';

/// Card displaying a plan summary in the list view
class PlanCard extends StatelessWidget {
  final PlanSummary plan;
  final VoidCallback onTap;

  const PlanCard({
    super.key,
    required this.plan,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(RedesignTokens.radiusCard),
          boxShadow: RedesignTokens.shadowLevel2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Title + Status
            Row(
              children: [
                Expanded(
                  child: Text(
                    plan.title ?? 'Untitled Plan',
                    style: GoogleFonts.eczar(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: RedesignTokens.ink,
                    ),
                  ),
                ),
                if (plan.status == 'archived')
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: RedesignTokens.slate.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Archived',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: RedesignTokens.slate,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Facepile
            if (plan.memberFacepile.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: MemberFacepile(
                  members: plan.memberFacepile,
                  size: 28,
                ),
              ),

            // Last message
            if (plan.lastMessageSnippet != null &&
                plan.lastMessageSnippet!.isNotEmpty)
              Row(
                children: [
                  if (plan.lastMessageAuthor == 'morgan') ...[
                    const MorganBadge(size: 14),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      plan.lastMessageSnippet!,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        color: RedesignTokens.slate,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

            // Footer: Proposal count + Last update
            const SizedBox(height: 12),
            Row(
              children: [
                if (plan.proposalCount > 0) ...[
                  Icon(
                    Icons.lightbulb_outline,
                    size: 16,
                    color: RedesignTokens.accentGold,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${plan.proposalCount} ${plan.proposalCount == 1 ? 'idea' : 'ideas'}',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      color: RedesignTokens.slate,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Text(
                  timeago.format(plan.updatedAt ?? plan.createdAt ?? DateTime.now()),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    color: RedesignTokens.slate,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: RedesignTokens.slate,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

