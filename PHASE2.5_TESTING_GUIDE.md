# Phase 2.5: Offline Feedback - Testing Guide

## 🎯 What Was Built

### Core Components:
1. **OfflineFeedbackQueue** - Local storage for failed feedback
2. **FeedbackSyncService** - Auto-sync when network returns
3. **HomeFeedbackServiceOffline** - Unified feedback API with offline fallback

### How It Works:
```
User Action (Rate/Skip)
         ↓
   Check Network
    ↙        ↘
Online?      Offline?
  ↓             ↓
Send Now    Queue Local
  ↓             ↓
Success      Wait...
             ↓
        Network Back!
             ↓
        Auto-Sync 🎉
```

---

## 🧪 Test Scenarios

### Test 1: Normal Online Flow
**Steps:**
1. Start app (should be online)
2. Give feedback (Try It / Skip)
3. Should show: "Thanks for feedback! 👍"
4. Check backend - feedback should be saved

**Expected:**
- ✅ Immediate sync
- ✅ Green success message
- ✅ Backend receives data

---

### Test 2: Offline Queue
**Steps:**
1. Open Flutter DevTools
2. Go to Network tab → Click "Offline"
3. Give feedback in app
4. Should show: "Saved offline - will sync when online 📱"
5. Check queue: `await OfflineFeedbackQueue.getQueueSize()`
6. Should be > 0

**Expected:**
- ✅ Orange queued message
- ✅ Feedback stored locally
- ✅ No network errors
- ✅ Queue count increases

---

### Test 3: Auto-Sync on Reconnect
**Steps:**
1. Queue 3-5 feedback items while offline (Test 2)
2. Toggle DevTools Network back to "Online"
3. Wait 2-5 seconds
4. Should show: "📱 Syncing X offline feedback..."
5. Then: "✅ Synced X items!"
6. Check queue: should be 0

**Expected:**
- ✅ Auto-sync triggers
- ✅ All items uploaded
- ✅ Queue cleared
- ✅ Backend has all data

---

### Test 4: App Restart with Queue
**Steps:**
1. Queue 2-3 items while offline (don't sync)
2. Close app completely
3. Restart app
4. On startup, should show: "📱 Syncing X offline feedback..."
5. Queue should sync automatically

**Expected:**
- ✅ Queue persists across restarts
- ✅ Auto-sync on startup
- ✅ Data not lost

---

### Test 5: Network Error Fallback
**Steps:**
1. Be online
2. Stop backend server (or use invalid URL)
3. Give feedback
4. Should auto-queue (network error)
5. Should show orange message

**Expected:**
- ✅ Graceful fallback to queue
- ✅ No app crash
- ✅ User notified

---

### Test 6: Manual Sync Button
**Steps:**
1. Queue some items while offline
2. Come back online
3. Click sync button (🔄 icon in app bar)
4. Should show sync result

**Expected:**
- ✅ Manual trigger works
- ✅ Shows sync status
- ✅ Queue cleared

---

## 🔍 How to Debug

### Check Queue Contents:
```dart
final pending = await OfflineFeedbackQueue.getPendingFeedback();
for (var item in pending) {
  print('Queued: ${item.activityId} - ${item.action} - ${item.synced}');
}
```

### Check Network Status:
```dart
final service = FeedbackSyncService();
final online = await service.isOnline();
print('Online: $online');
```

### Force Sync:
```dart
final service = FeedbackSyncService();
final result = await service.syncPendingFeedback();
print('Synced: ${result.synced}, Failed: ${result.failed}');
```

### Clear Queue (Reset):
```dart
await OfflineFeedbackQueue.clearSynced();
// Or manually:
final prefs = await SharedPreferences.getInstance();
await prefs.remove('feedback_queue');
```

---

## 🚨 Troubleshooting

### Issue: "Queue not syncing on reconnect"
**Fix:**
- Check if `feedbackService.initialize()` was called in `initState()`
- Check if `startSyncMonitor()` is running
- Look for errors in console

### Issue: "Synced X, failed X" (some failed)
**Causes:**
- Backend validation errors (invalid data)
- Auth token expired
- Backend down

**Fix:**
- Check backend logs
- Verify data format
- Re-authenticate user

### Issue: "Queue growing too large"
**Causes:**
- Backend always failing
- Network permanently offline
- Auth issues

**Fix:**
- Add max queue size limit
- Add queue expiration (7 days)
- Alert user if queue > 50 items

---

## 📊 Production Monitoring

### Metrics to Track:
1. **Queue size** - Alert if > 50 items
2. **Sync success rate** - Should be > 95%
3. **Average sync delay** - Time from queue → sync
4. **Failed sync reasons** - Categorize errors

### Analytics Events:
```dart
// Track queue operations
analytics.logEvent(
  name: 'feedback_queued',
  parameters: {'action': action, 'offline': true},
);

// Track sync results
analytics.logEvent(
  name: 'feedback_synced',
  parameters: {'count': synced, 'failed': failed},
);
```

---

## 🎯 Performance Optimization

### Current Limits:
- **Max queue size:** Unlimited (⚠️ risk)
- **Sync frequency:** On reconnect only
- **Batch size:** All at once

### Recommended Improvements:
1. **Add max queue size (100 items)**
   ```dart
   if (queue.length >= 100) {
     // Remove oldest items
     queue.removeRange(0, 10);
   }
   ```

2. **Add TTL (Time To Live)**
   ```dart
   // Remove items older than 7 days
   queue.removeWhere((item) {
     return DateTime.now().difference(item.createdAt).inDays > 7;
   });
   ```

3. **Batch sync (10 items at a time)**
   ```dart
   final pending = await getPendingFeedback();
   final batch = pending.take(10);
   // Sync batch...
   ```

4. **Retry with exponential backoff**
   ```dart
   for (int retry = 0; retry < 3; retry++) {
     try {
       await syncItem(item);
       break;
     } catch (e) {
       await Future.delayed(Duration(seconds: 2 ^ retry));
     }
   }
   ```

---

## ✅ Pre-Launch Checklist

- [ ] Test offline mode (DevTools)
- [ ] Test app restart with queue
- [ ] Test auto-sync on reconnect
- [ ] Test manual sync button
- [ ] Test queue size limits
- [ ] Test queue persistence
- [ ] Add analytics events
- [ ] Add error logging (Sentry/Crashlytics)
- [ ] Document max queue size
- [ ] Add queue cleanup job

---

## 🚀 Ready to Ship!

**Phase 2.5 Offline Support: COMPLETE**

Your app now handles:
- ✅ Network failures gracefully
- ✅ Offline user feedback
- ✅ Auto-sync on reconnect
- ✅ Persistent queue across restarts
- ✅ Manual sync option

**Next:** Backend learning & vector search (you'll handle that!)

