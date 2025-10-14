import 'package:merryway/modules/core/theme/redesign_tokens.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/family_models.dart';
import '../widgets/member_rules_widget.dart';

class MemberDetailPage extends StatefulWidget {
  final FamilyMember member;
  final String householdId;

  const MemberDetailPage({
    super.key,
    required this.member,
    required this.householdId,
  });

  @override
  State<MemberDetailPage> createState() => _MemberDetailPageState();
}

class _MemberDetailPageState extends State<MemberDetailPage> {
  late FamilyMember currentMember;

  @override
  void initState() {
    super.initState();
    currentMember = widget.member;
  }

  Future<String?> _uploadPhotoToStorage(String entityType, String entityId) async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile == null) return null;

    try {
      final supabase = Supabase.instance.client;
      final fileName = '${entityType}_${entityId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = 'media/$fileName';

      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        await supabase.storage.from('media').uploadBinary(
              filePath,
              bytes,
              fileOptions: const FileOptions(contentType: 'image/jpeg'),
            );
      } else {
        final file = File(pickedFile.path);
        await supabase.storage.from('media').upload(filePath, file);
      }

      final publicUrl = supabase.storage.from('media').getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  Future<void> _uploadMemberPhoto() async {
    if (currentMember.id == null) return;

    final photoUrl = await _uploadPhotoToStorage('member', currentMember.id!);
    if (photoUrl == null) return;

    try {
      final supabase = Supabase.instance.client;

      await supabase
          .from('family_members')
          .update({'photo_url': photoUrl})
          .eq('id', currentMember.id!);

      setState(() {
        currentMember = FamilyMember(
          id: currentMember.id,
          name: currentMember.name,
          age: currentMember.age,
          role: currentMember.role,
          favoriteActivities: currentMember.favoriteActivities,
          birthday: currentMember.birthday,
          userId: currentMember.userId,
          avatarEmoji: currentMember.avatarEmoji,
          pinRequired: currentMember.pinRequired,
          devicePin: currentMember.devicePin,
          photoUrl: photoUrl,
          createdAt: currentMember.createdAt,
        );
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✓ Photo updated!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating member: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showEditDialog() async {
    final nameController = TextEditingController(text: currentMember.name);
    final customActivityController = TextEditingController();
    int age = currentMember.age;
    String role = currentMember.role.name;
    DateTime? birthday = currentMember.birthday;
    List<String> selectedActivities = List<String>.from(currentMember.favoriteActivities);
    
    final availableActivities = [
      'outdoor',
      'crafts',
      'reading',
      'sports',
      'music',
      'games',
      'cooking',
      'art',
    ];

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit ${currentMember.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Age: $age', style: const TextStyle(fontWeight: FontWeight.w600)),
                Slider(
                  value: age.toDouble(),
                  min: 1,
                  max: 100,
                  divisions: 99,
                  label: age.toString(),
                  onChanged: (value) {
                    setDialogState(() {
                      age = value.toInt();
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Birthday picker
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        birthday == null 
                          ? 'Birthday: Not set' 
                          : 'Birthday: ${birthday!.month}/${birthday!.day}/${birthday!.year}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: birthday ?? DateTime.now().subtract(const Duration(days: 365 * 5)),
                          firstDate: DateTime(1920),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            birthday = picked;
                          });
                        }
                      },
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text(birthday == null ? 'Set' : 'Change'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Role:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['parent', 'child', 'caregiver'].map((r) {
                    return ChoiceChip(
                      label: Text(r.capitalize()),
                      selected: role == r,
                      onSelected: (selected) {
                        if (selected) {
                          setDialogState(() {
                            role = r;
                          });
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text('Favorite Activities:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ...availableActivities.map((activity) {
                      final isSelected = selectedActivities.contains(activity);
                      return FilterChip(
                        label: Text(activity.capitalize()),
                        selected: isSelected,
                        onSelected: (selected) {
                          setDialogState(() {
                            if (selected) {
                              selectedActivities.add(activity);
                            } else {
                              selectedActivities.remove(activity);
                            }
                          });
                        },
                      );
                    }),
                    // Show custom activities
                    ...selectedActivities
                        .where((a) => !availableActivities.contains(a))
                        .map((activity) => FilterChip(
                              label: Text(activity),
                              selected: true,
                              onSelected: (selected) {
                                setDialogState(() {
                                  selectedActivities.remove(activity);
                                });
                              },
                              deleteIcon: const Icon(Icons.close, size: 16),
                              onDeleted: () {
                                setDialogState(() {
                                  selectedActivities.remove(activity);
                                });
                              },
                            )),
                  ],
                ),
                const SizedBox(height: 12),
                // Custom activity input
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: customActivityController,
                        decoration: const InputDecoration(
                          labelText: 'Add custom activity',
                          hintText: 'e.g., "painting", "coding"',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        final custom = customActivityController.text.trim();
                        if (custom.isNotEmpty && !selectedActivities.contains(custom.toLowerCase())) {
                          setDialogState(() {
                            selectedActivities.add(custom.toLowerCase());
                            customActivityController.clear();
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      child: const Icon(Icons.add, size: 20),
                    ),
                  ],
                ),
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
                  'age': age,
                  'role': role,
                  'activities': selectedActivities,
                  'birthday': birthday,
                });
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );

    if (result != null && currentMember.id != null) {
      try {
        final supabase = Supabase.instance.client;
        final updateData = {
          'name': result['name'],
          'age': result['age'],
          'role': result['role'],
          'favorite_activities': result['activities'],
        };
        if (result['birthday'] != null) {
          updateData['birthday'] = (result['birthday'] as DateTime).toIso8601String().split('T')[0];
        }
        await supabase.from('family_members').update(updateData).eq('id', currentMember.id!);

        // Update local state
        setState(() {
          currentMember = FamilyMember(
            id: currentMember.id,
            name: result['name'],
            age: result['age'],
            role: MemberRole.values.firstWhere((r) => r.name == result['role']),
            favoriteActivities: result['activities'],
            birthday: result['birthday'],
            avatarEmoji: currentMember.avatarEmoji,
            pinRequired: currentMember.pinRequired,
            devicePin: currentMember.devicePin,
            userId: currentMember.userId,
            photoUrl: currentMember.photoUrl,
            createdAt: currentMember.createdAt,
          );
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${result['name']} updated!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating member: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MerryWayTheme.softBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context, currentMember),
          icon: const Icon(Icons.arrow_back, color: RedesignTokens.ink),
        ),
        title: Text(
          currentMember.name,
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
            // Member Avatar and Info
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: RedesignTokens.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(24),
                      image: currentMember.photoUrl != null
                          ? DecorationImage(
                              image: NetworkImage(currentMember.photoUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: currentMember.photoUrl == null
                        ? Center(
                            child: Text(
                              currentMember.avatarEmoji ?? currentMember.name[0],
                              style: const TextStyle(fontSize: 48),
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Material(
                      color: RedesignTokens.primary,
                      elevation: 2,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: _uploadMemberPhoto,
                        borderRadius: BorderRadius.circular(12),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Basic Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Basic Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Age', '${currentMember.age} years old'),
                    _buildInfoRow('Role', currentMember.role.name.capitalize()),
                    if (currentMember.birthday != null)
                      _buildInfoRow(
                        'Birthday',
                        '${currentMember.birthday!.month}/${currentMember.birthday!.day}/${currentMember.birthday!.year}',
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Favorite Activities Card
            if (currentMember.favoriteActivities.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Favorite Activities',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: currentMember.favoriteActivities
                            .map((activity) => Chip(
                                  label: Text(activity.capitalize()),
                                  backgroundColor: RedesignTokens.primary.withOpacity(0.1),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Member Rules Widget
            MemberRulesWidget(
              member: currentMember,
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: RedesignTokens.slate,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

extension on String {
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';
}

