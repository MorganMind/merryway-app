import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import '../../family/blocs/family_bloc.dart';
import '../../family/models/family_models.dart';
import '../../family/services/default_pod_service.dart';
import '../../core/theme/merryway_theme.dart';
import '../../core/theme/redesign_tokens.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int currentStep = 0;
  late PageController pageController;

  // Household step
  final householdNameController = TextEditingController();

  // Member step
  List<MemberData> members = [];

  // Pre-populated activity list for selection
  static const activityOptions = [
    'Reading',
    'Cooking',
    'Sports',
    'Arts & Crafts',
    'Gardening',
    'Music',
    'Outdoor Adventures',
    'Board Games',
    'Movies',
    'Hiking',
    'Dancing',
    'Baking',
    'Video Games',
    'Puzzles',
    'Nature Walks',
    'Swimming',
    'Biking',
    'Singing',
    'Photography',
    'Building'
  ];

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    householdNameController.dispose();
    pageController.dispose();
    super.dispose();
  }

  void _addMember() {
    setState(() {
      members.add(MemberData());
    });
  }

  void _removeMember(int index) {
    setState(() {
      members.removeAt(index);
    });
  }

  void _submitOnboarding(BuildContext context) {
    if (householdNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Every household needs a name! ✨'),
          backgroundColor: RedesignTokens.primary,
        ),
      );
      return;
    }

    if (members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Let\'s add at least one wonderful family member! 💕'),
          backgroundColor: RedesignTokens.primary,
        ),
      );
      return;
    }

    // Validate all members have names
    for (var member in members) {
      if (member.name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Every family member needs a name! 🌟'),
            backgroundColor: RedesignTokens.primary,
          ),
        );
        return;
      }
    }

    // Create household
    context.read<FamilyBloc>().add(
          CreateHouseholdEvent(householdNameController.text),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RedesignTokens.canvas,
      body: BlocListener<FamilyBloc, FamilyState>(
        listener: (context, state) async {
          if (state is HouseholdCreated) {
            try {
              final supabase = Supabase.instance.client;
              final userId = supabase.auth.currentUser!.id;

              // Check if household already exists
              final existingHouseholds = await supabase
                  .from('households')
                  .select()
                  .eq('user_id', userId)
                  .order('created_at', ascending: false)
                  .limit(1);

              String householdId;
              final name = householdNameController.text.trim();

              if (existingHouseholds.isNotEmpty) {
                // Use existing household
                householdId = existingHouseholds.first['id'] as String;
              } else {
                // Create new household
                final householdData = await supabase
                    .from('households')
                    .insert({
                      'user_id': userId,
                      'name': name,
                    })
                    .select()
                    .single();

                householdId = householdData['id'] as String;
              }

              // Save family members to Supabase
              final membersToInsert = members.map((member) => {
                'household_id': householdId,
                'name': member.name,
                'age': member.age,
                'role': member.role.name,
                'favorite_activities': member.selectedActivities,
              }).toList();

              List<String> createdMemberIds = [];
              if (membersToInsert.isNotEmpty) {
                final insertedMembers = await supabase
                    .from('family_members')
                    .insert(membersToInsert)
                    .select();
                createdMemberIds = insertedMembers.map((m) => m['id'] as String).toList();
              }

              // Create default "Just Me" pod for the user
              await DefaultPodService.ensureDefaultPodExists(householdId);

              // Cache household ID in local storage for quick access
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('household_id', householdId);
              await prefs.setString('household_name', name);

              // Show success message
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Welcome to Merryway, $name! 🏡✨',
                    ),
                    backgroundColor: RedesignTokens.accentGold,
                    duration: const Duration(seconds: 2),
                  ),
                );

                // Navigate to home after brief delay
                Future.delayed(const Duration(milliseconds: 800), () {
                  if (mounted) {
                    context.go('/home');
                  }
                });
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error saving to Supabase: $e'),
                    backgroundColor: Colors.red[400],
                  ),
                );
              }
            }
          } else if (state is FamilyError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Oh dear! ${state.message}'),
                backgroundColor: Colors.red[400],
              ),
            );
          }
        },
        child: SafeArea(
          child: PageView(
            controller: pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildHouseholdStep(context),
              _buildMembersStep(context),
              _buildSummaryStep(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHouseholdStep(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Magic flourish (decorative element)
          Text(
            '✨',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: 24),
          Text(
            'Welcome to Merryway',
            style: Theme.of(context).textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Your family\'s personal guide to making the most of your time together.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: MerryWayTheme.textMuted,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          TextField(
            controller: householdNameController,
            decoration: const InputDecoration(
              hintText: 'What should we call your family?',
              hintStyle: TextStyle(color: Color(0xFFCCCCCC)),
              prefixIcon: Icon(Icons.home_rounded, color: MerryWayTheme.primarySoftBlue),
            ),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          // Helpful suggestions
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            children: [
              'The Smith Family',
              'Casa Chaos',
              'Our Happy Home',
            ].map((suggestion) {
              return ActionChip(
                label: Text(suggestion),
                onPressed: () {
                  householdNameController.text = suggestion;
                },
                backgroundColor: RedesignTokens.accentSage.withOpacity(0.2),
                labelStyle: const TextStyle(
                  fontSize: 12,
                  color: MerryWayTheme.textDark,
                ),
              );
            }).toList(),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (householdNameController.text.isNotEmpty) {
                  pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Every family needs a name! ✨'),
                      backgroundColor: RedesignTokens.primary,
                    ),
                  );
                }
              },
              child: const Text('Next'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMembersStep(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Text(
            'Who\'s in the family?',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Tell us about the wonderful people who make your home special',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: MerryWayTheme.textMuted,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: members.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline_rounded,
                          size: 80,
                          color: MerryWayTheme.primarySoftBlue.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No family members yet',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the button below to add someone special! 💫',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: MerryWayTheme.textMuted,
                              ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      return _buildMemberCard(context, index);
                    },
                  ),
          ),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _addMember,
              icon: const Icon(Icons.add),
              label: const Text('Add Family Member'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: MerryWayTheme.primarySoftBlue, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: members.isNotEmpty
                      ? () {
                          pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
                  child: const Text('Next'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMemberCard(BuildContext context, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        members[index].name = value;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'Name',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                IconButton(
                  onPressed: () => _removeMember(index),
                  icon: const Icon(Icons.close, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: members[index].age,
                    decoration: const InputDecoration(
                      labelText: 'Age',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: List.generate(
                      100,
                      (i) =>
                          DropdownMenuItem(value: i + 1, child: Text('${i + 1} years')),
                    ),
                    onChanged: (value) {
                      setState(() {
                        members[index].age = value ?? 5;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<MemberRole>(
                    value: members[index].role,
                    decoration: const InputDecoration(
                      labelText: 'Role',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: MemberRole.values
                        .map((role) => DropdownMenuItem(
                              value: role,
                              child: Text(_capitalize(role.name)),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        members[index].role = value ?? MemberRole.child;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Favorite activities:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: activityOptions.map((activity) {
                bool isSelected = members[index].selectedActivities.contains(activity);
                return FilterChip(
                  label: Text(activity),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        members[index].selectedActivities.add(activity);
                      } else {
                        members[index].selectedActivities.remove(activity);
                      }
                    });
                  },
                  selectedColor: RedesignTokens.accentSage.withOpacity(0.3),
                  checkmarkColor: MerryWayTheme.primarySoftBlue,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStep(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Text(
            '🎉',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: 16),
          Text(
            'Ready to begin?',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Here\'s your beautiful family',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: MerryWayTheme.textMuted,
                ),
          ),
          const SizedBox(height: 32),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.home_rounded, color: MerryWayTheme.primarySoftBlue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          householdNameController.text,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  ...members.map((member) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: MerryWayTheme.primarySoftBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.person,
                                size: 20,
                                color: MerryWayTheme.primarySoftBlue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    member.name,
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  Text(
                                    '${member.age} years • ${_capitalize(member.role.name)}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: MerryWayTheme.textMuted,
                                        ),
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
          const Spacer(),
          BlocBuilder<FamilyBloc, FamilyState>(
            builder: (context, state) {
              if (state is FamilyLoading) {
                return const CircularProgressIndicator();
              }
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _submitOnboarding(context),
                  child: const Text('Create Your Family ✨'),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
              pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: const Text('Back'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}

class MemberData {
  String name = '';
  int age = 5;
  MemberRole role = MemberRole.child;
  List<String> selectedActivities = [];
}
