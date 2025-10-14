# Plans - Quick Start Guide

## 🚀 Get Plans Running in 30 Minutes

### Step 1: Database (5 minutes)

1. Open Supabase SQL Editor
2. Copy and paste `supabase_plans_schema.sql`
3. Click "Run"
4. ✅ You'll see: "Success. No rows returned"

---

### Step 2: Backend (10 minutes)

1. **Create model file:**
   ```bash
   touch family/models/plans.py
   ```
   Copy contents from `PLANS_BACKEND_COMPLETE.md` → Section "Step 2: Backend Models"

2. **Create services:**
   ```bash
   touch family/services/plans_service.py
   touch family/services/morgan_plans_service.py
   ```
   Copy from `PLANS_BACKEND_COMPLETE.md` → Sections "Step 3" and "Step 4"

3. **Create views:**
   ```bash
   touch family/views/plans_view.py
   ```
   Copy from `PLANS_BACKEND_COMPLETE.md` → Section "Step 5"

4. **Update URLs (`family/urls.py`):**
   ```python
   from .views.plans_view import (
       plans_view,
       plan_detail_view,
       plan_messages_view,
       plan_proposals_view,
       proposal_vote_view,
       plan_constraints_view,
       plan_decision_view,
       plan_itinerary_view,
       plan_archive_view,
       plan_reopen_view,
       morgan_action_view,
   )
   
   # Add these patterns:
   path("plans/", plans_view, name="plans"),
   path("plans/<str:plan_id>/", plan_detail_view, name="plan_detail"),
   path("plans/<str:plan_id>/messages/", plan_messages_view, name="plan_messages"),
   path("plans/<str:plan_id>/proposals/", plan_proposals_view, name="plan_proposals"),
   path("proposals/<str:proposal_id>/vote/", proposal_vote_view, name="proposal_vote"),
   path("plans/<str:plan_id>/constraints/", plan_constraints_view, name="plan_constraints"),
   path("plans/<str:plan_id>/decision/", plan_decision_view, name="plan_decision"),
   path("plans/<str:plan_id>/itinerary/", plan_itinerary_view, name="plan_itinerary"),
   path("plans/<str:plan_id>/archive/", plan_archive_view, name="plan_archive"),
   path("plans/<str:plan_id>/reopen/", plan_reopen_view, name="plan_reopen"),
   path("morgan/act/", morgan_action_view, name="morgan_action"),
   ```

5. **Restart server:**
   ```bash
   python manage.py runserver
   ```

---

### Step 3: Test Backend (5 minutes)

```bash
# Get your auth token first
export TOKEN="your-supabase-jwt-token"
export HOUSEHOLD_ID="your-household-id"

# Test 1: Create a plan
curl -X POST http://localhost:8000/api/v1/plans/ \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "household_id": "'$HOUSEHOLD_ID'",
    "title": "Weekend Museum Trip",
    "member_ids": []
  }'

# Copy the "id" from response

# Test 2: Get plans list
curl http://localhost:8000/api/v1/plans/?household_id=$HOUSEHOLD_ID \
  -H "Authorization: Bearer $TOKEN"

# ✅ If you see your plan, backend is working!
```

---

### Step 4: Frontend Models (5 minutes)

1. **Update `pubspec.yaml`:**
   ```yaml
   dependencies:
     freezed_annotation: ^2.4.1
     json_annotation: ^4.8.1
     http: ^1.1.0
   
   dev_dependencies:
     build_runner: ^2.4.6
     freezed: ^2.4.5
     json_serializable: ^6.7.1
   ```

2. **Install:**
   ```bash
   flutter pub get
   ```

3. **Create models:**
   ```bash
   mkdir -p lib/modules/plans/models
   touch lib/modules/plans/models/plan_models.dart
   ```
   Copy from `PLANS_FLUTTER_COMPLETE_GUIDE.md` → Step 1

4. **Generate code:**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

---

### Step 5: Frontend Service (3 minutes)

```bash
mkdir -p lib/modules/plans/services
touch lib/modules/plans/services/plans_service.dart
```

Copy from `PLANS_FLUTTER_COMPLETE_GUIDE.md` → Step 2

---

### Step 6: Frontend Widgets (5 minutes)

```bash
mkdir -p lib/modules/plans/widgets

# Create all widget files:
touch lib/modules/plans/widgets/plan_card.dart
touch lib/modules/plans/widgets/member_facepile.dart
touch lib/modules/plans/widgets/proposal_card.dart
touch lib/modules/plans/widgets/vote_buttons.dart
touch lib/modules/plans/widgets/message_bubble.dart
touch lib/modules/plans/widgets/morgan_badge.dart
touch lib/modules/plans/widgets/chat_composer.dart
touch lib/modules/plans/widgets/constraint_chip.dart
```

Copy each from `PLANS_FLUTTER_COMPLETE_GUIDE.md` → Step 3

---

### Step 7: Frontend Screens (5 minutes)

```bash
mkdir -p lib/modules/plans/screens

touch lib/modules/plans/screens/plans_list_screen.dart
touch lib/modules/plans/screens/plan_thread_screen.dart
touch lib/modules/plans/widgets/decision_sheet.dart
touch lib/modules/plans/widgets/itinerary_drawer.dart
```

Copy from:
- `PLANS_FLUTTER_COMPLETE_GUIDE.md` → Step 4 (plans_list_screen)
- `PLANS_FLUTTER_SCREENS_COMPLETE.md` → (remaining screens)

---

### Step 8: Add to Navigation (2 minutes)

In your bottom nav or app routes:

```dart
import 'package:your_app/modules/plans/screens/plans_list_screen.dart';

// In your navigation:
PlansListScreen(
  householdId: currentUser.householdId,
)
```

---

### Step 9: Run & Test (5 minutes)

```bash
flutter run
```

**Test:**
1. ✅ Tap "Plans" in nav
2. ✅ See empty state
3. ✅ Tap FAB "New plan"
4. ✅ Create a plan
5. ✅ Opens plan thread
6. ✅ Type a message
7. ✅ Tap "Summarize" chip
8. ✅ Morgan responds

---

## 🎉 You're Done!

Plans is now live in your app!

---

## 📁 File Checklist

### Backend (5 files)
- [ ] `supabase_plans_schema.sql` ✅ Run in Supabase
- [ ] `family/models/plans.py`
- [ ] `family/services/plans_service.py`
- [ ] `family/services/morgan_plans_service.py`
- [ ] `family/views/plans_view.py`
- [ ] `family/urls.py` (updated)

### Frontend (16 files)
- [ ] `lib/modules/plans/models/plan_models.dart`
- [ ] `lib/modules/plans/services/plans_service.dart`
- [ ] `lib/modules/plans/widgets/plan_card.dart`
- [ ] `lib/modules/plans/widgets/member_facepile.dart`
- [ ] `lib/modules/plans/widgets/proposal_card.dart`
- [ ] `lib/modules/plans/widgets/vote_buttons.dart`
- [ ] `lib/modules/plans/widgets/message_bubble.dart`
- [ ] `lib/modules/plans/widgets/morgan_badge.dart`
- [ ] `lib/modules/plans/widgets/chat_composer.dart`
- [ ] `lib/modules/plans/widgets/constraint_chip.dart`
- [ ] `lib/modules/plans/widgets/decision_sheet.dart`
- [ ] `lib/modules/plans/widgets/itinerary_drawer.dart`
- [ ] `lib/modules/plans/screens/plans_list_screen.dart`
- [ ] `lib/modules/plans/screens/plan_thread_screen.dart`
- [ ] `pubspec.yaml` (updated)
- [ ] Navigation (updated)

---

## 🐛 Troubleshooting

### "No rows returned" in Supabase
✅ This is correct! It means the tables were created successfully.

### Backend: "ModuleNotFoundError"
Run: `pip install openai pydantic`

### Frontend: "Undefined class _$Plan"
Run: `flutter pub run build_runner build --delete-conflicting-outputs`

### "OPENAI_API_KEY not set"
Add to `.env`:
```
OPENAI_API_KEY=sk-...your-key...
```

### 401 Unauthorized
Check your JWT token is valid and not expired.

---

## 📚 Full Guides

- **Backend:** `PLANS_BACKEND_COMPLETE.md`
- **Frontend:** `PLANS_FLUTTER_COMPLETE_GUIDE.md` + `PLANS_FLUTTER_SCREENS_COMPLETE.md`
- **Summary:** `PLANS_IMPLEMENTATION_SUMMARY.md`

---

**Ready to ship collaborative planning!** 🚀

