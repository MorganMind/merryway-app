import 'package:merryway/modules/core/theme/redesign_tokens.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/user_context_service.dart';
import '../models/family_models.dart';
import '../models/pod_model.dart';
import 'pod_detail_page.dart';

class PodsManagementPage extends StatefulWidget {
  final String householdId;
  final List<FamilyMember> allMembers;
  final String? currentMemberId;

  const PodsManagementPage({
    Key? key,
    required this.householdId,
    required this.allMembers,
    this.currentMemberId,
  }) : super(key: key);

  @override
  State<PodsManagementPage> createState() => _PodsManagementPageState();
}

class _PodsManagementPageState extends State<PodsManagementPage> {
  List<Pod> pods = [];
  bool isLoading = true;

  final List<String> availableIcons = [
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

  final List<String> availableColors = [
    '#B4D7E8', // Soft Blue
    '#FFB4D7', // Soft Pink
    '#FFE8B4', // Soft Yellow
    '#B4FFD7', // Soft Green
    '#D7B4FF', // Soft Purple
    '#FFD4B4', // Soft Orange
  ];

  @override
  void initState() {
    super.initState();
    _loadPods();
  }

  Future<void> _loadPods() async {
    setState(() => isLoading = true);
    try {
      final supabase = Supabase.instance.client;
      final data = await supabase
          .from('pods')
          .select()
          .eq('household_id', widget.householdId)
          .order('created_at');

      // Load all pods
      var loadedPods = (data as List).map((p) => Pod.fromJson(p)).toList();
      
      // Filter out parent-only pods if current user is a child
      final currentUser = UserContextService.getCurrentMember(widget.currentMemberId, widget.allMembers);
      if (currentUser?.role == MemberRole.child) {
        loadedPods = loadedPods.where((pod) => !_isPodParentOnly(pod)).toList();
      }

      setState(() {
        pods = loadedPods;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading pods: $e')),
        );
      }
    }
  }
  
  /// Check if a pod contains only parents (no children or caregivers)
  bool _isPodParentOnly(Pod pod) {
    if (pod.memberIds.isEmpty) return false;
    
    // Get all members in this pod
    final podMembers = widget.allMembers.where((m) => pod.memberIds.contains(m.id)).toList();
    
    // If all members are parents, it's a parent-only pod
    return podMembers.isNotEmpty && podMembers.every((m) => m.role == MemberRole.parent);
  }

  Future<void> _showCreatePodDialog() async {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    Set<String> selectedMembers = {};
    String selectedIcon = availableIcons[0];
    String selectedColor = availableColors[0];

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create Pod'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Pod Name',
                    hintText: 'e.g., "Adults Night", "Kids Only"',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    hintText: 'e.g., "Date night activities"',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                const Text('Icon:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: availableIcons.map((icon) {
                    return ChoiceChip(
                      label: Text(icon, style: const TextStyle(fontSize: 24)),
                      selected: selectedIcon == icon,
                      onSelected: (selected) {
                        if (selected) {
                          setDialogState(() => selectedIcon = icon);
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text('Color:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: availableColors.map((color) {
                    return ChoiceChip(
                      label: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Color(int.parse(color.substring(1), radix: 16) + 0xFF000000),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black12, width: 1),
                        ),
                      ),
                      selected: selectedColor == color,
                      onSelected: (selected) {
                        if (selected) {
                          setDialogState(() => selectedColor = color);
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text('Members:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ...widget.allMembers.map((member) {
                  final isSelected = selectedMembers.contains(member.id);
                  return CheckboxListTile(
                    title: Text(member.name),
                    subtitle: Text('${member.age} • ${member.role.name}'),
                    value: isSelected,
                    onChanged: (selected) {
                      setDialogState(() {
                        if (selected == true) {
                          selectedMembers.add(member.id!);
                        } else {
                          selectedMembers.remove(member.id);
                        }
                      });
                    },
                  );
                }),
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
                if (nameController.text.trim().isEmpty) {
                  return;
                }
                Navigator.pop(context, {
                  'name': nameController.text.trim(),
                  'description': descController.text.trim(),
                  'memberIds': selectedMembers.toList(),
                  'icon': selectedIcon,
                  'color': selectedColor,
                });
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      try {
        final supabase = Supabase.instance.client;
        await supabase.from('pods').insert({
          'household_id': widget.householdId,
          'name': result['name'],
          'description': result['description'],
          'member_ids': result['memberIds'],
          'icon': result['icon'],
          'color': result['color'],
        });

        await _loadPods();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Pod "${result['name']}" created!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating pod: $e')),
          );
        }
      }
    }
  }

  Future<void> _deletePod(Pod pod) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Pod'),
        content: Text('Delete "${pod.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: RedesignTokens.dangerColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final supabase = Supabase.instance.client;
        await supabase.from('pods').delete().eq('id', pod.id!);
        await _loadPods();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('"${pod.name}" deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting pod: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RedesignTokens.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: RedesignTokens.ink),
        ),
        title: Text(
          'Manage Pods',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: RedesignTokens.ink,
              ),
        ),
        actions: [
          IconButton(
            onPressed: _showCreatePodDialog,
            icon: const Icon(Icons.add, color: RedesignTokens.primary),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pods.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.group_add, size: 64, color: RedesignTokens.slate),
                      const SizedBox(height: 16),
                      Text(
                        'No pods yet',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: RedesignTokens.slate,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create pods to quickly select groups',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: RedesignTokens.slate,
                            ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _showCreatePodDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Create Your First Pod'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: pods.length,
                  itemBuilder: (context, index) {
                    final pod = pods[index];
                    final memberNames = widget.allMembers
                        .where((m) => pod.memberIds.contains(m.id))
                        .map((m) => m.name)
                        .join(', ');

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        onTap: () async {
                          final updatedPod = await Navigator.push<Pod>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PodDetailPage(
                                pod: pod,
                                allMembers: widget.allMembers,
                              ),
                            ),
                          );
                          // Reload if pod was updated
                          if (updatedPod != null) {
                            await _loadPods();
                          }
                        },
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Color(int.parse(pod.color.substring(1), radix: 16) + 0xFF000000),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              pod.icon,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                        title: Text(
                          pod.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (pod.description != null && pod.description!.isNotEmpty)
                              Text(pod.description!, style: const TextStyle(fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(
                              memberNames.isNotEmpty ? memberNames : 'No members',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: RedesignTokens.dangerColor),
                          onPressed: () => _deletePod(pod),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

