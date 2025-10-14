# Setup Mock Endpoint - Quick Test Instructions

## 🎯 Goal
Get the Family Health Dashboard showing with fake data so you can see how it looks!

---

## 📝 Steps to Add Mock Endpoint

### 1. Copy the Mock Views

Copy the content from `MOCK_FAMILY_HEALTH_ENDPOINT.py` into your Django project.

**Add to:** `family/views/family_health_views.py` (or create this file)

### 2. Update Your URLs

Add these routes to your Django `urls.py`:

```python
# In your main urls.py or family/urls.py
from .views import family_health_views  # or wherever you put the mock views

urlpatterns = [
    # ... your existing paths ...
    
    # Mock Family Health Endpoints
    path('family-health/metrics/', family_health_views.get_family_health_metrics, name='family_health_metrics'),
    path('family-health/achievements/', family_health_views.get_achievements, name='get_achievements'),
    path('family-health/milestones/', family_health_views.get_milestones, name='get_milestones'),
]
```

### 3. Restart Django

```bash
# Stop your Django server (Ctrl+C)
# Then restart it
python manage.py runserver
```

### 4. Test in Your Browser

Open the Flutter app and tap the **🏆 trophy icon** in the top-right corner.

---

## ✅ **What You Should See:**

The dashboard will now display:
- 🔥 **7 Day Streak** (golden card)
- ⭐ **Connection Score: 85 "Thriving"** (purple gradient card)
- 📊 **Quick Stats:**
  - 5 activities this week
  - 18 activities this month
  - 12.5h time together
  - 4.6 avg rating
- 📈 **Weekly Trend:** Bar chart showing `[1, 2, 0, 1, 3, 0, 2]`
- 🏆 **Most Active Group:** "The Whole Gang" (12 activities, 20.5 hours)
- 🌟 **Activity Champion:** Sarah (15 activities initiated)
- 🎉 **Recent Achievements:**
  - First Steps (bronze)
  - Week Warrior (silver)
  - Quality Champions (gold)
- 🎯 **Active Milestones:**
  - First 25 (18/25 complete)
  - 50 Hours Together (33/50 complete)

---

## 🐛 Troubleshooting

### If you still see "No metrics returned":

1. **Check Django is running:**
   ```bash
   curl http://localhost:8000/api/v1/family-health/metrics/
   ```
   Should NOT return 404.

2. **Check the console logs:**
   - Open browser DevTools (F12)
   - Look for the response status and body

3. **Test the endpoint directly:**
   Visit in browser: `http://localhost:8000/api/v1/family-health/metrics/?household_id=test`
   
   Should show the JSON response.

4. **Check authentication:**
   Make sure your Django view has `@permission_classes([IsAuthenticated])` and your Supabase JWT middleware is configured.

---

## 🎯 After Testing

Once you confirm the dashboard UI looks good, you can:

1. **Keep the mock data** and continue building other features
2. **Implement the real backend** using `BACKEND_FAMILY_HEALTH_REQUIREMENTS.md` for actual live data
3. **Mix both:** Use mock data for some features, real data for others

The mock endpoint lets you see the full dashboard design immediately! 🎨

