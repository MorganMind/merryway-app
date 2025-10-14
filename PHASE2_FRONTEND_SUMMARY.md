# Merryway Phase 2: Frontend Implementation Summary

## ✅ Completed Components

### 1. **Feedback Actions Widget**
**File:** `lib/modules/home/widgets/feedback_actions.dart`

- Skip/Rate/Try It buttons
- Expandable 5-star rating
- "Mark Complete" action
- Loading states
- Smooth animations

### 2. **Ranked Suggestion Card**
**File:** `lib/modules/home/widgets/ranked_suggestion_card.dart`

- Primary vs. secondary card styling
- Rank badges ("⭐ Top Pick", "Option 2", "Option 3")
- Gradient colors per rank
- Duration & tags display
- Integrated feedback actions (primary card only)
- Slide/fade/scale animations

### 3. **Feedback Service**
**File:** `lib/modules/home/services/feedback_service.dart`

- `submitFeedback()` - Send action + rating to backend
- `logCompletion()` - Mark activity as completed
- Uses Dio with auth token injection
- Error handling

### 4. **Existing Components (Already Built)**
- ✅ `ParticipantSelector` - Select family members
- ✅ `ContextInputPanel` - Weather/time/prompt controls
- ✅ `QuickControls` - Compact context display
- ✅ `GetSuggestionsEvent` - Already supports `participants` field

---

## 🎨 UI Features

### Primary Card
```
┌────────────────────────────────────┐
│ ⭐ Top Pick                         │
│                                    │
│ Sunrise walk in the park           │
│ _Perfect for the sunny morning..._│
│                                    │
│ ⏱️ 30 min    [outdoor] [active]    │
│ ─────────────────────────────────  │
│ [Skip]          [Try It!]          │
└────────────────────────────────────┘
```

### Alternative Cards
```
┌────────────────────────────────────┐
│ Option 2                           │
│                                    │
│ Bike ride through neighborhood     │
│ _Great for afternoon energy..._    │
│                                    │
│ ⏱️ 60 min    [outdoor] [exercise]  │
└────────────────────────────────────┘
```

---

## 🔌 Backend Integration Points

### GET Suggestions (Enhanced)
**Endpoint:** `POST /api/v1/suggest-activity/`

**Request:**
```json
{
  "household_id": "uuid",
  "weather": "sunny",
  "time_of_day": "morning",
  "day_of_week": "saturday",
  "custom_prompt": "something active",
  "participant_ids": ["member1", "member2"]  // ← Phase 2
}
```

**Response:**
```json
{
  "suggestion_id": "uuid",  // ← Phase 2 (for feedback)
  "suggestions": [
    {
      "activity": "Sunrise walk in the park",
      "rationale": "Perfect for the sunny morning...",
      "durationMinutes": 30,
      "tags": ["outdoor", "active"]
    },
    // 2 more alternatives...
  ],
  "context": { ... }
}
```

### POST Feedback (New)
**Endpoint:** `POST /api/v1/feedback/`

**Request:**
```json
{
  "suggestion_id": "uuid",
  "activity_id": "uuid",
  "action": "accept|skip|complete",
  "rating": 5,  // optional (1-5)
  "notes": "We loved it!"  // optional
}
```

---

## 🚀 Next Steps

### For Backend Team:
1. Implement `POST /api/v1/feedback/` endpoint
2. Return `suggestion_id` in suggestion responses
3. Return `activity_id` for each suggestion
4. Implement weight learning from feedback
5. Seed 50+ activities to catalog
6. Enable pgvector for Phase 2.5

### For Testing:
1. Select participants
2. Get ranked suggestions (3 cards)
3. Click "Try It!" on primary card
4. Rate it 1-5 stars
5. Click "Mark Complete"
6. Verify feedback reaches backend
7. Get new suggestions (should be learning!)

---

## 📱 User Flow

```
1. Open Home
   ↓
2. Select who's joining (Participant Selector)
   ↓
3. Customize context (weather/time/prompt)
   ↓
4. Get 3 ranked suggestions
   ├── Top Pick (with feedback buttons)
   ├── Option 2
   └── Option 3
   ↓
5. User clicks "Try It!" or "Skip"
   ↓
6. If "Try It!":
   ├── Expand rating (1-5 stars)
   ├── Click "Mark Complete"
   └── Feedback sent to backend
   ↓
7. New suggestions loaded (learning applied!)
```

---

## 🎯 Phase 2 Goals Achieved

✅ **Participant Selection** - Filter suggestions by who's joining  
✅ **Ranked Suggestions** - Top pick + 2 alternatives  
✅ **Feedback Loop** - Skip/Accept/Complete actions  
✅ **Star Ratings** - 1-5 stars for completed activities  
✅ **Learning Foundation** - Backend gets feedback for ML  
✅ **Smooth UX** - Animations, loading states, clear CTAs

---

## 🔧 Configuration

**Environment:** `lib/config/environment.dart`
```dart
static const String apiUrl = 'http://localhost:8000/api/v1';
```

**Service Locator:** `lib/modules/core/di/service_locator.dart`
- Dio already configured with auth token injection
- Add `HomeFeedbackService` if needed

---

## 📊 Expected Backend Data Flow

```
User Action → Frontend → Backend → Learning
──────────────────────────────────────────
1. Get Suggestions
   - Send context + participants
   - Receive ranked activities (scored)
   
2. Submit Feedback
   - Send action (skip/accept/complete)
   - Send rating (if complete)
   - Backend logs to feedback table
   
3. Weight Learning (Backend)
   - After 10+ feedback items
   - Recompute learned_weights
   - Next suggestions use new weights!
```

---

## 🎨 Design Tokens

**Colors:**
- Primary Card: `#B4D7E8` → `#7FB3D5` (blue gradient)
- Option 2: `#F4A6B8` → `#E88FA0` (pink gradient)
- Option 3: `#E5C17D` → `#D9A55D` (golden gradient)
- Feedback Buttons: White on transparent
- Skip Button: `#8B8B8B` border

**Animations:**
- Card entrance: 600ms slide + fade + scale
- Rating expand: 300ms
- Star selection: 200ms scale

---

**Ready for backend integration!** 🚀

When backend is ready:
1. Test feedback submission
2. Verify weights update after 10+ feedbacks
3. Confirm suggestions improve over time
4. Monitor rationale quality

