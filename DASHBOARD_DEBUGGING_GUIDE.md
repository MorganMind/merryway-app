# Family Health Dashboard - Debugging Guide

## 🔍 What I Added

### **1. Verbose Logging in Service**
**File:** `lib/modules/family/services/family_health_service.dart`

The service now prints:
- 🔵 The full API URL being called
- 🔵 First 20 characters of the auth token
- 🔵 HTTP response status code
- 🔵 First 200 characters of response body
- ✅ Success confirmation when data is parsed
- ❌ Detailed error messages and stack traces

### **2. Error Display in Dashboard**
**File:** `lib/modules/family/pages/family_health_dashboard_page.dart`

The dashboard now shows:
- **Error State**: Red icon + error message + retry button
- **Empty State**: "Start Your Journey" message (for first-time users)
- **Loaded State**: Full dashboard with metrics
- **Debug Button**: "Show Debug Info" button to print connection details

---

## 🎯 How to Debug

### **Step 1: Open the Dashboard**
Tap the **🏆 golden trophy icon** in the top-right of your home page.

### **Step 2: Check What You See**

#### **If you see a RED ERROR icon:**
1. Read the error message displayed
2. Tap **"Show Debug Info"** button
3. Check your browser console (F12) for detailed logs

#### **If you see "Start Your Journey!" (empty state):**
This means the API returned `null` successfully (no error, just no data).
- Check console for: `❌ Dashboard: No metrics data returned`
- This could mean:
  - Backend returned 404 (endpoint not found)
  - Backend returned empty/null response
  - Data format doesn't match expected schema

### **Step 3: Check Console Logs**

Look for these debug messages in your browser console:

```
🔵 Dashboard: Loading metrics for household <id>
🔵 Fetching family health metrics...
  URL: http://localhost:8000/api/v1/family-health/metrics/?household_id=<id>
  Token: eyJhbGciOiJIUzI1NiIs...
  Response status: <code>
  Response body: <first 200 chars>
```

### **Common Issues & Solutions:**

#### **1. Status 404 - Endpoint Not Found**
```
Response status: 404
```
**Solution:** Your Django backend doesn't have the `/family-health/metrics/` endpoint yet.

**Check:**
- Is the Django server running on `http://localhost:8000`?
- Did you add the URL patterns from `BACKEND_FAMILY_HEALTH_REQUIREMENTS.md`?
- Try manually visiting: `http://localhost:8000/api/v1/family-health/metrics/?household_id=<your_id>`

#### **2. Status 401/403 - Authentication Error**
```
Response status: 401
```
**Solution:** The Supabase JWT token isn't being accepted by Django.

**Check:**
- Did you configure Django to accept Supabase JWT tokens?
- Is the `Authorization: Bearer <token>` header being sent?
- Does your Django view have `@permission_classes([IsAuthenticated])`?

#### **3. Status 500 - Backend Error**
```
Response status: 500
```
**Solution:** Your Django backend is crashing.

**Check Django terminal logs** for the Python error/traceback.

#### **4. Status 200 but Empty/Null Response**
```
Response status: 200
Response body: null
```
**Solution:** Backend is working but returning no data.

**Possible causes:**
- Household ID doesn't exist in Django database
- No activities/reviews exist yet for this household
- Backend logic is returning empty metrics

**Check:**
- Does the household exist in your Django database?
- Have you created any experiences/reviews for this household?
- Are the database tables created and seeded?

#### **5. Status 200 but JSON Parsing Error**
```
✅ Response status: 200
❌ Exception: FormatException: Unexpected character...
```
**Solution:** Backend is returning data in wrong format.

**Check:**
- Does the response match the schema in `BACKEND_FAMILY_HEALTH_REQUIREMENTS.md`?
- Are all required fields present?
- Are data types correct (e.g., `int` not `string` for counts)?

---

## 🧪 Quick Test

### **Test 1: Is Django Running?**
```bash
curl http://localhost:8000/api/v1/
```
Should return some response (not connection refused).

### **Test 2: Is the Endpoint Available?**
```bash
curl http://localhost:8000/api/v1/family-health/metrics/?household_id=YOUR_HOUSEHOLD_ID \
  -H "Authorization: Bearer YOUR_SUPABASE_TOKEN"
```
Should return JSON with metrics data.

### **Test 3: Check Your Household ID**
In the Flutter app, tap "Show Debug Info" to see:
```
📋 Debug Info:
  Household ID: <your-id>
  API URL: http://localhost:8000/api/v1
  Full endpoint: http://localhost:8000/api/v1/family-health/metrics/?household_id=<your-id>
```

Copy that full endpoint and test it in your browser or with `curl`.

---

## 📋 Expected Response Format

Your Django backend should return JSON like this:

```json
{
  "household_id": "uuid",
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
    "pod_id": "uuid",
    "pod_name": "Parents",
    "icon": "👨‍👩",
    "activity_count": 12,
    "total_hours": 20.5
  },
  "most_active_inviter": {
    "member_id": "uuid",
    "member_name": "Sarah",
    "avatar_emoji": "👩",
    "initiated_count": 15,
    "participated_count": 40
  },
  "recent_achievements": [],
  "milestones": [],
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
}
```

---

## 🎯 Next Steps

1. **Open the dashboard** and look at what state it's in
2. **Check the console logs** for the detailed request/response info
3. **Compare the response** to the expected format above
4. **Fix the backend** based on what the logs reveal

The dashboard will now tell you **exactly** what's wrong! 🔍

