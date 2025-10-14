# Default "Just Me" Pod Feature

## Overview

Every authenticated user automatically gets a default pod called **"Just Me"** with the description **"On my Merryway"**. This pod is personal to each household and only visible to that household's members (via Row Level Security).

---

## 🎯 Purpose

The "Just Me" pod allows users to quickly get activity suggestions for solo activities or mark themselves for individual experiences. It provides a convenient default for single-person planning.

---

## ✨ Features

### 1. Automatic Creation
- **Created on Onboarding**: When a user completes onboarding and creates a household, the "Just Me" pod is automatically created.
- **Created for Existing Users**: When existing users open the home page, the system checks if the "Just Me" pod exists. If not, it creates it automatically.

### 2. Pod Properties
- **Name**: `Just Me`
- **Description**: `On my Merryway`
- **Icon**: 🎒
- **Color**: `#B4D7E8` (Soft Blue)
- **Initial Members**: Empty (user can add themselves via account linking)

### 3. Account Linking Integration
- **Auto-Add on Link**: When a user links their authenticated account to a family member, that member is automatically added to the "Just Me" pod.
- **Auto-Remove on Unlink**: If the linking logic supports unlinking (future feature), the member will be removed from the "Just Me" pod.

---

## 📦 Implementation

### Service: `DefaultPodService`

**Location**: `lib/modules/family/services/default_pod_service.dart`

#### Methods:

##### `ensureDefaultPodExists(String householdId)`
Checks if the "Just Me" pod exists for a household. If not, creates it.

**Usage**:
```dart
await DefaultPodService.ensureDefaultPodExists(householdId);
```

**Called in**:
- `OnboardingPage` - After household and members are created
- `HomePage._loadHouseholdId()` - When home page loads (for existing users)

##### `addCurrentUserToDefaultPod({required String householdId, required String memberId})`
Adds a family member to the "Just Me" pod. If the pod doesn't exist, creates it first.

**Usage**:
```dart
await DefaultPodService.addCurrentUserToDefaultPod(
  householdId: householdId,
  memberId: member.id,
);
```

**Called in**:
- `SimpleSettingsPage._linkMemberToCurrentUser()` - After user links their account to a member

##### `removeCurrentUserFromDefaultPod({required String householdId, required String memberId})`
Removes a family member from the "Just Me" pod.

**Usage** (future):
```dart
await DefaultPodService.removeCurrentUserFromDefaultPod(
  householdId: householdId,
  memberId: member.id,
);
```

---

## 🔄 User Flow

### New Users (Onboarding)
1. User signs up and authenticates
2. User creates household: "The Smiths"
3. User adds family members: Mom, Dad, Kids
4. **System automatically creates "Just Me" pod** (empty)
5. User can optionally link their account to "Mom"
6. **System automatically adds "Mom" to "Just Me" pod**
7. User navigates to home page
8. User can select "Just Me" pod from preset sheet

### Existing Users (No "Just Me" Pod Yet)
1. User opens app and navigates to home page
2. `HomePage._loadHouseholdId()` is called
3. **System checks if "Just Me" pod exists**
4. **If not, system creates it automatically**
5. Pods are loaded and displayed
6. User sees "Just Me" in their pod list

### Linking Account
1. User goes to Settings
2. User taps "This is me" button on a family member
3. System confirms linking
4. **System updates member with `user_id`**
5. **System adds member to "Just Me" pod**
6. Data is reloaded
7. User sees confirmation

---

## 🗄️ Database

### Table: `pods`

The "Just Me" pod is stored in the standard `pods` table with these properties:

```json
{
  "id": "generated-uuid",
  "household_id": "household-uuid",
  "name": "Just Me",
  "description": "On my Merryway",
  "member_ids": [],  // Empty initially, populated when user links account
  "icon": "🎒",
  "color": "#B4D7E8",
  "created_at": "2025-10-12T10:00:00Z",
  "updated_at": "2025-10-12T10:00:00Z"
}
```

### Row Level Security (RLS)

The "Just Me" pod is protected by the same RLS policies as all other pods:

```sql
-- Users can only view pods from their own household
CREATE POLICY "Users can view their household's pods"
  ON pods FOR SELECT
  USING (
    household_id IN (
      SELECT id FROM households WHERE user_id = auth.uid()
    )
  );
```

This ensures each household's "Just Me" pod is only visible to members of that household.

---

## 🎨 UI Behavior

### Pod List
The "Just Me" pod appears in the standard pod list:
- **Settings → Pods → Manage**: Shows "Just Me" along with other pods
- **Home Page → Long-press member chip**: Shows "Just Me" in preset sheet

### Identification
- **Icon**: 🎒 (backpack emoji)
- **Color**: Soft blue (#B4D7E8)
- **Position**: Sorted alphabetically, so typically appears near the top

### Editing
Users can edit the "Just Me" pod like any other pod:
- Change name (not recommended, but allowed)
- Change description
- Change icon and color
- Add/remove members manually
- Delete the pod (system will recreate it on next app load)

---

## 🧪 Testing Checklist

### New User Flow
- [ ] Create new account
- [ ] Complete onboarding
- [ ] Verify "Just Me" pod exists in database
- [ ] Navigate to Settings → Pods → Manage
- [ ] Verify "Just Me" pod is visible
- [ ] Verify pod has correct name, description, icon, color
- [ ] Verify `member_ids` is empty array

### Existing User Flow (No Pod Yet)
- [ ] Use existing account without "Just Me" pod
- [ ] Navigate to home page
- [ ] Verify "Just Me" pod is created
- [ ] Refresh pods list
- [ ] Verify "Just Me" pod appears

### Account Linking Flow
- [ ] Go to Settings
- [ ] Link account to a family member
- [ ] Verify member is added to "Just Me" pod
- [ ] Check database to confirm `member_ids` contains member UUID
- [ ] Open preset sheet on home page
- [ ] Select "Just Me" pod
- [ ] Verify only the linked member is selected

### Resilience
- [ ] Delete "Just Me" pod manually in database
- [ ] Reload home page
- [ ] Verify "Just Me" pod is recreated
- [ ] Create pod with name "Just Me" manually
- [ ] Reload home page
- [ ] Verify system doesn't create duplicate
- [ ] Verify existing "Just Me" pod is preserved

---

## 🐛 Error Handling

### Pod Creation Failure
If pod creation fails (network error, database error, etc.):
- Error is logged to debug console
- App continues normally
- Pod will be created on next app load/refresh

### Silent Failures
All `DefaultPodService` methods catch exceptions and log them without throwing. This ensures:
- Onboarding doesn't fail due to pod creation issues
- Home page doesn't crash if pod creation fails
- Account linking succeeds even if "Just Me" pod update fails

---

## 🔮 Future Enhancements

### Smart Initialization
- Automatically add the primary user (first member created) to "Just Me" pod
- Pre-populate based on account email/name matching

### Personalization
- Allow users to customize the default pod's name and description
- Remember user's preference for "Just Me" pod icon/color

### Multi-User Pods
- Create multiple personal pods: "Just Me (Work)", "Just Me (Relaxing)"
- Allow users to have multiple solo-focused pods

### Pod Templates
- Offer "Just Me" as a template when creating new pods
- Include other common templates: "Date Night", "Kids Only", etc.

---

## 📚 Related Documentation

- **`PODS_FEATURE_COMPLETE.md`** - Complete pods feature documentation
- **`PHASE3_5_POD_RULES_FRONTEND.md`** - Pod rules and filtering documentation
- **Supabase Setup**: See `fix_pods_table.sql` for pod table schema

---

## 🎯 Summary

✅ **Automatic**: Created for all new and existing users  
✅ **Personal**: Only visible within each household  
✅ **Integrated**: Works with account linking  
✅ **Resilient**: Handles errors gracefully  
✅ **Customizable**: Users can edit like any other pod  

The "Just Me" pod provides a convenient default for single-person activity planning, enhancing the user experience without requiring any additional setup! 🎒✨

