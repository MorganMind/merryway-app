# Phase 3.5: Pod-Aware Filtering & Rules - Frontend Implementation

## Overview

This document outlines the **frontend implementation** for Phase 3.5, which adds:
- **Member Rules**: Natural language constraints for individual family members
- **Pod Rules**: Natural language constraints for pods (sub-groups)
- **Pod-Aware Suggestions**: Activity suggestions filtered and ranked by active pod
- **Rules Management UI**: Full CRUD interface for member and pod rules

**Note:** You will need to implement the **backend** components as outlined in your original spec. This document focuses solely on the frontend.

---

## 📦 What Was Implemented (Frontend)

### 1. Models

#### `lib/modules/family/models/rule_models.dart`
New models for member and pod rules:

```dart
class MemberRule {
  final String? id;
  final String memberId;
  final String ruleText;  // e.g., "Home by 5 PM", "No loud activities"
  final String? category; // 'time', 'health', 'safety', 'preference'
  final bool isActive;
  final DateTime? createdAt;
}

class PodRule {
  final String? id;
  final String podId;
  final String ruleText;  // e.g., "Educational focus", "Max 30 minutes"
  final String? category; // 'time', 'health', 'safety', 'preference'
  final bool isActive;
  final DateTime? createdAt;
}
```

### 2. Services

#### `lib/modules/family/services/rules_service.dart`
Handles all API calls for rules and pod-aware suggestions:

**Member Rules:**
- `Future<List<MemberRule>> getMemberRules(String memberId)`
- `Future<MemberRule> addMemberRule({required String memberId, required String ruleText, String? category})`
- `Future<void> deleteMemberRule(String ruleId)`

**Pod Rules:**
- `Future<List<PodRule>> getPodRules(String podId)`
- `Future<PodRule> addPodRule({required String podId, required String ruleText, String? category})`
- `Future<void> deletePodRule(String ruleId)`

**Pod-Aware Suggestions:**
- `Future<Map<String, dynamic>> getSuggestionsForPod({...})`

All methods use HTTP with bearer token authentication from Supabase.

### 3. UI Components

#### `lib/modules/family/widgets/member_rules_widget.dart`
Collapsible card widget for managing member rules:

**Features:**
- Displays all rules for a member
- Color-coded category badges (time, health, safety, preference)
- Add new rules with category selection
- Delete existing rules
- Expand/collapse interface

**Usage:**
```dart
MemberRulesWidget(
  member: familyMember,
  onRulesChanged: () {
    // Called when rules are added/deleted
  },
)
```

#### `lib/modules/family/widgets/pod_rules_widget.dart`
Collapsible card widget for managing pod rules (same interface as MemberRulesWidget):

**Usage:**
```dart
PodRulesWidget(
  pod: pod,
  onRulesChanged: () {
    // Called when rules are added/deleted
  },
)
```

### 4. Pages

#### `lib/modules/family/pages/member_detail_page.dart`
Full-screen detail view for a family member:

**Features:**
- Display member avatar, name, age, role, birthday
- Edit member information
- View favorite activities
- **Integrated MemberRulesWidget** for managing rules
- Navigate from settings page member card

**Navigation:**
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => MemberDetailPage(
      member: member,
      householdId: householdId,
    ),
  ),
);
```

#### `lib/modules/family/pages/pod_detail_page.dart`
Full-screen detail view for a pod:

**Features:**
- Display pod icon, name, description, color
- Edit pod information
- View pod members
- **Integrated PodRulesWidget** for managing rules
- Navigate from pods management page

**Navigation:**
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => PodDetailPage(
      pod: pod,
      allMembers: allMembers,
    ),
  ),
);
```

### 5. Integration Updates

#### Updated: `lib/modules/family/pages/pods_management_page.dart`
- Added `onTap` to pod cards to navigate to `PodDetailPage`
- Reload pods after returning from detail page

#### Updated: `lib/modules/settings/pages/simple_settings_page.dart`
- Added `onTap` to member cards to navigate to `MemberDetailPage`
- Reload members after returning from detail page

---

## 🔧 Backend Requirements (For You to Implement)

### Database Tables (Supabase SQL)

You'll need to create these tables in Supabase:

#### 1. `member_rules`
```sql
CREATE TABLE member_rules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  member_id UUID NOT NULL REFERENCES household_members(id) ON DELETE CASCADE,
  rule_text TEXT NOT NULL,
  category TEXT,  -- 'time', 'health', 'safety', 'preference'
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_member_rules_member_id ON member_rules(member_id);

ALTER TABLE member_rules ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view member rules from their household"
  ON member_rules FOR SELECT USING (
    member_id IN (
      SELECT id FROM household_members
      WHERE household_id IN (
        SELECT id FROM households WHERE user_id = auth.uid()
      )
    )
  );
```

#### 2. `pod_rules`
```sql
CREATE TABLE pod_rules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pod_id UUID NOT NULL REFERENCES pods(id) ON DELETE CASCADE,
  rule_text TEXT NOT NULL,
  category TEXT,  -- 'time', 'health', 'safety', 'preference'
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### 3. `pod_learning_profiles` (Optional for Phase 3.5)
For tracking pod-specific learning and engagement. See your original spec for details.

#### 4. `suggestion_logs_with_pod` (Optional for Phase 3.5)
For logging pod-aware suggestions. See your original spec for details.

### API Endpoints (Django)

The frontend expects these endpoints:

#### Member Rules
- `GET /api/v1/rules/member/?member_id={uuid}` → Returns `{rules: [...]}`
- `POST /api/v1/rules/member/add/` → Body: `{member_id, rule_text, category}`
- `DELETE /api/v1/rules/member/delete/?rule_id={uuid}`

#### Pod Rules
- `GET /api/v1/rules/pod/?pod_id={uuid}` → Returns `{rules: [...]}`
- `POST /api/v1/rules/pod/add/` → Body: `{pod_id, rule_text, category}`
- `DELETE /api/v1/rules/pod/delete/?rule_id={uuid}`

#### Pod-Aware Suggestions (NEW)
- `POST /api/v1/suggestions/pod/`
  - **Request Body:**
    ```json
    {
      "household_id": "uuid",
      "pod_member_ids": ["uuid1", "uuid2"],
      "weather": "sunny|rainy|cloudy",
      "time_bucket": "morning|afternoon|evening",
      "day_of_week": "monday|tuesday|...",
      "custom_prompt": "optional string",
      "pod_id": "optional uuid"
    }
    ```
  - **Response:**
    ```json
    {
      "pod_id": "uuid",
      "pod_member_ids": ["uuid1", "uuid2"],
      "context_summary": "2 members, sunny, afternoon",
      "suggestions": [
        {
          "activity": "Outdoor scavenger hunt",
          "rationale": "For Alice & Bob — perfect afternoon activity, ideal for the sun, just right at 45min",
          "durationMinutes": 45,
          "tags": ["outdoor", "active"]
        }
      ]
    }
    ```

### Backend Services (Python)

You'll need to implement:

#### 1. `RulesService` (`family/services/rules_service.py`)
Methods for CRUD operations on member and pod rules.

#### 2. `PodSuggestionService` (`family/services/pod_suggestion_service.py`)
- `generate_suggestions_for_pod()`: Main method that:
  1. Fetches member rules for pod members
  2. Fetches pod rules for the pod
  3. Combines rules with custom prompt
  4. Uses vector similarity to find candidates
  5. Applies policy checks
  6. Ranks with pod-specific learning
  7. Builds rationale with pod/rule context
  8. Logs suggestion with pod context

Refer to your original Phase 3.5 spec for full implementation details.

---

## 🎨 UI Flow

### Member Rules Flow:
1. User opens **Settings** page
2. Taps on a **family member card**
3. `MemberDetailPage` opens
4. Scrolls down to see **"Rules"** card
5. Taps expand button to add/view rules
6. Selects category (time/health/safety/preference)
7. Enters rule text (e.g., "Home by 5 PM")
8. Taps checkmark to save
9. Rule appears with color-coded badge
10. Rules are sent to backend and stored in `member_rules` table

### Pod Rules Flow:
1. User opens **Settings** page
2. Taps **"Manage"** next to **Pods** section
3. `PodsManagementPage` opens
4. Taps on a **pod card**
5. `PodDetailPage` opens
6. Scrolls down to see **"Pod Rules"** card
7. (Same flow as member rules)
8. Rules are sent to backend and stored in `pod_rules` table

---

## 🧪 Testing Checklist

### Frontend (Already Implemented)
- [ ] Member rules widget loads existing rules for a member
- [ ] Adding a member rule creates it via API
- [ ] Deleting a member rule soft-deletes it via API
- [ ] Pod rules widget loads existing rules for a pod
- [ ] Adding a pod rule creates it via API
- [ ] Deleting a pod rule soft-deletes it via API
- [ ] Category chips work correctly (time, health, safety, preference)
- [ ] Rules display with correct color-coded badges
- [ ] MemberDetailPage is accessible from settings
- [ ] PodDetailPage is accessible from pods management

### Backend (You Need to Implement)
- [ ] Create `member_rules` table in Supabase
- [ ] Create `pod_rules` table in Supabase
- [ ] RLS policies are active and correct
- [ ] GET `/api/v1/rules/member/` returns rules for a member
- [ ] POST `/api/v1/rules/member/add/` creates a rule
- [ ] DELETE `/api/v1/rules/member/delete/` soft-deletes a rule
- [ ] GET `/api/v1/rules/pod/` returns rules for a pod
- [ ] POST `/api/v1/rules/pod/add/` creates a rule
- [ ] DELETE `/api/v1/rules/pod/delete/` soft-deletes a rule
- [ ] POST `/api/v1/suggestions/pod/` returns pod-aware suggestions
- [ ] Pod suggestions combine member rules + pod rules
- [ ] Rationale mentions pod context and relevant rules

---

## 📊 Example Usage

### Adding a Member Rule

**Scenario:** Parent adds a rule for their child "Sarah" (age 8):
- **Rule Text:** "No screen time after 7 PM"
- **Category:** `time`

**Frontend Call:**
```dart
final rule = await rulesService.addMemberRule(
  memberId: sarah.id!,
  ruleText: 'No screen time after 7 PM',
  category: 'time',
);
```

**Backend API Call:**
```http
POST /api/v1/rules/member/add/
Authorization: Bearer {supabase_jwt}
Content-Type: application/json

{
  "member_id": "sarah-uuid",
  "rule_text": "No screen time after 7 PM",
  "category": "time"
}
```

**Backend Response:**
```json
{
  "id": "rule-uuid",
  "member_id": "sarah-uuid",
  "rule_text": "No screen time after 7 PM",
  "category": "time",
  "is_active": true,
  "created_at": "2025-10-12T10:30:00Z"
}
```

### Adding a Pod Rule

**Scenario:** Parent adds a rule for the "Weeknight Study" pod:
- **Rule Text:** "Educational activities only"
- **Category:** `preference`

**Frontend Call:**
```dart
final rule = await rulesService.addPodRule(
  podId: weeknightStudyPod.id!,
  ruleText: 'Educational activities only',
  category: 'preference',
);
```

### Getting Pod-Aware Suggestions

**Scenario:** User selects the "Kids" pod and wants suggestions for a rainy afternoon:

**Frontend Call:**
```dart
final response = await rulesService.getSuggestionsForPod(
  householdId: householdId,
  podMemberIds: kidsPod.memberIds,
  weather: 'rainy',
  timeBucket: 'afternoon',
  dayOfWeek: 'saturday',
  customPrompt: 'something creative',
  podId: kidsPod.id,
);
```

**Expected Response:**
```json
{
  "pod_id": "kids-pod-uuid",
  "pod_member_ids": ["child1-uuid", "child2-uuid"],
  "context_summary": "2 members, rainy, afternoon",
  "suggestions": [
    {
      "activity": "Indoor fort building",
      "rationale": "For Sarah & Tommy — perfect afternoon activity, cozy for the rain, honoring 'Educational activities only'",
      "durationMinutes": 45,
      "tags": ["indoor", "creative", "educational"]
    },
    {
      "activity": "Science experiments",
      "rationale": "For Sarah & Tommy — great timing, cozy for the rain, honoring 'No screen time'",
      "durationMinutes": 30,
      "tags": ["indoor", "educational", "science"]
    }
  ]
}
```

---

## 🚀 Next Steps

### For Frontend (Completed ✅)
- ✅ Rule models created
- ✅ RulesService implemented
- ✅ MemberRulesWidget created
- ✅ PodRulesWidget created
- ✅ MemberDetailPage created
- ✅ PodDetailPage created
- ✅ Integration in settings and pods pages

### For Backend (Your Tasks)
1. **Create Database Tables:**
   - `member_rules` with RLS
   - `pod_rules` with RLS
   - (Optional) `pod_learning_profiles`
   - (Optional) `suggestion_logs_with_pod`

2. **Implement Django Services:**
   - `RulesService` for CRUD operations
   - `PodSuggestionService` for pod-aware filtering and ranking

3. **Create API Endpoints:**
   - Member rules: GET, POST, DELETE
   - Pod rules: GET, POST, DELETE
   - Pod suggestions: POST

4. **Update Activity Service:**
   - Modify `generate_activity_suggestions` to incorporate rules
   - OR create new `generate_suggestions_for_pod` method

5. **Testing:**
   - Test all endpoints with curl/Postman
   - Verify RLS policies work correctly
   - Test pod-aware suggestions with real rules

---

## 📖 API Reference Summary

### Member Rules API

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/rules/member/?member_id={uuid}` | Get all rules for a member |
| POST | `/api/v1/rules/member/add/` | Add a rule for a member |
| DELETE | `/api/v1/rules/member/delete/?rule_id={uuid}` | Delete a member rule |

### Pod Rules API

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/rules/pod/?pod_id={uuid}` | Get all rules for a pod |
| POST | `/api/v1/rules/pod/add/` | Add a rule for a pod |
| DELETE | `/api/v1/rules/pod/delete/?rule_id={uuid}` | Delete a pod rule |

### Pod Suggestions API

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/suggestions/pod/` | Get pod-aware activity suggestions |

---

## 🎯 Summary

**Frontend is complete!** 🎉

You now have:
- Full UI for managing member and pod rules
- Service layer for API communication
- Beautiful detail pages for members and pods
- Integration with existing settings and pods management

**Next:** Implement the backend components outlined in this document to enable the full pod-aware filtering and rules experience!

---

## 📚 Related Documentation

- `PODS_FEATURE_COMPLETE.md` - Complete pods feature documentation
- Original Phase 3.5 spec (provided by you) - Backend implementation details
- `PHASE4_BACKEND_REQUIREMENTS.md` - Phase 4 backend requirements

---

## 💡 Tips

1. **Start with Database Tables**: Create `member_rules` and `pod_rules` first
2. **Test RLS Policies**: Ensure users can only access rules from their household
3. **Implement CRUD First**: Get basic member/pod rules working before pod suggestions
4. **Pod Suggestions Can Wait**: The pod-aware suggestions endpoint is optional for initial testing
5. **Use Existing Patterns**: Your backend likely has similar patterns for household/member management

Good luck with the backend implementation! 🚀

