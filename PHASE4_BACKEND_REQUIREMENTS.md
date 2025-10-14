# Phase 4: Backend Requirements

## Overview

This document outlines **exactly what you need to implement** in the Django backend for Phase 4: Plan · Do · Reflect.

**⚠️ IMPORTANT:** The Django backend is **REQUIRED** for Phase 4, not optional. The backend will:
- Handle all experience/review/moment creation (with validation)
- Implement learning weights to boost/dampen suggestions based on feedback
- Process media uploads with thumbnailing and EXIF scrubbing
- Provide business logic layer between frontend and Supabase

---

## 1. Database Setup (Supabase)

**File:** `supabase_phase4_plan_do_reflect.sql`

### Action Required:
```bash
# Run this in Supabase SQL Editor
# Copy/paste the entire contents of supabase_phase4_plan_do_reflect.sql
```

### What It Creates:
- ✅ `experiences` table
- ✅ `experience_reviews` table
- ✅ `merry_moments` table
- ✅ `media_items` table
- ✅ Adds `last_activity_at` to `households` and `pods`
- ✅ RLS policies for all tables
- ✅ Indexes for performance

**Status:** Database schema is ready, just needs to be executed in Supabase.

---

## 2. Django Models (REQUIRED)

**Location:** `family/models.py` (or create `family/models/experiences.py`)

### Models to Create:

**Note:** While the frontend uses Supabase directly for reads, these models allow Django to perform business logic, validation, and learning weight updates.

```python
from django.db import models
from django.contrib.postgres.fields import ArrayField
import uuid

class Experience(models.Model):
    STATUS_CHOICES = [
        ('planned', 'Planned'),
        ('live', 'Live'),
        ('done', 'Done'),
        ('cancelled', 'Cancelled'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4)
    household_id = models.UUIDField(db_index=True)
    activity_name = models.TextField(null=True, blank=True)
    suggestion_id = models.TextField(null=True, blank=True)
    participant_ids = ArrayField(models.UUIDField(), default=list)
    start_at = models.DateTimeField(null=True, blank=True)
    end_at = models.DateTimeField(null=True, blank=True)
    place = models.TextField(null=True, blank=True)
    place_address = models.TextField(null=True, blank=True)
    place_lat = models.FloatField(null=True, blank=True)
    place_lng = models.FloatField(null=True, blank=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='planned')
    prep_notes = models.TextField(null=True, blank=True)
    needs_adult = models.BooleanField(default=False)
    cost_estimate = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    created_by = models.UUIDField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'experiences'
        ordering = ['-created_at']


class ExperienceReview(models.Model):
    EFFORT_CHOICES = [
        ('easy', 'Easy'),
        ('moderate', 'Moderate'),
        ('hard', 'Hard'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4)
    experience_id = models.UUIDField(db_index=True)
    household_id = models.UUIDField(db_index=True)
    rating = models.IntegerField()  # 1-5
    effort_felt = models.CharField(max_length=20, choices=EFFORT_CHOICES, null=True, blank=True)
    cleanup_felt = models.CharField(max_length=20, choices=EFFORT_CHOICES, null=True, blank=True)
    note = models.TextField(null=True, blank=True)
    reviewed_by = models.UUIDField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'experience_reviews'
        ordering = ['-created_at']


class MerryMoment(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4)
    household_id = models.UUIDField(db_index=True)
    experience_id = models.UUIDField(null=True, blank=True)
    title = models.TextField()
    description = models.TextField(null=True, blank=True)
    participant_ids = ArrayField(models.UUIDField(), default=list)
    occurred_at = models.DateTimeField(db_index=True)
    place = models.TextField(null=True, blank=True)
    media_ids = ArrayField(models.UUIDField(), default=list)
    created_by = models.UUIDField(null=True, blank=True)
    is_manual = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'merry_moments'
        ordering = ['-occurred_at']


class MediaItem(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4)
    household_id = models.UUIDField(db_index=True)
    merry_moment_id = models.UUIDField(null=True, blank=True)
    experience_id = models.UUIDField(null=True, blank=True)
    file_url = models.TextField()
    thumbnail_url = models.TextField(null=True, blank=True)
    mime_type = models.TextField()
    file_size_bytes = models.IntegerField(null=True, blank=True)
    width_px = models.IntegerField(null=True, blank=True)
    height_px = models.IntegerField(null=True, blank=True)
    duration_seconds = models.IntegerField(null=True, blank=True)
    caption = models.TextField(null=True, blank=True)
    uploaded_by = models.UUIDField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'media_items'
        ordering = ['-created_at']
```

**Note:** These models are required for Django to validate, process, and apply learning weights to experiences.

---

## 3. Pydantic Schemas (REQUIRED)

**Location:** `family/schemas.py` (or `family/schemas/experiences.py`)

### Schemas to Create:

These schemas validate incoming API requests and ensure data integrity.

```python
from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime
from enum import Enum

class ExperienceStatus(str, Enum):
    planned = "planned"
    live = "live"
    done = "done"
    cancelled = "cancelled"

class ExperienceCreate(BaseModel):
    household_id: str
    activity_name: Optional[str] = None
    suggestion_id: Optional[str] = None
    participant_ids: List[str] = []
    start_at: Optional[datetime] = None
    end_at: Optional[datetime] = None
    place: Optional[str] = None
    place_address: Optional[str] = None
    place_lat: Optional[float] = None
    place_lng: Optional[float] = None
    status: ExperienceStatus = ExperienceStatus.planned
    prep_notes: Optional[str] = None
    needs_adult: bool = False
    cost_estimate: Optional[float] = None
    created_by: Optional[str] = None

class ExperienceUpdate(BaseModel):
    activity_name: Optional[str] = None
    participant_ids: Optional[List[str]] = None
    start_at: Optional[datetime] = None
    end_at: Optional[datetime] = None
    place: Optional[str] = None
    status: Optional[ExperienceStatus] = None
    prep_notes: Optional[str] = None

class ExperienceResponse(BaseModel):
    id: str
    household_id: str
    activity_name: Optional[str]
    suggestion_id: Optional[str]
    participant_ids: List[str]
    start_at: Optional[datetime]
    end_at: Optional[datetime]
    place: Optional[str]
    status: str
    prep_notes: Optional[str]
    needs_adult: bool
    cost_estimate: Optional[float]
    created_by: Optional[str]
    created_at: datetime
    updated_at: datetime

class ExperienceReviewCreate(BaseModel):
    experience_id: str
    household_id: str
    rating: int = Field(..., ge=1, le=5)
    effort_felt: Optional[str] = None  # easy, moderate, hard
    cleanup_felt: Optional[str] = None  # easy, moderate, hard
    note: Optional[str] = None
    reviewed_by: Optional[str] = None

class MerryMomentCreate(BaseModel):
    household_id: str
    experience_id: Optional[str] = None
    title: str
    description: Optional[str] = None
    participant_ids: List[str] = []
    occurred_at: datetime
    place: Optional[str] = None
    media_ids: List[str] = []
    created_by: Optional[str] = None
    is_manual: bool = False

class MerryMomentResponse(BaseModel):
    id: str
    household_id: str
    experience_id: Optional[str]
    title: str
    description: Optional[str]
    participant_ids: List[str]
    occurred_at: datetime
    place: Optional[str]
    media_ids: List[str]
    created_by: Optional[str]
    is_manual: bool
    created_at: datetime
    updated_at: datetime
```

---

## 4. API Endpoints (Django Views) - REQUIRED

**Location:** `family/views/experiences.py`

### All 11 Endpoints Must Be Implemented:

The frontend will call these endpoints instead of directly accessing Supabase.

#### A. Experiences CRUD

```python
from django.views.decorators.http import require_http_methods
from django.views.decorators.csrf import csrf_exempt
from django.http import JsonResponse
import json
from supabase import create_client
from datetime import datetime

# Initialize Supabase client
supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

# --------------------------------------------------
# 1. CREATE EXPERIENCE
# --------------------------------------------------
@csrf_exempt
@require_http_methods(["POST"])
async def create_experience(request):
    """
    POST /api/v1/experiences/
    
    Body:
    {
        "household_id": "uuid",
        "activity_name": "Park Picnic",
        "participant_ids": ["member1", "member2"],
        "start_at": "2024-01-15T14:00:00Z",
        "place": "Golden Gate Park",
        "status": "planned",
        "prep_notes": "Bring snacks",
        "needs_adult": true,
        "cost_estimate": 25.50
    }
    """
    try:
        data = json.loads(request.body)
        
        # Insert into Supabase (or use Django ORM if you created models)
        result = supabase.table('experiences').insert(data).execute()
        
        return JsonResponse(result.data[0], status=201)
    except Exception as e:
        return JsonResponse({"error": str(e)}, status=400)


# --------------------------------------------------
# 2. LIST EXPERIENCES
# --------------------------------------------------
@csrf_exempt
@require_http_methods(["GET"])
async def list_experiences(request):
    """
    GET /api/v1/experiences/?household_id=xxx&status=live
    """
    try:
        household_id = request.GET.get('household_id')
        status = request.GET.get('status')  # Optional filter
        
        query = supabase.table('experiences').select('*')
        
        if household_id:
            query = query.eq('household_id', household_id)
        if status:
            query = query.eq('status', status)
        
        result = query.order('created_at', desc=True).execute()
        
        return JsonResponse({"experiences": result.data}, status=200)
    except Exception as e:
        return JsonResponse({"error": str(e)}, status=400)


# --------------------------------------------------
# 3. GET SINGLE EXPERIENCE
# --------------------------------------------------
@csrf_exempt
@require_http_methods(["GET"])
async def get_experience(request, experience_id):
    """
    GET /api/v1/experiences/<id>/
    """
    try:
        result = supabase.table('experiences').select('*').eq('id', experience_id).single().execute()
        return JsonResponse(result.data, status=200)
    except Exception as e:
        return JsonResponse({"error": str(e)}, status=404)


# --------------------------------------------------
# 4. UPDATE EXPERIENCE
# --------------------------------------------------
@csrf_exempt
@require_http_methods(["PATCH"])
async def update_experience(request, experience_id):
    """
    PATCH /api/v1/experiences/<id>/
    
    Body: { "status": "live", "start_at": "2024-01-15T14:05:00Z" }
    """
    try:
        data = json.loads(request.body)
        
        result = supabase.table('experiences').update(data).eq('id', experience_id).execute()
        
        return JsonResponse(result.data[0], status=200)
    except Exception as e:
        return JsonResponse({"error": str(e)}, status=400)


# --------------------------------------------------
# 5. DELETE EXPERIENCE
# --------------------------------------------------
@csrf_exempt
@require_http_methods(["DELETE"])
async def delete_experience(request, experience_id):
    """
    DELETE /api/v1/experiences/<id>/
    """
    try:
        supabase.table('experiences').delete().eq('id', experience_id).execute()
        return JsonResponse({"message": "Experience deleted"}, status=204)
    except Exception as e:
        return JsonResponse({"error": str(e)}, status=400)
```

#### B. Experience Reviews

```python
# --------------------------------------------------
# 6. CREATE REVIEW
# --------------------------------------------------
@csrf_exempt
@require_http_methods(["POST"])
async def create_review(request, experience_id):
    """
    POST /api/v1/experiences/<id>/reviews/
    
    Body:
    {
        "household_id": "uuid",
        "rating": 5,
        "effort_felt": "easy",
        "cleanup_felt": "moderate",
        "note": "Kids loved it!",
        "reviewed_by": "user-uuid"
    }
    """
    try:
        data = json.loads(request.body)
        data['experience_id'] = experience_id
        
        result = supabase.table('experience_reviews').insert(data).execute()
        
        return JsonResponse(result.data[0], status=201)
    except Exception as e:
        return JsonResponse({"error": str(e)}, status=400)


# --------------------------------------------------
# 7. GET REVIEWS FOR EXPERIENCE
# --------------------------------------------------
@csrf_exempt
@require_http_methods(["GET"])
async def get_reviews(request, experience_id):
    """
    GET /api/v1/experiences/<id>/reviews/
    """
    try:
        result = supabase.table('experience_reviews').select('*').eq('experience_id', experience_id).execute()
        return JsonResponse({"reviews": result.data}, status=200)
    except Exception as e:
        return JsonResponse({"error": str(e)}, status=400)
```

#### C. Merry Moments

```python
# --------------------------------------------------
# 8. CREATE MERRY MOMENT
# --------------------------------------------------
@csrf_exempt
@require_http_methods(["POST"])
async def create_merry_moment(request):
    """
    POST /api/v1/merry-moments/
    
    Body:
    {
        "household_id": "uuid",
        "experience_id": "uuid" (optional),
        "title": "Park Day",
        "description": "Great family time",
        "participant_ids": ["member1", "member2"],
        "occurred_at": "2024-01-15T14:00:00Z",
        "place": "Golden Gate Park",
        "is_manual": true
    }
    """
    try:
        data = json.loads(request.body)
        
        result = supabase.table('merry_moments').insert(data).execute()
        
        # Update household last_activity_at
        supabase.table('households').update({
            'last_activity_at': data['occurred_at']
        }).eq('id', data['household_id']).execute()
        
        return JsonResponse(result.data[0], status=201)
    except Exception as e:
        return JsonResponse({"error": str(e)}, status=400)


# --------------------------------------------------
# 9. LIST MERRY MOMENTS
# --------------------------------------------------
@csrf_exempt
@require_http_methods(["GET"])
async def list_merry_moments(request):
    """
    GET /api/v1/merry-moments/?household_id=xxx
    """
    try:
        household_id = request.GET.get('household_id')
        
        query = supabase.table('merry_moments').select('*')
        
        if household_id:
            query = query.eq('household_id', household_id)
        
        result = query.order('occurred_at', desc=True).execute()
        
        return JsonResponse({"moments": result.data}, status=200)
    except Exception as e:
        return JsonResponse({"error": str(e)}, status=400)


# --------------------------------------------------
# 10. GET SINGLE MERRY MOMENT
# --------------------------------------------------
@csrf_exempt
@require_http_methods(["GET"])
async def get_merry_moment(request, moment_id):
    """
    GET /api/v1/merry-moments/<id>/
    """
    try:
        result = supabase.table('merry_moments').select('*').eq('id', moment_id).single().execute()
        return JsonResponse(result.data, status=200)
    except Exception as e:
        return JsonResponse({"error": str(e)}, status=404)
```

#### D. Media Upload

```python
from PIL import Image
import io
import os
from django.core.files.uploadedfile import InMemoryUploadedFile

# --------------------------------------------------
# 11. UPLOAD MEDIA
# --------------------------------------------------
@csrf_exempt
@require_http_methods(["POST"])
async def upload_media(request):
    """
    POST /api/v1/media/upload/
    
    Multipart form data:
    - file: image/video file
    - household_id: uuid
    - merry_moment_id: uuid (optional)
    - experience_id: uuid (optional)
    - caption: string (optional)
    """
    try:
        file = request.FILES['file']
        household_id = request.POST.get('household_id')
        merry_moment_id = request.POST.get('merry_moment_id')
        experience_id = request.POST.get('experience_id')
        caption = request.POST.get('caption')
        
        # Generate filename
        ext = os.path.splitext(file.name)[1]
        filename = f"{household_id}/{uuid.uuid4()}{ext}"
        
        # Upload to Supabase Storage
        file_bytes = file.read()
        upload_result = supabase.storage.from_('media').upload(
            filename,
            file_bytes,
            {'content-type': file.content_type}
        )
        
        # Get public URL
        file_url = supabase.storage.from_('media').get_public_url(filename)
        
        # Generate thumbnail if image
        thumbnail_url = None
        if file.content_type.startswith('image/'):
            thumbnail_url = await _generate_thumbnail(file_bytes, filename, household_id)
        
        # EXIF scrub (remove metadata)
        # You can use PIL to strip EXIF data if needed
        
        # Get dimensions if image
        width_px, height_px = None, None
        if file.content_type.startswith('image/'):
            img = Image.open(io.BytesIO(file_bytes))
            width_px, height_px = img.size
        
        # Create media_item record
        media_data = {
            'household_id': household_id,
            'merry_moment_id': merry_moment_id,
            'experience_id': experience_id,
            'file_url': file_url,
            'thumbnail_url': thumbnail_url,
            'mime_type': file.content_type,
            'file_size_bytes': file.size,
            'width_px': width_px,
            'height_px': height_px,
            'caption': caption,
            'uploaded_by': request.user.id if request.user.is_authenticated else None,
        }
        
        result = supabase.table('media_items').insert(media_data).execute()
        
        return JsonResponse(result.data[0], status=201)
    except Exception as e:
        return JsonResponse({"error": str(e)}, status=400)


async def _generate_thumbnail(file_bytes, original_filename, household_id):
    """Generate and upload thumbnail"""
    img = Image.open(io.BytesIO(file_bytes))
    img.thumbnail((200, 200))
    
    thumb_io = io.BytesIO()
    img.save(thumb_io, format='JPEG')
    thumb_bytes = thumb_io.getvalue()
    
    thumb_filename = f"{household_id}/thumbs/{os.path.splitext(original_filename)[0]}_thumb.jpg"
    
    supabase.storage.from_('media').upload(
        thumb_filename,
        thumb_bytes,
        {'content-type': 'image/jpeg'}
    )
    
    return supabase.storage.from_('media').get_public_url(thumb_filename)
```

---

## 5. URL Configuration

**Location:** `family/urls.py`

```python
from django.urls import path
from .views import experiences

urlpatterns = [
    # Experiences
    path('experiences/', experiences.create_experience, name='create_experience'),
    path('experiences/', experiences.list_experiences, name='list_experiences'),
    path('experiences/<uuid:experience_id>/', experiences.get_experience, name='get_experience'),
    path('experiences/<uuid:experience_id>/', experiences.update_experience, name='update_experience'),
    path('experiences/<uuid:experience_id>/', experiences.delete_experience, name='delete_experience'),
    
    # Reviews
    path('experiences/<uuid:experience_id>/reviews/', experiences.create_review, name='create_review'),
    path('experiences/<uuid:experience_id>/reviews/', experiences.get_reviews, name='get_reviews'),
    
    # Merry Moments
    path('merry-moments/', experiences.create_merry_moment, name='create_merry_moment'),
    path('merry-moments/', experiences.list_merry_moments, name='list_merry_moments'),
    path('merry-moments/<uuid:moment_id>/', experiences.get_merry_moment, name='get_merry_moment'),
    
    # Media
    path('media/upload/', experiences.upload_media, name='upload_media'),
]
```

---

## 6. Learning Weights Update (REQUIRED)

**Location:** `family/services/learning_service.py`

### Purpose:
After a review is submitted, automatically update suggestion weights to boost good activities and dampen poor ones. This is a **core feature** that makes suggestions smarter over time.

```python
class LearningService:
    @staticmethod
    async def update_weights_from_review(review: ExperienceReview, experience: Experience):
        """
        Update learning weights based on review feedback.
        
        Logic:
        - Rating 4-5: Boost weight for this activity type in this context
        - Rating 1-2: Dampen weight for this activity type
        - Consider: weather, time, day, participants, tags
        """
        
        # Get activity context from experience
        context = {
            'weather': experience.weather_context,  # You'd need to store this
            'time_of_day': experience.time_context,
            'day_of_week': experience.day_context,
            'participant_count': len(experience.participant_ids),
            'tags': experience.tags,
        }
        
        # Calculate weight adjustment
        if review.rating >= 4:
            weight_delta = 0.1 * review.rating  # Boost by 10% per star (40-50% for 4-5 stars)
        elif review.rating <= 2:
            weight_delta = -0.1 * (3 - review.rating)  # Dampen by 10-20%
        else:
            weight_delta = 0  # Neutral for rating 3
        
        # Apply weight to activity-context pair
        # You'd store this in a `activity_weights` table or similar
        # Example structure:
        # {
        #   "activity_name": "Park Picnic",
        #   "context_hash": "sunny_afternoon_weekend",
        #   "weight": 1.2,  # Start at 1.0, adjust over time
        # }
        
        # Pseudo-code:
        # weight_record = get_or_create_weight(experience.activity_name, context)
        # weight_record.weight += weight_delta
        # weight_record.save()
        
        # Also consider effort and cleanup for future suggestions
        # If cleanup was "hard", maybe suggest outdoor activities less frequently
        
        pass  # Implement your logic here
```

---

## 7. Supabase Storage Setup

### Create Storage Bucket:

1. Go to Supabase Dashboard → Storage
2. Create bucket: `media`
3. Make it **private** (RLS will control access)
4. Enable RLS policies:

```sql
-- Allow authenticated users to upload to their household folder
CREATE POLICY "Users can upload to their household"
ON storage.objects FOR INSERT
WITH CHECK (
  auth.uid() IN (
    SELECT user_id FROM public.family_members
    WHERE household_id = (storage.foldername(name))[1]::uuid
  )
);

-- Allow authenticated users to read their household media
CREATE POLICY "Users can view their household media"
ON storage.objects FOR SELECT
USING (
  auth.uid() IN (
    SELECT user_id FROM public.family_members
    WHERE household_id = (storage.foldername(name))[1]::uuid
  )
);
```

---

## 8. Testing

### Manual Testing Checklist:

```bash
# 1. Create Experience
curl -X POST http://localhost:8000/api/v1/experiences/ \
  -H "Content-Type: application/json" \
  -d '{
    "household_id": "your-household-id",
    "activity_name": "Park Picnic",
    "participant_ids": ["member1", "member2"],
    "start_at": "2024-01-15T14:00:00Z",
    "status": "planned"
  }'

# 2. List Experiences
curl http://localhost:8000/api/v1/experiences/?household_id=your-household-id

# 3. Update Experience (mark as live)
curl -X PATCH http://localhost:8000/api/v1/experiences/<experience-id>/ \
  -H "Content-Type: application/json" \
  -d '{"status": "live", "start_at": "2024-01-15T14:05:00Z"}'

# 4. Create Review
curl -X POST http://localhost:8000/api/v1/experiences/<experience-id>/reviews/ \
  -H "Content-Type: application/json" \
  -d '{
    "household_id": "your-household-id",
    "rating": 5,
    "effort_felt": "easy",
    "cleanup_felt": "moderate",
    "note": "Great time!"
  }'

# 5. Create Merry Moment
curl -X POST http://localhost:8000/api/v1/merry-moments/ \
  -H "Content-Type: application/json" \
  -d '{
    "household_id": "your-household-id",
    "title": "Park Picnic",
    "participant_ids": ["member1", "member2"],
    "occurred_at": "2024-01-15T14:00:00Z",
    "is_manual": false
  }'

# 6. Upload Media
curl -X POST http://localhost:8000/api/v1/media/upload/ \
  -F "file=@photo.jpg" \
  -F "household_id=your-household-id" \
  -F "merry_moment_id=moment-id" \
  -F "caption=Great day at the park!"
```

---

## 9. Dependencies to Install

```bash
# Add to requirements.txt
supabase-py==2.3.4  # Supabase client
Pillow==10.2.0      # Image processing for thumbnails
python-magic==0.4.27  # MIME type detection
```

```bash
pip install -r requirements.txt
```

---

## 10. Implementation Checklist

### **Backend Tasks (ALL REQUIRED):**

1. ✅ **Database**: Run `supabase_phase4_plan_do_reflect.sql` in Supabase SQL Editor
2. ✅ **Storage**: Create storage bucket `media` in Supabase with RLS policies
3. ✅ **Dependencies**: Install `supabase-py`, `Pillow`, `python-magic`
4. ✅ **Models**: Create Django models (Experience, ExperienceReview, MerryMoment, MediaItem)
5. ✅ **Schemas**: Create Pydantic schemas for validation
6. ✅ **API Views**: Implement all 11 API endpoints
7. ✅ **URL Routes**: Add routes to `family/urls.py`
8. ✅ **Learning Weights**: Implement learning service to boost/dampen suggestions
9. ✅ **Media Upload**: Implement media endpoint with thumbnailing and EXIF scrubbing
10. ✅ **Testing**: Test all endpoints with curl or Postman

### **Expected Timeline:**
- Database + Storage: 15 minutes
- Models + Schemas: 30 minutes
- API Endpoints (copy/paste from doc): 45 minutes
- Learning Weights: 1-2 hours
- Media Upload: 1 hour
- Testing: 30 minutes

**Total: 3-5 hours**

---

## Notes

- **Architecture:** Frontend calls Django API → Django performs business logic/validation → Django writes to Supabase
- **RLS is Active:** All tables have Row Level Security policies, so users can only access their household data
- **Hybrid Reads:** Frontend can still read directly from Supabase for performance (list experiences, list moments)
- **Learning Weights:** The key reason for using Django - suggestions get smarter over time based on reviews

---

## Why Django Backend is Required

1. **Learning Weights**: Automatically boost/dampen suggestions based on review ratings
2. **Data Validation**: Ensure ratings are 1-5, participants exist, etc.
3. **Business Logic**: Complex operations like cascading creates (review → moment → weight update)
4. **Media Processing**: Server-side thumbnailing, EXIF scrubbing, optimization
5. **Future Features**: Analytics, recommendations, notifications, background jobs

---

**Ready to implement?** Start with step 1 (run the migration), then implement the API endpoints. Frontend changes will be made to call your Django API.

