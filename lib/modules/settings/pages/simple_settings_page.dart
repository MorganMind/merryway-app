import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../../core/theme/merryway_theme.dart';
import '../../core/theme/redesign_tokens.dart';
import '../../home/widgets/compact_header.dart';
import '../../family/models/family_models.dart';
import '../../family/blocs/family_bloc.dart';
import '../../family/pages/pods_management_page.dart';
import '../../family/pages/locations_management_page.dart';
import '../../family/pages/member_detail_page.dart';
import '../../family/pages/family_health_dashboard_page.dart';
import '../../family/services/default_pod_service.dart';
import '../../auth/services/user_context_service.dart';
import '../../auth/widgets/user_switcher.dart';

class SimpleSettingsPage extends StatefulWidget {
  const SimpleSettingsPage({super.key});

  @override
  State<SimpleSettingsPage> createState() => _SimpleSettingsPageState();
}

class _SimpleSettingsPageState extends State<SimpleSettingsPage> {
  String? householdId;
  String? householdName;
  String? householdPhotoUrl;
  String? userEmail;
  String? currentMemberId;
  List<FamilyMember> familyMembers = [];
  List<Map<String, dynamic>> allHouseholds = [];
  bool familyModeEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  Future<void> _loadInfo() async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    
    try {
      // Load ALL households from Supabase
      final householdList = await supabase
          .from('households')
          .select()
          .eq('user_id', userId!)
          .order('created_at', ascending: false);
      
      setState(() {
        allHouseholds = List<Map<String, dynamic>>.from(householdList);
        userEmail = supabase.auth.currentUser?.email ?? 'Not signed in';
      });

      // Load current household (most recent) with members
      final householdData = householdList.isNotEmpty ? householdList.first : null;

      if (householdData != null) {
        // Load family members from Supabase
        final membersData = await supabase
            .from('family_members')
            .select()
            .eq('household_id', householdData['id'])
            .order('created_at');

        // Load current member ID from UserContextService
        final loadedCurrentMemberId = await UserContextService.getSelectedMemberId();

        setState(() {
          householdId = householdData['id'];
          householdName = householdData['name'];
          householdPhotoUrl = householdData['photo_url'];
          familyModeEnabled = householdData['family_mode_enabled'] ?? false;
          currentMemberId = loadedCurrentMemberId;
          
          familyMembers = (membersData as List<dynamic>).map((m) {
            return FamilyMember.fromJson(m);
          }).toList();
        });
      } else {
        setState(() {
          householdName = 'No household yet';
          familyMembers = [];
        });
      }
    } catch (e) {
      print('Error loading from Supabase: $e');
      setState(() {
        userEmail = supabase.auth.currentUser?.email ?? 'Not signed in';
        householdName = 'Error loading';
        familyMembers = [];
      });
    }
  }

  Future<void> _toggleFamilyMode(bool value) async {
    if (householdId == null) return;

    try {
      final supabase = Supabase.instance.client;
      await supabase
          .from('households')
          .update({'family_mode_enabled': value})
          .eq('id', householdId!);

      setState(() {
        familyModeEnabled = value;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(value
                ? '✓ Family Mode enabled! User switcher will appear on home screen.'
                : '✓ Family Mode disabled. User switcher hidden.'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating Family Mode: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String?> _uploadPhotoToStorage(String prefix, String id) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image == null) return null;

      final supabase = Supabase.instance.client;
      final Uint8List bytes = await image.readAsBytes();
      final fileName = '${prefix}_${id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '${prefix}_photos/$fileName';

      // Upload to Supabase Storage using Uint8List for web compatibility
      await supabase.storage.from('media').uploadBinary(
        filePath,
        bytes,
        fileOptions: const FileOptions(
          upsert: true,
          contentType: 'image/jpeg',
        ),
      );

      // Get public URL
      final photoUrl = supabase.storage.from('media').getPublicUrl(filePath);
      return photoUrl;
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

  Future<void> _uploadFamilyPhoto() async {
    if (householdId == null) return;

    final photoUrl = await _uploadPhotoToStorage('household', householdId!);
    if (photoUrl == null) return;

    try {
      final supabase = Supabase.instance.client;

      // Update household with photo URL
      await supabase
          .from('households')
          .update({'photo_url': photoUrl})
          .eq('id', householdId!);

      setState(() {
        householdPhotoUrl = photoUrl;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✓ Family photo updated!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating household: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadMemberPhoto(FamilyMember member) async {
    if (member.id == null) return;

    final photoUrl = await _uploadPhotoToStorage('member', member.id!);
    if (photoUrl == null) return;

    try {
      final supabase = Supabase.instance.client;

      // Update member with photo URL
      await supabase
          .from('household_members')
          .update({'photo_url': photoUrl})
          .eq('id', member.id!);

      // Reload data to reflect the change
      await _loadInfo();

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

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
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
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await Supabase.instance.client.auth.signOut();
      if (mounted) {
        context.go('/login');
      }
    }
  }

  Future<void> _clearData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Local Data'),
        content: const Text(
          'This will clear your household and member data from this device. You can recreate it by going through onboarding again.',
        ),
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
            child: const Text('Clear Data'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('household_id');
      await prefs.remove('household_name');
      await prefs.remove('family_members');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data cleared! Redirecting to onboarding...')),
        );
        context.go('/onboarding');
      }
    }
  }

  Future<void> _showAddMemberDialog() async {
    final nameController = TextEditingController();
    final customActivityController = TextEditingController();
    int age = 5;
    String role = 'child';
    DateTime? birthday;
    List<String> selectedActivities = [];
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
          title: const Text('Add Family Member'),
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
                    Text(
                      birthday == null 
                        ? 'Birthday: Not set' 
                        : 'Birthday: ${birthday!.month}/${birthday!.day}/${birthday!.year}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
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
              child: const Text('Add Member'),
            ),
          ],
        ),
      ),
    );

    if (result != null && householdId != null) {
      try {
        // Add member to Supabase
        final supabase = Supabase.instance.client;
        final insertData = {
          'household_id': householdId!,
          'name': result['name'],
          'age': result['age'],
          'role': result['role'],
          'favorite_activities': result['activities'],
        };
        if (result['birthday'] != null) {
          insertData['birthday'] = (result['birthday'] as DateTime).toIso8601String().split('T')[0];
        }
        await supabase.from('family_members').insert(insertData);

        // Reload data
        await _loadInfo();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${result['name']} added!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding member: $e')),
          );
        }
      }
    }
  }

  Future<void> _editMember(FamilyMember member) async {
    final nameController = TextEditingController(text: member.name);
    final customActivityController = TextEditingController();
    int age = member.age;
    String role = member.role.name;
    DateTime? birthday = member.birthday;
    List<String> selectedActivities = List<String>.from(member.favoriteActivities);
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
          title: Text('Edit ${member.name}'),
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
                    Text(
                      birthday == null 
                        ? 'Birthday: Not set' 
                        : 'Birthday: ${birthday!.month}/${birthday!.day}/${birthday!.year}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
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

    if (result != null && householdId != null) {
      try {
        // Update member in Supabase
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
        await supabase.from('family_members').update(updateData).eq('id', member.id!);

        // Reload data
        await _loadInfo();

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

  Future<void> _removeMember(FamilyMember member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Member'),
        content: Text('Remove ${member.name} from your household?'),
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
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Remove from Supabase
        final supabase = Supabase.instance.client;
        await supabase.from('family_members').delete().eq('id', member.id!);

        // Reload data
        await _loadInfo();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${member.name} removed')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error removing member: $e')),
          );
        }
      }
    }
  }

  Future<void> _linkMemberToCurrentUser(FamilyMember member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Link Your Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Link "${member.name}" to your account?'),
            const SizedBox(height: 12),
            const Text(
              'This will:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('• Automatically log you in as ${member.name}'),
            const Text('• Track your votes and activity'),
            const Text('• Personalize suggestions for you'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Link Account'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final supabase = Supabase.instance.client;
        final currentUserId = supabase.auth.currentUser?.id;

        if (currentUserId == null) {
          throw 'Not authenticated';
        }

        // Update member with user_id
        await supabase
            .from('family_members')
            .update({'user_id': currentUserId})
            .eq('id', member.id!);

        // Add this member to the "Just Me" pod
        if (householdId != null) {
          await DefaultPodService.addCurrentUserToDefaultPod(
            householdId: householdId!,
            memberId: member.id!,
          );
        }

        // Reload data
        await _loadInfo();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✓ Linked! You are now "${member.name}"'),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error linking account: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _setPinForMember(FamilyMember member) async {
    final pinController = TextEditingController(text: member.devicePin ?? '');
    bool requirePin = member.pinRequired;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('${member.pinRequired ? 'Update' : 'Set'} PIN'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Set a PIN for ${member.name}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pinController,
                decoration: const InputDecoration(
                  labelText: 'PIN (6 digits)',
                  hintText: '123456',
                  helperText: 'Leave empty to remove PIN',
                ),
                keyboardType: TextInputType.number,
                maxLength: 6,
                obscureText: true,
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                title: const Text('Require PIN to switch to this account'),
                subtitle: const Text('Others will need to enter PIN to use your profile'),
                value: requirePin,
                onChanged: (value) {
                  setDialogState(() {
                    requirePin = value ?? false;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save PIN'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      try {
        final supabase = Supabase.instance.client;
        final pin = pinController.text.trim();

        // Validate PIN if provided
        if (pin.isNotEmpty && (pin.length != 6 || int.tryParse(pin) == null)) {
          throw 'PIN must be exactly 6 digits';
        }

        // Update member
        await supabase
            .from('family_members')
            .update({
              'device_pin': pin.isEmpty ? null : pin,
              'pin_required': pin.isEmpty ? false : requirePin,
            })
            .eq('id', member.id!);

        // Reload data
        await _loadInfo();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                pin.isEmpty 
                    ? '✓ PIN removed' 
                    : '✓ PIN ${member.pinRequired ? 'updated' : 'set'}!',
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error setting PIN: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteHousehold(String householdIdToDelete, String householdNameToDelete) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Family'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Delete "$householdNameToDelete"?'),
            const SizedBox(height: 12),
            const Text(
              'This will permanently delete:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text('• All family members'),
            const Text('• All pods'),
            const Text('• All locations'),
            const Text('• All votes'),
            const SizedBox(height: 12),
            const Text(
              'This action cannot be undone.',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete Family'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final supabase = Supabase.instance.client;

        // Delete all associated data
        // RLS policies should handle cascading, but we'll be explicit
        await supabase.from('idea_votes').delete().eq('household_id', householdIdToDelete);
        await supabase.from('pods').delete().eq('household_id', householdIdToDelete);
        await supabase.from('locations').delete().eq('household_id', householdIdToDelete);
        await supabase.from('family_members').delete().eq('household_id', householdIdToDelete);
        await supabase.from('households').delete().eq('id', householdIdToDelete);

        // Clear local cache if this was the current household
        if (householdIdToDelete == householdId) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('household_id');
          await prefs.remove('household_name');
          await prefs.remove('family_members');
        }

        // Reload data
        await _loadInfo();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('"$householdNameToDelete" deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting family: $e')),
          );
        }
      }
    }
  }

  Future<void> _switchHousehold(String newHouseholdId, String newHouseholdName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('household_id', newHouseholdId);
    await prefs.setString('household_name', newHouseholdName);

    // Reload data
    await _loadInfo();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Switched to "$newHouseholdName"')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RedesignTokens.canvas,
      body: Column(
        children: [
          // Compact Header
          CompactHeader(
            isIdeasActive: false,
            isPlannerActive: false,
            isMomentsActive: false,
            onIdeas: () => context.go('/'),
            onPlanner: () {
              if (householdId != null) {
                context.push('/plans', extra: {
                  'householdId': householdId,
                });
              }
            },
            onTime: () {
              if (householdId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FamilyHealthDashboardPage(
                      householdId: householdId!,
                    ),
                  ),
                );
              }
            },
            onMoments: () {
              if (householdId != null && familyMembers.isNotEmpty) {
                context.push('/moments', extra: {
                  'householdId': householdId!,
                  'allMembers': familyMembers,
                });
              }
            },
            onSettings: () {
              // Already on settings page
            },
            onHelp: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Help coming soon!')),
              );
            },
            onLogout: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
              
              if (confirmed == true && context.mounted) {
                await Supabase.instance.client.auth.signOut();
                if (context.mounted) {
                  context.go('/login');
                }
              }
            },
            userSwitcher: familyModeEnabled && familyMembers.isNotEmpty
                ? UserSwitcher(
                    members: familyMembers,
                    currentUser: UserContextService.getCurrentMember(
                      currentMemberId,
                      familyMembers,
                    ),
                    onUserSelected: (member) async {
                      await UserContextService.setSelectedMember(member.id!);
                      setState(() {
                        currentMemberId = member.id;
                      });
                    },
                  )
                : null,
          ),
          
          // Content
          Expanded(
            child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // Account Section
              _buildSectionHeader(context, 'Account'),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: RedesignTokens.primary,
                        child: Text(
                          (userEmail?[0] ?? '?').toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: const Text('Email'),
                      subtitle: Text(userEmail ?? 'Not signed in'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: householdPhotoUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(14), // More rounded square
                              child: Image.network(
                                householdPhotoUrl!,
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(Icons.home, color: RedesignTokens.primary),
                      title: Text(
                        householdName ?? 'Your Family',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: RedesignTokens.ink,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      subtitle: const Text('Household Name'),
                      trailing: IconButton(
                        onPressed: _uploadFamilyPhoto,
                        icon: const Icon(Icons.add_a_photo),
                        tooltip: 'Upload family photo',
                        color: RedesignTokens.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Family Mode Section
              _buildSectionHeader(context, 'Family Mode'),
              const SizedBox(height: 12),
              Card(
                child: SwitchListTile(
                  secondary: Icon(
                    familyModeEnabled ? Icons.people : Icons.person,
                    color: familyModeEnabled 
                        ? RedesignTokens.primary 
                        : RedesignTokens.mutedText,
                  ),
                  title: Text(
                    familyModeEnabled ? 'Family Mode Enabled' : 'Family Mode Disabled',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    familyModeEnabled
                        ? 'User switcher is shown on home screen. Perfect for shared devices!'
                        : 'Enable to show a Netflix-style user switcher for family members on shared devices.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: RedesignTokens.mutedText,
                    ),
                  ),
                  value: familyModeEnabled,
                  onChanged: _toggleFamilyMode,
                  activeColor: RedesignTokens.primary,
                ),
              ),
              const SizedBox(height: 32),

              // All Families Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionHeader(context, 'All Families (${allHouseholds.length})'),
                ],
              ),
              const SizedBox(height: 12),
              
              if (allHouseholds.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(
                            Icons.home_outlined,
                            size: 48,
                            color: RedesignTokens.mutedText,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No families yet',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: RedesignTokens.mutedText,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                ...allHouseholds.map((household) {
                  final isCurrentHousehold = household['id'] == householdId;
                  final createdAt = household['created_at'] != null
                      ? DateTime.parse(household['created_at'])
                      : null;
                  final dateStr = createdAt != null
                      ? '${createdAt.month}/${createdAt.day}/${createdAt.year}'
                      : 'Unknown date';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: isCurrentHousehold
                        ? RedesignTokens.primary.withOpacity(0.1)
                        : null,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isCurrentHousehold
                            ? RedesignTokens.primary
                            : RedesignTokens.mutedText,
                        child: Icon(
                          Icons.home,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              household['name'],
                              style: TextStyle(
                                fontWeight: isCurrentHousehold
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                          if (isCurrentHousehold)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: RedesignTokens.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'ACTIVE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      subtitle: Text('Created: $dateStr'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isCurrentHousehold)
                            IconButton(
                              icon: const Icon(Icons.swap_horiz, size: 20),
                              onPressed: () => _switchHousehold(
                                household['id'],
                                household['name'],
                              ),
                              tooltip: 'Switch to this family',
                              color: RedesignTokens.primary,
                            ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20),
                            onPressed: () => _deleteHousehold(
                              household['id'],
                              household['name'],
                            ),
                            tooltip: 'Delete family',
                            color: RedesignTokens.dangerColor,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 32),

              // Family Members Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionHeader(context, 'Family Members (${familyMembers.length})'),
                  ElevatedButton.icon(
                    onPressed: _showAddMemberDialog,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      backgroundColor: RedesignTokens.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              if (familyMembers.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(
                            Icons.people_outline,
                            size: 48,
                            color: RedesignTokens.mutedText,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No family members yet',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: RedesignTokens.mutedText,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap "Add" to add your first member',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: RedesignTokens.mutedText,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              
              ...familyMembers.map((member) {
                final currentUserId = Supabase.instance.client.auth.currentUser?.id;
                final isLinkedToCurrentUser = member.userId == currentUserId;
                
                return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  onTap: () async {
                    if (householdId != null) {
                      final updatedMember = await Navigator.push<FamilyMember>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MemberDetailPage(
                            member: member,
                            householdId: householdId!,
                          ),
                        ),
                      );
                      // Reload if member was updated
                      if (updatedMember != null) {
                        await _loadInfo();
                      }
                    }
                  },
                  leading: CircleAvatar(
                    backgroundColor: member.role == MemberRole.parent
                        ? RedesignTokens.primary
                        : RedesignTokens.accentGold,
                    backgroundImage: member.photoUrl != null 
                        ? NetworkImage(member.photoUrl!) 
                        : null,
                    child: member.photoUrl == null
                        ? Text(
                            member.avatarEmoji ?? member.name.substring(0, 1).toUpperCase(),
                            style: TextStyle(
                              color: member.avatarEmoji != null ? null : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: member.avatarEmoji != null ? 20 : null,
                            ),
                          )
                        : null,
                  ),
                  title: Row(
                    children: [
                      Text(
                        member.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      if (isLinkedToCurrentUser) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: RedesignTokens.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'YOU',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      if (member.pinRequired) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.lock_outline, size: 14, color: RedesignTokens.mutedText),
                      ],
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Age: ${member.age} • ${member.role.name.capitalize()}'),
                      if (member.favoriteActivities.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Wrap(
                            spacing: 4,
                            children: member.favoriteActivities.take(3).map((activity) {
                              return Chip(
                                label: Text(
                                  activity,
                                  style: const TextStyle(fontSize: 10),
                                ),
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // "This is me" button if not linked
                      if (!isLinkedToCurrentUser && member.userId == null)
                        IconButton(
                          icon: const Icon(Icons.person_add_outlined, color: RedesignTokens.primary),
                          onPressed: () => _linkMemberToCurrentUser(member),
                          tooltip: 'This is me',
                        ),
                      
                      // Set PIN button (only if linked to current user)
                      if (isLinkedToCurrentUser)
                        IconButton(
                          icon: Icon(
                            member.pinRequired ? Icons.lock : Icons.lock_open_outlined,
                            color: RedesignTokens.accentGold,
                          ),
                          onPressed: () => _setPinForMember(member),
                          tooltip: member.pinRequired ? 'Update PIN' : 'Set PIN',
                        ),
                      
                      // Upload photo button
                      IconButton(
                        icon: Icon(
                          member.photoUrl != null ? Icons.photo_camera : Icons.add_a_photo_outlined,
                          color: RedesignTokens.mutedText,
                        ),
                        onPressed: () => _uploadMemberPhoto(member),
                        tooltip: 'Add photo',
                      ),
                      
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: RedesignTokens.primary),
                        onPressed: () => _editMember(member),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: RedesignTokens.dangerColor),
                        onPressed: () => _removeMember(member),
                      ),
                    ],
                  ),
                ),
              );
              }),
              const SizedBox(height: 32),

            // Pods Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionHeader(context, 'Pods'),
                ElevatedButton.icon(
                  onPressed: () {
                    if (householdId != null && familyMembers.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PodsManagementPage(
                            householdId: householdId!,
                            allMembers: familyMembers,
                            currentMemberId: currentMemberId,
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.group_add, size: 18),
                  label: const Text('Manage'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    backgroundColor: RedesignTokens.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.people_outline, color: RedesignTokens.primary),
                title: const Text('Family Pods'),
                subtitle: const Text('Create quick-select groups like "Date Night" or "Kids Only"'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  if (householdId != null && familyMembers.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PodsManagementPage(
                          householdId: householdId!,
                          allMembers: familyMembers,
                          currentMemberId: currentMemberId,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 32),

            // Locations Section (NEW)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionHeader(context, 'Locations'),
                ElevatedButton.icon(
                  onPressed: () {
                    if (householdId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LocationsManagementPage(
                            householdId: householdId!,
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.location_on, size: 18),
                  label: const Text('Manage'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    backgroundColor: RedesignTokens.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.map, color: RedesignTokens.primary),
                title: const Text('Saved Locations'),
                subtitle: const Text('Add places like "Home", "School", "Work" to reference in prompts'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  if (householdId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LocationsManagementPage(
                          householdId: householdId!,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 32),

            // Family Health Section
            _buildSectionHeader(context, 'Family Trails'),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.explore_outlined, color: RedesignTokens.primary),
                    title: const Text('Family Trails'),
                    subtitle: const Text('View your progress, streaks, achievements & milestones'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      if (householdId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FamilyHealthDashboardPage(
                              householdId: householdId!,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.celebration, color: RedesignTokens.primary),
                    title: const Text('Moments'),
                    subtitle: const Text('View planned and completed family activities'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      if (householdId != null && familyMembers.isNotEmpty) {
                        context.push(
                          '/moments',
                          extra: {
                            'householdId': householdId!,
                            'allMembers': familyMembers,
                          },
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Data Section
            _buildSectionHeader(context, 'Data'),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.refresh, color: RedesignTokens.accentGold),
                    title: const Text('Re-do Onboarding'),
                    subtitle: const Text('Start fresh with household setup'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      context.go('/onboarding');
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.delete_outline, color: RedesignTokens.dangerColor),
                    title: const Text('Clear Local Data'),
                    subtitle: const Text('Remove household and members from this device'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _clearData,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Actions
            _buildSectionHeader(context, 'Actions'),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.logout, color: RedesignTokens.dangerColor),
                title: const Text('Sign Out'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _handleLogout,
              ),
            ),
            const SizedBox(height: 32),

            // App Info
            Center(
              child: Column(
                children: [
                  Text(
                    'Merryway',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: RedesignTokens.mutedText,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Made with ❤️ by Onyx Company',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: RedesignTokens.mutedText,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text('✨', style: TextStyle(fontSize: 24)),
                ],
              ),
            ),
          ],
        ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        isIdeasActive: false,
        isMomentsActive: false,
        isPlannerActive: false,
        isTimeActive: false,
        onIdeas: () => context.go('/'),
        onMoments: () {
          if (householdId != null && familyMembers.isNotEmpty) {
            context.push('/moments', extra: {
              'householdId': householdId!,
              'allMembers': familyMembers,
            });
          }
        },
        onPlanner: () {
          if (householdId != null) {
            context.push('/plans', extra: {
              'householdId': householdId,
            });
          }
        },
        onTime: () {
          if (householdId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FamilyHealthDashboardPage(
                  householdId: householdId!,
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: RedesignTokens.mutedText,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
    );
  }
}

extension StringExtension on String {
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';
}

