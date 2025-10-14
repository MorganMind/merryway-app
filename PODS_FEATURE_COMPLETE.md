# Pods Feature - Complete Implementation Guide

## Overview

**Pods** are sub-groups within a family that allow you to quickly organize and select specific combinations of family members for activities. Think of them as saved presets for "who's joining" - e.g., "Parents + Toddler", "Older kids only", "Everyone".

---

## 1. Database Schema (Supabase)

### Table: `pods`

```sql
-- Drop existing pods table if it exists (for clean setup)
DROP TABLE IF EXISTS pods CASCADE;

-- Create pods table
CREATE TABLE pods (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  household_id UUID NOT NULL REFERENCES households(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  member_ids JSONB NOT NULL DEFAULT '[]'::jsonb, -- Array of member UUIDs
  color TEXT DEFAULT '#B4D7E8', -- Hex color for visual identification
  icon TEXT DEFAULT '👥', -- Emoji or icon name
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index on household_id for faster queries
CREATE INDEX idx_pods_household_id ON pods(household_id);

-- Enable Row Level Security
ALTER TABLE pods ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view their household's pods" ON pods;
DROP POLICY IF EXISTS "Users can insert pods for their household" ON pods;
DROP POLICY IF EXISTS "Users can update their household's pods" ON pods;
DROP POLICY IF EXISTS "Users can delete their household's pods" ON pods;

-- RLS Policies
CREATE POLICY "Users can view their household's pods"
  ON pods FOR SELECT
  USING (
    household_id IN (
      SELECT id FROM households WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert pods for their household"
  ON pods FOR INSERT
  WITH CHECK (
    household_id IN (
      SELECT id FROM households WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update their household's pods"
  ON pods FOR UPDATE
  USING (
    household_id IN (
      SELECT id FROM households WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete their household's pods"
  ON pods FOR DELETE
  USING (
    household_id IN (
      SELECT id FROM households WHERE user_id = auth.uid()
    )
  );

-- Trigger to auto-update updated_at
DROP TRIGGER IF EXISTS update_pods_updated_at ON pods;
CREATE TRIGGER update_pods_updated_at
  BEFORE UPDATE ON pods
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

### Example Data

```sql
-- Insert example pods
INSERT INTO pods (household_id, name, description, member_ids, color, icon)
VALUES
  ('your-household-uuid', 'Everyone', 'The whole family', '["member-1-uuid", "member-2-uuid", "member-3-uuid"]'::jsonb, '#B4D7E8', '👨‍👩‍👧‍👦'),
  ('your-household-uuid', 'Parents Only', 'Just mom and dad', '["parent-1-uuid", "parent-2-uuid"]'::jsonb, '#E5C17D', '👫'),
  ('your-household-uuid', 'Kids', 'All the children', '["child-1-uuid", "child-2-uuid"]'::jsonb, '#D9B9E0', '👶');
```

---

## 2. Flutter Model

### File: `lib/modules/family/models/pod_model.dart`

```dart
import 'package:equatable/equatable.dart';

class Pod extends Equatable {
  final String? id;
  final String householdId;
  final String name;
  final String? description;
  final List<String> memberIds;
  final String color;
  final String icon;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Pod({
    this.id,
    required this.householdId,
    required this.name,
    this.description,
    required this.memberIds,
    this.color = '#B4D7E8',
    this.icon = '👥',
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        householdId,
        name,
        description,
        memberIds,
        color,
        icon,
        createdAt,
        updatedAt,
      ];

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'household_id': householdId,
        'name': name,
        if (description != null) 'description': description,
        'member_ids': memberIds,
        'color': color,
        'icon': icon,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      };

  factory Pod.fromJson(Map<String, dynamic> json) {
    return Pod(
      id: json['id'],
      householdId: json['household_id'],
      name: json['name'],
      description: json['description'],
      memberIds: List<String>.from(json['member_ids'] ?? []),
      color: json['color'] ?? '#B4D7E8',
      icon: json['icon'] ?? '👥',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Pod copyWith({
    String? id,
    String? householdId,
    String? name,
    String? description,
    List<String>? memberIds,
    String? color,
    String? icon,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Pod(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      name: name ?? this.name,
      description: description ?? this.description,
      memberIds: memberIds ?? this.memberIds,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
```

---

## 3. Pods Management Page

### File: `lib/modules/family/pages/pods_management_page.dart`

**Purpose:** Full CRUD interface for managing pods.

**Features:**
- List all pods for a household
- Create new pods
- Edit existing pods
- Delete pods
- Color and icon picker
- Member selection

**Key Methods:**
- `_loadPods()` - Fetch pods from Supabase
- `_showCreatePodDialog()` - Dialog to create new pod
- `_showEditPodDialog()` - Dialog to edit existing pod
- `_deletePod()` - Delete a pod with confirmation

**Usage:**
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => PodsManagementPage(
      householdId: householdId,
      allMembers: familyMembers,
    ),
  ),
);
```

---

## 4. Participant Preset Sheet

### File: `lib/modules/home/widgets/participant_preset_sheet.dart`

**Purpose:** Quick selection sheet to apply pods or manage them.

**Features:**
- Display all pods with icons, colors, and member names
- Apply a pod (set selected participants)
- Navigate to Pods Management page
- Edit button on each pod

**Key Parameters:**
```dart
ParticipantPresetSheet({
  required List<FamilyMember> allMembers,
  required Set<String> currentSelection,
  required List<Pod> pods,
  required Function(Set<String>) onApplyPod,
  required VoidCallback onManagePods,
})
```

**Usage:**
```dart
showModalBottomSheet(
  context: context,
  builder: (context) => ParticipantPresetSheet(
    allMembers: familyMembers,
    currentSelection: selectedParticipants,
    pods: pods,
    onApplyPod: (memberIds) {
      setState(() => selectedParticipants = memberIds);
    },
    onManagePods: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PodsManagementPage(...),
        ),
      );
    },
  ),
);
```

---

## 5. Integration in HomePage

### File: `lib/modules/home/pages/home_page.dart`

**State Variables:**
```dart
List<Pod> pods = [];
Set<String> selectedParticipants = {};
```

**Methods:**

#### Load Pods from Supabase
```dart
Future<void> _loadPods() async {
  if (householdId == null) return;

  try {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('pods')
        .select()
        .eq('household_id', householdId!)
        .order('created_at');

    setState(() {
      pods = (response as List).map((json) => Pod.fromJson(json)).toList();
    });
  } catch (e) {
    print('Error loading pods: $e');
  }
}
```

#### Show Preset Sheet
```dart
void _showPresetSheet() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ParticipantPresetSheet(
      allMembers: familyMembers,
      currentSelection: selectedParticipants,
      pods: pods,
      onApplyPod: (memberIds) {
        _onParticipantsChanged(memberIds);
      },
      onManagePods: () async {
        Navigator.pop(context);
        if (householdId != null && familyMembers.isNotEmpty) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PodsManagementPage(
                householdId: householdId!,
                allMembers: familyMembers,
              ),
            ),
          );
          await _loadPods(); // Reload pods after returning
        }
      },
    ),
  );
}
```

#### Update Participants
```dart
void _onParticipantsChanged(Set<String> newSelection) {
  setState(() {
    selectedParticipants = newSelection;
  });
  _saveParticipantSelection();
  _fetchNewSuggestion(); // Re-fetch suggestions with new participants
}
```

---

## 6. Integration in Settings

### File: `lib/modules/settings/pages/simple_settings_page.dart`

**Pods Section:**
```dart
Card(
  child: Column(
    children: [
      ListTile(
        leading: const Icon(Icons.groups),
        title: const Text('Pods'),
        subtitle: const Text('Manage family sub-groups'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PodsManagementPage(
                householdId: householdId!,
                allMembers: familyMembers,
              ),
            ),
          );
        },
      ),
    ],
  ),
)
```

---

## 7. Participant Selector Integration

### File: `lib/modules/home/widgets/participant_selector.dart`

**Purpose:** Displays family members as chips with selection state.

**Long Press Behavior:**
- Long-pressing any member chip opens the Participant Preset Sheet
- This allows quick access to pods for fast selection

**Integration:**
```dart
ParticipantSelector(
  allMembers: familyMembers,
  selectedMemberIds: selectedParticipants,
  onSelectionChanged: _onParticipantsChanged,
  onManagePresets: _showPresetSheet, // Opens preset sheet with pods
)
```

---

## 8. Key Features & Behaviors

### Auto-Reload
- Pods are loaded on `HomePage` initialization via `_loadPods()`
- Pods are reloaded after returning from `PodsManagementPage`

### Persistence
- Pods are stored in Supabase (permanent)
- Participant selections can be saved to `SharedPreferences` per context (optional)

### Visual Identity
- Each pod has a **color** (hex code) for visual distinction
- Each pod has an **icon** (emoji) for quick recognition

### Member Display
- Preset sheet shows member names for each pod: "Alice, Bob, Charlie"
- Gracefully handles members that no longer exist

### Edit Flow
1. User taps "Manage" in preset sheet → Opens `PodsManagementPage`
2. User taps "Edit" (✏️) on a pod → Opens edit dialog
3. User modifies name, description, members, color, icon
4. User saves → Pod updated in Supabase
5. User returns to home → Pods reloaded

---

## 9. Testing Checklist

### Database
- [ ] Run SQL migration in Supabase SQL Editor
- [ ] Verify `pods` table exists
- [ ] Verify RLS policies are active
- [ ] Insert test data and verify it appears

### Create Pod
- [ ] Open Pods Management page
- [ ] Tap "Create New Pod"
- [ ] Enter name, description
- [ ] Select members
- [ ] Choose color and icon
- [ ] Save and verify it appears in list

### Edit Pod
- [ ] Tap "Edit" (✏️) on a pod
- [ ] Modify any field
- [ ] Save and verify changes persist

### Delete Pod
- [ ] Tap "Delete" on a pod
- [ ] Confirm deletion
- [ ] Verify pod is removed

### Apply Pod
- [ ] On home page, long-press a member chip
- [ ] Preset sheet opens
- [ ] Tap a pod
- [ ] Verify participants are updated on suggestion card

### Suggestion Integration
- [ ] Apply a pod
- [ ] Tap "Try Another Idea"
- [ ] Verify backend receives correct `participant_ids`
- [ ] Verify suggestions are personalized to the pod

---

## 10. Common Patterns

### Creating a Pod
```dart
final newPod = Pod(
  householdId: householdId,
  name: 'Weekend Warriors',
  description: 'Dad and the kids for Saturday adventures',
  memberIds: ['dad-id', 'kid-1-id', 'kid-2-id'],
  color: '#E5C17D',
  icon: '⚽',
);

await supabase.from('pods').insert(newPod.toJson());
```

### Updating a Pod
```dart
await supabase
    .from('pods')
    .update({
      'name': 'Updated Name',
      'member_ids': ['member-1', 'member-2'],
    })
    .eq('id', podId);
```

### Deleting a Pod
```dart
await supabase.from('pods').delete().eq('id', podId);
```

### Fetching Pods
```dart
final response = await supabase
    .from('pods')
    .select()
    .eq('household_id', householdId)
    .order('created_at');

final pods = (response as List).map((json) => Pod.fromJson(json)).toList();
```

---

## 11. Future Enhancements

### Suggested Features
1. **Smart Pods**: Auto-create pods based on usage patterns
2. **Default Pod**: Set a default pod for specific times/days
3. **Pod Scheduling**: "Use 'Kids' pod on weekday afternoons"
4. **Pod Analytics**: Track which pods are used most
5. **Pod Sharing**: Share pod configurations between households
6. **Color Themes**: Pre-defined color palettes for pods
7. **Icon Library**: Expanded emoji/icon picker
8. **Pod Templates**: Pre-built templates for common family structures

---

## 12. Troubleshooting

### Pods Not Appearing
- Verify `household_id` matches in both `households` and `pods` tables
- Check RLS policies are enabled
- Verify user is authenticated
- Check browser console for errors

### "Edit" Button Not Working
- Verify `onManagePods` callback is passed to `ParticipantPresetSheet`
- Check navigation is properly closing the sheet before opening management page

### Members Not Updating
- Ensure `member_ids` is a valid JSON array in Supabase
- Verify member IDs exist in `family_members` table
- Check that `_loadPods()` is called after returning from management page

### Pods Not Saving
- Check Supabase table permissions
- Verify RLS policies allow INSERT/UPDATE
- Check for validation errors in pod data (missing required fields)

---

## 13. API Reference

### Pod Model Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `id` | `String?` | No | UUID, auto-generated |
| `householdId` | `String` | Yes | FK to households table |
| `name` | `String` | Yes | Display name of pod |
| `description` | `String?` | No | Optional description |
| `memberIds` | `List<String>` | Yes | Array of member UUIDs |
| `color` | `String` | No | Hex color code (default: `#B4D7E8`) |
| `icon` | `String` | No | Emoji or icon name (default: `👥`) |
| `createdAt` | `DateTime?` | No | Auto-generated timestamp |
| `updatedAt` | `DateTime?` | No | Auto-updated timestamp |

---

## 14. Summary

Pods provide a powerful, user-friendly way to organize family members into reusable groups. The implementation is:

✅ **Database-backed**: Persistent storage in Supabase  
✅ **Secure**: RLS policies ensure data privacy  
✅ **User-friendly**: Visual identity with colors and icons  
✅ **Integrated**: Deep integration with participant selection and suggestions  
✅ **Flexible**: Full CRUD operations with intuitive UI  
✅ **Performant**: Efficient queries with proper indexing  

The feature is **production-ready** and can be extended with the suggested enhancements above.

