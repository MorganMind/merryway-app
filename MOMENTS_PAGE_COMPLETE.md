# Moments Page - Complete Documentation

## Overview

The **Moments Page** is a comprehensive view of both planned and completed family activities. It provides a unified interface for viewing upcoming experiences and browsing your family's activity history.

---

## Features

### 📅 **Upcoming Tab**
Shows planned experiences that have been accepted but not yet started:
- **Countdown timers** - "In 2 hours", "Tomorrow", "In 3 days"
- **Scheduled date/time** - Full details of when the activity is planned
- **Location** - Where the activity will take place
- **Prep notes** - Reminders like "Bring snacks and soccer ball"
- **Participants** - Who's joining this experience
- **Visual indicators** - Golden accent to highlight upcoming plans

### ✅ **Completed Tab**
Shows all finished activities and memories:
- **Completed Experiences** - Activities that were planned and finished
- **Manual Merry Moments** - Journal entries added by users
- **Chronological sorting** - Most recent activities first
- **Visual distinction** - Different icons for auto-created vs manual entries
- **Photo indicators** - Shows how many photos are attached
- **Date labels** - "Today", "Yesterday", "3 days ago", "2 weeks ago"

---

## Navigation

### Access the Moments Page:

**Option 1: From Home Page**
```
Home AppBar → 🎉 Celebration Icon → Moments Page
```

**Option 2: From Settings**
```
Settings → Family Time Health Section → Moments → Moments Page
```

---

## Data Flow

### What Shows in Upcoming:
1. User taps "Make it an Experience" on a suggestion
2. Selects "Plan for Later" (not "Now")
3. Chooses participants, time, place, prep notes
4. Experience is created with `status: 'planned'`
5. **Appears in Upcoming Tab** ✨

### What Shows in Completed:
1. **From Completed Experiences:**
   - User marks experience as "Done"
   - System sets `status: 'done'`, `end_at: timestamp`
   - Optionally creates a Merry Moment with review
   - **Appears in Completed Tab** ✨

2. **From Manual Journaling:**
   - User taps "Journal" FAB
   - Enters activity details (or uses AI parsing)
   - System creates `MerryMoment` with `is_manual: true`
   - **Appears in Completed Tab** ✨

---

## UI Components

### Card Types

#### 1. Upcoming Experience Card
- **Golden gradient** background (subtle)
- **Schedule icon** (⏰) in golden accent
- **Time until** text in bold golden color
- **Date/time** with calendar icon
- **Place** with location pin icon
- **Prep notes** in light blue info box
- **Participant chips** with avatars

#### 2. Completed Experience Card
- **White background** with soft shadow
- **Check circle icon** (✅) in soft blue
- **"Days since"** text ("Yesterday", "3 days ago")
- **Date** in muted text
- **Place** with location pin
- **Participant chips** with avatars

#### 3. Merry Moment Card
- **White background** with soft shadow
- **Icon varies:**
  - ✏️ Edit icon for manual entries (lavender)
  - 🎊 Celebration icon for auto-created (golden)
- **Description** text if present
- **Place** with location pin
- **Participant chips** with avatars
- **Photo count badge** if photos attached

---

## Code Structure

### Files Created/Modified

```
lib/modules/experiences/pages/
  ├── moments_page.dart                  [NEW] Main Moments page with tabs
  └── merry_moments_page.dart            [EXISTING] Original implementation

lib/modules/experiences/widgets/
  └── add_manual_moment_sheet.dart       [MODIFIED] Fixed theme imports

lib/modules/core/routing/
  └── app_router.dart                    [MODIFIED] Added /moments route

lib/modules/home/pages/
  └── home_page.dart                     [MODIFIED] Added Moments icon button

lib/modules/settings/pages/
  └── simple_settings_page.dart          [MODIFIED] Added Moments list tile
```

### Key Models

```dart
// Experience (from experience_models.dart)
class Experience {
  String? id;
  String householdId;
  String? activityName;
  List<String> participantIds;
  DateTime? startAt;
  DateTime? endAt;
  String? place;
  String? prepNotes;
  String status; // 'planned', 'live', 'done', 'cancelled'
}

// MerryMoment (from experience_models.dart)
class MerryMoment {
  String? id;
  String householdId;
  String? experienceId;
  String title;
  String? description;
  List<String> participantIds;
  DateTime occurredAt;
  String? place;
  bool isManual;
  List<String> mediaIds;
}
```

---

## Backend Requirements

### Supabase Tables Used

**1. `experiences`** (existing)
- Stores planned and completed experiences
- Queried by `status` field ('planned', 'done')

**2. `merry_moments`** (existing)
- Stores all memory entries
- Both auto-created (from experiences) and manual

### API Calls

```dart
// Fetch planned experiences
await ExperienceRepository().listExperiences(householdId, status: 'planned');

// Fetch completed experiences
await ExperienceRepository().listExperiences(householdId, status: 'done');

// Fetch all merry moments
await supabase
  .from('merry_moments')
  .select()
  .eq('household_id', householdId)
  .order('occurred_at', ascending: false);
```

---

## User Flows

### Flow 1: View Upcoming Plans
```
1. User opens Moments page
2. "Upcoming" tab is default
3. User sees list of planned experiences
4. Each card shows countdown and details
5. User can tap card to view full details (future: edit/cancel)
```

### Flow 2: Browse Completed History
```
1. User taps "Completed" tab
2. User sees chronological list of:
   - Completed experiences
   - Manual journal entries
3. Each card shows date, participants, place
4. Photo indicators show if media attached
5. User can tap card to view full details (future: view photos/reviews)
```

### Flow 3: Add Manual Memory
```
1. User taps "Journal" FAB (floating action button)
2. Sheet opens with input fields
3. User enters:
   - Title/description
   - Participants (select from family)
   - Place (optional)
   - Date (defaults to today)
4. Optional: Parse with AI for natural language input
5. User taps "Save"
6. Moment appears immediately in Completed tab
```

---

## Future Enhancements

### Short-term (Phase 4+):
- [ ] Tap card to view full details (modal or page)
- [ ] View photos/videos in gallery view
- [ ] View experience review (rating, notes)
- [ ] Edit/cancel planned experiences
- [ ] Delete manual moments
- [ ] Filter/search by participant or place

### Medium-term:
- [ ] Calendar view of planned experiences
- [ ] Export to device calendar (.ics)
- [ ] Share moment via link
- [ ] Add photos to existing moments
- [ ] Tag moments with categories

### Long-term:
- [ ] Slideshow/memory reel
- [ ] Yearly recap ("Year in Moments")
- [ ] Collaborative moment creation
- [ ] Voice notes attached to moments

---

## Testing Checklist

- [x] Page loads without errors
- [x] Upcoming tab shows planned experiences
- [x] Completed tab shows done experiences + moments
- [x] Empty states display correctly
- [x] Pull-to-refresh works on both tabs
- [x] Tab badges show correct counts
- [x] Journal FAB opens manual moment sheet
- [x] Navigation from home page works
- [x] Navigation from settings page works
- [x] Cards display all information correctly
- [x] Date formatting is correct ("Today", "Yesterday", etc.)
- [x] Participant avatars render properly
- [x] Theme colors are consistent

---

## Known Issues

None currently! 🎉

---

## Summary

The Moments page provides a unified view of your family's activity timeline:
- **Upcoming Tab**: What's planned and coming soon
- **Completed Tab**: Your family's activity history and memories

It integrates seamlessly with the existing experience and moment creation flows, providing a central hub for tracking both future plans and past memories.

**Status**: ✅ **Complete and ready to use!**

