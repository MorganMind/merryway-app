# Phase 3: Quick Start Guide 🚀

## What You Just Got

✨ **Hybrid Multi-User Identity System**
- Everyone can have their own login (teens, parents)
- OR use Netflix-style user switcher on shared devices (young kids)
- Voting now knows WHO is voting
- PIN protection for parent accounts

---

## 3-Minute Setup

### Step 1: Run Database Migration

1. Open Supabase Dashboard → SQL Editor
2. Copy contents of `supabase_phase3_multi_user.sql`
3. Execute
4. ✅ Done! Tables and RLS policies created

### Step 2: Enable Family Mode (Optional)

**Option A: From UI (Recommended)** ✨
1. Go to Settings (⚙️ icon on home screen)
2. Find the "Family Mode" section
3. Toggle it **ON**
4. Done! User switcher will appear on home screen

**Option B: Via SQL**

```sql
UPDATE households 
SET family_mode_enabled = true 
WHERE id = 'your-household-id';
```

**To get your household ID:**
```sql
SELECT id, name FROM households WHERE user_id = (SELECT auth.uid());
```

### Step 3: Set Avatar Emojis (Optional but fun!)

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

UPDATE family_members 
SET avatar_emoji = '👶' 
WHERE name = 'Lily';
```

### Step 4: Hot Restart App

```bash
# In your Flutter terminal, press 'R'
```

---

## What You'll See

### If Family Mode is DISABLED (default):
- No user switcher
- Voting works as the logged-in user
- Good for: personal devices, teens with their own accounts

### If Family Mode is ENABLED:
- **User switcher** appears in top-right of home screen
- Tap to see all family members
- Select a member to switch
- **Their** votes get recorded
- Good for: shared iPads, young kids using parent's device

---

## Next Steps

### Add PIN Protection (Optional)

For parent accounts on shared devices:

```sql
UPDATE family_members 
SET device_pin = '123456', pin_required = true 
WHERE name = 'Mom';
```

Now kids can't switch to Mom's profile without the PIN!

### Backend Integration (Your Turn)

The frontend now sends `currentMemberId` everywhere. When you implement:
- **Consent scopes** (Can this kid do paid activities?)
- **Household norms** (Is it past quiet hours?)
- **Policy checks** (Is this member allowed to upload photos?)

...the backend will know WHO is asking and can enforce rules accordingly.

See `PHASE3_HYBRID_MULTIUSER_SETUP.md` for full details.

---

## Common Scenarios

### Scenario: "I'm a single parent with 2 young kids"

**Setup:**
1. Enable family mode: `UPDATE households SET family_mode_enabled = true`
2. Set avatar emojis for everyone
3. (Optional) Set PIN on your account

**Result:**
- Log in once on your iPad
- Use switcher to let kids pick their profile
- Their votes/suggestions are personalized to them
- You can switch back to your profile with PIN

### Scenario: "My teenager wants their own account"

**Setup:**
1. Have teen sign up with their own email
2. Link their account:
   ```sql
   UPDATE family_members 
   SET user_id = 'teen-auth-id' 
   WHERE name = 'Emma';
   ```
3. They log in on their own device

**Result:**
- Teen has full independence
- No switcher needed (they're auth-linked)
- Votes and activity tied to their account

### Scenario: "We all share one device, no separate logins"

**Setup:**
1. Parent logs in once
2. Enable family mode
3. Add all family members (no `user_id` linking)

**Result:**
- Everyone uses parent's login
- Switcher lets each person select their profile
- Votes are tracked per person

---

## Testing It

1. Hot restart app
2. If family mode enabled → See user switcher in top-right
3. Tap switcher → See list of all family members
4. Select a different member → Notice "Who's using?" changes
5. Vote on an activity → Check Supabase:
   ```sql
   SELECT * FROM idea_votes ORDER BY created_at DESC LIMIT 5;
   ```
6. ✅ Verify `member_id` matches selected user

---

## Files Changed

**New Files:**
- `supabase_phase3_multi_user.sql` - Database migration
- `lib/modules/auth/services/user_context_service.dart` - Who is using the app?
- `lib/modules/auth/widgets/user_switcher.dart` - Netflix-style UI
- `PHASE3_HYBRID_MULTIUSER_SETUP.md` - Full documentation

**Updated Files:**
- `lib/modules/family/models/family_models.dart` - Added Phase 3 fields
- `lib/modules/home/pages/home_page.dart` - Integrated user switcher
- `lib/modules/home/widgets/suggestion_card.dart` - Pass currentMemberId
- `lib/modules/home/widgets/idea_voting_widget.dart` - Use currentMemberId

---

## Troubleshooting

**Q: Switcher not showing?**
- Check: `SELECT family_mode_enabled FROM households`
- Should be `true`

**Q: Votes going to wrong person?**
- Check current member selection
- Debug: `print('Current Member ID: $currentMemberId');`

**Q: PIN not working?**
- Check: `SELECT device_pin, pin_required FROM family_members`
- PIN must be exactly 6 digits

---

## What's Next?

Phase 3 gives you the **foundation** for:
- ✅ Identity management (done!)
- 🔜 Consent scopes (backend)
- 🔜 Household norms (backend)
- 🔜 Policy evaluation (backend)
- 🔜 Permissions UI (frontend)

See the full spec in your original message for complete Phase 3 implementation.

🎉 **Enjoy your hybrid multi-user system!**

