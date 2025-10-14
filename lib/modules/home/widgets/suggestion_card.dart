import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../family/models/family_models.dart';
import '../../core/theme/merryway_theme.dart';
import 'participant_selector.dart';
import 'idea_voting_widget.dart';

class SuggestionCard extends StatefulWidget {
  final int index;
  final ActivitySuggestion suggestion;
  final String? householdId;
  final List<FamilyMember>? allMembers;
  final String? currentMemberId;  // Who is viewing/voting?
  final Set<String>? selectedMemberIds;
  final Function(Set<String>)? onParticipantsChanged;
  final VoidCallback? onManagePresets;
  final VoidCallback? onMakeExperience;

  const SuggestionCard({
    super.key,
    required this.index,
    required this.suggestion,
    this.householdId,
    this.allMembers,
    this.currentMemberId,
    this.selectedMemberIds,
    this.onParticipantsChanged,
    this.onManagePresets,
    this.onMakeExperience,
  });

  @override
  State<SuggestionCard> createState() => _SuggestionCardState();
}

class _SuggestionCardState extends State<SuggestionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInCubic),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get a random magic touch quote
    final magicTouch = MerryWayTheme.magicTouches[
        math.Random().nextInt(MerryWayTheme.magicTouches.length)];

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Main card
            Card(
              margin: EdgeInsets.zero,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _getGradientColors(widget.index),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 44), // Extra bottom padding for voting pill
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  // Activity title
                  Text(
                    widget.suggestion.activity,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 12),

                  // Info chips (distance, venue type, duration)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (widget.suggestion.distanceMiles != null)
                        _buildInfoChip(
                          context,
                          Icons.location_on,
                          '${widget.suggestion.distanceMiles!.toStringAsFixed(1)} mi',
                        ),
                      if (widget.suggestion.venueType != null)
                        _buildInfoChip(
                          context,
                          widget.suggestion.venueType == 'indoor'
                              ? Icons.home
                              : Icons.park,
                          widget.suggestion.venueType!,
                        ),
                      if (widget.suggestion.durationMinutes != null)
                        _buildInfoChip(
                          context,
                          Icons.access_time,
                          '${widget.suggestion.durationMinutes} min',
                        ),
                      if (widget.suggestion.averageRating != null)
                        _buildInfoChip(
                          context,
                          Icons.star,
                          '${widget.suggestion.averageRating!.toStringAsFixed(1)}',
                        ),
                    ],
                  ),
                  if (widget.suggestion.distanceMiles != null ||
                      widget.suggestion.venueType != null ||
                      widget.suggestion.durationMinutes != null)
                    const SizedBox(height: 16),

                  // Location
                  if (widget.suggestion.location != null) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.place,
                          size: 16,
                          color: Colors.white.withOpacity(0.85),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.suggestion.location!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 13,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Participant selector
                  if (widget.allMembers != null &&
                      widget.selectedMemberIds != null &&
                      widget.onParticipantsChanged != null &&
                      widget.onManagePresets != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ParticipantSelector(
                        allMembers: widget.allMembers!,
                        selectedMemberIds: widget.selectedMemberIds!,
                        onSelectionChanged: widget.onParticipantsChanged!,
                        onManagePresets: widget.onManagePresets!,
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Rationale
                  Text(
                    widget.suggestion.rationale,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.95),
                          height: 1.6,
                        ),
                  ),
                  const SizedBox(height: 16),

                  // Description (What to Expect)
                  if (widget.suggestion.description != null &&
                      widget.suggestion.description!.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: Colors.white.withOpacity(0.9),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'What to Expect',
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.suggestion.description!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.85),
                                  height: 1.5,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Attire
                  if (widget.suggestion.attire.isNotEmpty) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.checkroom,
                          size: 18,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Wear: ${widget.suggestion.attire.join(", ")}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Food
                  if (widget.suggestion.foodAvailable != null) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.restaurant,
                          size: 18,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.suggestion.foodAvailable!['available'] == true
                                ? 'Food: ${widget.suggestion.foodAvailable!['type'] ?? 'Available'}'
                                : 'Food: Not available',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Review info
                  if (widget.suggestion.reviewCount != null &&
                      widget.suggestion.reviewCount! > 0) ...[
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (index) => Icon(
                            index < (widget.suggestion.averageRating ?? 0).round()
                                ? Icons.star
                                : Icons.star_border,
                            size: 16,
                            color: Colors.amber,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${widget.suggestion.averageRating!.toStringAsFixed(1)} (${widget.suggestion.reviewCount} reviews)',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white.withOpacity(0.85),
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Tags
                  if (widget.suggestion.tags.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.suggestion.tags
                          .map((tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  tag,
                                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                ),
                              ))
                          .toList(),
                    ),
                  const SizedBox(height: 20),

                  // Magic touch divider
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0),
                          Colors.white.withOpacity(0.3),
                          Colors.white.withOpacity(0),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Make it an Experience button
                  if (widget.onMakeExperience != null) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: widget.onMakeExperience,
                        icon: const Icon(Icons.event_available, size: 18),
                        label: const Text('Make it an Experience'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.25),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Magic touch quote
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '✨',
                        style: TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          magicTouch,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withOpacity(0.95),
                                fontStyle: FontStyle.italic,
                                height: 1.5,
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
            
            // Voting pill - positioned at bottom center
            if (widget.householdId != null && widget.allMembers != null)
              Positioned(
                bottom: -16,
                left: 0,
                right: 0,
                child: Center(
                  child: IdeaVotingWidget(
                    activityName: widget.suggestion.activity,
                    householdId: widget.householdId!,
                    allMembers: widget.allMembers!,
                    currentMemberId: widget.currentMemberId,
                    category: 'today',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
          ),
        ],
      ),
    );
  }

  List<Color> _getGradientColors(int index) {
    const gradients = [
      [Color(0xFFB4D7E8), Color(0xFF87B8D8)], // Soft blue
      [Color(0xFFF4A6B8), Color(0xFFE88FA0)], // Warm pink
      [Color(0xFFE5C17D), Color(0xFFD9A55D)], // Golden
    ];

    return gradients[index % gradients.length];
  }
}

