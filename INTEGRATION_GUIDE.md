# Merryway Redesign - Integration Guide

## ✅ Completed Components

All UI components for Phases 1-3 have been created:

### Phase 1: Foundation
- ✅ `lib/modules/core/theme/redesign_tokens.dart` - Design system tokens
- ✅ `lib/modules/home/widgets/compact_header.dart` - New header bar
- ✅ `lib/modules/home/widgets/sticky_pod_row.dart` - Sticky pod chips
- ✅ `lib/modules/home/widgets/simplified_suggestion_card.dart` - New card layout

### Phase 2: Intelligence Layer
- ✅ `lib/modules/home/widgets/feedback_bar.dart` - Heart/neutral/hide controls
- ✅ `lib/modules/home/widgets/inline_participants_editor.dart` - Per-card participant editing

### Phase 3: Conversational UX
- ✅ `lib/modules/home/widgets/bottom_composer.dart` - ChatGPT-style search

---

## 🔄 Integration Steps for `home_page.dart`

### Step 1: Add Imports

Add to the top of `home_page.dart`:

```dart
import 'widgets/compact_header.dart';
import 'widgets/sticky_pod_row.dart';
import 'widgets/simplified_suggestion_card.dart';
import 'widgets/feedback_bar.dart';
import 'widgets/inline_participants_editor.dart';
import 'widgets/bottom_composer.dart';
import '../core/theme/redesign_tokens.dart';
```

### Step 2: Update Scaffold Background Color

Replace:
```dart
backgroundColor: MerryWayTheme.softBg,
```

With:
```dart
backgroundColor: RedesignTokens.canvas,
```

### Step 3: Replace the Build Method Structure

The new structure should be:

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: RedesignTokens.canvas,
    body: Stack(
      children: [
        // Main content
        SafeArea(
          child: Column(
            children: [
              // Compact Header (sticky)
              CompactHeader(
                greeting: _getGreeting(),
                familyName: householdName,
                onSmartSuggestion: _fetchSmartSuggestion,
                onFamilyHealth: () {
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
                onSettings: () => context.push('/settings'),
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

              // Sticky Pod Row
              StickyPodRow(
                pods: pods,
                selectedPodId: selectedPodId,
                isAllMode: isAllMode,
                onPodSelected: (podId, isAll) {
                  setState(() {
                    selectedPodId = podId;
                    isAllMode = isAll;
                  });
                  _fetchNewSuggestion();
                },
                onManagePods: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PodsManagementPage(
                        householdId: householdId!,
                        currentMemberId: currentMemberId,
                      ),
                    ),
                  ).then((_) => _loadPods());
                },
              ),

              // Scrollable content area
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: RedesignTokens.space16),
                      
                      // Live/Upcoming experiences (if any)
                      ...liveExperiences.map((exp) => LiveExperienceCard(
                        experience: exp,
                        allMembers: familyMembers,
                        onComplete: _handleExperienceComplete,
                        onCancel: _handleExperienceCancel,
                      )),
                      
                      // Smart suggestion (if available)
                      if (showSmartSuggestion && smartSuggestionData != null)
                        SmartSuggestionCard(
                          data: smartSuggestionData!,
                          onDismiss: _dismissSmartSuggestion,
                          onTryIt: () {
                            // Handle smart suggestion acceptance
                          },
                        ),
                      
                      // AI suggestions loading banner
                      if (isLoadingAISuggestions)
                        Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: RedesignTokens.getGutter(
                              MediaQuery.of(context).size.width,
                            ),
                          ),
                          padding: const EdgeInsets.all(RedesignTokens.space24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                RedesignTokens.accentGold.withOpacity(0.1),
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
                                    RedesignTokens.accentGold,
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
                      
                      // Suggestion cards
                      BlocBuilder<FamilyBloc, FamilyState>(
                        builder: (context, state) {
                          if (state is SuggestionsLoaded) {
                            return Column(
                              children: state.response.suggestions.map((suggestion) {
                                return Stack(
                                  children: [
                                    SimplifiedSuggestionCard(
                                      title: suggestion.activity,
                                      rationale: suggestion.rationale,
                                      durationMinutes: suggestion.durationMinutes,
                                      tags: suggestion.tags,
                                      location: suggestion.location,
                                      distanceMiles: suggestion.distanceMiles,
                                      venueType: suggestion.venueType,
                                      participants: familyMembers
                                          .where((m) => selectedParticipants.contains(m.id))
                                          .toList(),
                                      podName: pods
                                          .firstWhere((p) => p.id == selectedPodId,
                                              orElse: () => Pod(
                                                    id: '',
                                                    householdId: '',
                                                    name: 'All',
                                                    memberIds: [],
                                                  ))
                                          .name,
                                      onMakeExperience: () => _showCreateExperienceSheet(suggestion),
                                      onWishbook: () {
                                        // TODO: Add to wishbook
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Added to Wishbook!')),
                                        );
                                      },
                                      onSkip: () => _fetchNewSuggestion(),
                                      onEditParticipants: () {
                                        // Show participants editor sheet
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder: (context) => ParticipantsEditorSheet(
                                            allMembers: familyMembers,
                                            selectedMemberIds: selectedParticipants,
                                            onSave: (newSelection) {
                                              setState(() {
                                                selectedParticipants = newSelection;
                                              });
                                            },
                                          ),
                                        );
                                      },
                                      onMenu: () {
                                        // Show menu options
                                      },
                                    ),
                                    
                                    // Feedback Bar (overlay on card)
                                    FeedbackBar(
                                      onAction: (action) {
                                        switch (action) {
                                          case FeedbackAction.like:
                                            // Add to wishbook + positive signal
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Saved to Wishbook ❤️'),
                                              ),
                                            );
                                            break;
                                          case FeedbackAction.neutral:
                                            // Soft skip
                                            _fetchNewSuggestion();
                                            break;
                                          case FeedbackAction.hide:
                                            // Hide with reason
                                            _fetchNewSuggestion();
                                            break;
                                        }
                                      },
                                      alwaysVisible: MediaQuery.of(context).size.width < 768,
                                    ),
                                  ],
                                );
                              }).toList(),
                            );
                          }
                          
                          if (state is FamilyLoading) {
                            return SizedBox(
                              height: 200,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: RedesignTokens.accentGold,
                                ),
                              ),
                            );
                          }
                          
                          return const SizedBox.shrink();
                        },
                      ),
                      
                      const SizedBox(height: 120), // Space for bottom composer
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Bottom Composer (sticky at bottom)
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: BottomComposer(
            onSubmit: (query, tokens) {
              // Handle submission
              setState(() {
                customPrompt = query;
              });
              _fetchAISuggestions();
            },
            onVoiceStart: () {
              // Start voice recording
              setState(() {
                // isRecording = true;
              });
            },
            onVoiceStop: () {
              // Stop voice recording
              setState(() {
                // isRecording = false;
              });
            },
            onMagic: () {
              // Show magic suggestions
              _fetchSmartSuggestion();
            },
            isRecording: false, // Update with actual state
          ),
        ),
      ],
    ),
  );
}
```

---

## 🧪 Testing Checklist

- [ ] Header displays greeting + family name correctly
- [ ] Pod row is sticky and switches pods correctly
- [ ] Suggestion cards display all information
- [ ] Feedback bar appears and animates
- [ ] Participants editor opens and saves
- [ ] Bottom composer accepts input and submits
- [ ] Voice button toggles (UI only, needs backend)
- [ ] Magic button triggers smart suggestions
- [ ] All touch targets ≥ 44px
- [ ] Respects design tokens throughout

---

## 📝 Notes

1. **Voice Input**: UI is ready, but actual voice-to-text requires platform-specific implementation
2. **Wishbook**: Backend integration needed
3. **Policy Guards**: Logic needs to be implemented in the participants editor
4. **Analytics**: Hooks are in place but need backend endpoints

---

## 🚀 Next Steps

1. Hot reload and test each component
2. Implement backend endpoints for feedback actions
3. Add voice-to-text implementation
4. Implement wishbook functionality
5. Add policy guard logic
6. Connect analytics hooks

