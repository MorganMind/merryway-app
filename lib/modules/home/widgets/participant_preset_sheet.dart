import 'package:flutter/material.dart';
import '../../family/models/family_models.dart';
import '../../family/models/pod_model.dart';

class ParticipantPresetSheet extends StatefulWidget {
  final List<FamilyMember> allMembers;
  final Set<String> currentSelection;
  final List<Pod> pods;
  final Function(Set<String>) onApplyPod;
  final VoidCallback onManagePods;

  const ParticipantPresetSheet({
    super.key,
    required this.allMembers,
    required this.currentSelection,
    required this.pods,
    required this.onApplyPod,
    required this.onManagePods,
  });

  @override
  State<ParticipantPresetSheet> createState() => _ParticipantPresetSheetState();
}

class _ParticipantPresetSheetState extends State<ParticipantPresetSheet> {
  String _getMemberNames(List<String> memberIds) {
    final names = widget.allMembers
        .where((m) => memberIds.contains(m.id))
        .map((m) => m.name)
        .toList();
    
    if (names.isEmpty) return 'None';
    if (names.length == 1) return names[0];
    if (names.length == 2) return '${names[0]} & ${names[1]}';
    return '${names[0]}, ${names[1]} + ${names.length - 2} more';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quick Select',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4A4A4A),
                    ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Color(0xFF8B8B8B)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Current selection
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Selection',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF8B8B8B),
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getMemberNames(widget.currentSelection.toList()),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Saved Pods
          if (widget.pods.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Pods',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF8B8B8B),
                      ),
                ),
                TextButton.icon(
                  onPressed: widget.onManagePods,
                  icon: const Icon(Icons.settings, size: 16),
                  label: const Text('Manage'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...widget.pods.map((pod) {
              final color = pod.color != null 
                  ? Color(int.parse(pod.color!.substring(1, 7), radix: 16) + 0xFF000000)
                  : const Color(0xFFB4D7E8);
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: color,
                    radius: 16,
                    child: Text(
                      pod.icon ?? '👥',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  title: Text(
                    pod.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    _getMemberNames(pod.memberIds),
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        onPressed: () {
                          widget.onManagePods();
                        },
                        tooltip: 'Edit pod',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                  onTap: () {
                    widget.onApplyPod(pod.memberIds.toSet());
                    Navigator.pop(context);
                  },
                ),
              );
            }),
          ] else ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Icon(
                      Icons.group_add,
                      size: 48,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No pods yet',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: widget.onManagePods,
                      child: const Text('Create your first pod'),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Common presets (quick suggestions)
          const SizedBox(height: 16),
          Text(
            'Quick Ideas',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF8B8B8B),
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildQuickPreset(
                context,
                'Everyone',
                widget.allMembers.map((m) => m.id!).toSet(),
                Icons.groups,
              ),
              _buildQuickPreset(
                context,
                'Parents',
                widget.allMembers
                    .where((m) => m.role == MemberRole.parent)
                    .map((m) => m.id!)
                    .toSet(),
                Icons.favorite,
              ),
              _buildQuickPreset(
                context,
                'Kids',
                widget.allMembers
                    .where((m) => m.role == MemberRole.child)
                    .map((m) => m.id!)
                    .toSet(),
                Icons.child_care,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPreset(
    BuildContext context,
    String label,
    Set<String> memberIds,
    IconData icon,
  ) {
    if (memberIds.isEmpty) return const SizedBox.shrink();

    return ActionChip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      onPressed: () {
        widget.onApplyPod(memberIds);
        Navigator.pop(context);
      },
      backgroundColor: const Color(0xFFE8F4F8),
    );
  }
}

