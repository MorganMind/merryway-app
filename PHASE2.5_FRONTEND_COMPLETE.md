# Phase 2.5 Frontend - IMPLEMENTATION COMPLETE

## ✅ Components Created

### 1. **Offline Feedback Queue**
**File:** `lib/modules/home/services/offline_feedback_queue.dart`

- Queue feedback when offline
- Store in SharedPreferences
- Track sync status
- Clear synced items

**Features:**
- `addFeedback()` - Queue locally
- `getPendingFeedback()` - Get unsynced items
- `markSynced()` - Mark as uploaded
- `clearSynced()` - Clean up
- `getQueueSize()` - Count pending

---

### 2. **Feedback Sync Service**
**File:** `lib/modules/home/services/feedback_sync_service.dart`

- Monitor connectivity changes
- Auto-sync when online
- Batch upload pending feedback
- Report sync results

**Features:**
- `startSyncMonitor()` - Watch connectivity
- `syncPendingFeedback()` - Upload queue
- `isOnline()` - Check status

---

### 3. **Dependencies Added**
**File:** `pubspec.yaml`

```yaml
connectivity_plus: ^5.0.0  # Network monitoring
```

Run: `flutter pub get`

---

## 🎯 Frontend Integration Ready

### Backend Endpoints Needed:

**Existing (already used):**
```
POST /api/v1/feedback/
```

**New (for Phase 3 - Analytics):**
```
GET /api/v1/household/engagement/?id=HOUSEHOLD_ID&days=30
GET /api/v1/household/preferences/?id=HOUSEHOLD_ID&days=30
GET /api/v1/activities/performance/?id=HOUSEHOLD_ID&days=30
```

---

## 📱 How Offline Queue Works

### User Flow:

```
1. User gives feedback
   ↓
2. Check network status
   ├─ Online → Send immediately
   └─ Offline → Queue locally
   ↓
3. Show appropriate message
   ├─ "Thanks for feedback! 👍"
   └─ "Saved offline - will sync when online 📱"
   ↓
4. When network returns
   → Auto-sync all queued feedback
   ↓
5. Clear successfully synced items
```

### Code Integration:

```dart
// In home_page.dart or similar:

// 1. Initialize sync service
late FeedbackSyncService feedbackSyncService;

@override
void initState() {
  super.initState();
  feedbackSyncService = FeedbackSyncService();
  feedbackSyncService.startSyncMonitor();  // Auto-sync on reconnect
  _checkPendingFeedback();  // Sync any queued on startup
}

// 2. Check for pending feedback on startup
Future<void> _checkPendingFeedback() async {
  final queueSize = await OfflineFeedbackQueue.getQueueSize();
  if (queueSize > 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Syncing $queueSize offline feedback...'),
        duration: const Duration(seconds: 3),
      ),
    );
    await feedbackSyncService.syncPendingFeedback();
  }
}

// 3. Submit feedback (handles offline automatically)
Future<void> _submitFeedback(
  String suggestionId,
  String activityId,
  String action,
  int? rating,
) async {
  try {
    final isOnline = await feedbackSyncService.isOnline();

    if (isOnline) {
      // Try immediate sync
      await feedbackSyncService.dio.post(
        '${feedbackSyncService.baseUrl}/feedback/',
        data: {
          'suggestion_id': suggestionId,
          'activity_id': activityId,
          'action': action,
          if (rating != null) 'rating': rating,
        },
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thanks for feedback! 👍')),
      );
    } else {
      // Queue offline
      await OfflineFeedbackQueue.addFeedback(
        suggestionId: suggestionId,
        activityId: activityId,
        action: action,
        rating: rating,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saved offline - will sync when online 📱'),
        ),
      );
    }
  } catch (e) {
    // Network error → fall back to queue
    await OfflineFeedbackQueue.addFeedback(
      suggestionId: suggestionId,
      activityId: activityId,
      action: action,
      rating: rating,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Queued offline: $e')),
    );
  }
}
```

---

## 🧪 Testing Offline Mode

### In Flutter DevTools:

1. **Open DevTools** (in browser or IDE)
2. **Go to Network tab**
3. **Toggle "Offline" mode**
4. **Give feedback** → Should queue
5. **Toggle back online** → Should auto-sync
6. **Check console** for "Syncing X offline feedback..."

### Manual Testing:

```dart
// Test 1: Queue feedback
await OfflineFeedbackQueue.addFeedback(
  suggestionId: 'test-123',
  activityId: 'activity-456',
  action: 'accept',
  rating: 5,
);

// Test 2: Check queue
final pending = await OfflineFeedbackQueue.getPendingFeedback();
print('Pending: ${pending.length}');  // Should be 1

// Test 3: Sync
final service = FeedbackSyncService();
final result = await service.syncPendingFeedback();
print('Synced: ${result.synced}, Failed: ${result.failed}');

// Test 4: Queue should be empty
final afterSync = await OfflineFeedbackQueue.getPendingFeedback();
print('After sync: ${afterSync.length}');  // Should be 0
```

---

## 🚀 Phase 3 Preview: Analytics Dashboard

The offline queue sets the foundation for rich analytics! When you're ready:

### Analytics Components (Coming Next):

1. **AnalyticsRepository** - Fetch metrics from backend
2. **AnalyticsBloc** - Manage analytics state
3. **AnalyticsPage** - Main dashboard UI
4. **Engagement Chart** - Visual metrics
5. **Participant Stats** - Individual preferences
6. **Activity Rankings** - Top performing activities

### Mock Analytics View:

```
┌──────────────────────────────────────┐
│ Family Insights        [Last 30 days]│
├──────────────────────────────────────┤
│ 📊 Engagement                        │
│ ┌────────┬────────┬────────┐         │
│ │   42   │  78%   │  4.5   │         │
│ │ Ideas  │Accept  │Rating  │         │
│ └────────┴────────┴────────┘         │
│                                      │
│ 👨‍👩‍👧‍👦 Who Loves What?                   │
│ ┌────────────────────────────────┐   │
│ │ Alice (7)              92% ⭐4.8│   │
│ │ Loves: Park, Crafts, Stories   │   │
│ ├────────────────────────────────┤   │
│ │ Bob (5)                85% ⭐4.5│   │
│ │ Loves: Biking, Games, Movies   │   │
│ └────────────────────────────────┘   │
│                                      │
│ 🏆 Top Activities                    │
│ 1. 🥇 Sunset picnic      95% ⭐4.9  │
│ 2. 🥈 Board games        88% ⭐4.7  │
│ 3. 🥉 Craft time         82% ⭐4.5  │
└──────────────────────────────────────┘
```

---

## 📊 Current Status

| Component | Status | Notes |
|-----------|--------|-------|
| Offline Queue | ✅ Complete | Ready for use |
| Sync Service | ✅ Complete | Auto-syncs on reconnect |
| connectivity_plus | ✅ Added | Monitors network |
| Analytics (Optional) | 🔜 Phase 3 | Can build on queue |
| Vector Search | 🔙 Backend only | N/A for frontend |
| Multi-Armed Bandit | 🔙 Backend only | N/A for frontend |

---

## 🎯 What's Next

### For Immediate Use:
1. **Integrate into existing home page** (see code example above)
2. **Test offline mode** in DevTools
3. **Verify sync on reconnect**

### For Phase 3 (Optional):
1. **Build analytics dashboard** (if backend supports it)
2. **Add charts/visualizations** (fl_chart package)
3. **Show family insights** in settings

---

## 🛡️ Error Handling

The offline queue gracefully handles:

- **Network failures** → Queues automatically
- **Server errors** → Retries on next sync
- **App restarts** → Persists in SharedPreferences
- **Partial syncs** → Continues with remaining items

---

## 💡 Pro Tips

1. **Queue Size Indicator:**
   ```dart
   // Show badge on settings icon
   FutureBuilder<int>(
     future: OfflineFeedbackQueue.getQueueSize(),
     builder: (context, snapshot) {
       final count = snapshot.data ?? 0;
       return Badge(
         label: Text('$count'),
         isLabelVisible: count > 0,
         child: Icon(Icons.settings),
       );
     },
   )
   ```

2. **Manual Sync Button:**
   ```dart
   IconButton(
     icon: Icon(Icons.sync),
     onPressed: () async {
       final result = await feedbackSyncService.syncPendingFeedback();
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text(result.message)),
       );
     },
   )
   ```

3. **Clear Old Queue (Maintenance):**
   ```dart
   // Clear items older than 7 days
   final queue = await OfflineFeedbackQueue.getPendingFeedback();
   final old = queue.where((item) {
     return DateTime.now().difference(item.createdAt).inDays > 7;
   });
   // Delete old items...
   ```

---

**Phase 2.5 Offline Features: COMPLETE! 🎉**

Ready to handle flaky networks and offline users like a pro!

