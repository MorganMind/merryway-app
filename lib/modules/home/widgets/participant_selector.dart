import 'package:flutter/material.dart';
import '../../family/models/family_models.dart';

class ParticipantSelector extends StatelessWidget {
  final List<FamilyMember> allMembers;
  final Set<String> selectedMemberIds;
  final Function(Set<String>) onSelectionChanged;
  final VoidCallback onManagePresets;

  const ParticipantSelector({
    super.key,
    required this.allMembers,
    required this.selectedMemberIds,
    required this.onSelectionChanged,
    required this.onManagePresets,
  });

  void _toggleMember(String memberId) {
    final newSelection = Set<String>.from(selectedMemberIds);
    if (newSelection.contains(memberId)) {
      newSelection.remove(memberId);
    } else {
      newSelection.add(memberId);
    }
    onSelectionChanged(newSelection);
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Color _getAvatarColor(int index) {
    final colors = [
      const Color(0xFFB4D7E8), // Soft blue
      const Color(0xFFFFD4E5), // Warm pink
      const Color(0xFFFFF4D4), // Golden
      const Color(0xFFD4F4DD), // Mint
      const Color(0xFFE8D4FF), // Lavender
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    if (allMembers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Who\'s joining?',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF8B8B8B),
                    fontWeight: FontWeight.w600,
                  ),
            ),
            TextButton.icon(
              onPressed: onManagePresets,
              icon: const Icon(Icons.bookmark_border, size: 14),
              label: const Text('Presets', style: TextStyle(fontSize: 12)),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: const Size(0, 28),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 50,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: allMembers.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final member = allMembers[index];
              final isSelected = selectedMemberIds.contains(member.id);

              return GestureDetector(
                onTap: () => _toggleMember(member.id!),
                onLongPress: onManagePresets,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _getAvatarColor(index).withOpacity(0.3)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: isSelected
                          ? _getAvatarColor(index)
                          : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: _getAvatarColor(index),
                        child: Text(
                          _getInitials(member.name),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Name
                      Text(
                        member.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected
                              ? const Color(0xFF4A4A4A)
                              : const Color(0xFF8B8B8B),
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Status indicator
                      AnimatedScale(
                        scale: isSelected ? 1.0 : 0.8,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          isSelected ? Icons.check_circle : Icons.circle_outlined,
                          size: 16,
                          color: isSelected
                              ? _getAvatarColor(index)
                              : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (selectedMemberIds.isEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Tap to include people',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFFCCCCCC),
                  fontStyle: FontStyle.italic,
                  fontSize: 11,
                ),
          ),
        ],
      ],
    );
  }
}

