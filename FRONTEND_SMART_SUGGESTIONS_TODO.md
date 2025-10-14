# Frontend Implementation: Smart Location Suggestions

## Status: READY TO IMPLEMENT

✅ **Backend Code Complete** - See `BACKEND_SMART_SUGGESTIONS.md`
✅ **Location Models Created** - `lib/modules/location/models/location_model.dart`
✅ **Proximity Manager Created** - `lib/modules/location/services/proximity_manager.dart`

---

## Remaining Frontend Tasks

### 1. Update `pubspec.yaml` Dependencies

Add these dependencies:

```yaml
dependencies:
  # Existing dependencies...
  
  # Location & Proximity
  geolocator: ^10.1.0
  permission_handler: ^11.1.0
```

### 2. Platform-Specific Configuration

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Merryway uses your coarse location to suggest activities near your defined places like Home or School. Location data never leaves your device.</string>
```

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### 3. Create Smart Suggestion Card Widget

**File**: `lib/modules/home/widgets/smart_suggestion_card.dart`

This widget will:
- Display the featured activity with golden border
- Show location label and nearby members
- Include reasoning and confidence
- Have dismiss and activate buttons
- Show debug info (optional toggle)
- Appear at top of home page

### 4. Create Location Privacy Settings Page

**File**: `lib/modules/settings/pages/location_privacy_page.dart`

Features:
- Privacy-first info card
- Toggle for auto suggestions
- Toggle for location sharing
- Toggle for Bluetooth detection
- Toggle for WiFi detection
- Save to backend API

### 5. Update RulesService

**File**: `lib/modules/family/services/rules_service.dart`

Add methods:
```dart
Future<Map<String, dynamic>> smartSuggestion({
  required String householdId,
  required String locationLabel,
  required List<String> nearbyMemberIds,
  required String timeBucket,
  required String dayType,
  required String dayOfWeek,
  required double confidence,
  required List<String> signalsUsed,
  required String reason,
  required String weather,
});

Future<void> logSmartSuggestionAction({
  required String logId,
  required String action,  // 'dismissed' or 'activated'
});

Future<LocationPrivacySettings> getLocationPrivacy(String memberId);

Future<void> setLocationPrivacy(LocationPrivacySettings settings);
```

### 6. Update HomePage

**File**: `lib/modules/home/pages/home_page.dart`

Changes:
- Add `ProximityManager` instance
- Add `ProximityState? currentProximityState`
- Add `ActivitySuggestion? smartSuggestedActivity`
- Add `String? smartSuggestLogId`
- Add `bool showSmartSuggestion`
- Initialize proximity tracking in `initState()`
- Add callback for proximity changes
- Fetch smart suggestion from backend
- Display `SmartSuggestionCard` at top
- Handle dismiss and activate actions

### 7. Add Location Management to Settings

**File**: `lib/modules/settings/pages/simple_settings_page.dart`

Add:
- Link to Location Privacy settings
- List of defined locations
- Add/edit location functionality
- Store coordinates locally (SharedPreferences)
- Sync labels to backend

---

## Implementation Priority

1. ✅ **Backend** (DONE - see BACKEND_SMART_SUGGESTIONS.md)
2. ✅ **Models** (DONE)
3. ✅ **ProximityManager** (DONE)
4. **Update pubspec.yaml** ← START HERE
5. **Configure iOS/Android permissions**
6. **Create SmartSuggestionCard widget**
7. **Update RulesService API calls**
8. **Integrate into HomePage**
9. **Create LocationPrivacyPage**
10. **Add to Settings**

---

## Data Flow

```
┌─────────────────────────────────────────────────┐
│ Device (Privacy-First)                          │
│                                                  │
│ 1. GPS → Coarse Location (200m)                │
│ 2. Check Geofences (on-device)                 │
│ 3. Detect WiFi/Bluetooth (on-device)           │
│ 4. Build ProximityState                        │
│ 5. Check Dwell Time (30s)                      │
│ 6. Check Cooldown (60s)                        │
│                                                  │
│ IF STABLE:                                      │
│   ↓                                             │
│ 7. Send coarse label ("near School")           │
│    + member IDs                                 │
│    + confidence, signals                        │
│    TO BACKEND                                   │
└─────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────┐
│ Backend (Django)                                │
│                                                  │
│ 1. Receive coarse data (no coordinates)        │
│ 2. Check privacy opt-in for all members        │
│ 3. Check cooldown                               │
│ 4. Find/create pod for members                 │
│ 5. Generate pod-aware suggestions               │
│ 6. Apply policy checks                          │
│ 7. Return first valid activity                  │
│ 8. Log (coarse data only)                       │
└─────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────┐
│ Device (Display)                                │
│                                                  │
│ 1. Receive activity suggestion                  │
│ 2. Display SmartSuggestionCard                  │
│ 3. User can dismiss or activate                 │
│ 4. Log action to backend                        │
└─────────────────────────────────────────────────┘
```

---

## Privacy Guarantees

✅ **Coordinates stored on device only**
✅ **Only coarse labels sent to backend** ("near School")
✅ **Opt-in required for all members**
✅ **Dwell time prevents false positives**
✅ **Cooldown prevents spam**
✅ **Confidence threshold ensures quality**
✅ **Debug mode for transparency**

---

## Next Steps

1. **For Backend**: Copy code from `BACKEND_SMART_SUGGESTIONS.md` to your Django project
2. **For Frontend**: Complete the remaining tasks above
3. **Test**: Use debug mode to verify location detection
4. **Privacy**: Ensure all members opt in via settings

---

Would you like me to implement any of the remaining frontend files now?

