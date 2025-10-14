import 'package:flutter/material.dart';
import '../../core/theme/redesign_tokens.dart';
import '../../family/models/family_models.dart';

/// Simplified suggestion card with new hierarchy:
/// Title → "Why now" → Meta pills → Location → Pod row → Collapsed details → CTA row
class SimplifiedSuggestionCard extends StatefulWidget {
  final String title;
  final String rationale;
  final int? durationMinutes;
  final List<String> tags;
  final String? location;
  final double? distanceMiles;
  final String? venueType;
  final List<FamilyMember> participants;
  final String? podName;
  final Function(List<String> activeParticipantIds)? onMakeExperience; // Pass active participant IDs
  final Function(String memberId, bool included)? onParticipantToggle;
  final VoidCallback? onMenu;
  final VoidCallback? onTap; // Called when card is tapped to show details
  final Map<String, String>? memberFeedback; // memberId -> 'like' or 'dislike'
  final Function(String action)? onFeedback; // 'love', 'neutral', 'not_interested'
  final String? currentMemberId; // ID of the current user
  final VoidCallback? onWhyThis; // Callback for "Why this?" link
  
  const SimplifiedSuggestionCard({
    Key? key,
    required this.title,
    required this.rationale,
    this.durationMinutes,
    this.tags = const [],
    this.location,
    this.distanceMiles,
    this.venueType,
    this.participants = const [],
    this.podName,
    required this.onMakeExperience,
    this.onParticipantToggle,
    this.onMenu,
    this.onTap,
    this.memberFeedback,
    this.onFeedback,
    this.currentMemberId,
    this.onWhyThis,
  }) : super(key: key);

  @override
  State<SimplifiedSuggestionCard> createState() => _SimplifiedSuggestionCardState();
}

class _SimplifiedSuggestionCardState extends State<SimplifiedSuggestionCard> {
  final Set<String> _toggledOffMembers = {};
  String _currentFeedback = 'neutral'; // Default to neutral

  @override
  void initState() {
    super.initState();
    _initializeFeedback();
  }

  @override
  void didUpdateWidget(SimplifiedSuggestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update feedback if memberFeedback prop changes
    if (oldWidget.memberFeedback != widget.memberFeedback) {
      _initializeFeedback();
    }
  }

  void _initializeFeedback() {
    // Set initial feedback state from memberFeedback prop
    if (widget.memberFeedback != null && widget.currentMemberId != null) {
      final feedback = widget.memberFeedback![widget.currentMemberId];
      if (feedback != null && feedback != _currentFeedback) {
        if (mounted) {
          setState(() {
            _currentFeedback = feedback;
          });
        } else {
          // During initState, just set the value directly
          _currentFeedback = feedback;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(RedesignTokens.radiusCard),
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: RedesignTokens.getGutter(MediaQuery.of(context).size.width),
          vertical: RedesignTokens.space12,
        ),
        padding: const EdgeInsets.all(RedesignTokens.space24),
        decoration: BoxDecoration(
          color: Colors.white, // Explicit white background for cards
          borderRadius: BorderRadius.circular(RedesignTokens.radiusCard),
          boxShadow: RedesignTokens.shadowNone,
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top: Title + Feedback Actions + Menu
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: RedesignTokens.titleLarge,
                ),
              ),
              // Feedback actions (love, not interested) - neutral is default hidden state
              if (widget.onFeedback != null) ...[
                _FeedbackAction(
                  icon: Icons.favorite,
                  label: 'Love',
                  color: RedesignTokens.slate, // Gray by default
                  selectedColor: Colors.red, // Red when selected
                  isSelected: _currentFeedback == 'love',
                  onTap: () {
                    // Toggle: if already loved, go back to neutral
                    if (_currentFeedback == 'love') {
                      setState(() => _currentFeedback = 'neutral');
                      widget.onFeedback!('neutral');
                    } else {
                      setState(() => _currentFeedback = 'love');
                      widget.onFeedback!('love');
                    }
                  },
                ),
                const SizedBox(width: 4),
                _FeedbackAction(
                  icon: Icons.block, // Circle with line through it (no entry symbol)
                  label: 'Not interested',
                  color: RedesignTokens.mutedText, // Gray by default
                  hoverColor: RedesignTokens.dangerColor, // Red on hover
                  isSelected: _currentFeedback == 'not_interested',
                  onTap: () {
                    // Toggle: if already not interested, go back to neutral
                    if (_currentFeedback == 'not_interested') {
                      setState(() => _currentFeedback = 'neutral');
                      widget.onFeedback!('neutral');
                    } else {
                      setState(() => _currentFeedback = 'not_interested');
                      widget.onFeedback!('not_interested');
                    }
                  },
                ),
              ],
              if (widget.onMenu != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  onPressed: widget.onMenu,
                  icon: const Icon(Icons.more_vert),
                  color: RedesignTokens.slate,
                  iconSize: 20,
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                ),
              ],
            ],
          ),
          
          // "Why this?" link
          if (widget.onWhyThis != null) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: widget.onWhyThis,
              child: Text(
                'Why this?',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: RedesignTokens.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
          
          const SizedBox(height: RedesignTokens.space12),
          
          // Meta pills row
          Wrap(
            spacing: RedesignTokens.space8,
            runSpacing: RedesignTokens.space8,
            children: [
              if (widget.distanceMiles != null)
                _buildDistancePill(widget.distanceMiles!),
              if (widget.venueType != null)
                _buildMetaPill(widget.venueType!, Icons.home_outlined),
              if (widget.durationMinutes != null)
                _buildMetaPill(
                  '${widget.durationMinutes} min',
                  Icons.schedule_outlined,
                ),
              ...widget.tags.take(3).map((tag) => _buildMetaPill(tag, null)),
            ],
          ),
          
          // Location (if available)
          if (widget.location != null) ...[
            const SizedBox(height: RedesignTokens.space12),
            Row(
              children: [
                Icon(
                  Icons.place,
                  size: 16,
                  color: RedesignTokens.slate,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.location!,
                    style: RedesignTokens.meta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          
          const SizedBox(height: RedesignTokens.space16),
          
          // Rationale text (moved above What to expect)
          Text(
            widget.rationale,
            style: RedesignTokens.body.copyWith(
              color: RedesignTokens.slate,
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: RedesignTokens.space16),
          
          // What to expect (always expanded)
          _buildWhatToExpect(),
          
          const SizedBox(height: RedesignTokens.space20),
          
          // Toggleable participants chips (moved above CTA)
          _buildParticipantsRow(),
          
          const SizedBox(height: RedesignTokens.space16),
          
          // CTA row (pinned at bottom)
          _buildCTARow(),
        ],
        ),
      ),
    );
  }

  Widget _buildMetaPill(String label, IconData? icon) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RedesignTokens.space12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: RedesignTokens.infoPillBg,
        borderRadius: BorderRadius.circular(RedesignTokens.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: RedesignTokens.slate),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: RedesignTokens.caption.copyWith(
              color: RedesignTokens.slate,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistancePill(double distanceMiles) {
    // Mock travel time estimates based on distance
    final driveMinutes = (distanceMiles * 3).round(); // ~20mph avg city driving
    final walkMinutes = (distanceMiles * 20).round(); // ~3mph walking
    final transitMinutes = (distanceMiles * 5).round(); // ~12mph avg transit
    
    return Tooltip(
      message: '🚗 Drive: ${driveMinutes}m\n🚶 Walk: ${walkMinutes}m\n🚌 Transit: ${transitMinutes}m',
      textStyle: const TextStyle(
        fontSize: 12,
        color: Colors.white,
        height: 1.5,
      ),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      preferBelow: false,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: RedesignTokens.space12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: RedesignTokens.infoPillBg,
          borderRadius: BorderRadius.circular(RedesignTokens.radiusPill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 14,
              color: RedesignTokens.slate,
            ),
            const SizedBox(width: 4),
            Text(
              '${distanceMiles.toStringAsFixed(1)} mi',
              style: RedesignTokens.caption.copyWith(
                color: RedesignTokens.slate,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantsRow() {
    if (widget.participants.isEmpty) return const SizedBox.shrink();
    
    // Sort participants: parents first, then by active/inactive state
    final sortedParticipants = List<FamilyMember>.from(widget.participants);
    sortedParticipants.sort((a, b) {
      final aId = a.id ?? '';
      final bId = b.id ?? '';
      final aToggledOff = _toggledOffMembers.contains(aId);
      final bToggledOff = _toggledOffMembers.contains(bId);
      
      // First, sort by toggled state (active first, inactive last)
      if (aToggledOff != bToggledOff) {
        return aToggledOff ? 1 : -1;
      }
      
      // Within same state, parents come first
      final aIsParent = a.isParent();
      final bIsParent = b.isParent();
      if (aIsParent != bIsParent) {
        return aIsParent ? -1 : 1;
      }
      
      return 0; // Keep original order if same role and state
    });
    
    return Wrap(
      spacing: RedesignTokens.space8,
      runSpacing: RedesignTokens.space8,
      children: sortedParticipants.map((member) {
        final memberId = member.id ?? '';
        final isToggledOff = _toggledOffMembers.contains(memberId);
        final isCurrentUser = memberId == widget.currentMemberId;
        // Show current user's feedback from state, otherwise from memberFeedback map
        final feedback = isCurrentUser ? _currentFeedback : widget.memberFeedback?[memberId];
        
        return Stack(
          clipBehavior: Clip.none,
          children: [
            InkWell(
              onTap: widget.onParticipantToggle != null
                  ? () {
                      setState(() {
                        if (isToggledOff) {
                          _toggledOffMembers.remove(memberId);
                          widget.onParticipantToggle!(memberId, true);
                        } else {
                          _toggledOffMembers.add(memberId);
                          widget.onParticipantToggle!(memberId, false);
                        }
                      });
                    }
                  : null,
              borderRadius: BorderRadius.circular(RedesignTokens.radiusPill),
              child: Opacity(
                opacity: isToggledOff ? 0.3 : 1.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: RedesignTokens.space12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isToggledOff
                        ? RedesignTokens.mutedText.withOpacity(0.1)
                        : RedesignTokens.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(RedesignTokens.radiusPill),
                    border: Border.all(
                      color: isToggledOff
                          ? RedesignTokens.mutedText.withOpacity(0.2)
                          : RedesignTokens.primary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Avatar circle with outside border (28px total = 24px avatar + 2*2px border)
                      Container(
                        width: member.photoUrl != null ? 28 : 24,
                        height: member.photoUrl != null ? 28 : 24,
                        decoration: member.photoUrl != null
                            ? BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              )
                            : null,
                        padding: member.photoUrl != null ? const EdgeInsets.all(2) : null,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isToggledOff
                                ? RedesignTokens.mutedText
                                : RedesignTokens.primary,
                            shape: BoxShape.circle,
                            image: member.photoUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(member.photoUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: member.photoUrl == null
                              ? Center(
                                  child: Text(
                                    member.name[0].toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Name
                      Text(
                        member.name,
                        style: RedesignTokens.meta.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isToggledOff
                              ? RedesignTokens.mutedText
                              : RedesignTokens.slate,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Feedback indicator badge (bottom-right corner of chip)
            if (feedback != null && feedback != 'neutral')
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: RedesignTokens.divider,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      feedback == 'love'
                          ? Icons.favorite
                          : Icons.close,
                      size: 10,
                      color: feedback == 'love'
                          ? Colors.red // Red for love
                          : RedesignTokens.dangerColor,
                    ),
                  ),
                ),
              ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildWhatToExpect() {
    return Container(
      padding: const EdgeInsets.all(RedesignTokens.space16),
      decoration: BoxDecoration(
        color: RedesignTokens.canvas.withOpacity(0.5),
        borderRadius: BorderRadius.circular(RedesignTokens.radiusButton),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 18,
                color: RedesignTokens.slate,
              ),
              const SizedBox(width: RedesignTokens.space8),
              Text(
                'What to Expect',
                style: RedesignTokens.meta.copyWith(
                  fontWeight: FontWeight.w700,
                  color: RedesignTokens.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: RedesignTokens.space12),
          Text(
            'This is a family-friendly activity perfect for all ages. Expect to spend quality time together with plenty of smiles and laughter. The atmosphere is welcoming and there are facilities nearby.',
            style: RedesignTokens.body.copyWith(
              color: RedesignTokens.slate,
              height: 1.5,
            ),
          ),
          const SizedBox(height: RedesignTokens.space16),
          
          // First row: Wear & Food
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Wear section
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.checkroom,
                      size: 16,
                      color: RedesignTokens.mutedText,
                    ),
                    const SizedBox(width: RedesignTokens.space8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: RedesignTokens.caption.copyWith(
                            color: RedesignTokens.slate,
                          ),
                          children: [
                            TextSpan(
                              text: 'Wear: ',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const TextSpan(
                              text: 'comfortable clothes, sunscreen',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: RedesignTokens.space12),
              // Food section
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.restaurant,
                      size: 16,
                      color: RedesignTokens.mutedText,
                    ),
                    const SizedBox(width: RedesignTokens.space8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: RedesignTokens.caption.copyWith(
                            color: RedesignTokens.slate,
                          ),
                          children: [
                            TextSpan(
                              text: 'Food: ',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const TextSpan(
                              text: 'snacks available on-site',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: RedesignTokens.space8),
          
          // Second row: Bring & Cost
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bring section
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.backpack,
                      size: 16,
                      color: RedesignTokens.mutedText,
                    ),
                    const SizedBox(width: RedesignTokens.space8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: RedesignTokens.caption.copyWith(
                            color: RedesignTokens.slate,
                          ),
                          children: [
                            TextSpan(
                              text: 'Bring: ',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const TextSpan(
                              text: 'water bottle, sunscreen',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: RedesignTokens.space12),
              // Cost section
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.attach_money,
                      size: 16,
                      color: RedesignTokens.mutedText,
                    ),
                    const SizedBox(width: RedesignTokens.space8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: RedesignTokens.caption.copyWith(
                            color: RedesignTokens.slate,
                          ),
                          children: [
                            TextSpan(
                              text: 'Cost: ',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const TextSpan(
                              text: 'Free / \$5-10 per person',
                            ),
                          ],
                        ),
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

  Widget _buildCTARow() {
    return ElevatedButton.icon(
      onPressed: widget.onMakeExperience != null
          ? () {
              // Get active participants (not toggled off)
              final activeParticipantIds = widget.participants
                  .where((member) => !_toggledOffMembers.contains(member.id ?? ''))
                  .map((member) => member.id ?? '')
                  .where((id) => id.isNotEmpty)
                  .toList();
              widget.onMakeExperience!(activeParticipantIds);
            }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: RedesignTokens.primary,
        foregroundColor: RedesignTokens.onPrimary,
        padding: const EdgeInsets.symmetric(vertical: RedesignTokens.space16, horizontal: RedesignTokens.space24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RedesignTokens.radiusButton),
        ),
        elevation: 0,
        minimumSize: const Size(double.infinity, 0),
      ),
      icon: const Icon(Icons.add_circle_outline, size: 20),
      label: Text(
        'Make it an experience',
        style: RedesignTokens.button.copyWith(
          color: RedesignTokens.onPrimary,
        ),
      ),
    );
  }
}

/// A hover-aware feedback action button that shows text label on hover
class _FeedbackAction extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color? hoverColor;
  final Color? selectedColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _FeedbackAction({
    required this.icon,
    required this.label,
    required this.color,
    this.hoverColor,
    this.selectedColor,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  State<_FeedbackAction> createState() => _FeedbackActionState();
}

class _FeedbackActionState extends State<_FeedbackAction> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final displayColor = widget.isSelected && widget.selectedColor != null
        ? widget.selectedColor!
        : (_isHovering && widget.hoverColor != null 
            ? widget.hoverColor! 
            : widget.color);
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(RedesignTokens.radiusButton),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: _isHovering ? RedesignTokens.space12 : RedesignTokens.space8,
            vertical: RedesignTokens.space8,
          ),
          decoration: BoxDecoration(
            color: widget.isSelected 
                ? displayColor.withOpacity(0.15)
                : (_isHovering ? displayColor.withOpacity(0.1) : Colors.transparent),
            borderRadius: BorderRadius.circular(RedesignTokens.radiusButton),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 18,
                color: displayColor,
              ),
              if (_isHovering) ...[
                const SizedBox(width: 6),
                Text(
                  widget.label,
                  style: RedesignTokens.caption.copyWith(
                    color: displayColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

