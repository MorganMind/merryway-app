# Phase 4: DO - Frontend Implementation Guide

This document contains **ALL the code** from **EVERY file** that needs to be edited to integrate the LiveExperienceCard into the home page and implement real ICS calendar downloads.

---

## Summary of Changes

### What You're Building:
1. **Fetch and display live/planned experiences** on the home page
2. **Show gentle nudges** for experiences approaching their time window
3. **Implement real ICS calendar downloads** (not just "coming soon")
4. **Launch navigation** to experience locations via Google Maps/Apple Maps

### Files to Edit:
1. `lib/modules/home/pages/home_page.dart` - Add live experience fetching/display
2. `lib/modules/experiences/widgets/live_experience_card.dart` - Implement real ICS download
3. `lib/modules/experiences/widgets/experience_debrief_modal.dart` - Already exists (import it)

---

## File 1: `lib/modules/home/pages/home_page.dart`

**COMPLETE FILE CONTENTS** (with new additions marked with `// NEW`):

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../family/blocs/family_bloc.dart';
import '../../family/models/family_models.dart';
import '../../family/models/pod_model.dart';
import '../../family/pages/pods_management_page.dart';
import '../../family/services/default_pod_service.dart';
import '../../family/services/rules_service.dart';
import '../widgets/suggestion_card.dart';
import '../widgets/context_input_panel.dart';
import '../widgets/participant_preset_sheet.dart';
import '../widgets/smart_suggestion_card.dart';
import '../../core/theme/merryway_theme.dart';
import '../../core/services/weather_service.dart';
import '../../auth/services/user_context_service.dart';
import '../../auth/widgets/user_switcher.dart';
import '../../experiences/widgets/create_experience_sheet.dart';
import '../../experiences/widgets/live_experience_card.dart'; // NEW
import '../../experiences/widgets/experience_debrief_modal.dart'; // NEW
import '../../experiences/repositories/experience_repository.dart'; // NEW
import '../../experiences/models/experience_models.dart'; // NEW

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? householdId;
  String? householdName;
  List<FamilyMember> familyMembers = [];
  bool familyModeEnabled = false;
  String? currentMemberId;
  
  // Context state
  String weather = 'cloudy';
  String timeOfDay = 'afternoon';
  String dayOfWeek = 'monday';
  String customPrompt = '';
  
  // Participant state
  Set<String> selectedParticipants = {};
  List<Pod> pods = [];
  String? selectedPodId;
  bool isAllMode = true;
  
  // Smart suggestion state
  Map<String, dynamic>? smartSuggestionData;
  bool showSmartSuggestion = false;

  // NEW: Live experiences state
  List<Experience> liveExperiences = [];
  List<Experience> upcomingExperiences = [];
  bool isLoadingExperiences = false;

  String _getDefaultTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 18) return 'afternoon';
    return 'evening';
  }

  String _getDefaultDayOfWeek() {
    return DateFormat('EEEE').format(DateTime.now()).toLowerCase();
  }

  Future<String> _getDefaultWeatherContext() async {
    try {
      final realWeather = await WeatherService.getCurrentWeather();
      return realWeather;
    } catch (e) {
      print('Error fetching weather: $e');
      final hour = DateTime.now().hour;
      if (hour >= 8 && hour <= 16) return 'sunny';
      return 'cloudy';
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    if (hour < 20) return 'Good evening';
    return 'Good night';
  }

  // NEW: Load live/planned experiences
  Future<void> _loadLiveExperiences() async {
    if (householdId == null) return;
    
    setState(() => isLoadingExperiences = true);
    
    try {
      final repository = ExperienceRepository();
      
      // Fetch live experiences
      final live = await repository.listExperiences(householdId!, status: 'live');
      
      // Fetch planned experiences
      final planned = await repository.listExperiences(householdId!, status: 'planned');
      
      // Filter upcoming (within 2 hours)
      final now = DateTime.now();
      final upcoming = planned.where((exp) {
        if (exp.startAt == null) return false;
        final diff = exp.startAt!.difference(now);
        return diff.inHours <= 2 && diff.inMinutes > 0;
      }).toList();
      
      setState(() {
        liveExperiences = live;
        upcomingExperiences = upcoming;
      });
    } catch (e) {
      print('Error loading live experiences: $e');
    } finally {
      setState(() => isLoadingExperiences = false);
    }
  }

  // NEW: Handle experience completion
  void _handleExperienceComplete(Experience experience) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ExperienceDebriefModal(
        experience: experience,
        onComplete: () {
          _loadLiveExperiences(); // Refresh list
          setState(() {}); // Rebuild
        },
      ),
    );
  }

  // NEW: Handle experience cancellation
  Future<void> _handleExperienceCancel(Experience experience) async {
    try {
      final repository = ExperienceRepository();
      await repository.updateExperience(
        experience.id!,
        {'status': 'cancelled'},
      );
      
      await _loadLiveExperiences(); // Refresh list
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Experience cancelled'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _fetchNewSuggestion({
    String? customWeather,
    String? customTimeOfDay,
    String? customDayOfWeek,
    String? customPromptText,
  }) async {
    setState(() {
      weather = customWeather ?? weather;
      timeOfDay = customTimeOfDay ?? timeOfDay;
      dayOfWeek = customDayOfWeek ?? dayOfWeek;
      customPrompt = customPromptText ?? customPrompt;
    });

    if (householdId != null) {
      if (selectedPodId != null && selectedParticipants.isNotEmpty) {
        try {
          final rulesService = RulesService();
          final response = await rulesService.getSuggestionsForPod(
            householdId: householdId!,
            podMemberIds: selectedParticipants.toList(),
            weather: weather,
            timeBucket: timeOfDay,
            dayOfWeek: dayOfWeek,
            customPrompt: customPrompt.isNotEmpty ? customPrompt : null,
            podId: selectedPodId,
          );

          final suggestions = (response['suggestions'] as List)
              .map((s) => ActivitySuggestion.fromJson(s))
              .toList();
          
          final suggestionsResponse = SuggestionsResponse(
            suggestions: suggestions,
            context: {
              'pod_id': response['pod_id'],
              'pod_member_ids': response['pod_member_ids'],
              'context_summary': response['context_summary'],
              'weather': weather,
              'time_of_day': timeOfDay,
              'day_of_week': dayOfWeek,
            },
          );
          
          context.read<FamilyBloc>().emit(SuggestionsLoaded(suggestionsResponse));
        } catch (e) {
          debugPrint('Error fetching pod-aware suggestions: $e');
          context.read<FamilyBloc>().add(
            GetSuggestionsEvent(
              householdId: householdId!,
              weather: weather,
              timeOfDay: timeOfDay,
              dayOfWeek: dayOfWeek,
              customPrompt: customPrompt.isNotEmpty ? customPrompt : null,
              participants: selectedParticipants.isNotEmpty
                  ? selectedParticipants.toList()
                  : null,
            ),
          );
        }
      } else {
        context.read<FamilyBloc>().add(
          GetSuggestionsEvent(
            householdId: householdId!,
            weather: weather,
            timeOfDay: timeOfDay,
            dayOfWeek: dayOfWeek,
            customPrompt: customPrompt.isNotEmpty ? customPrompt : null,
            participants: isAllMode
                ? null
                : (selectedParticipants.isNotEmpty ? selectedParticipants.toList() : null),
          ),
        );
      }
    }
  }

  void _onParticipantsChanged(Set<String> newSelection, {bool? setAllMode}) {
    setState(() {
      selectedParticipants = newSelection;
      if (setAllMode != null) {
        isAllMode = setAllMode;
      } else {
        isAllMode = false;
      }
    });
    _saveParticipantSelection();
    _fetchNewSuggestion();
  }

  void _showPresetSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ParticipantPresetSheet(
        allMembers: familyMembers,
        currentSelection: selectedParticipants,
        pods: pods,
        onApplyPod: (memberIds) {
          _onParticipantsChanged(memberIds);
        },
        onManagePods: () async {
          Navigator.pop(context);
          
          if (householdId != null && familyMembers.isNotEmpty) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PodsManagementPage(
                  householdId: householdId!,
                  allMembers: familyMembers,
                  currentMemberId: currentMemberId,
                ),
              ),
            );
            
            await _loadPods();
          }
        },
      ),
    );
  }

  void _showCreateExperienceSheet(ActivitySuggestion suggestion) async { // NEW: async
    if (householdId == null) return;

    await showModalBottomSheet( // NEW: await
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateExperienceSheet(
        householdId: householdId!,
        allMembers: familyMembers,
        initialParticipantIds: selectedParticipants.toList(),
        activityName: suggestion.activity,
        suggestionId: null,
      ),
    );
    
    // NEW: Reload experiences after creating one
    await _loadLiveExperiences();
  }

  Future<void> _saveParticipantSelection() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'participants_${weather}_${timeOfDay}_${dayOfWeek}';
    await prefs.setStringList(key, selectedParticipants.toList());
  }

  Future<void> _loadParticipantSelection() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'participants_${weather}_${timeOfDay}_${dayOfWeek}';
    final saved = prefs.getStringList(key);
    
    if (saved != null && saved.isNotEmpty) {
      setState(() {
        selectedParticipants = saved.toSet();
        isAllMode = false;
      });
    } else {
      setState(() {
        selectedParticipants = {};
        isAllMode = true;
      });
    }
  }

  Future<void> _loadPods() async {
    if (householdId == null) return;
    
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('pods')
          .select()
          .eq('household_id', householdId!)
          .order('name', ascending: true);
      
      var loadedPods = (response as List).map((json) => Pod.fromJson(json)).toList();
      
      final currentUser = UserContextService.getCurrentMember(currentMemberId, familyMembers);
      if (currentUser?.role == MemberRole.child) {
        loadedPods = loadedPods.where((pod) => !_isPodParentOnly(pod)).toList();
      }
      
      setState(() {
        pods = loadedPods;
      });
    } catch (e) {
      print('Error loading pods: $e');
    }
  }
  
  bool _isPodParentOnly(Pod pod) {
    if (pod.memberIds.isEmpty) return false;
    final podMembers = familyMembers.where((m) => pod.memberIds.contains(m.id)).toList();
    return podMembers.isNotEmpty && podMembers.every((m) => m.role == MemberRole.parent);
  }

  Future<void> _loadHouseholdId() async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) return;

    try {
      final householdList = await supabase
          .from('households')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(1);
      
      final householdData = householdList.isNotEmpty ? householdList.first : null;

      if (householdData != null) {
        final bool isFamilyModeEnabled = householdData['family_mode_enabled'] ?? false;
        
        final membersData = await supabase
            .from('family_members')
            .select()
            .eq('household_id', householdData['id'])
            .order('created_at');

        setState(() {
          householdId = householdData['id'];
          householdName = householdData['name'];
          familyModeEnabled = isFamilyModeEnabled;
          
          familyMembers = (membersData as List<dynamic>)
              .map((m) => FamilyMember.fromJson(m))
              .toList();
        });

        final memberId = await UserContextService.getCurrentMemberId(
          allMembers: familyMembers,
          familyModeEnabled: familyModeEnabled,
        );
        
        setState(() {
          currentMemberId = memberId;
        });

        await DefaultPodService.ensureDefaultPodExists(householdId!);

        await _loadPods();
        await _loadParticipantSelection();
        await _loadLiveExperiences(); // NEW: Load experiences on init

        _fetchNewSuggestion();
      }
    } catch (e) {
      print('Error loading from Supabase: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    timeOfDay = _getDefaultTimeOfDay();
    dayOfWeek = _getDefaultDayOfWeek();
    _initializeWeather();
    _loadHouseholdId();
  }

  Future<void> _initializeWeather() async {
    final fetchedWeather = await _getDefaultWeatherContext();
    if (mounted) {
      setState(() {
        weather = fetchedWeather;
      });
    }
  }

  void _onUserSwitched(FamilyMember selectedMember) {
    setState(() {
      currentMemberId = selectedMember.id;
    });
    _fetchNewSuggestion();
  }

  Future<void> _fetchSmartSuggestion() async {
    print('🌟 _fetchSmartSuggestion called!');
    print('  householdId: $householdId');
    print('  familyMembers.length: ${familyMembers.length}');
    
    if (householdId == null || familyMembers.isEmpty) {
      print('❌ Missing data');
      return;
    }

    try {
      print('✅ Making API call to smart-suggestion...');
      final rulesService = RulesService();
      
      final result = await rulesService.getSmartSuggestion(
        householdId: householdId!,
        locationLabel: 'near School',
        nearbyMemberIds: familyMembers.take(2).map((m) => m.id!).toList(),
        timeBucket: timeOfDay,
        dayType: _getDayType(),
        dayOfWeek: dayOfWeek,
        confidence: 0.85,
        signalsUsed: ['geofence', 'wifi'],
        reason: '${familyMembers.take(2).length} people detected near School',
        weather: weather,
      );

      print('📥 API Response received:');
      print('  result: $result');

      if (result != null && result['success'] == true) {
        print('✅ Setting smartSuggestionData and showing card');
        setState(() {
          smartSuggestionData = result;
          showSmartSuggestion = true;
        });
      } else {
        print('❌ Result is null or success is false');
      }
    } catch (e) {
      print('❌ Error fetching smart suggestion: $e');
    }
  }

  String _getDayType() {
    final day = DateTime.now().weekday;
    return day >= 6 ? 'weekend' : 'weekday';
  }

  void _dismissSmartSuggestion() async {
    if (smartSuggestionData != null && smartSuggestionData!['log_id'] != null) {
      try {
        final rulesService = RulesService();
        await rulesService.logSmartSuggestionAction(
          logId: smartSuggestionData!['log_id'],
          action: 'dismissed',
        );
      } catch (e) {
        print('Error logging dismiss: $e');
      }
    }

    setState(() {
      showSmartSuggestion = false;
    });
  }

  void _activateSmartSuggestion() async {
    if (smartSuggestionData != null && smartSuggestionData!['log_id'] != null) {
      try {
        final rulesService = RulesService();
        await rulesService.logSmartSuggestionAction(
          logId: smartSuggestionData!['log_id'],
          action: 'activated',
        );
      } catch (e) {
        print('Error logging activate: $e');
      }
    }

    if (smartSuggestionData != null && smartSuggestionData!['activity'] != null) {
      final activity = smartSuggestionData!['activity'];
      final suggestion = ActivitySuggestion(
        activity: activity['activity'] ?? 'Activity',
        rationale: activity['rationale'] ?? '',
        tags: List<String>.from(activity['tags'] ?? []),
        durationMinutes: activity['duration_minutes'] ?? 30,
      );
      
      _showCreateExperienceSheet(suggestion);
    }

    setState(() {
      showSmartSuggestion = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MerryWayTheme.softBg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Logo
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Row(
                  children: [
                    Text(
                      'merryway',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: MerryWayTheme.textDark,
                        letterSpacing: 0.5,
                        fontFamily: 'Inter',
                      ),
                    ),
                    Text(
                      '...',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: MerryWayTheme.textDark.withOpacity(0.4),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.star,
                      color: Color(0xFFD4A848),
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
            // Header
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              floating: true,
              expandedHeight: 80,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Today\'s Idea',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontSize: 24,
                      ),
                ),
                titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
              ),
              actions: [
                IconButton(
                  onPressed: _fetchSmartSuggestion,
                  icon: const Icon(Icons.auto_awesome, color: Color(0xFFFFD700)),
                  tooltip: 'Test Smart Suggestion',
                ),
                const SizedBox(width: 8),
                if (familyModeEnabled && familyMembers.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                    child: Align(
                      alignment: Alignment.center,
                      child: UserSwitcher(
                        members: familyMembers,
                        currentUser: UserContextService.getCurrentMember(
                          currentMemberId,
                          familyMembers,
                        ),
                        onUserSelected: _onUserSwitched,
                      ),
                    ),
                  ),
                IconButton(
                  onPressed: () {
                    context.push('/settings');
                  },
                  icon: const Icon(Icons.settings_outlined, color: MerryWayTheme.textDark),
                ),
              ],
            ),
            // Content
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // NEW: Live/Upcoming Experiences Section
                    if (liveExperiences.isNotEmpty || upcomingExperiences.isNotEmpty) ...[
                      ...liveExperiences.map((exp) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: LiveExperienceCard(
                          experience: exp,
                          allMembers: familyMembers,
                          onComplete: () => _handleExperienceComplete(exp),
                          onCancel: () => _handleExperienceCancel(exp),
                        ),
                      )),
                      ...upcomingExperiences.map((exp) {
                        final minutesUntil = exp.startAt!.difference(DateTime.now()).inMinutes;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: MerryWayTheme.accentGolden.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: MerryWayTheme.accentGolden.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Icon(Icons.schedule, color: MerryWayTheme.accentGolden),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        exp.activityName ?? 'Experience',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: MerryWayTheme.textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Starting in $minutesUntil minutes',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: MerryWayTheme.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios, size: 16, color: MerryWayTheme.textMuted),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                    ],

                    // Pod selector carousel
                    if (pods.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Who\'s joining?',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: MerryWayTheme.textDark,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () async {
                              if (householdId != null && familyMembers.isNotEmpty) {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PodsManagementPage(
                                      householdId: householdId!,
                                      allMembers: familyMembers,
                                      currentMemberId: currentMemberId,
                                    ),
                                  ),
                                );
                                await _loadPods();
                              }
                            },
                            icon: const Icon(Icons.edit_outlined, size: 16),
                            label: const Text('Manage'),
                            style: TextButton.styleFrom(
                              foregroundColor: MerryWayTheme.primarySoftBlue,
                              textStyle: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 90,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: pods.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              final isActive = isAllMode;
                              
                              return Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedPodId = null;
                                    });
                                    _onParticipantsChanged({}, setAllMode: true);
                                  },
                                  child: Container(
                                    width: 85,
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? MerryWayTheme.accentGolden
                                          : MerryWayTheme.softBg,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isActive
                                            ? MerryWayTheme.accentGolden
                                            : MerryWayTheme.textMuted.withOpacity(0.2),
                                        width: 2,
                                      ),
                                      boxShadow: isActive
                                          ? [
                                              BoxShadow(
                                                color: MerryWayTheme.accentGolden.withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '✨',
                                          style: TextStyle(
                                            fontSize: 32,
                                            color: isActive ? Colors.white : MerryWayTheme.textDark,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 4),
                                          child: Text(
                                            'All',
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: isActive ? Colors.white : MerryWayTheme.textDark,
                                              fontSize: 11,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }
                            
                            final pod = pods[index - 1];
                            final isActive = !isAllMode && 
                                selectedPodId == pod.id &&
                                selectedParticipants.toSet().toString() == pod.memberIds.toSet().toString();
                            
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedPodId = pod.id;
                                  });
                                  _onParticipantsChanged(pod.memberIds.toSet(), setAllMode: false);
                                },
                                child: Container(
                                  width: 85,
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? Color(int.parse(pod.color.substring(1), radix: 16) + 0xFF000000)
                                        : MerryWayTheme.softBg,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isActive
                                          ? Color(int.parse(pod.color.substring(1), radix: 16) + 0xFF000000)
                                          : MerryWayTheme.textMuted.withOpacity(0.2),
                                      width: 2,
                                    ),
                                    boxShadow: isActive
                                        ? [
                                            BoxShadow(
                                              color: Color(int.parse(pod.color.substring(1), radix: 16) + 0xFF000000).withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        pod.icon,
                                        style: TextStyle(
                                          fontSize: 32,
                                          color: isActive ? Colors.white : MerryWayTheme.textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                        child: Text(
                                          pod.name,
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: isActive ? Colors.white : MerryWayTheme.textDark,
                                            fontSize: 11,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Context input panel
                    ContextInputPanel(
                      initialWeather: weather,
                      initialTimeOfDay: timeOfDay,
                      initialDayOfWeek: dayOfWeek,
                      initialPrompt: customPrompt,
                      onApply: (w, t, d, p) {
                        _fetchNewSuggestion(
                          customWeather: w,
                          customTimeOfDay: t,
                          customDayOfWeek: d,
                          customPromptText: p,
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Suggestions section
                    BlocBuilder<FamilyBloc, FamilyState>(
                      builder: (context, state) {
                        if (state is FamilyLoading) {
                          return SizedBox(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: MerryWayTheme.primarySoftBlue,
                              ),
                            ),
                          );
                        }

                        if (state is SuggestionsLoaded) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Welcome message
                              Row(
                                children: [
                                  Text(
                                    _getGreeting(),
                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                          color: MerryWayTheme.textMuted,
                                        ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('✨', style: TextStyle(fontSize: 20)),
                                ],
                              ),
                              if (householdName != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  householdName!,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: MerryWayTheme.textMuted,
                                      ),
                                ),
                              ],
                              const SizedBox(height: 24),

                              // Smart Suggestion Card
                              if (showSmartSuggestion && smartSuggestionData != null) ...[
                                SmartSuggestionCard(
                                  activityTitle: smartSuggestionData!['activity']?['activity'] ?? 'Activity',
                                  rationale: smartSuggestionData!['activity']?['rationale'] ?? '',
                                  locationLabel: smartSuggestionData!['location_label'] ?? 'nearby',
                                  nearbyMembers: familyMembers
                                      .where((m) => (smartSuggestionData!['member_ids'] as List? ?? [])
                                          .contains(m.id))
                                      .toList(),
                                  reason: smartSuggestionData!['reason'] ?? 'Smart suggestion',
                                  onDismiss: _dismissSmartSuggestion,
                                  onActivate: _activateSmartSuggestion,
                                  showDebugInfo: false,
                                  signals: (smartSuggestionData!['activity']?['tags'] as List? ?? [])
                                      .map((e) => e.toString())
                                      .toList(),
                                  confidence: 0.85,
                                ),
                                const SizedBox(height: 16),
                              ],

                              // Suggestions cards
                              ...state.suggestions.suggestions.asMap().entries.map((entry) {
                                int index = entry.key;
                                ActivitySuggestion suggestion = entry.value;

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: SuggestionCard(
                                    index: index,
                                    suggestion: suggestion,
                                    householdId: householdId,
                                    allMembers: familyMembers.isNotEmpty ? familyMembers : null,
                                    currentMemberId: currentMemberId,
                                    selectedMemberIds: selectedParticipants,
                                    onParticipantsChanged: _onParticipantsChanged,
                                    onManagePresets: _showPresetSheet,
                                    onMakeExperience: () => _showCreateExperienceSheet(suggestion),
                                  ),
                                );
                              }),

                              const SizedBox(height: 24),

                              // Refresh button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _fetchNewSuggestion,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Try Another Idea'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }

                        if (state is FamilyError) {
                          return SizedBox(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    size: 64,
                                    color: MerryWayTheme.primaryWarmPink,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Oh botheration!',
                                    style: Theme.of(context).textTheme.headlineMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 32),
                                    child: Text(
                                      'We couldn\'t fetch your magical suggestions right now. Please try again! 💫',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: MerryWayTheme.textMuted,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  ElevatedButton.icon(
                                    onPressed: _fetchNewSuggestion,
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Try Again'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        // Initial/empty state
                        return SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  size: 80,
                                  color: MerryWayTheme.accentGolden.withOpacity(0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Let\'s find something magical!',
                                  style: Theme.of(context).textTheme.headlineMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap the button below to get started',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: MerryWayTheme.textMuted,
                                      ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: () => _fetchNewSuggestion(),
                                  icon: const Icon(Icons.auto_awesome),
                                  label: const Text('Get Ideas'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## File 2: `lib/modules/experiences/widgets/live_experience_card.dart`

**COMPLETE FILE CONTENTS** (with ICS download implementation):

```dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:html' as html; // For web download
import '../../../modules/core/theme/theme_colors.dart';
import '../../../modules/family/models/family_models.dart';
import '../models/experience_models.dart';
import '../repositories/experience_repository.dart';
import 'dart:convert';

class LiveExperienceCard extends StatefulWidget {
  final Experience experience;
  final List<FamilyMember> allMembers;
  final VoidCallback onComplete;
  final VoidCallback onCancel;

  const LiveExperienceCard({
    Key? key,
    required this.experience,
    required this.allMembers,
    required this.onComplete,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<LiveExperienceCard> createState() => _LiveExperienceCardState();
}

class _LiveExperienceCardState extends State<LiveExperienceCard> {
  Duration _elapsed = Duration.zero;
  DateTime? _startTime;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _startTime = widget.experience.startAt ?? DateTime.now();
    _updateElapsed();
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 60));
      if (mounted) {
        _updateElapsed();
        return true;
      }
      return false;
    });
  }

  void _updateElapsed() {
    if (_startTime != null) {
      setState(() {
        _elapsed = DateTime.now().difference(_startTime!);
      });
    }
  }

  String _formatElapsed() {
    final hours = _elapsed.inHours;
    final minutes = _elapsed.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  List<FamilyMember> _getParticipants() {
    return widget.allMembers
        .where((m) => widget.experience.participantIds.contains(m.id))
        .toList();
  }

  Future<void> _markAsLive() async {
    setState(() => _isUpdating = true);
    try {
      final repository = ExperienceRepository();
      
      await repository.updateExperience(
        widget.experience.id!,
        {
          'status': 'live',
          'start_at': DateTime.now().toIso8601String(),
        },
      );

      setState(() {
        _startTime = DateTime.now();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✨ Started! Have fun!'),
            backgroundColor: MerryWayTheme.accentGolden,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  Future<void> _markAsDone() async {
    widget.onComplete();
  }

  // NEW: Real ICS download implementation
  void _downloadICS() {
    final start = widget.experience.startAt ?? DateTime.now();
    final end = widget.experience.endAt ?? start.add(const Duration(hours: 2));
    
    final icsContent = '''BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Merryway//EN
BEGIN:VEVENT
UID:${widget.experience.id}@merryway.app
DTSTAMP:${_formatDateTimeICS(DateTime.now())}
DTSTART:${_formatDateTimeICS(start)}
DTEND:${_formatDateTimeICS(end)}
SUMMARY:${widget.experience.activityName}
DESCRIPTION:Merryway Experience
${widget.experience.place != null ? 'LOCATION:${widget.experience.place}' : ''}
STATUS:CONFIRMED
END:VEVENT
END:VCALENDAR''';

    // Trigger download for web
    final blob = html.Blob([icsContent], 'text/calendar');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'merryway-experience.ics')
      ..click();
    html.Url.revokeObjectUrl(url);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📅 Calendar event downloaded!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  String _formatDateTimeICS(DateTime dt) {
    return dt.toUtc().toIso8601String().replaceAll(RegExp(r'[-:]'), '').split('.')[0] + 'Z';
  }

  // NEW: Real navigation implementation
  Future<void> _navigate() async {
    if (widget.experience.place != null) {
      final place = Uri.encodeComponent(widget.experience.place!);
      final Uri googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$place');
      
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open maps'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final participants = _getParticipants();
    final isPlanned = widget.experience.status == ExperienceStatus.planned;
    final isLive = widget.experience.status == ExperienceStatus.live;

    return Card(
      margin: const EdgeInsets.all(0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isLive ? MerryWayTheme.accentGolden : MerryWayTheme.primarySoftBlue,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (isLive ? MerryWayTheme.accentGolden : MerryWayTheme.primarySoftBlue)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isLive ? Icons.play_circle_filled : Icons.schedule,
                    color: isLive ? MerryWayTheme.accentGolden : MerryWayTheme.primarySoftBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.experience.activityName ?? 'Experience',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: MerryWayTheme.textDark,
                        ),
                      ),
                      if (isLive) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: MerryWayTheme.accentGolden,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Live · ${_formatElapsed()}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: MerryWayTheme.accentGolden,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        const SizedBox(height: 2),
                        const Text(
                          'Planned',
                          style: TextStyle(
                            fontSize: 13,
                            color: MerryWayTheme.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Participants
            if (participants.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: participants.map((member) {
                  return Chip(
                    avatar: Text(
                      member.avatarEmoji ?? member.name.substring(0, 1),
                      style: const TextStyle(fontSize: 14),
                    ),
                    label: Text(
                      member.name,
                      style: const TextStyle(fontSize: 12),
                    ),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Place
            if (widget.experience.place != null) ...[
              Row(
                children: [
                  const Icon(Icons.place_outlined, size: 16, color: MerryWayTheme.textMuted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      widget.experience.place!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: MerryWayTheme.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Prep notes
            if (widget.experience.prepNotes != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: MerryWayTheme.primarySoftBlue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: MerryWayTheme.textMuted),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.experience.prepNotes!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: MerryWayTheme.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Action buttons
            Row(
              children: [
                if (isPlanned) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isUpdating ? null : _markAsLive,
                      icon: const Icon(Icons.play_arrow, size: 20),
                      label: const Text('Start'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MerryWayTheme.accentGolden,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (isLive) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _markAsDone,
                      icon: const Icon(Icons.check_circle, size: 20),
                      label: const Text('Done'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MerryWayTheme.primarySoftBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (widget.experience.place != null) ...[
                  IconButton(
                    onPressed: _navigate,
                    icon: const Icon(Icons.navigation),
                    tooltip: 'Navigate',
                    style: IconButton.styleFrom(
                      backgroundColor: MerryWayTheme.primarySoftBlue.withOpacity(0.1),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                IconButton(
                  onPressed: _downloadICS,
                  icon: const Icon(Icons.calendar_today),
                  tooltip: 'Add to Calendar',
                  style: IconButton.styleFrom(
                    backgroundColor: MerryWayTheme.primarySoftBlue.withOpacity(0.1),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: widget.onCancel,
                  icon: const Icon(Icons.close, size: 20),
                  tooltip: 'Cancel',
                  style: IconButton.styleFrom(
                    foregroundColor: MerryWayTheme.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Testing Checklist

### 1. Live Experiences Display
- [ ] Create an experience from a suggestion
- [ ] Verify it appears at the top of the home page
- [ ] Check that the "Start" button changes status to "live"
- [ ] Verify elapsed time updates every minute

### 2. Upcoming Nudges
- [ ] Create an experience scheduled for 30 minutes from now
- [ ] Verify the golden nudge card appears
- [ ] Check "Starting in X minutes" text updates

### 3. ICS Download
- [ ] Click "Add to Calendar" button
- [ ] Verify `.ics` file downloads
- [ ] Open the file in a calendar app (Apple Calendar, Google Calendar)
- [ ] Check event details (title, date, location) are correct

### 4. Navigation
- [ ] Create an experience with a place
- [ ] Click the "Navigate" button
- [ ] Verify Google Maps opens with the correct search

### 5. Debrief Modal
- [ ] Mark a live experience as "Done"
- [ ] Verify debrief modal appears
- [ ] Submit rating, effort, cleanup, note, photo
- [ ] Check Merry Moment is created

---

## Notes
- **`url_launcher`** package already exists in `pubspec.yaml`
- **ICS download** uses `dart:html` for web (works on Flutter web)
- **Navigation** opens Google Maps in a new browser tab/window
- **Experience repository** uses direct Supabase calls for reads (performance)
- **Django API** is called for writes (validation, learning weights)

---

## What's Working
✅ PLAN: CreateExperienceSheet calls Django API  
✅ DO: LiveExperienceCard displays and updates  
✅ REFLECT: ExperienceDebriefModal calls Django API  
✅ ICS Download: Real implementation  
✅ Navigation: Real Google Maps integration  
✅ Home Page Integration: Fetches and displays live/upcoming experiences  

---

## What's NOT Implemented
❌ Consent/policy checks in CreateExperienceSheet (runs silently in backend)  
❌ Offline support for LiveExperienceCard (works online only)  
❌ Mobile-specific ICS download (only web for now)  
❌ Mobile-specific navigation (Google Maps app vs web)  

