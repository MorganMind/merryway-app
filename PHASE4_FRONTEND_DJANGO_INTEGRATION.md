# Phase 4: Frontend Django Integration

## Overview

The frontend has been updated to use the Django backend API for all write operations (create, update, delete) while keeping direct Supabase access for read operations (list, get) for optimal performance.

---

## What Changed

### **Architecture**

**Before:**
```
Frontend → Supabase (direct)
```

**After:**
```
Frontend → Django API → Supabase (for writes)
Frontend → Supabase (direct, for reads)
```

**Benefits:**
- Django validates all writes
- Django applies learning weights after reviews
- Django handles media uploads with thumbnailing
- Supabase direct reads remain fast (no API hop)

---

## New Files Created

### 1. `lib/modules/experiences/repositories/experience_repository.dart`

**Purpose:** Abstraction layer for all experience-related API calls.

**Methods:**

#### Experiences
- `createExperience(Experience)` → calls `POST /api/v1/experiences/`
- `updateExperience(String id, Map updates)` → calls `PATCH /api/v1/experiences/{id}/`
- `deleteExperience(String id)` → calls `DELETE /api/v1/experiences/{id}/`
- `getExperience(String id)` → calls `GET /api/v1/experiences/{id}/`
- `listExperiences(String householdId, {String? status})` → **Supabase direct** for performance

#### Reviews
- `createReview(ExperienceReview)` → calls `POST /api/v1/experiences/{id}/reviews/`
- `getReviews(String experienceId)` → **Supabase direct** for performance

#### Merry Moments
- `createMerryMoment(MerryMoment)` → calls `POST /api/v1/merry-moments/`
- `listMerryMoments(String householdId)` → **Supabase direct** for performance
- `getMerryMoment(String momentId)` → **Supabase direct** for performance

#### Media
- `uploadMedia({...})` → calls `POST /api/v1/media/upload/` (multipart)

**Features:**
- Automatically attaches Supabase JWT token to all requests
- Handles errors with exceptions
- Returns typed models

---

## Updated Files

### 1. `lib/modules/experiences/widgets/create_experience_sheet.dart`

**Changed:** `_createExperience()` method

**Before:**
```dart
await supabase.from('experiences').insert(experience.toJson());
```

**After:**
```dart
final repository = ExperienceRepository();
await repository.createExperience(experience);
```

**Benefit:** Django validates data and ensures business logic is applied.

---

### 2. `lib/modules/experiences/widgets/live_experience_card.dart`

**Changed:** `_markAsLive()` method

**Before:**
```dart
await supabase
    .from('experiences')
    .update({'status': 'live', 'start_at': DateTime.now().toIso8601String()})
    .eq('id', widget.experience.id!);
```

**After:**
```dart
final repository = ExperienceRepository();
await repository.updateExperience(
  widget.experience.id!,
  {'status': 'live', 'start_at': DateTime.now().toIso8601String()},
);
```

**Benefit:** Django validates status transitions.

---

### 3. `lib/modules/experiences/widgets/experience_debrief_modal.dart`

**Changed:** `_submitDebrief()` method

**Before (multiple direct Supabase calls):**
```dart
// 1. Create review
await supabase.from('experience_reviews').insert(review.toJson());

// 2. Mark experience as done
await supabase.from('experiences').update({...});

// 3. Create Merry Moment
await supabase.from('merry_moments').insert(moment.toJson());

// 4. Update household
await supabase.from('households').update({...});

// 5. Upload photo (placeholder)
```

**After (Django API handles everything):**
```dart
final repository = ExperienceRepository();

// 1. Create review (Django marks experience as done + updates learning weights)
await repository.createReview(review);

// 2. Create Merry Moment (Django updates household.last_activity_at)
final createdMoment = await repository.createMerryMoment(moment);

// 3. Upload photo (Django handles thumbnailing + EXIF scrubbing)
if (_photo != null) {
  await repository.uploadMedia(
    householdId: widget.experience.householdId,
    filePath: _photo!.path,
    merryMomentId: createdMoment.id,
    experienceId: widget.experience.id,
    caption: ...,
  );
}
```

**Benefits:**
- Django creates review + marks experience as done in one transaction
- Django updates learning weights automatically
- Django creates moment + updates household in one transaction
- Django processes media (thumbnails, EXIF scrub)
- Fewer round trips, better atomicity

---

### 4. `lib/modules/experiences/widgets/add_manual_moment_sheet.dart`

**Changed:** `_saveMoment()` method

**Before:**
```dart
await supabase.from('merry_moments').insert(moment.toJson());
await supabase.from('households').update({'last_activity_at': ...});
```

**After:**
```dart
final repository = ExperienceRepository();
await repository.createMerryMoment(moment);
// Django handles household update automatically
```

**Benefit:** Django ensures moment creation and household update happen atomically.

---

## Backend Requirements

For these frontend changes to work, you **MUST** implement the Django backend as specified in `PHASE4_BACKEND_REQUIREMENTS.md`.

### Critical Endpoints:

1. `POST /api/v1/experiences/` - Create experience
2. `PATCH /api/v1/experiences/{id}/` - Update experience
3. `POST /api/v1/experiences/{id}/reviews/` - Create review
   - Must mark experience as `done`
   - Must call `LearningService.update_weights_from_review()`
4. `POST /api/v1/merry-moments/` - Create merry moment
   - Must update `households.last_activity_at`
5. `POST /api/v1/media/upload/` - Upload media
   - Must generate thumbnail
   - Must scrub EXIF data
   - Must create `media_items` entry

---

## Testing the Integration

### 1. Create Experience
```dart
// User taps "Make it an Experience"
// Frontend calls: POST /api/v1/experiences/
// Django validates, creates in Supabase, returns created experience
```

**Backend must:**
- Validate `participant_ids` exist
- Validate `status` is valid enum
- Create experience in Supabase
- Return created experience JSON

### 2. Mark as Live
```dart
// User taps "Start"
// Frontend calls: PATCH /api/v1/experiences/{id}/
// Django validates, updates in Supabase
```

**Backend must:**
- Validate status transition (planned → live)
- Update in Supabase
- Return updated experience

### 3. Complete & Review
```dart
// User taps "Done" → fills debrief
// Frontend calls: POST /api/v1/experiences/{id}/reviews/
// Django creates review, marks experience done, updates weights
```

**Backend must:**
- Create review in Supabase
- Update experience.status = 'done', experience.end_at = now
- Call `LearningService.update_weights_from_review()`
- Return created review

### 4. Create Merry Moment
```dart
// After review, or manual entry
// Frontend calls: POST /api/v1/merry-moments/
// Django creates moment, updates household
```

**Backend must:**
- Create merry moment in Supabase
- Update `households.last_activity_at` to `occurred_at`
- Return created moment

### 5. Upload Media
```dart
// User selects photo in debrief
// Frontend calls: POST /api/v1/media/upload/ (multipart)
// Django uploads to Supabase Storage, creates media_items entry
```

**Backend must:**
- Accept multipart file upload
- Upload original to `media/{household_id}/{filename}` in Supabase Storage
- Generate thumbnail, upload to `media/{household_id}/thumbs/{filename}`
- Scrub EXIF data
- Create `media_items` entry with URLs
- Return created media_item JSON

---

## Error Handling

All repository methods throw exceptions on failure. Widgets catch and display to user:

```dart
try {
  await repository.createExperience(experience);
  // Success
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error: $e')),
  );
}
```

**Common Errors:**
- 400: Validation failed (missing fields, invalid data)
- 401: Not authenticated (JWT expired or missing)
- 404: Resource not found (experience/household doesn't exist)
- 500: Server error (Django exception, Supabase down)

---

## Environment Variables

Frontend already configured to use:
```dart
Environment.apiUrl // http://localhost:8000/api/v1 (development)
```

Backend must:
- Accept requests from `http://localhost:8686` (CORS)
- Validate JWT tokens from Supabase
- Return JSON responses

---

## Next Steps

1. **You (Backend):**
   - Run `supabase_phase4_plan_do_reflect.sql` migration
   - Create Supabase Storage bucket `media`
   - Install dependencies: `supabase-py`, `Pillow`, `python-magic`
   - Implement 11 API endpoints from `PHASE4_BACKEND_REQUIREMENTS.md`
   - Implement `LearningService` for weight updates
   - Test endpoints with curl

2. **Me (Frontend):**
   - ✅ Already done! Frontend is ready to use your API

3. **Testing:**
   - Create experience → should appear in `experiences` table
   - Mark as live → should update status
   - Complete → should create review, update weights, create moment
   - Upload photo → should appear in Supabase Storage

---

## Summary

✅ **Frontend changes complete**
✅ **New `ExperienceRepository` abstracts all API calls**
✅ **Widgets updated to use repository**
✅ **Hybrid architecture (Django for writes, Supabase for reads)**
✅ **Ready for backend implementation**

**Next:** Backend implements API endpoints → End-to-end flow works → Suggestions get smarter over time! 🚀

---

## Questions?

- **Q: Why not use Supabase for everything?**
  - A: Learning weights require server-side logic. Can't boost/dampen suggestions from client alone.

- **Q: Why keep Supabase direct reads?**
  - A: Performance. Listing moments/experiences doesn't need business logic, so skip the API hop.

- **Q: What if Django is down?**
  - A: Frontend shows error. User can retry. Consider implementing offline queue for critical actions.

- **Q: Can I change the API structure?**
  - A: Yes! Just update `ExperienceRepository` methods to match your endpoints.


