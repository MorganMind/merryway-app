import 'package:flutter/material.dart';
import '../../family/models/family_models.dart';
import '../../core/theme/theme_colors.dart';
import '../../core/theme/merryway_theme.dart';

class SmartSuggestionCard extends StatelessWidget {
  final String activityTitle;
  final String rationale;
  final String locationLabel;
  final List<FamilyMember> nearbyMembers;
  final String reason;
  final VoidCallback onDismiss;
  final VoidCallback onActivate;
  final bool showDebugInfo;
  final List<String> signals;
  final double confidence;

  const SmartSuggestionCard({
    Key? key,
    required this.activityTitle,
    required this.rationale,
    required this.locationLabel,
    required this.nearbyMembers,
    required this.reason,
    required this.onDismiss,
    required this.onActivate,
    this.showDebugInfo = false,
    this.signals = const [],
    this.confidence = 0.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFD700).withOpacity(0.15),  // Golden
            const Color(0xFFFFA500).withOpacity(0.1),   // Orange
          ],
        ),
        border: Border.all(
          color: const Color(0xFFFFD700),  // Golden border
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header: "Featured" badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withOpacity(0.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      'Featured',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFB8860B),  // Dark golden
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: onDismiss,
                  icon: const Icon(Icons.close, size: 20),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  splashRadius: 20,
                ),
              ],
            ),
          ),

          // Main content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location + "Who's nearby"
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: MerryWayTheme.primarySoftBlue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Color(0xFFB8860B)),
                      const SizedBox(width: 6),
                      Text(
                        locationLabel,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFB8860B),
                        ),
                      ),
                      const Spacer(),
                      if (nearbyMembers.isNotEmpty)
                        Text(
                          '${nearbyMembers.length} ${nearbyMembers.length == 1 ? "person" : "people"} nearby',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: MerryWayTheme.textMuted,
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Activity title
                Text(
                  activityTitle,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: MerryWayTheme.textDark,
                  ),
                ),

                const SizedBox(height: 8),

                // Rationale
                Text(
                  rationale,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: MerryWayTheme.textMuted,
                    fontStyle: FontStyle.italic,
                  ),
                ),

                const SizedBox(height: 12),

                // Nearby members avatars
                if (nearbyMembers.isNotEmpty) ...[
                  Row(
                    children: [
                      Text(
                        'Who\'s nearby:',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: MerryWayTheme.textMuted,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ...nearbyMembers.take(4).map((member) {
                        return Container(
                          width: 28,
                          height: 28,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: MerryWayTheme.primarySoftBlue,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(
                              member.avatarEmoji ?? '👤',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        );
                      }),
                      if (nearbyMembers.length > 4)
                        Text(
                          '+${nearbyMembers.length - 4}',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                // Reason
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFFFD700).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lightbulb_outline,
                        size: 18,
                        color: Color(0xFFB8860B),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          reason,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: MerryWayTheme.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Debug info (if enabled)
                if (showDebugInfo) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🔍 Debug Info',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: MerryWayTheme.textMuted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Signals: ${signals.join(", ")}',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontSize: 10,
                            color: MerryWayTheme.textMuted,
                          ),
                        ),
                        Text(
                          'Confidence: ${(confidence * 100).toStringAsFixed(0)}%',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontSize: 10,
                            color: MerryWayTheme.textMuted,
                          ),
                        ),
                        Text(
                          'Members: ${nearbyMembers.map((m) => m.name).join(", ")}',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontSize: 10,
                            color: MerryWayTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onDismiss,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: MerryWayTheme.textMuted.withOpacity(0.3)),
                          foregroundColor: MerryWayTheme.textDark,
                        ),
                        child: const Text('Maybe later'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onActivate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(
                          'Try This!',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

