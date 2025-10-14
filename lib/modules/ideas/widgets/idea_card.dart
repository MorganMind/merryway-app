import 'package:flutter/material.dart';
import '../../core/theme/theme_colors.dart';
import '../../family/models/family_models.dart';
import '../models/idea_models.dart';

// Access MerryWayTheme constants
class MerryWayTheme {
  static const Color primarySoftBlue = Color(0xFF91C8E4);
  static const Color accentLavender = Color(0xFFB4A7D6);
  static const Color accentGolden = Color(0xFFFFD700);
  static const Color accentSoftPink = Color(0xFFFFB6C1);
  static const Color textDark = Color(0xFF2D3436);
  static const Color textMuted = Color(0xFF636E72);
  static const Color softBg = Color(0xFFF5F5F5);
}

class IdeaCard extends StatelessWidget {
  final Idea idea;
  final List<FamilyMember> allMembers;
  final VoidCallback onTap;
  final VoidCallback? onLike;

  const IdeaCard({
    Key? key,
    required this.idea,
    required this.allMembers,
    required this.onTap,
    this.onLike,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final creator = allMembers.firstWhere(
      (m) => m.id == idea.creatorMemberId,
      orElse: () => FamilyMember(
        id: idea.creatorMemberId,
        name: 'Unknown',
        age: 0,
        role: MemberRole.parent,
      ),
    );

    final isDueSoon = _checkIfDueSoon();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User-created indicator
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: MerryWayTheme.accentLavender.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.lightbulb,
                      color: MerryWayTheme.accentLavender,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title and metadata
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Due soon badge
                        if (isDueSoon) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: MerryWayTheme.accentGolden.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Due Soon',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: MerryWayTheme.accentGolden,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                        // Title
                        Text(
                          idea.title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: MerryWayTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Creator
                        Row(
                          children: [
                            Text(
                              '${creator.avatarEmoji ?? '👤'} ',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              'by ${creator.name}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: MerryWayTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Summary
              if (idea.summary != null && idea.summary!.isNotEmpty) ...[
                Text(
                  idea.summary!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: MerryWayTheme.textDark,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
              ],

              // Badges
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (idea.durationMinutes != null)
                    _buildBadge(Icons.access_time, '${idea.durationMinutes}min'),
                  if (idea.costBand != null)
                    _buildBadge(Icons.attach_money, _formatCost(idea.costBand!)),
                  if (idea.indoorOutdoor != null)
                    _buildBadge(
                      idea.indoorOutdoor == 'indoor' ? Icons.home : Icons.wb_sunny,
                      idea.indoorOutdoor!,
                    ),
                  if (idea.minAge != null)
                    _buildBadge(Icons.child_care, '${idea.minAge}+'),
                  if (idea.needsAdult)
                    _buildBadge(Icons.supervisor_account, 'Adult'),
                ],
              ),
              const SizedBox(height: 12),

              // Footer row
              Row(
                children: [
                  // Visibility chip
                  _buildChip(
                    _getVisibilityIcon(),
                    idea.visibility.displayName,
                    MerryWayTheme.textMuted,
                  ),
                  const Spacer(),
                  // Likes
                  InkWell(
                    onTap: onLike,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          idea.isLikedByMe ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: idea.isLikedByMe
                              ? MerryWayTheme.accentSoftPink
                              : MerryWayTheme.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${idea.likesCount}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: MerryWayTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Comments
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.comment_outlined,
                        size: 18,
                        color: MerryWayTheme.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${idea.commentsCount}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: MerryWayTheme.textDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: MerryWayTheme.primarySoftBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: MerryWayTheme.primarySoftBlue),
          const SizedBox(width: 3),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: MerryWayTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getVisibilityIcon() {
    switch (idea.visibility) {
      case IdeaVisibility.household:
        return Icons.group;
      case IdeaVisibility.private:
        return Icons.lock_outline;
      case IdeaVisibility.podOnly:
        return Icons.people_outline;
    }
  }

  String _formatCost(String cost) {
    switch (cost) {
      case 'free':
        return 'Free';
      case 'low':
        return '\$';
      case 'medium':
        return '\$\$';
      case 'high':
        return '\$\$\$';
      default:
        return cost;
    }
  }

  bool _checkIfDueSoon() {
    if (idea.nextDueAt == null) return false;

    final now = DateTime.now();
    final dueAt = idea.nextDueAt!;
    final difference = dueAt.difference(now);

    // Consider "due soon" if within 2 days
    return difference.inDays >= 0 && difference.inDays <= 2;
  }
}

