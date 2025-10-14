# Phase 4: DO - Backend Requirements

This document outlines **exactly what you need to implement** in the Django backend to support the "DO" phase (Live Experiences).

---

## What the Frontend Expects

### 1. List Experiences (GET)
The frontend calls:
```python
GET /api/v1/experiences/?household_id=<id>&status=<status>
```

**Expected Response:**
```json
[
  {
    "id": "uuid",
    "household_id": "uuid",
    "activity_name": "Park Playground",
    "suggestion_id": "optional-uuid",
    "participant_ids": ["uuid1", "uuid2"],
    "start_at": "2025-10-12T15:30:00Z",
    "end_at": "2025-10-12T17:30:00Z",
    "place": "Golden Gate Park",
    "place_address": null,
    "place_lat": null,
    "place_lng": null,
    "status": "live",  // or "planned", "done", "cancelled"
    "prep_notes": "Bring sunscreen",
    "needs_adult": false,
    "cost_estimate": null,
    "created_by": "uuid",
    "created_at": "2025-10-12T14:00:00Z",
    "updated_at": "2025-10-12T15:30:00Z"
  }
]
```

### 2. Update Experience Status (PATCH)
The frontend calls:
```python
PATCH /api/v1/experiences/<experience_id>/
Content-Type: application/json
Authorization: Bearer <supabase-jwt>

{
  "status": "live",
  "start_at": "2025-10-12T15:30:00Z"
}
```

**Expected Response:**
```json
{
  "id": "uuid",
  "status": "live",
  "start_at": "2025-10-12T15:30:00Z",
  ...all other fields...
}
```

### 3. Create Experience (POST)
Already implemented (calls Django API from `CreateExperienceSheet`).

---

## Option 1: Direct Supabase Reads (Frontend Only)

**YOU DON'T NEED TO DO ANYTHING ON THE BACKEND.**

The frontend already has this implemented in `ExperienceRepository.listExperiences()`:

```dart
Future<List<Experience>> listExperiences(String householdId, {String? status}) async {
  final response = status != null
      ? await _supabase
          .from('experiences')
          .select()
          .eq('household_id', householdId)
          .eq('status', status)
          .order('created_at', ascending: false)
      : await _supabase
          .from('experiences')
          .select()
          .eq('household_id', householdId)
          .order('created_at', ascending: false);

  return (response as List).map((json) => Experience.fromJson(json)).toList();
}
```

**Pros:**
- ✅ No backend work required
- ✅ Fast reads (direct from Supabase)
- ✅ Works offline with Supabase caching

**Cons:**
- ❌ No backend validation on reads
- ❌ No server-side filtering/logic

---

## Option 2: Django API for Reads (Recommended for Consistency)

If you want **all** experience operations to go through Django (for logging, analytics, policy checks), implement these Django endpoints:

### Django View: List Experiences

**File:** `family/views/experiences.py`

```python
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from supabase import create_client
import os

SUPABASE_URL = os.environ.get('SUPABASE_URL')
SUPABASE_KEY = os.environ.get('SUPABASE_SERVICE_KEY')
supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def list_experiences_view(request):
    """
    GET /api/v1/experiences/?household_id=<id>&status=<status>
    
    List experiences for a household, optionally filtered by status.
    """
    household_id = request.query_params.get('household_id')
    status_filter = request.query_params.get('status')
    
    if not household_id:
        return Response(
            {'error': 'household_id query parameter required'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    # Verify user has access to this household
    user_id = str(request.user.id)
    household_check = supabase.table('households').select('id').eq('id', household_id).eq('user_id', user_id).execute()
    
    if not household_check.data:
        return Response(
            {'error': 'Household not found or access denied'},
            status=status.HTTP_404_NOT_FOUND
        )
    
    # Query experiences
    query = supabase.table('experiences').select('*').eq('household_id', household_id)
    
    if status_filter:
        query = query.eq('status', status_filter)
    
    query = query.order('created_at', desc=True)
    
    result = query.execute()
    
    return Response(result.data, status=status.HTTP_200_OK)
```

### Django View: Update Experience

**File:** `family/views/experiences.py`

```python
@api_view(['PATCH'])
@permission_classes([IsAuthenticated])
def update_experience_view(request, experience_id):
    """
    PATCH /api/v1/experiences/<experience_id>/
    
    Update an experience (typically status changes).
    """
    # Verify experience exists and user has access
    experience = supabase.table('experiences').select('*').eq('id', experience_id).single().execute()
    
    if not experience.data:
        return Response(
            {'error': 'Experience not found'},
            status=status.HTTP_404_NOT_FOUND
        )
    
    household_id = experience.data['household_id']
    user_id = str(request.user.id)
    
    # Verify user owns this household
    household_check = supabase.table('households').select('id').eq('id', household_id).eq('user_id', user_id).execute()
    
    if not household_check.data:
        return Response(
            {'error': 'Access denied'},
            status=status.HTTP_403_FORBIDDEN
        )
    
    # Update experience
    updates = request.data
    
    # Add updated_at timestamp
    from datetime import datetime, timezone
    updates['updated_at'] = datetime.now(timezone.utc).isoformat()
    
    result = supabase.table('experiences').update(updates).eq('id', experience_id).execute()
    
    return Response(result.data[0], status=status.HTTP_200_OK)
```

### URL Configuration

**File:** `family/urls.py`

```python
from django.urls import path
from .views import experiences

urlpatterns = [
    # ... existing patterns ...
    
    # Experiences
    path('experiences/', experiences.list_experiences_view, name='list_experiences'),
    path('experiences/<uuid:experience_id>/', experiences.update_experience_view, name='update_experience'),
]
```

---

## What About the Debrief/Reviews?

**Already implemented!** The frontend calls these Django endpoints (from `PHASE4_BACKEND_REQUIREMENTS.md`):

1. **POST `/api/v1/experiences/<experience_id>/reviews/`** - Create review
2. **POST `/api/v1/merry-moments/`** - Create Merry Moment
3. **POST `/api/v1/media/upload/`** - Upload photo

These endpoints **must exist** in your Django backend for the debrief modal to work.

---

## ICS Calendar Download

**No backend required!** The ICS file is generated client-side in Flutter and downloaded directly to the user's browser.

---

## Navigation to Places

**No backend required!** The Flutter app uses `url_launcher` to open Google Maps URLs directly.

---

## Summary

### Required Backend Changes:

#### If Using Option 1 (Direct Supabase Reads):
- ✅ **Nothing!** Frontend already reads directly from Supabase.
- ⚠️ **You still need** the Phase 4 write endpoints:
  - `POST /api/v1/experiences/` (create)
  - `PATCH /api/v1/experiences/<id>/` (update status)
  - `POST /api/v1/experiences/<id>/reviews/` (debrief)
  - `POST /api/v1/merry-moments/` (create moment)
  - `POST /api/v1/media/upload/` (upload photo)

#### If Using Option 2 (Django for All Operations):
- ⚠️ **Add** the two views above:
  - `GET /api/v1/experiences/` (list)
  - `PATCH /api/v1/experiences/<id>/` (update)
- ⚠️ **Keep** all Phase 4 write endpoints from above

---

## Testing Your Backend

### Test 1: List Experiences
```bash
curl -X GET \
  'http://localhost:8000/api/v1/experiences/?household_id=<YOUR_HOUSEHOLD_ID>&status=live' \
  -H 'Authorization: Bearer <SUPABASE_JWT>'
```

**Expected:** 200 OK with array of experiences

### Test 2: Update Experience Status
```bash
curl -X PATCH \
  'http://localhost:8000/api/v1/experiences/<EXPERIENCE_ID>/' \
  -H 'Authorization: Bearer <SUPABASE_JWT>' \
  -H 'Content-Type: application/json' \
  -d '{
    "status": "live",
    "start_at": "2025-10-12T15:30:00Z"
  }'
```

**Expected:** 200 OK with updated experience object

### Test 3: Create Experience (Already Tested)
```bash
curl -X POST \
  'http://localhost:8000/api/v1/experiences/' \
  -H 'Authorization: Bearer <SUPABASE_JWT>' \
  -H 'Content-Type: application/json' \
  -d '{
    "household_id": "<YOUR_HOUSEHOLD_ID>",
    "activity_name": "Park Playground",
    "participant_ids": ["<MEMBER_ID_1>", "<MEMBER_ID_2>"],
    "start_at": "2025-10-12T15:30:00Z",
    "place": "Golden Gate Park",
    "status": "planned"
  }'
```

**Expected:** 201 Created with experience object

---

## Dependencies

Already in `requirements.txt` (from Phase 4):
```
supabase==2.9.1
djangorestframework==3.15.0
python-jose[cryptography]==3.3.0
```

No new dependencies needed for DO phase.

---

## What's Working vs What's Not

### ✅ Already Working (Frontend):
- Creates experiences via Django API
- Reads experiences via Supabase (Option 1)
- Updates experience status via Django API (if you implement it)
- Displays live/planned experiences on home page
- ICS calendar download
- Google Maps navigation
- Debrief modal with Django API calls

### ⚠️ Needs Backend Implementation:
- **Option 1:** Just the write endpoints (create, update, review, moment, media)
- **Option 2:** All CRUD endpoints (list, create, update, delete, review, moment, media)

### ❌ Not Implemented Anywhere:
- Consent/policy checks (runs silently, no UI feedback yet)
- Offline experience updates (works online only)
- Push notifications for upcoming experiences
- Recurring experiences
- Experience templates

---

## Recommendation

**Use Option 1** (Direct Supabase reads from frontend):
- Faster for users
- Less backend code
- Frontend already implements it
- You only need to implement the write endpoints (which you may already have from Phase 4)

**Use Option 2** if:
- You want centralized logging/analytics
- You need server-side filtering (e.g., policy-based visibility)
- You want to add caching or rate limiting

---

## Next Steps

1. **Check if you already have** the Phase 4 write endpoints:
   - `POST /api/v1/experiences/`
   - `PATCH /api/v1/experiences/<id>/`
   - `POST /api/v1/experiences/<id>/reviews/`
   - `POST /api/v1/merry-moments/`
   - `POST /api/v1/media/upload/`

2. **If yes:** You're done! Frontend will work with Option 1.

3. **If no:** Implement them using `PHASE4_BACKEND_REQUIREMENTS.md` as a guide.

4. **If you want Option 2:** Add the two GET/PATCH views above.

5. **Test the frontend** by creating an experience and watching it appear on the home page.

