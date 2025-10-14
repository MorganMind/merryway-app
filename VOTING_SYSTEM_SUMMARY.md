# 🗳️ Idea Voting System - Implementation Summary

## Overview
3-level voting system (Love / Neutral / Not Interested) with smart aggregation logic for family activity suggestions.

---

## ✅ **What's Been Implemented**

### **1. Database (Supabase)**
**File:** `supabase_idea_votes.sql`

Created `idea_votes` table with:
- `household_id`, `member_id`, `activity_name`, `category`
- `vote_type`: `love`, `neutral`, or `not_interested`
- RLS policies for security
- Unique constraint: one vote per member per activity

**To Set Up:**
```sql
-- Run in Supabase SQL Editor
-- File: supabase_idea_votes.sql
```

---

### **2. Frontend Models**
**File:** `lib/modules/family/models/idea_vote_model.dart`

- `IdeaVote`: Represents a single vote
- `VoteType` enum: love, neutral, notInterested
- `VoteAggregation`: Smart vote counting with built-in logic:
  - `shouldHide`: Everyone voted "not interested"
  - `isJustForOne`: Everyone not interested except one "love"
  - `shouldPromptNeutral`: Everyone not interested except one "neutral"

---

### **3. Voting UI Widget**
**File:** `lib/modules/home/widgets/idea_voting_widget.dart`

**Features:**
- ✅ Vote buttons for each family member (Love / Neutral / Not Interested)
- ✅ Visual feedback (selected state, colors)
- ✅ Real-time vote aggregation
- ✅ Special badges:
  - **"Just for [Member]"** badge (pink with heart icon)
  - **"Would you love this or pass?"** prompt for neutral voters (amber)
- ✅ Vote summary counts at bottom

---

### **4. Integration**
**Updated Files:**
- `lib/modules/home/widgets/suggestion_card.dart` - Added voting widget
- `lib/modules/home/pages/home_page.dart` - Pass householdId to cards

---

## 🎯 **How It Works**

### **Voting Flow:**
1. Each family member sees 3 buttons on every suggestion:
   - ❤️ **Love** (red) - Really want to do this
   - ➖ **Neutral** (gray) - Don't care either way
   - ✖️ **Not Interested** (orange) - Don't want to do this

2. Votes are saved to Supabase in real-time

### **Smart Aggregation:**

#### **Scenario 1: Everyone Not Interested**
```
Dad: Not Interested ✖️
Mom: Not Interested ✖️
Alice: Not Interested ✖️
```
**Result:** Activity is hidden (future enhancement)

---

#### **Scenario 2: "Just for X"**
```
Dad: Not Interested ✖️
Mom: Not Interested ✖️
Alice: Love ❤️
```
**Result:** 
```
┌──────────────────────────────────┐
│ 💗 Just for Alice                │
└──────────────────────────────────┘
```
"Sometimes you have to do things for others"

---

#### **Scenario 3: Prompt Neutral Voter**
```
Dad: Not Interested ✖️
Mom: Not Interested ✖️
Alice: Neutral ➖
```
**Result:**
```
┌──────────────────────────────────┐
│ ❓ Alice, would you love this    │
│    or pass?                      │
└──────────────────────────────────┘
```

---

## 📱 **User Experience**

### **On Suggestion Card:**
```
┌─────────────────────────────────────┐
│  Visit the Museum                   │
│  [2.5 mi] [indoor] [120 min]       │
├─────────────────────────────────────┤
│  Who's joining? [Alice ✓] [Bob ✓]  │
├─────────────────────────────────────┤
│  🗳️ VOTING                          │
│                                     │
│  Dad                                │
│  [❤️ Love] [➖ Neutral] [✖️ Pass]  │
│                                     │
│  Mom                                │
│  [❤️ Love] [➖ Neutral] [✖️ Pass]  │
│                                     │
│  Alice                              │
│  [❤️ Love] [➖ Neutral] [✖️ Pass]  │
│                                     │
│  ❤️ 1  ➖ 0  ✖️ 2                   │
├─────────────────────────────────────┤
│  Rationale text...                  │
│  ...rest of card                    │
└─────────────────────────────────────┘
```

---

## 🔮 **Future Enhancements (Not Yet Implemented)**

### **Phase 2:**
1. **Hide voted-out activities** - Don't show suggestions where everyone voted "not interested"
2. **Filter by category** - Different voting for "today", "upcoming", "saved ideas"
3. **Vote history** - See past votes, change votes
4. **Vote-based suggestions** - Backend uses votes to improve future suggestions
5. **Notification system** - Alert neutral voters when they need to decide
6. **Vote analytics** - "Alice loves museums!" insights

---

## 🚀 **To Use**

### **1. Run SQL Migration**
```bash
# Open Supabase SQL Editor
# Paste contents of: supabase_idea_votes.sql
# Click "Run"
```

### **2. Restart App**
```bash
# App will auto-reload with voting feature
```

### **3. Test Voting**
1. Open app → Home → See suggestions
2. Each suggestion now has voting buttons
3. Try different scenarios:
   - Everyone votes "Not Interested"
   - One person votes "Love", others "Not Interested" → See "Just for X" badge
   - One person votes "Neutral", others "Not Interested" → See prompt

---

## 🛠️ **Technical Details**

### **Vote Storage:**
```json
{
  "id": "uuid",
  "household_id": "household-uuid",
  "member_id": "member-uuid",
  "activity_name": "Visit the Museum",
  "category": "today",
  "vote_type": "love",
  "context": {"weather": "sunny", "time": "morning"}
}
```

### **Aggregation Logic:**
```dart
// Hide if everyone voted not interested
shouldHide = (notInterestedCount == totalMembers)

// "Just for X" if one loves, rest don't
isJustForOne = (loveCount == 1 && notInterestedCount == totalMembers - 1)

// Prompt if one neutral, rest don't
shouldPromptNeutral = (neutralCount == 1 && notInterestedCount == totalMembers - 1)
```

---

## ✨ **Design Principles**

1. **Family-first** - Consider everyone's preferences
2. **Considerate** - "Just for X" encourages doing things for others
3. **Non-intrusive** - Neutral voters only prompted when needed
4. **Real-time** - Votes saved immediately
5. **Visual clarity** - Clear icons and colors for each vote type

---

**Enjoy the new voting system!** 🎉

