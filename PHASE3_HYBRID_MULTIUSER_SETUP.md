# Phase 3: Hybrid Multi-User System 🎭

## Overview

Merryway now supports **hybrid multi-user identity** that combines the best of personal accounts and family-shared devices:

### Two Modes of Operation

1. **Personal Accounts** (Individual Auth)
   - Each family member has their own Supabase email/password login
   - Perfect for: Teens, independent users, separate devices
   - Votes and activity are tied to their auth account

2. **Family Mode** (Netflix-Style Switcher)
   - Parents enable "Family Mode" on their account
   - One login, but multiple family member profiles
   - Perfect for: Young kids, shared iPads/devices, convenience
   - Quick user switching with optional PIN protection

---

## Architecture

```
┌──────────────────────────────────────────────────────────┐
│                  Supabase Auth Account                   │
│                  (email/password login)                   │
└────────────────────┬─────────────────────────────────────┘
                     │
                     ├─→ Option 1: Linked Member
                     │   (member.user_id = auth.uid)
                     │   → Individual account, own login
                     │
                     └─→ Option 2: Family Mode
                         (household.family_mode_enabled = true)
                         → Show UserSwitcher widget
                         → Select active member from list
                         → Optional PIN protection per member
```

### Key Components

| Component | Purpose |
|-----------|---------|
| `family_members.user_id` | Links Supabase auth user to member (nullable) |
| `households.family_mode_enabled` | Enables user switcher on device |
| `family_members.device_pin` | 6-digit PIN for protected accounts |
| `family_members.pin_required` | Whether PIN is required |
| `family_members.avatar_emoji` | Profile emoji for visual identity |
| `UserContextService` | Determines current active member |
| `UserSwitcher` | Netflix-style UI for switching profiles |

---

## Database Setup

### Step 1: Run SQL Migration

Run `supabase_phase3_multi_user.sql` in your Supabase SQL editor:

```bash
# This creates:
✓ Updated family_members table (user_id, device_pin, pin_required, avatar_emoji)
✓ Updated households table (family_mode_enabled)
✓ consent_scopes table (predefined capabilities)
✓ member_consents table (per-member permissions)
✓ household_norms table (household-wide rules)
✓ policy_logs table (audit trail)
✓ RLS policies for all tables
✓ Helper functions (get_current_member_id)
```

### Step 2: Verify Tables

Check that these columns exist:

```sql
-- family_members
SELECT column_name FROM information_schema.columns 
WHERE table_name = 'family_members';

-- Should include:
-- user_id, device_pin, pin_required, avatar_emoji

-- households
SELECT column_name FROM information_schema.columns 
WHERE table_name = 'households';

-- Should include:
-- family_mode_enabled
```

---

## Frontend Implementation

### Files Added/Modified

**New Files:**
- `lib/modules/auth/services/user_context_service.dart` - Current member logic
- `lib/modules/auth/widgets/user_switcher.dart` - Netflix-style picker
- `lib/modules/family/models/family_models.dart` - Updated with Phase 3 fields

**Modified Files:**
- `lib/modules/home/pages/home_page.dart` - Integrated user switcher
- `lib/modules/home/widgets/suggestion_card.dart` - Pass currentMemberId
- `lib/modules/home/widgets/idea_voting_widget.dart` - Use currentMemberId

### How It Works

1. **On App Start**:
   ```dart
   // Load household and members
   await _loadHouseholdId();
   
   // Determine current member
   final memberId = await UserContextService.getCurrentMemberId(
     allMembers: familyMembers,
     familyModeEnabled: familyModeEnabled,
   );
   ```

2. **Current Member Priority**:
   - ✅ **First**: Check if auth user is linked to a member (`member.user_id == auth.uid`)
   - ✅ **Second**: If family mode enabled, use switcher selection (from `SharedPreferences`)
   - ✅ **Third**: Return `null` (no active member)

3. **User Switcher** (if family mode enabled):
   ```dart
   UserSwitcher(
     members: familyMembers,
     currentUser: UserContextService.getCurrentMember(
       currentMemberId,
       familyMembers,
     ),
     onUserSelected: (member) {
       // Saves to SharedPreferences
       // Updates UI
       // Re-fetches suggestions
     },
   )
   ```

4. **Voting with Current Member**:
   ```dart
   IdeaVotingWidget(
     activityName: 'Park Picnic',
     householdId: householdId,
     allMembers: familyMembers,
     currentMemberId: currentMemberId, // ← Who is voting
     category: 'today',
   )
   ```

---

## Usage Scenarios

### Scenario 1: Family with Teens + Young Kids

**Setup:**
- **Mom** (Parent): Own Supabase account (`mom@family.com`)
  - Enables family mode: `UPDATE households SET family_mode_enabled = true`
  - Links her account: `UPDATE family_members SET user_id = 'mom-auth-id' WHERE name = 'Mom'`
- **Dad** (Parent): Own Supabase account (`dad@family.com`)
  - Links his account: `UPDATE family_members SET user_id = 'dad-auth-id' WHERE name = 'Dad'`
- **Teen (15)**: Own Supabase account (`teen@family.com`)
  - Links their account: `UPDATE family_members SET user_id = 'teen-auth-id' WHERE name = 'Emma'`
- **Kid 1 (8)**: No auth account
  - Uses switcher on Mom's device
- **Kid 2 (5)**: No auth account
  - Uses switcher on Mom's device

**Result:**
- Mom logs in → See user switcher (Mom, Kid 1, Kid 2)
- Dad logs in → No switcher (just Dad)
- Teen logs in → No switcher (just Teen)
- When Kid 1 votes on Mom's device → Vote recorded for Kid 1

### Scenario 2: Single Parent with PIN-Protected Account

**Setup:**
- **Parent**: Supabase account, family mode enabled
  - Sets PIN on their profile: `device_pin = '123456'`, `pin_required = true`
- **Child**: No auth account

**Result:**
- Parent logs in → User switcher shows (Parent, Child)
- Child can select "Child" freely (no PIN)
- To switch to "Parent" → Requires PIN entry
- Prevents kids from seeing parent-only features

### Scenario 3: Each Member Has Their Own Device

**Setup:**
- **All members**: Own Supabase accounts
  - Each has `user_id` linked to their member record
  - Family mode disabled: `family_mode_enabled = false`

**Result:**
- No user switcher shown
- Each person logs into their own device
- Votes, suggestions, etc. are personalized to their account

---

## Enabling Family Mode

### Option 1: Settings UI (Recommended) ✨

**Built-in to the app!** Just:

1. Open Settings (⚙️ icon on home screen)
2. Scroll to "Family Mode" section
3. Toggle the switch **ON**
4. ✅ Done! User switcher appears on home screen

The UI shows:
- **Enabled**: "User switcher is shown on home screen. Perfect for shared devices!"
- **Disabled**: "Enable to show a Netflix-style user switcher for family members..."

### Option 2: Supabase Dashboard (Manual)

```sql
-- Enable family mode for a household
UPDATE households 
SET family_mode_enabled = true 
WHERE id = 'your-household-id';
```

Then hot restart your app.

---

## Setting PINs for Members

### Option 1: Supabase Dashboard (Manual)

```sql
-- Set PIN for a member
UPDATE family_members 
SET device_pin = '123456', pin_required = true 
WHERE id = 'member-id';
```

### Option 2: Settings UI (Recommended)

Add PIN settings in member edit dialog:

```dart
TextField(
  controller: _pinController,
  decoration: InputDecoration(
    labelText: 'Device PIN (optional)',
    hintText: 'Leave empty for no PIN',
  ),
  keyboardType: TextInputType.number,
  maxLength: 6,
  obscureText: true,
)

CheckboxListTile(
  title: const Text('Require PIN to switch to this account'),
  value: _pinRequired,
  onChanged: (value) {
    setState(() => _pinRequired = value ?? false);
  },
)
```

---

## Avatar Emojis

Add visual identity to members:

```sql
UPDATE family_members 
SET avatar_emoji = '👨' 
WHERE name = 'Dad';

UPDATE family_members 
SET avatar_emoji = '👩' 
WHERE name = 'Mom';

UPDATE family_members 
SET avatar_emoji = '🧒' 
WHERE name = 'Emma';
```

Or in onboarding/settings:

```dart
// Emoji picker
Row(
  children: ['👨', '👩', '👧', '👦', '🧒', '👶'].map((emoji) {
    return GestureDetector(
      onTap: () => setState(() => selectedEmoji = emoji),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: selectedEmoji == emoji 
              ? Colors.blue.withOpacity(0.2) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(emoji, style: const TextStyle(fontSize: 24)),
      ),
    );
  }).toList(),
)
```

---

## Testing the Hybrid System

### Test 1: Personal Account (No Switcher)

1. Create a household with 1 member (yourself)
2. Link your auth account:
   ```sql
   UPDATE family_members 
   SET user_id = (SELECT auth.uid()) 
   WHERE household_id = 'your-household-id';
   ```
3. Family mode disabled: `family_mode_enabled = false`
4. ✅ **Expected**: No user switcher shown, voting works as you

### Test 2: Family Mode (Switcher Visible)

1. Enable family mode:
   ```sql
   UPDATE households SET family_mode_enabled = true WHERE id = 'your-household-id';
   ```
2. Add 2+ members (don't link `user_id`)
3. Hot restart app
4. ✅ **Expected**: User switcher appears in header
5. ✅ **Expected**: Can switch between members
6. ✅ **Expected**: Votes are recorded for selected member

### Test 3: PIN Protection

1. Set PIN for one member:
   ```sql
   UPDATE family_members 
   SET device_pin = '123456', pin_required = true 
   WHERE name = 'Parent';
   ```
2. Try switching to that member
3. ✅ **Expected**: PIN entry modal appears
4. ✅ **Expected**: Correct PIN → switches successfully
5. ✅ **Expected**: Wrong PIN → error message, stays on current user

### Test 4: Hybrid (Some Linked, Some Not)

1. Link your account (Parent):
   ```sql
   UPDATE family_members SET user_id = (SELECT auth.uid()) WHERE name = 'Parent';
   ```
2. Enable family mode: `family_mode_enabled = true`
3. Add 2 more members (kids, no `user_id`)
4. ✅ **Expected**: User switcher shows all 3 members
5. ✅ **Expected**: Your votes always go to "Parent" (you're auth-linked)
6. ✅ **Expected**: Can switch to kids for their votes

---

## Troubleshooting

### Issue: User switcher not showing

**Check:**
- Is `family_mode_enabled = true`?
  ```sql
  SELECT family_mode_enabled FROM households WHERE id = 'your-id';
  ```
- Are there 2+ members in the household?
- Did you hot restart after enabling family mode?

**Fix:**
```sql
UPDATE households SET family_mode_enabled = true WHERE id = 'your-household-id';
```
Then hot restart (`R` in terminal).

---

### Issue: Votes not recording for correct member

**Check:**
- Is `currentMemberId` being passed to `IdeaVotingWidget`?
- Check `UserContextService.getCurrentMemberId()` logic

**Debug:**
```dart
print('Current Member ID: $currentMemberId');
print('Family Mode Enabled: $familyModeEnabled');
print('Auth User ID: ${Supabase.instance.client.auth.currentUser?.id}');
```

---

### Issue: PIN entry not working

**Check:**
- Is `device_pin` set and `pin_required = true`?
  ```sql
  SELECT device_pin, pin_required FROM family_members WHERE id = 'member-id';
  ```
- Is PIN exactly 6 digits?

**Fix:**
```sql
UPDATE family_members 
SET device_pin = '123456', pin_required = true 
WHERE id = 'member-id';
```

---

## Backend Integration (Coming in Phase 3.5)

The backend will use `currentMemberId` for:
- **Policy checks**: Is this member allowed to do paid activities?
- **Consent scopes**: Can this member upload photos?
- **Household norms**: Does this violate quiet hours?
- **Analytics**: Track which member engages most

Example backend policy check:

```python
from family.services.policy_service import PolicyEvaluationService

# Check if current member can suggest a paid activity
policy_response = await PolicyEvaluationService.check_policy(
    household_id=household_id,
    request=PolicyCheckRequest(
        participant_ids=[current_member_id],  # ← From frontend
        action="suggest_activity",
        action_context={
            "cost_usd": 15,
            "outdoor": True,
        }
    )
)

if not policy_response.allowed:
    return JsonResponse({
        "error": policy_response.reason,
        "blocked_by": policy_response.blocked_by,
    }, status=403)
```

---

## Summary

✅ **Hybrid system** supports both personal accounts and family-shared devices  
✅ **User switcher** appears when family mode is enabled  
✅ **PIN protection** keeps parent accounts secure  
✅ **Current member context** flows through voting, suggestions, and (soon) policies  
✅ **Flexible architecture** adapts to your family's needs  

**Next Steps:**
1. Run `supabase_phase3_multi_user.sql` migration
2. Enable family mode for your household
3. Set avatar emojis for fun visual identity
4. (Optional) Set PINs for protected accounts
5. Test user switching and voting

---

## Need Help?

- **SQL not running?** Check Supabase SQL editor permissions
- **Switcher not showing?** Verify `family_mode_enabled = true`
- **Votes going to wrong member?** Check `currentMemberId` is passed correctly

🎯 **You're ready for Phase 3! Multi-user identity is live!**

