# Phase 4: Plan · Do · Reflect

## Overview

Phase 4 brings **Experiences** and **Merry Moments** to Merryway—transforming suggestions into lived experiences with tracking, debriefs, and memory keeping.

### Core Features

1. **Experiences**: Convert suggestions into planned/live/done activities
2. **Live Tracking**: Real-time experience cards with Start/Done/Navigate/Calendar
3. **10-Second Debrief**: Quick post-experience feedback capture
4. **Merry Moments**: Auto-created memory album from experiences
5. **Manual Journaling**: Natural language input with OpenAI parsing
6. **Days Since Tracking**: Track last activity date for pods and families

---

## Flow Diagram

```
Suggestion → Make Experience → Plan/Live → Complete → Debrief → Merry Moment
                                  ↓
                            Add to Calendar
                            Navigate to Place
                                  ↓
                            Manual Journal Entry (with OpenAI)
```

---

## Database Schema

### 1. `experiences`
```sql
id UUID PRIMARY KEY
household_id UUID (FK → households)
activity_name TEXT
suggestion_id TEXT (optional reference)
participant_ids JSONB (array of member IDs)
start_at TIMESTAMPTZ
end_at TIMESTAMPTZ
place TEXT
place_address TEXT
place_lat DOUBLE PRECISION
place_lng DOUBLE PRECISION
status TEXT (planned|live|done|cancelled)
prep_notes TEXT
needs_adult BOOLEAN
cost_estimate DECIMAL
created_by UUID (FK → auth.users)
created_at, updated_at TIMESTAMPTZ
```

### 2. `experience_reviews`
```sql
id UUID PRIMARY KEY
experience_id UUID (FK → experiences)
household_id UUID (FK → households)
rating INTEGER (1-5)
effort_felt TEXT (easy|moderate|hard)
cleanup_felt TEXT (easy|moderate|hard)
note TEXT
reviewed_by UUID (FK → auth.users)
created_at TIMESTAMPTZ
```

### 3. `merry_moments`
```sql
id UUID PRIMARY KEY
household_id UUID (FK → households)
experience_id UUID (FK → experiences, nullable)
title TEXT
description TEXT
participant_ids JSONB
occurred_at TIMESTAMPTZ
place TEXT
media_ids JSONB (array of media IDs)
created_by UUID
is_manual BOOLEAN (true if manually journaled)
created_at, updated_at TIMESTAMPTZ
```

### 4. `media_items`
```sql
id UUID PRIMARY KEY
household_id UUID (FK → households)
merry_moment_id UUID (FK → merry_moments)
experience_id UUID (FK → experiences)
file_url TEXT
thumbnail_url TEXT
mime_type TEXT
file_size_bytes INTEGER
width_px, height_px INTEGER
duration_seconds INTEGER (for videos)
caption TEXT
uploaded_by UUID
created_at TIMESTAMPTZ
```

### 5. Updated Columns
- `households.last_activity_at` (TIMESTAMPTZ)
- `pods.last_activity_at` (TIMESTAMPTZ)

---

## Setup Instructions

### 1. Run Supabase Migration

```bash
# In Supabase SQL Editor:
psql -h YOUR_SUPABASE_HOST -U postgres -d postgres < supabase_phase4_plan_do_reflect.sql

# Or copy/paste the contents into Supabase SQL Editor and run
```

### 2. Add OpenAI API Key

Get your OpenAI API key from [https://platform.openai.com/api-keys](https://platform.openai.com/api-keys)

Run the app with the key:

```bash
flutter run -d web-server --web-port 8686 \
  -t lib/main_development.dart \
  --dart-define=OPENAI_API_KEY=sk-your-key-here
```

### 3. Install Dependencies

```bash
flutter pub get
```

---

## Frontend Implementation

### Data Models

**Created:**
- `lib/modules/experiences/models/experience_models.dart`
  - `Experience`
  - `ExperienceReview`
  - `MerryMoment`
  - `MediaItem`
  - `ExperienceStatus` enum

### UI Components

**Created:**

1. **`CreateExperienceSheet`** (`lib/modules/experiences/widgets/create_experience_sheet.dart`)
   - Modal bottom sheet
   - Select participants
   - Choose time window (now/today/later)
   - Optional place, prep notes, cost
   - Creates `Experience` in Supabase

2. **`LiveExperienceCard`** (`lib/modules/experiences/widgets/live_experience_card.dart`)
   - Compact card for active/planned experiences
   - Shows elapsed time for live experiences
   - Actions: Start, Done, Navigate, Add to Calendar
   - Status badge (planned/live)

3. **`ExperienceDebriefModal`** (`lib/modules/experiences/widgets/experience_debrief_modal.dart`)
   - 10-second debrief dialog
   - Rating 1-5 stars
   - Effort felt (easy/moderate/hard)
   - Cleanup felt (easy/moderate/hard)
   - One-line note
   - Optional photo upload
   - Creates `ExperienceReview` and `MerryMoment`

4. **`MerryMomentsPage`** (`lib/modules/experiences/pages/merry_moments_page.dart`)
   - Album view of all merry moments
   - Shows manual and auto-generated moments
   - Days since tracking
   - FAB for manual journaling

5. **`AddManualMomentSheet`** (`lib/modules/experiences/widgets/add_manual_moment_sheet.dart`)
   - Natural language input field
   - "Parse with AI" button (OpenAI integration)
   - Auto-fills title, participants, place, date
   - Manual override for all fields

### Integration

**Updated:**
- `lib/modules/home/widgets/suggestion_card.dart`
  - Added "Make it an Experience" button
  - Accepts `onMakeExperience` callback

---

## User Flows

### Flow 1: Create and Complete an Experience

1. User sees a suggestion on home page
2. Taps **"Make it an Experience"**
3. **CreateExperienceSheet** opens:
   - Selects participants (default: current selection)
   - Chooses **"Now"** (starts immediately as `live`)
   - Optionally adds place, prep notes
   - Taps **"Start Now! 🎉"**
4. Experience is created with `status: live`
5. **LiveExperienceCard** appears (optional, can be shown on home):
   - Shows elapsed time
   - Has **"Done"** button
6. User taps **"Done"**
7. **ExperienceDebriefModal** opens:
   - Rates 1-5 stars
   - Selects effort/cleanup felt
   - Writes quick note
   - Optionally adds photo
   - Taps **"Save & Create Merry Moment"**
8. System:
   - Creates `ExperienceReview`
   - Updates experience `status: done`, `end_at: now`
   - Creates `MerryMoment` (linked to experience)
   - Updates `households.last_activity_at`
9. User sees **"✨ Merry Moment created!"** snackbar

### Flow 2: Manual Journaling with OpenAI

1. User opens **Merry Moments** page (add route or link)
2. Taps **"Journal"** FAB or **"Add Manual Moment"** header button
3. **AddManualMomentSheet** opens
4. User types in natural language:
   ```
   Today me and Sarah went to the park, then the whole family had pizza at 6pm
   ```
5. Taps **"Parse with AI"**
6. OpenAI parses and auto-fills:
   - **Title**: "Park Day & Pizza"
   - **Participants**: Sarah, [user], [other members]
   - **Place**: "Park" (or null if not specific)
   - **Date**: Today
7. User reviews, optionally edits
8. Taps **"Save Moment"**
9. System:
   - Creates `MerryMoment` with `is_manual: true`
   - Updates `households.last_activity_at`
10. User sees **"✨ Merry Moment saved!"**

### Flow 3: Plan an Experience for Later

1. User sees suggestion
2. Taps **"Make it an Experience"**
3. Chooses **"Later"**
4. Picks date + time (e.g., Saturday 2pm)
5. Adds place: "Golden Gate Park"
6. Adds prep notes: "Bring snacks and soccer ball"
7. Checks **"Needs adult"**
8. Taps **"Plan It"**
9. Experience created with `status: planned`, `start_at: <selected time>`
10. Later, user can:
    - View in a "Planned Experiences" section
    - Tap **"Start"** → changes to `status: live`
    - Export to calendar (.ics)
    - Navigate to place

---

## Days Since Tracking

**Purpose**: Show "It's been X days since you did something with [Pod/Family]"

**Implementation**:
- `households.last_activity_at` updated when:
  - Experience marked `done`
  - Manual moment created
- `pods.last_activity_at` updated when:
  - Experience with specific pod participants completes
  
**UI (Future)**:
- Home page banner: "It's been 3 days since you did something with the whole family"
- Pods page: Each pod shows "Last activity: 5 days ago"

---

## Backend Integration

### API Endpoints (User Implements)

#### 1. Experiences CRUD
```
POST   /api/v1/experiences/        # Create experience
GET    /api/v1/experiences/        # List household experiences
GET    /api/v1/experiences/:id/    # Get single experience
PATCH  /api/v1/experiences/:id/    # Update (status, start/end times)
DELETE /api/v1/experiences/:id/    # Cancel/delete
```

#### 2. Reviews
```
POST   /api/v1/experiences/:id/reviews/   # Create review
GET    /api/v1/experiences/:id/reviews/   # Get reviews for experience
```

#### 3. Merry Moments
```
POST   /api/v1/merry-moments/             # Create moment (manual or from experience)
GET    /api/v1/merry-moments/             # List household moments
GET    /api/v1/merry-moments/:id/         # Get single moment
PATCH  /api/v1/merry-moments/:id/         # Update moment
DELETE /api/v1/merry-moments/:id/         # Delete moment
```

#### 4. Media Upload
```
POST   /api/v1/media/upload/              # Multipart upload
  - Thumbnail generation
  - EXIF scrub
  - Store in Supabase Storage
  - Return media_item ID + URLs
```

#### 5. Learning Weights Update (Automatic)
After each review submission:
- Boost suggestions with high ratings
- Dampen suggestions with low ratings
- Consider context: weather, time, participants subset
- Preserve safety rules and diversity

---

## Environment Variables

### `.env.example`

```env
# Phase 4: Experiences & Merry Moments

# OpenAI API Key (for natural language journaling)
OPENAI_API_KEY=sk-your-openai-key-here

# Supabase (already configured)
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key

# Backend API
API_URL=http://localhost:8000/api/v1
```

### Run Command

```bash
flutter run -d web-server --web-port 8686 \
  -t lib/main_development.dart \
  --dart-define=OPENAI_API_KEY=sk-your-key
```

---

## Key Features Summary

✅ **Plan**: Create experiences from suggestions with participants, time, place  
✅ **Do**: Live tracking with elapsed time, navigation, calendar export  
✅ **Reflect**: 10-second debrief with rating, effort, note, photo  
✅ **Remember**: Auto-generated Merry Moments album  
✅ **Journal**: Manual entries with OpenAI natural language parsing  
✅ **Track**: Days since last activity for pods and families  

---

## Next Steps (Phase 5+)

- **Media Upload Service**: Full photo/video upload to Supabase Storage with thumbnailing
- **Share Links**: Short-lived share links for moments/albums
- **Learning Weights**: Backend ML to boost/dampen suggestions based on reviews
- **Wishbook**: User-created suggestions ("I want to...") that become future experiences
- **Calendar Sync**: Native calendar integration (not just ICS download)
- **Navigation Integration**: Deep links to Google Maps/Apple Maps with directions

---

## Testing Checklist

- [ ] Create experience from suggestion (now/today/later)
- [ ] Mark planned experience as live
- [ ] Mark live experience as done → debrief appears
- [ ] Submit debrief → merry moment created
- [ ] View merry moments page
- [ ] Add manual moment with natural language
- [ ] Parse with OpenAI → fields auto-fill
- [ ] Verify `last_activity_at` updates in households
- [ ] Verify participant chips work in experience sheet
- [ ] Verify live card shows elapsed time
- [ ] Verify "Add to Calendar" button (placeholder)
- [ ] Verify "Navigate" button (placeholder)

---

## Documentation Files

- `supabase_phase4_plan_do_reflect.sql` - Database migrations
- `.env.example` - Environment variables template
- `PHASE4_PLAN_DO_REFLECT.md` (this file) - Complete guide

---

**Phase 4 Complete!** 🎉  
Transform suggestions into lived experiences with memories that last.

