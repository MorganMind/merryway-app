import 'package:flutter/material.dart';
import '../../core/theme/redesign_tokens.dart';
import '../../family/models/family_models.dart';

/// Inline participants row for per-card participant customization
/// Allows forking participants for just that idea without changing active Pod
class InlineParticipantsEditor extends StatelessWidget {
  final List<FamilyMember> participants;
  final String? podName;
  final bool isCustom;
  final VoidCallback onEdit;
  final VoidCallback? onReset;
  final bool isPolicyBlocked;
  final String? policyReason;

  const InlineParticipantsEditor({
    Key? key,
    required this.participants,
    this.podName,
    this.isCustom = false,
    required this.onEdit,
    this.onReset,
    this.isPolicyBlocked = false,
    this.policyReason,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RedesignTokens.space16,
        vertical: RedesignTokens.space8,
      ),
      child: Row(
        children: [
          // Avatar stack (micro, 20px circles)
          if (participants.isNotEmpty)
            _buildAvatarStack(),
          
          const SizedBox(width: RedesignTokens.space8),
          
          // Pod name + custom badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      podName ?? 'Custom',
                      style: RedesignTokens.meta.copyWith(
                        fontWeight: FontWeight.w600,
                        color: RedesignTokens.slate,
                      ),
                    ),
                    if (isCustom) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: RedesignTokens.infoPillBg,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'custom',
                          style: RedesignTokens.caption.copyWith(
                            fontSize: 10,
                            color: RedesignTokens.mutedText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (isPolicyBlocked && policyReason != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.lock,
                        size: 12,
                        color: RedesignTokens.dangerColor,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          policyReason!,
                          style: RedesignTokens.caption.copyWith(
                            fontSize: 11,
                            color: RedesignTokens.dangerColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          
          // Edit link
          InkWell(
            onTap: onEdit,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: RedesignTokens.space8,
                vertical: 4,
              ),
              child: Text(
                'Edit',
                style: RedesignTokens.meta.copyWith(
                  color: RedesignTokens.accentGold,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          
          // Reset button (if custom)
          if (isCustom && onReset != null) ...[
            InkWell(
              onTap: onReset,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.refresh,
                  size: 16,
                  color: RedesignTokens.mutedText,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatarStack() {
    final displayCount = participants.length > 4 ? 3 : participants.length;
    final overflow = participants.length > 4 ? participants.length - 3 : 0;
    
    return SizedBox(
      height: 20,
      width: displayCount * 12.0 + 20 + (overflow > 0 ? 20 : 0),
      child: Stack(
        children: [
          ...List.generate(displayCount, (index) {
            return Positioned(
              left: index * 12.0,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: _getAvatarColor(index),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    participants[index].name[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
          }),
          if (overflow > 0)
            Positioned(
              left: displayCount * 12.0,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: RedesignTokens.mutedText,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    '+$overflow',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getAvatarColor(int index) {
    final colors = [
      RedesignTokens.accentSage,
      RedesignTokens.accentGold,
      const Color(0xFF8EA5D6),
      const Color(0xFFE8A87C),
    ];
    return colors[index % colors.length];
  }
}

/// Bottom sheet for editing participants
class ParticipantsEditorSheet extends StatefulWidget {
  final List<FamilyMember> allMembers;
  final Set<String> selectedMemberIds;
  final Function(Set<String>) onSave;

  const ParticipantsEditorSheet({
    Key? key,
    required this.allMembers,
    required this.selectedMemberIds,
    required this.onSave,
  }) : super(key: key);

  @override
  State<ParticipantsEditorSheet> createState() => _ParticipantsEditorSheetState();
}

class _ParticipantsEditorSheetState extends State<ParticipantsEditorSheet> {
  late Set<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = Set.from(widget.selectedMemberIds);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: RedesignTokens.cardSurface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(RedesignTokens.radiusCard),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: RedesignTokens.space12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: RedesignTokens.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: RedesignTokens.space24),
            child: Text(
              'Who\'s going?',
              style: RedesignTokens.titleSmall,
            ),
          ),
          
          const SizedBox(height: RedesignTokens.space16),
          
          // Member chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: RedesignTokens.space24),
            child: Wrap(
              spacing: RedesignTokens.space12,
              runSpacing: RedesignTokens.space12,
              children: widget.allMembers.map((member) {
                final isSelected = _selectedIds.contains(member.id);
                return FilterChip(
                  label: Text(member.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected && member.id != null) {
                        _selectedIds.add(member.id!);
                      } else if (member.id != null) {
                        _selectedIds.remove(member.id!);
                      }
                    });
                  },
                  selectedColor: RedesignTokens.accentGold.withOpacity(0.2),
                  checkmarkColor: RedesignTokens.accentGold,
                  backgroundColor: RedesignTokens.infoPillBg,
                  side: BorderSide(
                    color: isSelected ? RedesignTokens.accentGold : RedesignTokens.divider,
                    width: 1.5,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: RedesignTokens.space12,
                    vertical: RedesignTokens.space8,
                  ),
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: RedesignTokens.space24),
          
          // Save button
          Padding(
            padding: const EdgeInsets.fromLTRB(
              RedesignTokens.space24,
              0,
              RedesignTokens.space24,
              RedesignTokens.space24,
            ),
            child: ElevatedButton(
              onPressed: () {
                widget.onSave(_selectedIds);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: RedesignTokens.accentGold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: RedesignTokens.space16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(RedesignTokens.radiusButton),
                ),
                minimumSize: const Size(double.infinity, 0),
              ),
              child: Text(
                'Save (${_selectedIds.length} ${_selectedIds.length == 1 ? 'person' : 'people'})',
                style: RedesignTokens.button,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

