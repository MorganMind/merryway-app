# AI Suggestion Logging System

## Overview
Automatically tracks and logs all AI-generated activity suggestions for analytics, learning, and improvement.

---

## 🗄️ Database Schema

### Table: `ai_suggestion_logs`

```sql
CREATE TABLE ai_suggestion_logs (
  id UUID PRIMARY KEY,
  household_id UUID NOT NULL,
  pod_id UUID,
  prompt TEXT NOT NULL,                    -- User's search query
  context JSONB,                           -- Weather, time, day of week
  participant_ids UUID[],                  -- Members included
  suggestions JSONB NOT NULL,              -- Array of generated suggestions
  model_used TEXT DEFAULT 'gpt-3.5-turbo',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- User interaction tracking
  user_accepted_suggestion TEXT,           -- Which suggestion was accepted
  user_dismissed BOOLEAN DEFAULT FALSE,
  feedback_rating INTEGER                  -- 1-5 rating
);
```

---

## 📊 What Gets Logged

### On Every AI Search:
- ✅ **User's prompt** (search query)
- ✅ **Context** (weather, time of day, day of week)
- ✅ **Participants** (who was selected)
- ✅ **Pod** (if a specific pod was active)
- ✅ **All suggestions** returned by AI
- ✅ **Model used** (gpt-3.5-turbo)
- ✅ **Timestamp**

### On User Interaction:
- ✅ **Accepted suggestion** (when user clicks "Make it an Experience")
- ✅ **Dismissed** (future: when user closes without action)
- ✅ **Rating** (future: explicit feedback)

---

## 🔄 Data Flow

```
User enters search → AI generates suggestions
                              ↓
                    Save to ai_suggestion_logs
                              ↓
                    Store log ID in memory
                              ↓
            User clicks "Make it an Experience"
                              ↓
                Update log with accepted suggestion
```

---

## 💻 Frontend Implementation

### Location: `lib/modules/home/pages/home_page.dart`

#### 1. Save Suggestions After AI Response
```dart
Future<void> _saveAISuggestionsToDatabase(List<ActivitySuggestion> suggestions) async {
  final supabase = Supabase.instance.client;
  
  final result = await supabase.from('ai_suggestion_logs').insert({
    'household_id': householdId,
    'pod_id': selectedPodId,
    'prompt': customPrompt,
    'context': {
      'weather': weather,
      'time_of_day': timeOfDay,
      'day_of_week': dayOfWeek,
    },
    'participant_ids': selectedParticipants.toList(),
    'suggestions': suggestionsJson,
    'model_used': 'gpt-3.5-turbo',
  }).select();
  
  // Store log ID for tracking acceptance
  _lastAISuggestionLogId = result[0]['id'];
}
```

#### 2. Track Accepted Suggestions
```dart
Future<void> _trackAISuggestionAccepted(String suggestionName) async {
  await supabase
      .from('ai_suggestion_logs')
      .update({'user_accepted_suggestion': suggestionName})
      .eq('id', _lastAISuggestionLogId!);
}
```

---

## 📈 Analytics Use Cases

### 1. **Popular Search Terms**
```sql
SELECT prompt, COUNT(*) as searches
FROM ai_suggestion_logs
GROUP BY prompt
ORDER BY searches DESC
LIMIT 10;
```

### 2. **Acceptance Rate**
```sql
SELECT 
  COUNT(*) as total_searches,
  COUNT(user_accepted_suggestion) as accepted,
  ROUND(COUNT(user_accepted_suggestion)::NUMERIC / COUNT(*) * 100, 2) as acceptance_rate
FROM ai_suggestion_logs;
```

### 3. **Most Accepted Activities**
```sql
SELECT 
  user_accepted_suggestion,
  COUNT(*) as times_accepted
FROM ai_suggestion_logs
WHERE user_accepted_suggestion IS NOT NULL
GROUP BY user_accepted_suggestion
ORDER BY times_accepted DESC;
```

### 4. **Context Patterns**
```sql
SELECT 
  context->>'time_of_day' as time,
  context->>'weather' as weather,
  COUNT(*) as searches
FROM ai_suggestion_logs
GROUP BY time, weather
ORDER BY searches DESC;
```

---

## 🔐 Privacy & Security

- ✅ **RLS Enabled**: Users can only see logs from their households
- ✅ **No PII**: Only household/member IDs, no personal data
- ✅ **Opt-in by Design**: Only logs when user actively searches
- ✅ **Background Process**: Errors don't interrupt user experience

---

## 🚀 Setup Instructions

### 1. Run SQL Migration
```bash
# In Supabase SQL Editor:
psql < supabase_ai_suggestion_logs.sql
```

### 2. Verify Table Creation
```sql
SELECT * FROM ai_suggestion_logs LIMIT 1;
```

### 3. Test Frontend
```bash
# Run the app
flutter run

# Search for something like "outdoor fun"
# Click "Make it an Experience" on a suggestion
# Check the database:
SELECT * FROM ai_suggestion_logs ORDER BY created_at DESC LIMIT 1;
```

---

## 🐛 Debugging

### Check if logs are being created:
```sql
SELECT 
  id, 
  prompt, 
  jsonb_array_length(suggestions) as suggestion_count,
  user_accepted_suggestion,
  created_at
FROM ai_suggestion_logs
ORDER BY created_at DESC
LIMIT 5;
```

### Check acceptance tracking:
```sql
SELECT 
  prompt,
  user_accepted_suggestion,
  created_at
FROM ai_suggestion_logs
WHERE user_accepted_suggestion IS NOT NULL
ORDER BY created_at DESC;
```

---

## 📝 Future Enhancements

1. **Track Dismissals**: Log when users close suggestions without action
2. **Explicit Ratings**: Allow users to rate AI suggestion quality
3. **A/B Testing**: Track different prompt engineering approaches
4. **Feedback Loop**: Use acceptance data to improve future suggestions
5. **Cost Tracking**: Monitor API costs per household
6. **Weekly Insights**: Show users their search patterns

---

## ✅ Checklist

- [x] Database table created (`ai_suggestion_logs`)
- [x] RLS policies configured
- [x] Frontend saves suggestions after AI response
- [x] Frontend tracks accepted suggestions
- [x] Debug logging added
- [ ] Run SQL migration in Supabase
- [ ] Test end-to-end flow
- [ ] Verify data in database
- [ ] Create analytics dashboard (future)

---

## 📚 Related Documentation

- `BACKEND_AI_SUGGESTIONS_ENDPOINT.md` - AI endpoint implementation
- `AI_FEATURES_SUMMARY.md` - Overview of AI features
- `supabase_ai_suggestion_logs.sql` - Database schema

