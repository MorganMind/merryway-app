# Backend Requirements: Family Time Health Dashboard

## 1. Database Tables (Supabase SQL)

```sql
-- Family Health Metrics (cached/computed table, updated via trigger)
CREATE TABLE family_health_metrics (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  household_id UUID NOT NULL REFERENCES households(id) ON DELETE CASCADE,
  last_activity_date TIMESTAMPTZ,
  days_since_last_activity INT DEFAULT 0,
  current_streak INT DEFAULT 0,
  longest_streak INT DEFAULT 0,
  total_activities_all_time INT DEFAULT 0,
  connection_score INT DEFAULT 0,
  connection_level TEXT,
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(household_id)
);

-- Achievements (predefined)
CREATE TABLE achievements (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  key TEXT UNIQUE NOT NULL,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  icon TEXT NOT NULL,
  tier TEXT NOT NULL CHECK (tier IN ('bronze', 'silver', 'gold', 'platinum', 'diamond')),
  points INT NOT NULL,
  criteria JSONB NOT NULL
);

-- Unlocked Achievements (per household)
CREATE TABLE household_achievements (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  household_id UUID NOT NULL REFERENCES households(id) ON DELETE CASCADE,
  achievement_id UUID NOT NULL REFERENCES achievements(id) ON DELETE CASCADE,
  unlocked_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(household_id, achievement_id)
);

-- Milestones (predefined)
CREATE TABLE milestones (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  key TEXT UNIQUE NOT NULL,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  icon TEXT NOT NULL,
  target_value INT NOT NULL,
  reward_description TEXT NOT NULL,
  criteria_type TEXT NOT NULL CHECK (criteria_type IN ('total_activities', 'streak_days', 'total_hours', 'member_participation', 'pod_activities'))
);

-- Milestone Progress (per household)
CREATE TABLE household_milestones (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  household_id UUID NOT NULL REFERENCES households(id) ON DELETE CASCADE,
  milestone_id UUID NOT NULL REFERENCES milestones(id) ON DELETE CASCADE,
  current_value INT DEFAULT 0,
  completed BOOLEAN DEFAULT FALSE,
  completed_at TIMESTAMPTZ,
  UNIQUE(household_id, milestone_id)
);

-- Indexes
CREATE INDEX idx_family_health_household ON family_health_metrics(household_id);
CREATE INDEX idx_household_achievements_household ON household_achievements(household_id);
CREATE INDEX idx_household_milestones_household ON household_milestones(household_id);

-- RLS Policies
ALTER TABLE family_health_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE household_achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE household_milestones ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their household metrics"
  ON family_health_metrics FOR SELECT
  USING (household_id IN (
    SELECT household_id FROM family_members WHERE user_id = auth.uid()
  ));

CREATE POLICY "Users can view their household achievements"
  ON household_achievements FOR SELECT
  USING (household_id IN (
    SELECT household_id FROM family_members WHERE user_id = auth.uid()
  ));

CREATE POLICY "Users can view their household milestones"
  ON household_milestones FOR SELECT
  USING (household_id IN (
    SELECT household_id FROM family_members WHERE user_id = auth.uid()
  ));
```

## 2. Seed Data (Achievements & Milestones)

```sql
-- Seed Achievements
INSERT INTO achievements (key, title, description, icon, tier, points, criteria) VALUES
  ('first_activity', 'First Steps', 'Completed your first family activity', '🎉', 'bronze', 10, '{"min_activities": 1}'),
  ('week_streak', 'Week Warrior', 'Active 7 days in a row', '🔥', 'silver', 25, '{"min_streak": 7}'),
  ('month_streak', 'Monthly Master', 'Active 30 days in a row', '🏆', 'gold', 100, '{"min_streak": 30}'),
  ('ten_activities', 'Getting Started', 'Completed 10 activities', '🌟', 'bronze', 20, '{"min_activities": 10}'),
  ('fifty_activities', 'Activity Enthusiast', 'Completed 50 activities', '⭐', 'silver', 50, '{"min_activities": 50}'),
  ('hundred_activities', 'Century Club', 'Completed 100 activities', '💯', 'gold', 150, '{"min_activities": 100}'),
  ('perfect_week', 'Perfect Week', 'Active every day this week', '✨', 'silver', 30, '{"days_active_this_week": 7}'),
  ('quality_time', 'Quality Champions', 'Achieved 20 hours together this month', '⏰', 'gold', 75, '{"min_hours_this_month": 20}'),
  ('high_rating', 'Excellent Experiences', 'Maintained 4.5+ avg rating over 10 activities', '⭐', 'platinum', 200, '{"min_avg_rating": 4.5, "min_activities": 10}'),
  ('pod_master', 'Pod Master', 'All pods active this month', '👨‍👩‍👧‍👦', 'diamond', 300, '{"all_pods_active": true}');

-- Seed Milestones
INSERT INTO milestones (key, title, description, icon, target_value, reward_description, criteria_type) VALUES
  ('activities_25', 'First 25', 'Complete 25 family activities', '🎯', 25, 'Unlock "Memory Lane" feature', 'total_activities'),
  ('activities_50', 'Half Century', 'Complete 50 family activities', '🏅', 50, 'Unlock "Wishbook Pro" with AI suggestions', 'total_activities'),
  ('activities_100', 'Centurion', 'Complete 100 family activities', '👑', 100, 'Unlock "Custom Activity Builder"', 'total_activities'),
  ('streak_30', 'Monthly Streak', 'Stay active for 30 days straight', '🔥', 30, 'Unlock "Streak Shield" (1 free skip)', 'streak_days'),
  ('streak_100', 'Legendary Streak', 'Stay active for 100 days straight', '💎', 100, 'Unlock "Legendary Badge" on profile', 'streak_days'),
  ('hours_50', '50 Hours Together', 'Spend 50 hours in activities', '⏳', 50, 'Unlock "Time Capsule" photo album', 'total_hours'),
  ('hours_200', '200 Hours Together', 'Spend 200 hours in activities', '🌈', 200, 'Unlock "Family Yearbook" PDF export', 'total_hours');
```

## 3. API Endpoint 1: Get Family Health Metrics

**Endpoint:** `GET /api/v1/family-health/metrics/`

**Query Params:**
- `household_id` (required): UUID

**Response Schema:**
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
  "recent_achievements": [
    {
      "id": "uuid",
      "title": "Week Warrior",
      "description": "Active 7 days in a row",
      "icon": "🔥",
      "unlocked_at": "2025-10-12T10:00:00Z",
      "tier": "silver",
      "points": 25
    }
  ],
  "milestones": [
    {
      "id": "uuid",
      "title": "First 25",
      "description": "Complete 25 family activities",
      "target_value": 25,
      "current_value": 22,
      "completed": false,
      "reward_description": "Unlock 'Memory Lane' feature",
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
    "description": "Your family is creating wonderful memories together!",
    "encouragement": "You're doing amazing! Keep up the great work.",
    "strengths": [
      "Consistent activity",
      "High engagement",
      "Diverse experiences"
    ],
    "suggestions": [
      "Try a weekend adventure",
      "Involve all pod groups"
    ]
  }
}
```

**Logic to Compute:**

1. **Last Activity & Days Since:**
   - Query `merry_moments` table, order by `created_at DESC`, limit 1
   - Calculate `days_since_last_activity` = `NOW() - last_activity_date`

2. **Current Streak:**
   - Query `merry_moments` grouped by `DATE(created_at)`
   - Count consecutive days from today backwards

3. **Longest Streak:**
   - Query all `merry_moments`, find longest consecutive day sequence

4. **Total Activities (week/month/all time):**
   - Count `merry_moments` filtered by date range

5. **Total Hours Together:**
   - Sum `experiences.duration_minutes` (infer from `end_at - start_at` if null) / 60

6. **Average Rating:**
   - AVG(`experience_reviews.rating`) for household

7. **Most Active Pod:**
   - Count `experiences` grouped by participant subset
   - Match to `pods` table via `member_ids` overlap
   - Return pod with highest count

8. **Most Active Inviter:**
   - Count `experiences` grouped by `created_by_member_id` (add this field to `experiences` table)

9. **Recent Achievements:**
   - Join `household_achievements` with `achievements`
   - Order by `unlocked_at DESC`, limit 3

10. **Milestones:**
    - Join `household_milestones` with `milestones`
    - Calculate `current_value` based on `criteria_type`

11. **Weekly Trend:**
    - Count activities per day for last 7 days
    - Compare this week to previous week for `percent_change`

12. **Connection Score:**
    - Algorithm:
      ```
      score = 0
      score += min(current_streak * 2, 30)  # Max 30 pts from streak
      score += min(total_activities_this_month * 2, 30)  # Max 30 pts
      score += min(average_rating * 8, 40)  # Max 40 pts (5.0 rating = 40)
      
      if days_since_last_activity == 0: score += 10
      if days_active_this_week >= 5: score += 10
      
      Levels:
      0-30: "Just Starting" - Keep going!
      31-50: "Budding Connection" - Building momentum
      51-70: "Growing Together" - Great progress!
      71-85: "Thriving" - Wonderful memories!
      86-100: "Unbreakable Bond" - Legendary family!
      ```

## 4. API Endpoint 2: Get Achievements

**Endpoint:** `GET /api/v1/family-health/achievements/`

**Query Params:**
- `household_id` (required): UUID
- `unlocked_only` (optional): boolean (default false)

**Response:** Array of Achievement objects

**Logic:**
- If `unlocked_only=true`: Return only achievements in `household_achievements`
- Else: Return all achievements, mark `unlocked: true/false` based on `household_achievements` table

## 5. API Endpoint 3: Get Milestones

**Endpoint:** `GET /api/v1/family-health/milestones/`

**Query Params:**
- `household_id` (required): UUID

**Response:** Array of Milestone objects with progress

**Logic:**
- Join `household_milestones` with `milestones`
- Calculate `current_value` dynamically based on `criteria_type`:
  - `total_activities`: Count `merry_moments`
  - `streak_days`: Use `current_streak` from metrics
  - `total_hours`: Sum hours from `experiences`

## 6. Background Job: Update Metrics & Check Achievements

**Trigger:** After every `experience_reviews` INSERT or `merry_moments` INSERT

**Logic:**
1. Recalculate all metrics for the household
2. Update `family_health_metrics` table
3. Check all achievements:
   - For each achievement, evaluate `criteria` against household data
   - If met and not in `household_achievements`, INSERT new unlock
4. Update milestone progress in `household_milestones`

**Pseudo-code:**
```python
def update_family_health(household_id):
    # Compute metrics
    metrics = calculate_metrics(household_id)
    
    # Upsert metrics table
    upsert_family_health_metrics(household_id, metrics)
    
    # Check achievements
    all_achievements = get_all_achievements()
    for achievement in all_achievements:
        if not is_unlocked(household_id, achievement.id):
            if evaluate_criteria(achievement.criteria, metrics):
                unlock_achievement(household_id, achievement.id)
    
    # Update milestones
    update_milestone_progress(household_id)
```

## 7. Django View Code (Minimal Example)

```python
# family/views/family_health_views.py

from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.db import connection

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_family_health_metrics(request):
    household_id = request.GET.get('household_id')
    
    if not household_id:
        return Response({'error': 'household_id required'}, status=400)
    
    # Call your service/logic
    metrics = FamilyHealthService.compute_metrics(household_id)
    
    return Response(metrics, status=200)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_achievements(request):
    household_id = request.GET.get('household_id')
    unlocked_only = request.GET.get('unlocked_only', 'false').lower() == 'true'
    
    achievements = FamilyHealthService.get_achievements(household_id, unlocked_only)
    
    return Response(achievements, status=200)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_milestones(request):
    household_id = request.GET.get('household_id')
    
    milestones = FamilyHealthService.get_milestones(household_id)
    
    return Response(milestones, status=200)
```

## 8. URLs Configuration

```python
# family/urls.py

urlpatterns = [
    # ... existing paths ...
    path('family-health/metrics/', views.get_family_health_metrics, name='family_health_metrics'),
    path('family-health/achievements/', views.get_achievements, name='get_achievements'),
    path('family-health/milestones/', views.get_milestones, name='get_milestones'),
]
```

## Summary

### What You Need to Implement:

1. ✅ **4 Database Tables**: `family_health_metrics`, `achievements`, `household_achievements`, `milestones`, `household_milestones`
2. ✅ **Seed Data**: 10 achievements, 7 milestones
3. ✅ **3 API Endpoints**: `/metrics/`, `/achievements/`, `/milestones/`
4. ✅ **Metrics Calculation Logic**: Streaks, totals, averages, trends, connection score
5. ✅ **Background Job/Trigger**: Update metrics after each activity completion
6. ✅ **Achievement Evaluation**: Check criteria and unlock when met

All response schemas match what the Flutter frontend expects. Let me know when backend is ready! 🚀

