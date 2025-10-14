import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../../config/environment.dart';
import '../../family/blocs/family_bloc.dart';
import '../../family/models/family_models.dart';
import '../../family/models/pod_model.dart';
import '../../family/pages/pods_management_page.dart';
import '../../family/pages/family_health_dashboard_page.dart';
import '../../family/services/default_pod_service.dart';
import '../../family/services/rules_service.dart';
import '../widgets/suggestion_card.dart';
import '../widgets/context_input_panel.dart';
import '../widgets/participant_preset_sheet.dart';
import '../widgets/smart_suggestion_card.dart';
import '../../core/theme/merryway_theme.dart';
import '../../core/theme/redesign_tokens.dart';
import '../widgets/compact_header.dart';
import '../widgets/sticky_pod_row.dart';
import '../widgets/simplified_suggestion_card.dart';
import '../widgets/feedback_bar.dart';
import '../widgets/inline_participants_editor.dart';
import '../widgets/bottom_composer.dart';
import '../widgets/idea_card_detail_modal.dart';
import '../widgets/gentle_loading_indicator.dart';
import '../widgets/why_this_sheet.dart';
import '../services/suggestion_feedback_service.dart';
import '../../core/ui/widgets/animated_list_item.dart';
import '../../core/ui/widgets/whimsical_card.dart';
import '../../core/services/weather_service.dart';
import '../../auth/services/user_context_service.dart';
import '../../auth/widgets/user_switcher.dart';
import '../../experiences/widgets/create_experience_sheet.dart';
import '../../experiences/widgets/live_experience_card.dart';
import '../../experiences/widgets/experience_debrief_modal.dart';
import '../../experiences/repositories/experience_repository.dart';
import '../../experiences/models/experience_models.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? householdId;
  String? householdName;
  String? householdPhotoUrl;
  List<FamilyMember> familyMembers = [];
  bool familyModeEnabled = false;
  String? currentMemberId;  // Who is using the app right now
  
  // Context state
  String weather = 'cloudy';
  String timeOfDay = 'afternoon';
  String dayOfWeek = 'monday';
  String customPrompt = '';
  
  // Participant state
  Set<String> selectedParticipants = {};
  List<Pod> pods = [];
  String? selectedPodId; // Track which pod is currently selected
  bool isAllMode = true; // Track if "All" variety mode is active
  
  // Smart suggestion state
  Map<String, dynamic>? smartSuggestionData;
  bool showSmartSuggestion = false;

  // Live experiences state
  List<Experience> liveExperiences = [];
  List<Experience> upcomingExperiences = [];
  bool isLoadingExperiences = false;
  
  // AI suggestions loading state
  bool isLoadingAISuggestions = false;
  
  // Saved AI suggestions from database
  List<ActivitySuggestion> savedAISuggestions = [];

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
    // Fetch real weather from OpenWeatherMap
    try {
      final realWeather = await WeatherService.getCurrentWeather();
      return realWeather;
    } catch (e) {
      print('Error fetching weather: $e');
      // Fallback based on time
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

  // Load live/planned experiences
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

  // Handle experience completion
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

  // Handle experience cancellation
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
      // If there's a custom prompt, use AI-powered suggestions
      if (customPrompt.isNotEmpty) {
        await _fetchAISuggestions();
        return;
      }

      // If a pod is selected, use the pod-aware endpoint
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

          // Parse suggestions and dispatch to bloc
          final suggestions = (response['suggestions'] as List)
              .map((s) => ActivitySuggestion.fromJson(s))
              .toList();
          
          // Create a SuggestionsResponse object
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
          
          // Manually update the bloc state with pod-aware suggestions
          context.read<FamilyBloc>().emit(SuggestionsLoaded(suggestionsResponse));
        } catch (e) {
          debugPrint('Error fetching pod-aware suggestions: $e');
          // Fallback to regular endpoint
          context.read<FamilyBloc>().add(
            GetProgressiveSuggestionsEvent(
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
        // Use regular endpoint when no pod is selected
        context.read<FamilyBloc>().add(
          GetProgressiveSuggestionsEvent(
            householdId: householdId!,
            weather: weather,
            timeOfDay: timeOfDay,
            dayOfWeek: dayOfWeek,
            customPrompt: customPrompt.isNotEmpty ? customPrompt : null,
            // If "All" mode is active, don't filter by participants (variety mode)
            // Otherwise, filter by selected participants ("whole gang" or specific subset)
            participants: isAllMode
                ? null
                : (selectedParticipants.isNotEmpty ? selectedParticipants.toList() : null),
          ),
        );
      }
    }
  }

  String? _lastAISuggestionLogId; // Track the last AI suggestion log ID
  List<ActivitySuggestion> _savedAISuggestions = []; // Cache of saved AI suggestions
  Map<String, String> _suggestionFeedback = {}; // activity_name -> feedback_type

  Future<void> _loadSuggestionFeedback() async {
    if (householdId == null || currentMemberId == null) return;

    try {
      final feedback = await SuggestionFeedbackService.loadFeedback(
        householdId: householdId!,
        memberId: currentMemberId!,
      );
      
      setState(() {
        _suggestionFeedback = feedback;
      });
      
      debugPrint('✅ Loaded ${feedback.length} feedback entries');
      feedback.forEach((key, value) {
        debugPrint('  - "$key" -> $value');
      });
    } catch (e) {
      debugPrint('❌ Error loading feedback: $e');
    }
  }

  Future<void> _loadSavedAISuggestions() async {
    if (householdId == null) return;

    try {
      final supabase = Supabase.instance.client;
      
      // Load recent AI suggestion logs (last 20)
      final response = await supabase
          .from('ai_suggestion_logs')
          .select('suggestions, created_at, prompt')
          .eq('household_id', householdId!)
          .order('created_at', ascending: false)
          .limit(20);

      final List<ActivitySuggestion> allSuggestions = [];
      
      for (var log in response) {
        final suggestions = log['suggestions'] as List?;
        if (suggestions != null) {
          for (var suggestionJson in suggestions) {
            try {
              final suggestion = ActivitySuggestion.fromJson(suggestionJson);
              allSuggestions.add(suggestion);
            } catch (e) {
              debugPrint('Error parsing saved AI suggestion: $e');
            }
          }
        }
      }

      setState(() {
        _savedAISuggestions = allSuggestions;
      });
      
      debugPrint('✅ Loaded ${allSuggestions.length} saved AI suggestions from database');
    } catch (e) {
      debugPrint('❌ Error loading saved AI suggestions: $e');
    }
  }

  Future<void> _saveAISuggestionsToDatabase(List<ActivitySuggestion> suggestions) async {
    if (householdId == null) return;

    try {
      final supabase = Supabase.instance.client;
      
      // Prepare suggestions data for JSON storage (include all fields)
      final suggestionsJson = suggestions.map((s) => {
        'activity': s.activity,
        'rationale': s.rationale,
        'duration_minutes': s.durationMinutes,
        'tags': s.tags,
        'location': s.location,
        'distance_miles': s.distanceMiles,
        'venue_type': s.venueType,
        'description': s.description,
        'attire': s.attire,
        'food_available': s.foodAvailable,
        'average_rating': s.averageRating,
        'review_count': s.reviewCount,
      }).toList();

      // Save to ai_suggestion_logs table
      final result = await supabase.from('ai_suggestion_logs').insert({
        'household_id': householdId,
        'pod_id': selectedPodId,
        'prompt': customPrompt,
        'context': {
          'weather': weather,
          'time_of_day': timeOfDay,
          'day_of_week': dayOfWeek,
        },
        'participant_ids': isAllMode 
            ? null 
            : (selectedParticipants.isNotEmpty ? selectedParticipants.toList() : null),
        'suggestions': suggestionsJson,
        'model_used': 'gpt-3.5-turbo',
      }).select();

      // Store the log ID for tracking acceptance
      if (result.isNotEmpty) {
        _lastAISuggestionLogId = result[0]['id'];
      }

      debugPrint('✅ AI suggestions saved to database (log_id: $_lastAISuggestionLogId)');
      
      // Reload saved suggestions to include this new one
      await _loadSavedAISuggestions();
    } catch (e) {
      debugPrint('❌ Error saving AI suggestions to database: $e');
      // Don't show error to user - this is background logging
    }
  }

  Future<void> _trackAISuggestionAccepted(String suggestionName) async {
    if (_lastAISuggestionLogId == null) return;

    try {
      final supabase = Supabase.instance.client;
      
      await supabase
          .from('ai_suggestion_logs')
          .update({
            'user_accepted_suggestion': suggestionName,
          })
          .eq('id', _lastAISuggestionLogId!);

      debugPrint('✅ Tracked AI suggestion acceptance: $suggestionName');
    } catch (e) {
      debugPrint('❌ Error tracking AI suggestion acceptance: $e');
    }
  }

  Future<void> _fetchAISuggestions() async {
    if (householdId == null || customPrompt.isEmpty) return;

    setState(() {
      isLoadingAISuggestions = true;
    });

    try {
      final supabase = Supabase.instance.client;
      
      // Refresh session if expired
      final session = supabase.auth.currentSession;
      if (session == null) {
        throw Exception('No active session');
      }
      
      // Check if token is expired or about to expire (within 60 seconds)
      if (session.isExpired) {
        debugPrint('🔄 Token expired, refreshing...');
        final refreshResponse = await supabase.auth.refreshSession();
        if (refreshResponse.session == null) {
          throw Exception('Failed to refresh session');
        }
      }
      
      final token = supabase.auth.currentSession?.accessToken ?? '';
      
      debugPrint('🤖 Fetching AI suggestions for prompt: "$customPrompt"');
      
      final response = await http.post(
        Uri.parse('${Environment.apiUrl}/ai-suggestions/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'household_id': householdId,
          'prompt': customPrompt,
          'context': {
            'weather': weather,
            'time_of_day': timeOfDay,
            'day_of_week': dayOfWeek,
          },
          'participants': isAllMode
              ? null
              : (selectedParticipants.isNotEmpty ? selectedParticipants.toList() : null),
          'pod_id': selectedPodId,
        }),
      );

      debugPrint('🤖 AI suggestions response: ${response.statusCode}');
      debugPrint('🤖 Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          
          // Validate response structure
          if (data == null || data['suggestions'] == null) {
            throw Exception('Invalid response structure from backend');
          }
          
          final suggestions = (data['suggestions'] as List)
              .map((s) {
                try {
                  return ActivitySuggestion.fromJson(s);
                } catch (e) {
                  debugPrint('Error parsing suggestion: $e');
                  debugPrint('Suggestion data: $s');
                  rethrow;
                }
              })
              .toList();

          if (suggestions.isEmpty) {
            throw Exception('No suggestions returned from backend');
          }

          final suggestionsResponse = SuggestionsResponse(
            suggestions: suggestions,
            context: {
              'ai_generated': true,
              'prompt': customPrompt,
              'weather': weather,
              'time_of_day': timeOfDay,
              'day_of_week': dayOfWeek,
            },
          );

          if (mounted) {
            context.read<FamilyBloc>().emit(SuggestionsLoaded(suggestionsResponse));
            setState(() {
              isLoadingAISuggestions = false;
            });
            
            // Save AI suggestions to database for tracking
            _saveAISuggestionsToDatabase(suggestions);
          }
        } catch (e) {
          debugPrint('Error parsing response: $e');
          debugPrint('Response body: ${response.body}');
          if (mounted) {
            setState(() {
              isLoadingAISuggestions = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error parsing backend response. Check console for details.'),
                duration: const Duration(seconds: 5),
              ),
            );
          }
        }
      } else {
        debugPrint('❌ AI suggestions error: ${response.statusCode} - ${response.body}');
        if (mounted) {
          setState(() {
            isLoadingAISuggestions = false;
          });
          String errorMsg = 'Backend error: ${response.statusCode}';
          if (response.statusCode == 404) {
            errorMsg = 'Backend endpoint not found. Check Django server.';
          } else if (response.statusCode == 401 || response.statusCode == 403) {
            errorMsg = 'Authentication error. Please log in again.';
          } else if (response.statusCode == 500) {
            errorMsg = 'Django server error. Check your Django console for details.';
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              duration: const Duration(seconds: 6),
              action: SnackBarAction(
                label: 'Details',
                onPressed: () {
                  debugPrint('Full error: ${response.body}');
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Exception fetching AI suggestions: $e');
      if (mounted) {
        setState(() {
          isLoadingAISuggestions = false;
        });
        final errorMsg = e.toString();
        final displayMsg = errorMsg.length > 100 
            ? errorMsg.substring(0, 100) + '...' 
            : errorMsg;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Network error: $displayMsg'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _onParticipantsChanged(Set<String> newSelection, {bool? setAllMode}) {
    setState(() {
      selectedParticipants = newSelection;
      // If manually changed from participant chips (not from pod carousel), disable All mode
      if (setAllMode != null) {
        isAllMode = setAllMode;
      } else {
        // Manual change from participant chips
        isAllMode = false;
      }
    });
    _saveParticipantSelection();
    // Re-fetch suggestions with new participants
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
          // Close the sheet
          Navigator.pop(context);
          
          // Navigate to pods management page
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
            
            // Reload pods when returning
            await _loadPods();
          }
        },
      ),
    );
  }

  void _showCreateExperienceSheet(ActivitySuggestion suggestion, {List<String>? participantIds}) async {
    if (householdId == null) return;

    // Track that user accepted this AI suggestion (if it was from AI search)
    if (customPrompt.isNotEmpty) {
      await _trackAISuggestionAccepted(suggestion.activity);
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateExperienceSheet(
        householdId: householdId!,
        allMembers: familyMembers,
        initialParticipantIds: participantIds ?? selectedParticipants.toList(),
        activityName: suggestion.activity,
        suggestionId: null, // You can add an ID field to ActivitySuggestion if needed
      ),
    );
    
    // Reload experiences after creating one
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
        isAllMode = false; // Saved selection means specific filtering
      });
    } else {
      // Default to "All" mode (variety, no filtering)
      setState(() {
        selectedParticipants = {}; // Empty selection
        isAllMode = true; // Variety mode
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
      
      // Load all pods
      var loadedPods = (response as List).map((json) => Pod.fromJson(json)).toList();
      
      // Filter out parent-only pods if current user is a child
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
  
  /// Check if a pod contains only parents (no children or caregivers)
  bool _isPodParentOnly(Pod pod) {
    if (pod.memberIds.isEmpty) return false;
    
    // Get all members in this pod
    final podMembers = familyMembers.where((m) => pod.memberIds.contains(m.id)).toList();
    
    // If all members are parents, it's a parent-only pod
    return podMembers.isNotEmpty && podMembers.every((m) => m.role == MemberRole.parent);
  }

  Future<void> _loadHouseholdId() async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) return;

    try {
      // Load most recent household from Supabase
      final householdList = await supabase
          .from('households')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(1);
      
      final householdData = householdList.isNotEmpty ? householdList.first : null;

      if (householdData != null) {
        final bool isFamilyModeEnabled = householdData['family_mode_enabled'] ?? false;
        
        // Load family members from Supabase
        final membersData = await supabase
            .from('family_members')
            .select()
            .eq('household_id', householdData['id'])
            .order('created_at');

        setState(() {
          householdId = householdData['id'];
          householdName = householdData['name'];
          householdPhotoUrl = householdData['photo_url'];
          familyModeEnabled = isFamilyModeEnabled;
          
          // Use fromJson to properly parse all fields (including Phase 3 fields)
          familyMembers = (membersData as List<dynamic>)
              .map((m) => FamilyMember.fromJson(m))
              .toList();
        });

        // Determine current member ID
        final memberId = await UserContextService.getCurrentMemberId(
          allMembers: familyMembers,
          familyModeEnabled: familyModeEnabled,
        );
        
        setState(() {
          currentMemberId = memberId;
        });

        // Ensure default "Just Me" pod exists for this household
        await DefaultPodService.ensureDefaultPodExists(householdId!);

        await _loadPods();
        await _loadParticipantSelection();
        await _loadLiveExperiences(); // Load experiences on init
        await _loadSavedAISuggestions(); // Load saved AI suggestions from database
        await _loadSuggestionFeedback(); // Load user's feedback history

        _fetchNewSuggestion();
      }
    } catch (e) {
      print('Error loading from Supabase: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    // Set default context values
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
    
    // Reload feedback for the new user
    _loadSuggestionFeedback();
    
    // Optionally re-fetch suggestions for the new user
    _fetchNewSuggestion();
  }

  void _navigateToSettings() {
    // If current user is a child, require parent PIN
    final currentUser = familyMembers.firstWhere(
      (m) => m.id == currentMemberId,
      orElse: () => familyMembers.first,
    );
    
    if (currentUser.isChild()) {
      // Find a parent with a PIN
      final parentWithPin = familyMembers.firstWhere(
        (m) => m.isParent() && m.pinRequired && m.devicePin != null && m.devicePin!.isNotEmpty,
        orElse: () => familyMembers.first,
      );
      
      if (parentWithPin.id != currentUser.id && parentWithPin.pinRequired) {
        // Show PIN dialog
        _showPinDialogForSettings(parentWithPin);
        return;
      }
    }
    
    // No PIN required or user is parent
    context.push('/settings');
  }

  void _showPinDialogForSettings(FamilyMember parentMember) {
    final pinController = TextEditingController();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: RedesignTokens.primary,
                    borderRadius: BorderRadius.circular(6),
                    image: parentMember.photoUrl != null
                        ? DecorationImage(
                            image: NetworkImage(parentMember.photoUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: parentMember.photoUrl == null
                      ? Center(
                          child: Text(
                            parentMember.avatarEmoji ?? '👤',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Parent Permission Required',
                        style: RedesignTokens.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Enter ${parentMember.name}\'s PIN',
                        style: RedesignTokens.caption.copyWith(
                          color: RedesignTokens.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    pinController.dispose();
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.close, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // PIN input
            TextField(
              controller: pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'PIN',
                hintText: '6-digit PIN',
                counterText: '',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) {
                if (pinController.text == parentMember.devicePin) {
                  pinController.dispose();
                  Navigator.of(context).pop();
                  context.push('/settings');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Incorrect PIN')),
                  );
                  pinController.clear();
                }
              },
            ),
            const SizedBox(height: 16),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      pinController.dispose();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (pinController.text == parentMember.devicePin) {
                        pinController.dispose();
                        Navigator.of(context).pop();
                        context.push('/settings');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Incorrect PIN')),
                        );
                        pinController.clear();
                      }
                    },
                    child: const Text('Verify'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Smart suggestion methods
  Future<void> _fetchSmartSuggestion() async {
    print('🌟 _fetchSmartSuggestion called!');
    print('  householdId: $householdId');
    print('  familyMembers.length: ${familyMembers.length}');
    
    if (householdId == null) {
      print('❌ householdId is null!');
      return;
    }
    
    if (familyMembers.isEmpty) {
      print('❌ familyMembers is empty!');
      return;
    }

    try {
      print('✅ Making API call to smart-suggestion...');
      final rulesService = RulesService();
      
      // For testing: simulate a smart suggestion request
      final result = await rulesService.getSmartSuggestion(
        householdId: householdId!,
        locationLabel: 'near School',  // Simulated location
        nearbyMemberIds: familyMembers.take(2).map((m) => m.id!).toList(), // First 2 members
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

    // Create experience from smart suggestion
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
      backgroundColor: RedesignTokens.canvas,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Compact Header (sticky)
                CompactHeader(
                  isIdeasActive: true,
                  isPlannerActive: false,
                  isMomentsActive: false,
                  onIdeas: () {
                    // Already on home/ideas page, do nothing or scroll to top
                    // Could implement scroll to top here if needed
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
                  onMoments: () {
                    if (householdId != null && familyMembers.isNotEmpty) {
                      context.push('/moments', extra: {
                        'householdId': householdId!,
                        'allMembers': familyMembers,
                      });
                    }
                  },
                  onSettings: () => _navigateToSettings(),
                  onHelp: () {
                    // TODO: Navigate to help page or show help dialog
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
                          onUserSelected: _onUserSwitched,
                        )
                      : null,
                ),

                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 140), // Space for bottom composer + fade gradient
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: RedesignTokens.space16),
                        
                        // Greeting + Pod Row (horizontal)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              // Family Avatar
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: householdPhotoUrl == null
                                      ? LinearGradient(
                                          colors: [
                                            RedesignTokens.primary,
                                            RedesignTokens.accentSage,
                                          ],
                                        )
                                      : null,
                                  borderRadius: BorderRadius.circular(16), // More rounded square
                                  image: householdPhotoUrl != null
                                      ? DecorationImage(
                                          image: NetworkImage(householdPhotoUrl!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: householdPhotoUrl == null
                                    ? Center(
                                        child: Icon(
                                          Icons.family_restroom,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                      )
                                    : null,
                              ),
                              
                              const SizedBox(width: RedesignTokens.space16),
                              
                              // Greeting
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getGreeting(),
                                      style: RedesignTokens.body.copyWith(
                                        fontSize: 20,
                                        color: RedesignTokens.ink,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    if (householdName != null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        householdName!,
                                        style: RedesignTokens.meta.copyWith(
                                          fontSize: 15,
                                          color: RedesignTokens.mutedText,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: RedesignTokens.space16),
                        
                        // Pod Filter (inline, no background)
                        if (pods.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  // "All" mode chip
                                  _buildPodChip(
                                    label: 'All',
                                    icon: Icons.grid_view_rounded,
                                    isSelected: isAllMode,
                                    onTap: () {
                                      setState(() {
                                        isAllMode = true;
                                        selectedPodId = null;
                                        selectedParticipants = {}; // Clear selection in All mode
                                      });
                                      _fetchNewSuggestion();
                                    },
                                  ),
                                  const SizedBox(width: RedesignTokens.space8),
                                  
                                  // Pod chips with custom icons
                                  ...pods.map((pod) {
                                    final isSelected = !isAllMode && pod.id == selectedPodId;
                                    return Padding(
                                      padding: const EdgeInsets.only(right: RedesignTokens.space8),
                                      child: _buildPodChip(
                                        label: pod.name,
                                        icon: _getIconForPod(pod.icon),
                                        isSelected: isSelected,
                                        onTap: () {
                                          setState(() {
                                            isAllMode = false;
                                            selectedPodId = pod.id;
                                            // Populate selectedParticipants with pod members
                                            selectedParticipants = pod.memberIds.toSet();
                                          });
                                          _fetchNewSuggestion();
                                        },
                                      ),
                                    );
                                  }).toList(),
                                  
                                  // Manage button
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PodsManagementPage(
                                            householdId: householdId!,
                                            allMembers: familyMembers,
                                            currentMemberId: currentMemberId,
                                          ),
                                        ),
                                      ).then((_) => _loadPods());
                                    },
                                    borderRadius: BorderRadius.circular(RedesignTokens.radiusButton),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: RedesignTokens.space12,
                                        vertical: RedesignTokens.space8,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.tune,
                                            size: 16,
                                            color: RedesignTokens.primary,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Manage',
                                            style: RedesignTokens.meta.copyWith(
                                              color: RedesignTokens.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        
                        const SizedBox(height: RedesignTokens.space16),
                        // Live/Upcoming Experiences Section
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
                                  color: RedesignTokens.accentGold.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: RedesignTokens.accentGold.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Icon(Icons.schedule, color: RedesignTokens.accentGold),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            exp.activityName ?? 'Experience',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: RedesignTokens.ink,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Starting in $minutesUntil minutes',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: RedesignTokens.slate,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(Icons.arrow_forward_ios, size: 16, color: RedesignTokens.slate),
                                  ],
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),
                        ],

                        const SizedBox(height: RedesignTokens.space16),

                        // Smart suggestion section
                        if (showSmartSuggestion && smartSuggestionData != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: SmartSuggestionCard(
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
                          ),

                        // AI suggestions loading banner
                        if (isLoadingAISuggestions)
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.all(RedesignTokens.space24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  RedesignTokens.primary.withOpacity(0.1),
                                  RedesignTokens.accentSage.withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(RedesignTokens.radiusCard),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      RedesignTokens.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: RedesignTokens.space16),
                                Expanded(
                                  child: Text(
                                    'Creating personalized suggestions...',
                                    style: RedesignTokens.body,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: RedesignTokens.space16),

                        // Suggestions section
                        BlocBuilder<FamilyBloc, FamilyState>(
                          builder: (context, state) {
                            if (state is FamilyLoading) {
                              return const SizedBox(
                                height: 200,
                                child: GentleLoadingIndicator(
                                  message: 'Finding wonderful ideas...',
                                ),
                              );
                            }

                            if (state is ProgressiveSuggestionsLoading) {
                              // Show progressive suggestions as they load
                              final suggestions = state.suggestions;
                              
                              return Column(
                                children: [
                                    // Show loading indicator if not complete
                                    if (!state.isComplete)
                                      Container(
                                        margin: const EdgeInsets.only(bottom: 16),
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: RedesignTokens.accentGold.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(RedesignTokens.radiusCard),
                                          border: Border.all(
                                            color: RedesignTokens.accentGold.withOpacity(0.3),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                  RedesignTokens.accentGold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              'Finding more wonderful ideas...',
                                              style: GoogleFonts.spaceGrotesk(
                                                fontSize: 14,
                                                color: RedesignTokens.ink,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    
                                    // Show suggestions as they come in
                                    ...suggestions.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final suggestion = entry.value;
                                    
                                    return AnimatedListItem(
                                      index: index,
                                      delay: const Duration(milliseconds: 80),
                                      child: WhimsicalCard(
                                        hoverScale: 1.005,
                                        child: SimplifiedSuggestionCard(
                                          title: suggestion.activity,
                                          rationale: suggestion.rationale,
                                          durationMinutes: suggestion.durationMinutes,
                                          tags: suggestion.tags,
                                          location: suggestion.location,
                                          distanceMiles: suggestion.distanceMiles,
                                          venueType: suggestion.venueType,
                                          participants: isAllMode 
                                              ? familyMembers
                                              : familyMembers
                                                  .where((m) => selectedParticipants.contains(m.id))
                                                  .toList(),
                                          podName: pods.firstWhere(
                                            (p) => p.id == selectedPodId,
                                            orElse: () => Pod(
                                              id: '',
                                              householdId: '',
                                              name: isAllMode ? 'All' : 'Everyone',
                                              memberIds: [],
                                            ),
                                          ).name,
                                          onTap: () {
                                            final currentParticipants = isAllMode 
                                                ? familyMembers
                                                : familyMembers
                                                    .where((m) => selectedParticipants.contains(m.id))
                                                    .toList();
                                            
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) => IdeaCardDetailModal(
                                                  title: suggestion.activity,
                                                  rationale: suggestion.rationale,
                                                  durationMinutes: suggestion.durationMinutes,
                                                  tags: suggestion.tags,
                                                  location: suggestion.location,
                                                  distanceMiles: suggestion.distanceMiles,
                                                  venueType: suggestion.venueType,
                                                  participants: currentParticipants,
                                                  description: suggestion.description ?? 
                                                      'This is a family-friendly activity perfect for all ages. Expect to spend quality time together with plenty of smiles and laughter. The atmosphere is welcoming and there are facilities nearby.',
                                                  onMakeExperience: () {
                                                    final participantIds = currentParticipants
                                                        .map((m) => m.id ?? '')
                                                        .where((id) => id.isNotEmpty)
                                                        .toList();
                                                    Navigator.pop(context);
                                                    _showCreateExperienceSheet(suggestion, participantIds: participantIds);
                                                  },
                                                ),
                                              ),
                                            );
                                          },
                                          onMakeExperience: (activeParticipantIds) => _showCreateExperienceSheet(suggestion, participantIds: activeParticipantIds),
                                          onParticipantToggle: (memberId, included) {
                                            setState(() {
                                              if (included) {
                                                if (!selectedParticipants.contains(memberId)) {
                                                  selectedParticipants.add(memberId);
                                                }
                                              } else {
                                                selectedParticipants.remove(memberId);
                                              }
                                            });
                                          },
                                          memberFeedback: currentMemberId != null ? () {
                                            final activityKey = suggestion.activity.toLowerCase().trim();
                                            final feedback = _suggestionFeedback[activityKey];
                                            return feedback != null ? {currentMemberId!: feedback} : null;
                                          }() : null,
                                          onFeedback: (feedbackType) {
                                            if (currentMemberId != null) {
                                              SuggestionFeedbackService.saveFeedback(
                                                householdId: householdId!,
                                                memberId: currentMemberId!,
                                                activityName: suggestion.activity,
                                                feedbackType: feedbackType,
                                              );
                                              
                                              setState(() {
                                                final activityKey = suggestion.activity.toLowerCase().trim();
                                                _suggestionFeedback[activityKey] = feedbackType;
                                              });
                                            }
                                          },
                                          onWhyThis: () {
                                            final currentParticipants = isAllMode 
                                                ? familyMembers
                                                : familyMembers
                                                    .where((m) => selectedParticipants.contains(m.id))
                                                    .toList();
                                            
                                            final participantIds = currentParticipants
                                                .map((m) => m.id ?? '')
                                                .where((id) => id.isNotEmpty)
                                                .toList();
                                            
                                            showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              backgroundColor: Colors.transparent,
                                              builder: (context) => WhyThisSheet(
                                                suggestion: suggestion,
                                                allMembers: familyMembers,
                                                activeParticipantIds: participantIds,
                                                currentMemberId: currentMemberId ?? '',
                                                householdId: householdId ?? '',
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ],
                              );
                            }

                            if (state is SuggestionsLoaded) {
                              // Merge current suggestions with saved AI suggestions (deduplicate by activity name)
                              final currentSuggestions = state.suggestions.suggestions;
                              final seenActivities = currentSuggestions.map((s) => s.activity.toLowerCase()).toSet();
                              
                              // Only add saved AI suggestions that aren't already in current suggestions
                              final uniqueSavedSuggestions = _savedAISuggestions
                                  .where((s) => !seenActivities.contains(s.activity.toLowerCase()))
                                  .toList();
                              
                              final allSuggestions = [
                                ...currentSuggestions, // Current suggestions first
                                ...uniqueSavedSuggestions, // Then unique saved AI suggestions
                              ];
                              
                              return Column(
                                children: allSuggestions.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final suggestion = entry.value;
                                  
                              return AnimatedListItem(
                                index: index,
                                delay: const Duration(milliseconds: 80),
                                child: WhimsicalCard(
                                  hoverScale: 1.005, // Very subtle 0.5% scale
                                  child: SimplifiedSuggestionCard(
                                  title: suggestion.activity,
                                  rationale: suggestion.rationale,
                                  durationMinutes: suggestion.durationMinutes,
                                  tags: suggestion.tags,
                                  location: suggestion.location,
                                  distanceMiles: suggestion.distanceMiles,
                                  venueType: suggestion.venueType,
                                  participants: isAllMode 
                                      ? familyMembers // Show all members in "All" mode
                                      : familyMembers
                                          .where((m) => selectedParticipants.contains(m.id))
                                          .toList(),
                                  podName: pods.firstWhere(
                                    (p) => p.id == selectedPodId,
                                    orElse: () => Pod(
                                      id: '',
                                      householdId: '',
                                      name: isAllMode ? 'All' : 'Everyone',
                                      memberIds: [],
                                    ),
                                  ).name,
                                  onTap: () {
                                    // Get current participants from card (excluding toggled off)
                                    final currentParticipants = isAllMode 
                                        ? familyMembers
                                        : familyMembers
                                            .where((m) => selectedParticipants.contains(m.id))
                                            .toList();
                                    
                                    // Show detail modal
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => IdeaCardDetailModal(
                                          title: suggestion.activity,
                                          rationale: suggestion.rationale,
                                          durationMinutes: suggestion.durationMinutes,
                                          tags: suggestion.tags,
                                          location: suggestion.location,
                                          distanceMiles: suggestion.distanceMiles,
                                          venueType: suggestion.venueType,
                                          participants: currentParticipants,
                                          description: suggestion.description ?? 
                                              'This is a family-friendly activity perfect for all ages. Expect to spend quality time together with plenty of smiles and laughter. The atmosphere is welcoming and there are facilities nearby.',
                                          onMakeExperience: () {
                                            // Use the participants displayed in the card
                                            final participantIds = currentParticipants
                                                .map((m) => m.id ?? '')
                                                .where((id) => id.isNotEmpty)
                                                .toList();
                                            Navigator.pop(context);
                                            _showCreateExperienceSheet(suggestion, participantIds: participantIds);
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                  onMakeExperience: (activeParticipantIds) => _showCreateExperienceSheet(suggestion, participantIds: activeParticipantIds),
                                  onParticipantToggle: (memberId, included) {
                                    setState(() {
                                      if (included) {
                                        if (!selectedParticipants.contains(memberId)) {
                                          selectedParticipants.add(memberId);
                                        }
                                      } else {
                                        selectedParticipants.remove(memberId);
                                      }
                                    });
                                  },
                                memberFeedback: currentMemberId != null ? () {
                                  final activityKey = suggestion.activity.toLowerCase().trim();
                                  final feedback = _suggestionFeedback[activityKey];
                                  debugPrint('🔍 Looking up feedback for "$activityKey": $feedback');
                                  return feedback != null ? {currentMemberId!: feedback} : null;
                                }() : null,
                                onFeedback: (action) async {
                                  // Save feedback to database
                                  if (householdId != null && currentMemberId != null) {
                                    await SuggestionFeedbackService.saveFeedback(
                                      householdId: householdId!,
                                      memberId: currentMemberId!,
                                      activityName: suggestion.activity,
                                      feedbackType: action,
                                    );
                                    
                                    // Update local cache
                                    setState(() {
                                      _suggestionFeedback[suggestion.activity.toLowerCase().trim()] = action;
                                    });
                                  }
                                  
                                  switch (action) {
                                    case 'love':
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Saved to Wishbook ❤️')),
                                      );
                                      break;
                                    case 'neutral':
                                      // Don't fetch new suggestion, just neutral rating
                                      break;
                                    case 'not_interested':
                                      // Don't fetch new suggestion, just mark as not interested
                                      break;
                                  }
                                },
                                currentMemberId: currentMemberId,
                                onWhyThis: () {
                                  // Get current participants
                                  final currentParticipants = isAllMode 
                                      ? familyMembers
                                      : familyMembers
                                          .where((m) => selectedParticipants.contains(m.id))
                                          .toList();
                                  
                                  // Get their IDs
                                  final participantIds = currentParticipants
                                      .map((m) => m.id ?? '')
                                      .where((id) => id.isNotEmpty)
                                      .toList();
                                  
                                  // Show Why This sheet
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    isDismissible: true,
                                    enableDrag: true,
                                    backgroundColor: Colors.transparent,
                                    barrierColor: Colors.black.withOpacity(0.4),
                                    builder: (context) => WhyThisSheet(
                                      suggestion: suggestion,
                                      allMembers: familyMembers,
                                      activeParticipantIds: participantIds,
                                      currentMemberId: currentMemberId,
                                      householdId: householdId!,
                                    ),
                                  );
                                },
                                onMenu: () {},
                                  ),
                                ),
                              );
                                }).toList(),
                              );
                            }

                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Gradient fade overlay anchored at bottom (above bottom composer)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 180, // Taller fade gradient
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      RedesignTokens.canvas.withOpacity(0.0), // Fully transparent at top
                      RedesignTokens.canvas.withOpacity(0.7),  // Mid fade
                      RedesignTokens.canvas,                    // Solid at bottom
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
          ),
          
          // Bottom Composer (sticky at bottom)
          Positioned(
            bottom: MediaQuery.of(context).size.width < 900 ? 80 : 0, // Attach to nav bar on mobile
            left: 0,
            right: 0,
            child: BottomComposer(
              onSubmit: (query, tokens) {
                setState(() {
                  customPrompt = query;
                });
                _fetchAISuggestions();
              },
              onVoiceStart: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Voice input coming soon!')),
                );
              },
              onVoiceStop: () {},
              onMagic: _fetchSmartSuggestion,
              isRecording: false,
              currentWeather: weather,
              currentTimeOfDay: timeOfDay,
              currentDayOfWeek: dayOfWeek,
              onWeatherChanged: (value) => setState(() => weather = value),
              onTimeOfDayChanged: (value) => setState(() => timeOfDay = value),
              onDayOfWeekChanged: (value) => setState(() => dayOfWeek = value),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        isIdeasActive: true,
        isMomentsActive: false,
        isPlannerActive: false,
        isTimeActive: false,
        onIdeas: () {
          // Already on home/ideas page
        },
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

  Widget _buildPodChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(RedesignTokens.radiusPill),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: RedesignTokens.space16,
          vertical: RedesignTokens.space8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? RedesignTokens.primary : Colors.transparent,
          border: Border.all(
            color: isSelected ? RedesignTokens.primary : RedesignTokens.divider,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(RedesignTokens.radiusPill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? RedesignTokens.onPrimary : RedesignTokens.slate,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: RedesignTokens.meta.copyWith(
                color: isSelected ? RedesignTokens.onPrimary : RedesignTokens.slate,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForPod(String? iconName) {
    switch (iconName) {
      case 'family':
        return Icons.family_restroom;
      case 'people':
        return Icons.people;
      case 'child':
        return Icons.child_care;
      case 'person':
        return Icons.person;
      case 'school':
        return Icons.school;
      case 'sports':
        return Icons.sports;
      default:
        return Icons.group;
    }
  }
}
