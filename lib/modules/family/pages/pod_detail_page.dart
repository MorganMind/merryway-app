import 'package:merryway/modules/core/theme/redesign_tokens.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/family_models.dart';
import '../models/pod_model.dart';
import '../widgets/pod_rules_widget.dart';

class PodDetailPage extends StatefulWidget {
  final Pod pod;
  final List<FamilyMember> allMembers;

  const PodDetailPage({
    super.key,
    required this.pod,
    required this.allMembers,
  });

  @override
  State<PodDetailPage> createState() => _PodDetailPageState();
}

class _PodDetailPageState extends State<PodDetailPage> {
  late Pod currentPod;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    currentPod = widget.pod;
  }

  Future<void> _showEditDialog() async {
    final nameController = TextEditingController(text: currentPod.name);
    final descController = TextEditingController(text: currentPod.description ?? '');
    Set<String> selectedMembers = Set.from(currentPod.memberIds);
    String selectedIcon = currentPod.icon;
    String selectedColor = currentPod.color;

    final availableIcons = [
      '👨‍👩‍👧‍👦',
      '👥',
      '👨‍👩‍👧',
      '👶',
      '🧒',
      '👨‍👨‍👧',
      '👩‍👩‍👦',
      '💑',
      '👨‍👩‍👦‍👦',
      '⭐',
      '❤️',
      '🎉',
    ];

    final availableColors = [
      '#B4D7E8', // Soft Blue
      '#FFB4D7', // Soft Pink
      '#FFE8B4', // Soft Yellow
      '#B4FFD7', // Soft Green
      '#D7B4FF', // Soft Purple
      '#FFD4B4', // Soft Orange
    ];

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Pod'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Pod Name',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                // Icon picker
                const Text('Icon', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableIcons.map((icon) {
                    final isSelected = icon == selectedIcon;
                    return GestureDetector(
                      onTap: () => setDialogState(() => selectedIcon = icon),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSelected ? RedesignTokens.primary.withOpacity(0.2) : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? RedesignTokens.primary : Colors.grey[300]!,
                            width: 2,
                          ),
                        ),
                        child: Center(child: Text(icon, style: const TextStyle(fontSize: 24))),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                // Color picker
                const Text('Color', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableColors.map((color) {
                    final isSelected = color == selectedColor;
                    return GestureDetector(
                      onTap: () => setDialogState(() => selectedColor = color),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Color(int.parse(color.substring(1), radix: 16) + 0xFF000000),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? Colors.black : Colors.grey[300]!,
                            width: isSelected ? 3 : 1,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                // Member selector
                const Text('Members', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ...widget.allMembers.map((member) {
                  final isSelected = selectedMembers.contains(member.id);
                  return CheckboxListTile(
                    title: Text(member.name),
                    value: isSelected,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (bool? value) {
                      setDialogState(() {
                        if (value == true) {
                          selectedMembers.add(member.id!);
                        } else {
                          selectedMembers.remove(member.id);
                        }
                      });
                    },
                  );
                }).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a pod name')),
                  );
                  return;
                }

                Navigator.pop(context, {
                  'name': nameController.text,
                  'description': descController.text,
                  'memberIds': selectedMembers.toList(),
                  'icon': selectedIcon,
                  'color': selectedColor,
                });
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      try {
        final supabase = Supabase.instance.client;
        await supabase.from('pods').update({
          'name': result['name'],
          'description': result['description'],
          'member_ids': result['memberIds'],
          'icon': result['icon'],
          'color': result['color'],
        }).eq('id', currentPod.id!);

        setState(() {
          currentPod = currentPod.copyWith(
            name: result['name'],
            description: result['description'],
            memberIds: result['memberIds'],
            icon: result['icon'],
            color: result['color'],
          );
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pod updated!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating pod: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final podMembers = widget.allMembers
        .where((m) => currentPod.memberIds.contains(m.id))
        .toList();

    return Scaffold(
      backgroundColor: MerryWayTheme.softBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context, currentPod),
          icon: const Icon(Icons.arrow_back, color: RedesignTokens.ink),
        ),
        title: Text(
          currentPod.name,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: RedesignTokens.ink,
              ),
        ),
        actions: [
          IconButton(
            onPressed: _showEditDialog,
            icon: const Icon(Icons.edit, color: RedesignTokens.primary),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pod Icon and Info
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Color(int.parse(currentPod.color.substring(1), radix: 16) + 0xFF000000),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Text(
                    currentPod.icon,
                    style: const TextStyle(fontSize: 48),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Description
            if (currentPod.description != null && currentPod.description!.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentPod.description!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Members
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Members (${podMembers.length})',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 12),
                    if (podMembers.isEmpty)
                      Text(
                        'No members in this pod',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: RedesignTokens.slate,
                            ),
                      )
                    else
                      ...podMembers.map((member) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: RedesignTokens.primary.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      member.avatarEmoji ?? member.name[0],
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        member.name,
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        '${member.age} years old',
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Pod Rules Widget
            PodRulesWidget(
              pod: currentPod,
              onRulesChanged: () {
                // Rules changed, optionally refresh or notify
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }
}

