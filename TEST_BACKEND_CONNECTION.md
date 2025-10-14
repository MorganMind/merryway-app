# Test Backend Connection

## What "No metrics returned from backend" means:

This error means:
- ✅ The API call succeeded (no network error)
- ✅ Authentication worked (no 401/403)
- ❌ But the backend returned `null` or empty data

---

## 🔍 Check These Things:

### 1. What's the actual HTTP status code?

**Look in your browser console** (F12 → Console tab) for:
```
🔵 Fetching family health metrics...
  Response status: ???
  Response body: ???
```

**If you see:**

#### **Status 404**
```
Response status: 404
Response body: {"detail": "Not Found"}
```
➡️ **Problem:** Django endpoint doesn't exist yet.

**Solution:** Your Django backend needs the `/api/v1/family-health/metrics/` endpoint.

Check if you have this in your Django `urls.py`:
```python
path('family-health/metrics/', views.get_family_health_metrics, name='family_health_metrics'),
```

#### **Status 200 with empty/null body**
```
Response status: 200
Response body: null
```
or
```
Response status: 200
Response body: {}
```

➡️ **Problem:** Backend is running but returning no data.

**Possible causes:**
1. Household ID doesn't exist in Django database
2. No activities/experiences recorded yet
3. Backend logic returns empty metrics

---

## 🧪 Quick Test Commands

### Test 1: Is Django running?
```bash
curl http://localhost:8000/api/v1/
```

### Test 2: Test the metrics endpoint directly

**First, get your household ID:**
1. Open the dashboard
2. Tap "Show Debug Info" button
3. Copy the household ID from console

**Then test:**
```bash
# Replace YOUR_HOUSEHOLD_ID with your actual ID
curl "http://localhost:8000/api/v1/family-health/metrics/?household_id=YOUR_HOUSEHOLD_ID" \
  -H "Authorization: Bearer YOUR_SUPABASE_TOKEN" \
  -H "Content-Type: application/json"
```

**Expected response:**
- If endpoint exists but no data: `{"detail": "No activities found"}` or similar
- If endpoint doesn't exist: `{"detail": "Not Found"}`
- If endpoint works: Full JSON with metrics

---

## 🎯 Most Likely Scenario:

You said the backend was "seeded", but the **Django backend** for the Family Health Dashboard is **completely separate** from the Supabase database.

### What's in Supabase:
✅ `households` table
✅ `family_members` table
✅ `experiences` table
✅ `experience_reviews` table
✅ `merry_moments` table

### What's NOT in Django yet:
❌ Django models for family health
❌ Django API endpoints (`/family-health/metrics/`)
❌ Background calculation logic
❌ Achievements/milestones tracking

---

## 📋 What You Need to Do:

The Family Health Dashboard requires a **separate Django backend implementation**.

### Option 1: Implement the Full Backend (Recommended)
Follow `BACKEND_FAMILY_HEALTH_REQUIREMENTS.md`:
1. Create 5 Supabase tables (achievements, milestones, etc.)
2. Seed achievements & milestones
3. Create Django models
4. Implement 3 API endpoints
5. Add background metrics calculation

### Option 2: Quick Mock for Testing
Create a simple Django view that returns fake data:

```python
# family/views/family_health_views.py
from rest_framework.decorators import api_view
from rest_framework.response import Response

@api_view(['GET'])
def get_family_health_metrics(request):
    return Response({
        "household_id": request.GET.get('household_id'),
        "last_activity_date": "2025-10-12T14:30:00Z",
        "days_since_last_activity": 0,
        "current_streak": 7,
        "longest_streak": 15,
        "total_activities_this_week": 5,
        "total_activities_this_month": 18,
        "total_activities_all_time": 42,
        "total_hours_together_this_week": 12.5,
        "total_hours_together_this_month": 45.0,
        "average_rating": 4.6,
        "most_active_pod": {
            "pod_id": "test",
            "pod_name": "Parents",
            "icon": "👨‍👩",
            "activity_count": 12,
            "total_hours": 20.5
        },
        "most_active_inviter": {
            "member_id": "test",
            "member_name": "Sarah",
            "avatar_emoji": "👩",
            "initiated_count": 15,
            "participated_count": 40
        },
        "recent_achievements": [
            {
                "id": "1",
                "title": "First Steps",
                "description": "Completed your first activity",
                "icon": "🎉",
                "unlocked_at": "2025-10-10T10:00:00Z",
                "tier": "bronze",
                "points": 10
            }
        ],
        "milestones": [
            {
                "id": "1",
                "title": "First 25",
                "description": "Complete 25 activities",
                "target_value": 25,
                "current_value": 18,
                "completed": False,
                "reward_description": "Unlock Memory Lane",
                "icon": "🎯"
            }
        ],
        "weekly_trend": {
            "daily_counts": [1, 2, 0, 1, 3, 0, 2],
            "percent_change": 15.5,
            "direction": "up"
        },
        "days_active_this_week": 5,
        "days_active_this_month": 18,
        "connection_score": {
            "score": 85,
            "level": "Thriving",
            "description": "Your family is creating wonderful memories!",
            "encouragement": "Keep up the great work!",
            "strengths": ["Consistent activity", "High engagement"],
            "suggestions": ["Try a weekend adventure"]
        }
    })
```

Then add to `urls.py`:
```python
path('family-health/metrics/', views.get_family_health_metrics),
```

This will make the dashboard show with fake data so you can see how it looks!

---

## 🎯 Next Steps:

1. **Share the console logs** - What's the exact status code and response body?
2. **Test the endpoint manually** - Use the curl command above
3. **Choose your path:**
   - Quick mock (5 minutes) to see the dashboard UI
   - Full implementation (1-2 hours) for real functionality

