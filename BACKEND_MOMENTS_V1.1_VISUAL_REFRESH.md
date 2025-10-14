# Backend Requirements: Moments v1.1 Visual Refresh

## Overview
Backend support for the photo-forward Moments feed with upcoming carousel and completed mini-albums.

**Key Changes:**
- Two new API endpoints (upcoming & completed)
- Computed fields for time-to-start and proximity
- Media enrichment (cover URLs, counts)
- Review summaries
- Permission flags

**No Schema Changes Required** - Uses existing tables.

---

## 📡 API Endpoints

### 1. Get Upcoming Moments

```
GET /api/v1/moments/upcoming/?household_id={uuid}
```

**Query Parameters:**
- `household_id` (required): UUID of the household

**Response:**
```json
{
  "items": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "title": "Park Adventure",
      "start_at": "2025-10-13T15:00:00Z",
      "icon_emoji": "🎨",
      "participants": [
        {
          "id": "660e8400-e29b-41d4-a716-446655440000",
          "name": "Sarah",
          "avatar_emoji": "👧"
        },
        {
          "id": "770e8400-e29b-41d4-a716-446655440000",
          "name": "Dad",
          "avatar_emoji": "👨"
        }
      ],
      "time_to_start_minutes": 45,
      "within_60_minutes": true,
      "status": "planned"
    }
  ]
}
```

**Business Logic:**
1. Fetch all experiences with `status='planned'` and `start_at >= now()`
2. Order by `start_at` ascending (soonest first)
3. For each item:
   - Calculate `time_to_start_minutes` = (start_at - now) in minutes
   - Set `within_60_minutes` = true if 0 <= time_to_start <= 60
   - Get `icon_emoji` from experience or map from activity type
   - Load participant details with avatars

---

### 2. Get Completed Moments

```
GET /api/v1/moments/completed/?household_id={uuid}&limit=20&offset=0
```

**Query Parameters:**
- `household_id` (required): UUID of the household
- `limit` (optional, default=20): Number of items to return
- `offset` (optional, default=0): Pagination offset

**Response:**
```json
{
  "items": [
    {
      "id": "880e8400-e29b-41d4-a716-446655440000",
      "title": "Pizza Night",
      "date": "2025-10-10T18:30:00Z",
      "type": "experience",
      "is_manual": false,
      
      "participants": [
        {
          "id": "660e8400-e29b-41d4-a716-446655440000",
          "name": "Sarah",
          "avatar_emoji": "👧"
        }
      ],
      
      "cover_media_url": "https://xyz.supabase.co/storage/v1/object/public/merry-moments/photo.jpg",
      "media_count": 3,
      
      "review_summary": {
        "has_review": true,
        "rating": 5,
        "one_liner": "Perfect evening together!"
      },
      
      "can_add_media": true,
      "can_journal": true
    },
    {
      "id": "990e8400-e29b-41d4-a716-446655440000",
      "title": "Morning Walk",
      "date": "2025-10-09T08:00:00Z",
      "type": "moment",
      "is_manual": true,
      
      "participants": [
        {
          "id": "770e8400-e29b-41d4-a716-446655440000",
          "name": "Dad",
          "avatar_emoji": "👨"
        }
      ],
      
      "cover_media_url": null,
      "media_count": 0,
      
      "review_summary": {
        "has_review": false
      },
      
      "can_add_media": true,
      "can_journal": true
    }
  ],
  "total": 42,
  "has_more": true
}
```

**Business Logic:**
1. Fetch completed experiences (`status='done'`) and merry moments
2. Order by date descending (newest first)
3. For each item:
   - **Media enrichment:**
     - Query media table for items linked to this experience/moment
     - Set `media_count` = count of media items
     - Set `cover_media_url` = public URL of most recent photo (or null)
   - **Review enrichment:**
     - Query experience_reviews table
     - If review exists: `has_review=true`, include `rating` and `note`
     - If no review: `has_review=false`
   - **Permission flags:**
     - `can_add_media` = check if current user can upload photos
     - `can_journal` = check if current user can add/edit review

---

## 🔧 Django Implementation

### A. Views

```python
# family/views/moments_view.py
from django.http import JsonResponse
from django.views.decorators.http import require_http_methods
from django.utils import timezone
from datetime import timedelta
from ..models import Experience, MerryMoment, MediaItem, ExperienceReview
import logging

logger = logging.getLogger(__name__)

@require_http_methods(["GET"])
def get_upcoming_moments(request):
    """Get all upcoming/planned experiences for a household"""
    household_id = request.GET.get('household_id')
    
    if not household_id:
        return JsonResponse({'error': 'household_id required'}, status=400)
    
    try:
        # Fetch upcoming experiences
        now = timezone.now()
        experiences = Experience.objects.filter(
            household_id=household_id,
            status='planned',
            start_at__gte=now
        ).order_by('start_at')
        
        items = []
        for exp in experiences:
            # Calculate time to start
            time_diff = exp.start_at - now
            minutes_to_start = int(time_diff.total_seconds() / 60)
            
            # Get participants
            participants = [
                {
                    'id': str(member.id),
                    'name': member.name,
                    'avatar_emoji': member.avatar_emoji or member.name[0]
                }
                for member in exp.get_participants()
            ]
            
            items.append({
                'id': str(exp.id),
                'title': exp.activity_name or 'Unnamed Experience',
                'start_at': exp.start_at.isoformat(),
                'icon_emoji': get_activity_icon(exp.activity_name),
                'participants': participants,
                'time_to_start_minutes': minutes_to_start,
                'within_60_minutes': 0 <= minutes_to_start <= 60,
                'status': exp.status
            })
        
        return JsonResponse({'items': items})
    
    except Exception as e:
        logger.error(f"Error fetching upcoming moments: {e}")
        return JsonResponse({'error': str(e)}, status=500)


@require_http_methods(["GET"])
def get_completed_moments(request):
    """Get completed experiences and moments with media enrichment"""
    household_id = request.GET.get('household_id')
    limit = int(request.GET.get('limit', 20))
    offset = int(request.GET.get('offset', 0))
    
    if not household_id:
        return JsonResponse({'error': 'household_id required'}, status=400)
    
    try:
        # Fetch completed experiences
        experiences = Experience.objects.filter(
            household_id=household_id,
            status='done'
        ).order_by('-end_at')
        
        # Fetch merry moments
        moments = MerryMoment.objects.filter(
            household_id=household_id
        ).order_by('-occurred_at')
        
        # Combine and sort
        all_items = []
        
        for exp in experiences:
            item = {
                'id': str(exp.id),
                'title': exp.activity_name or 'Unnamed Activity',
                'date': exp.end_at.isoformat() if exp.end_at else exp.created_at.isoformat(),
                'type': 'experience',
                'is_manual': False,
                'participants': [
                    {
                        'id': str(m.id),
                        'name': m.name,
                        'avatar_emoji': m.avatar_emoji or m.name[0]
                    }
                    for m in exp.get_participants()
                ]
            }
            
            # Enrich with media
            enrich_with_media(item, experience_id=exp.id)
            
            # Enrich with review
            enrich_with_review(item, experience_id=exp.id)
            
            # Add permission flags
            current_member = get_current_member(request)
            item['can_add_media'] = can_add_media(exp, current_member)
            item['can_journal'] = can_add_journal(exp, current_member)
            
            all_items.append(item)
        
        for moment in moments:
            item = {
                'id': str(moment.id),
                'title': moment.title or 'Merry Moment',
                'date': moment.occurred_at.isoformat(),
                'type': 'moment',
                'is_manual': moment.is_manual,
                'participants': [
                    {
                        'id': str(m.id),
                        'name': m.name,
                        'avatar_emoji': m.avatar_emoji or m.name[0]
                    }
                    for m in moment.get_participants()
                ]
            }
            
            # Enrich with media
            enrich_with_media(item, merry_moment_id=moment.id)
            
            # Manual moments don't have reviews
            item['review_summary'] = {'has_review': False}
            
            # Add permission flags
            current_member = get_current_member(request)
            item['can_add_media'] = can_add_media(moment, current_member)
            item['can_journal'] = False  # Moments don't have journals
            
            all_items.append(item)
        
        # Sort by date descending
        all_items.sort(key=lambda x: x['date'], reverse=True)
        
        # Apply pagination
        total = len(all_items)
        paginated_items = all_items[offset:offset + limit]
        
        return JsonResponse({
            'items': paginated_items,
            'total': total,
            'has_more': offset + limit < total
        })
    
    except Exception as e:
        logger.error(f"Error fetching completed moments: {e}")
        return JsonResponse({'error': str(e)}, status=500)


# Helper functions

def enrich_with_media(item: dict, experience_id=None, merry_moment_id=None):
    """Add media count and cover URL to item"""
    from django.db.models import Q
    
    query = Q()
    if experience_id:
        query |= Q(experience_id=experience_id)
    if merry_moment_id:
        query |= Q(merry_moment_id=merry_moment_id)
    
    media_items = MediaItem.objects.filter(query).order_by('-created_at')
    
    item['media_count'] = media_items.count()
    
    if media_items.exists():
        cover = media_items.first()
        # file_url is already the public URL
        item['cover_media_url'] = cover.file_url
    else:
        item['cover_media_url'] = None


def enrich_with_review(item: dict, experience_id):
    """Add review summary to item"""
    try:
        review = ExperienceReview.objects.get(experience_id=experience_id)
        item['review_summary'] = {
            'has_review': True,
            'rating': review.rating,
            'one_liner': review.note or ''
        }
    except ExperienceReview.DoesNotExist:
        item['review_summary'] = {'has_review': False}


def get_activity_icon(activity_name: str) -> str:
    """Map activity name to emoji icon"""
    if not activity_name:
        return '✨'
    
    ICON_MAP = {
        'park': '🌳',
        'picnic': '🧺',
        'museum': '🏛️',
        'art': '🎨',
        'sports': '⚽',
        'soccer': '⚽',
        'basketball': '🏀',
        'swim': '🏊',
        'hike': '🥾',
        'bike': '🚴',
        'food': '🍕',
        'pizza': '🍕',
        'restaurant': '🍽️',
        'cook': '👨‍🍳',
        'bake': '🧁',
        'movie': '🎬',
        'game': '🎮',
        'read': '📚',
        'music': '🎵',
        'dance': '💃',
        'craft': '✂️',
        'science': '🔬',
        'zoo': '🦁',
        'aquarium': '🐠',
        'beach': '🏖️',
        'outdoor': '🏕️',
        'indoor': '🏠',
    }
    
    activity_lower = activity_name.lower()
    for keyword, icon in ICON_MAP.items():
        if keyword in activity_lower:
            return icon
    
    return '✨'


def get_current_member(request):
    """Get the currently authenticated family member from request"""
    # Extract from JWT token or session
    # Implementation depends on your auth setup
    from ..services.auth_service import get_member_from_token
    token = request.headers.get('Authorization', '').replace('Bearer ', '')
    return get_member_from_token(token)


def can_add_media(item, member) -> bool:
    """Check if member can add media to this item"""
    if not member:
        return False
    
    # Parents can always add
    if member.role in ['parent', 'caregiver']:
        return True
    
    # Participants can add
    if hasattr(item, 'participant_ids'):
        if str(member.id) in [str(p) for p in item.participant_ids]:
            return True
    
    return False


def can_add_journal(item, member) -> bool:
    """Check if member can add/edit journal/review"""
    if not member:
        return False
    
    # Only experiences have journals
    if not hasattr(item, 'status'):
        return False
    
    # Parents can always journal
    if member.role in ['parent', 'caregiver']:
        return True
    
    # Participants can journal
    if hasattr(item, 'participant_ids'):
        if str(member.id) in [str(p) for p in item.participant_ids]:
            return True
    
    return False
```

---

### B. Media URL Handling

**Note:** The `media_items` table stores the complete public URL in the `file_url` field, so no additional processing is needed. The Django backend (from Phase 4) already handles uploading to Supabase storage and stores the public URL directly in the database.

---

### C. URL Configuration

```python
# family/urls.py
from django.urls import path
from .views import moments_view

urlpatterns = [
    # ... existing patterns ...
    
    # Moments v1.1
    path('api/v1/moments/upcoming/', moments_view.get_upcoming_moments, name='moments-upcoming'),
    path('api/v1/moments/completed/', moments_view.get_completed_moments, name='moments-completed'),
]
```

---

## 🗄️ Database Schema (No Changes Required)

### Existing Tables Used:

#### `experiences`
```sql
id UUID PRIMARY KEY
household_id UUID
activity_name TEXT
participant_ids JSONB
start_at TIMESTAMPTZ
end_at TIMESTAMPTZ
status TEXT  -- 'planned', 'live', 'done', 'cancelled'
created_at TIMESTAMPTZ
```

#### `merry_moments`
```sql
id UUID PRIMARY KEY
household_id UUID
title TEXT
participant_ids JSONB
occurred_at TIMESTAMPTZ
is_manual BOOLEAN
created_at TIMESTAMPTZ
```

#### `media_items`
```sql
id UUID PRIMARY KEY
household_id UUID
experience_id UUID (nullable)
merry_moment_id UUID (nullable)
file_url TEXT NOT NULL
thumbnail_url TEXT
mime_type TEXT NOT NULL
file_size_bytes INTEGER
caption TEXT
uploaded_by UUID
created_at TIMESTAMPTZ
```

#### `experience_reviews`
```sql
id UUID PRIMARY KEY
experience_id UUID
rating INTEGER
note TEXT
created_at TIMESTAMPTZ
```

---

## 🔒 Supabase RLS Policies

Ensure these policies exist (likely already in place):

```sql
-- Media Items table
CREATE POLICY "Users can view media in their households"
  ON media_items FOR SELECT
  USING (
    household_id IN (
      SELECT id FROM households WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can upload media in their households"
  ON media_items FOR INSERT
  WITH CHECK (
    household_id IN (
      SELECT id FROM households WHERE user_id = auth.uid()
    )
  );
```

---

## 🧪 Testing

### Test Upcoming Endpoint

```bash
curl -X GET "http://localhost:8000/api/v1/moments/upcoming/?household_id=YOUR_HOUSEHOLD_ID" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Expected Response:**
```json
{
  "items": [
    {
      "id": "...",
      "title": "Park Adventure",
      "start_at": "2025-10-13T15:00:00Z",
      "icon_emoji": "🌳",
      "participants": [...],
      "time_to_start_minutes": 45,
      "within_60_minutes": true,
      "status": "planned"
    }
  ]
}
```

---

### Test Completed Endpoint

```bash
curl -X GET "http://localhost:8000/api/v1/moments/completed/?household_id=YOUR_HOUSEHOLD_ID&limit=5" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Expected Response:**
```json
{
  "items": [
    {
      "id": "...",
      "title": "Pizza Night",
      "date": "2025-10-10T18:30:00Z",
      "type": "experience",
      "cover_media_url": "https://...",
      "media_count": 3,
      "review_summary": {
        "has_review": true,
        "rating": 5,
        "one_liner": "Amazing!"
      },
      "can_add_media": true,
      "can_journal": true
    }
  ],
  "total": 42,
  "has_more": true
}
```

---

## ⚡ Performance Optimizations

### 1. Database Indexes

```sql
-- Experiences
CREATE INDEX idx_experiences_household_status ON experiences(household_id, status);
CREATE INDEX idx_experiences_start_at ON experiences(start_at);
CREATE INDEX idx_experiences_end_at ON experiences(end_at DESC);

-- Merry Moments
CREATE INDEX idx_merry_moments_household ON merry_moments(household_id);
CREATE INDEX idx_merry_moments_occurred_at ON merry_moments(occurred_at DESC);

-- Media Items
CREATE INDEX idx_media_items_experience ON media_items(experience_id);
CREATE INDEX idx_media_items_moment ON media_items(merry_moment_id);
CREATE INDEX idx_media_items_created_at ON media_items(created_at DESC);
```

### 2. Django Query Optimizations

```python
# Use select_related and prefetch_related
experiences = Experience.objects.filter(
    household_id=household_id,
    status='planned'
).select_related('household').prefetch_related('participants')

# Batch media queries
from django.db.models import Count
experiences = experiences.annotate(
    media_count=Count('media_items')
)
```

### 3. Caching

```python
from django.core.cache import cache

def get_media_items_for_experience(experience_id: str) -> List[MediaItem]:
    """Get media items with caching"""
    cache_key = f'media_items:{experience_id}'
    items = cache.get(cache_key)
    
    if not items:
        items = MediaItem.objects.filter(
            experience_id=experience_id
        ).order_by('-created_at')
        cache.set(cache_key, items, 300)  # Cache for 5 minutes
    
    return items
```

---

## 📋 Implementation Checklist

### Required (Must Have)
- [ ] Create `get_upcoming_moments` view
- [ ] Create `get_completed_moments` view
- [ ] Add URL patterns for both endpoints
- [ ] Implement `enrich_with_media` helper
- [ ] Implement `enrich_with_review` helper
- [ ] Implement `get_activity_icon` mapping
- [ ] Implement permission checks (`can_add_media`, `can_journal`)
- [ ] Add `get_public_url` Supabase helper
- [ ] Test both endpoints with curl
- [ ] Verify RLS policies on media table

### Nice to Have
- [ ] Add pagination to completed endpoint
- [ ] Cache public URLs (Redis)
- [ ] Add database indexes for performance
- [ ] Create thumbnail URLs (smaller for feed, full for detail)
- [ ] Add filtering by date range
- [ ] Add sorting options (date, rating, media count)

### Future Enhancements
- [ ] Add search/filter by tags
- [ ] Add "monthly highlights" aggregation
- [ ] Add stats endpoint (total moments, photos uploaded, etc.)
- [ ] Add batch operations (mark multiple as archived)

---

## 🐛 Troubleshooting

### Issue: No cover images showing
**Solution:** Check Supabase storage bucket is public:
```sql
-- Make bucket public
UPDATE storage.buckets 
SET public = true 
WHERE id = 'merry-moments';
```

### Issue: 500 error on completed endpoint
**Solution:** Check media_items table has correct foreign keys:
```sql
-- Verify FK constraints
SELECT * FROM media_items WHERE experience_id IS NULL AND merry_moment_id IS NULL;
```

### Issue: Participants not loading
**Solution:** Check participant_ids JSONB format:
```python
# Should be array of UUIDs
participant_ids = ["uuid1", "uuid2"]
```

---

## 📚 Related Documentation

- `PHASE4_BACKEND_REQUIREMENTS.md` - Experience/Moment creation
- `BACKEND_SMART_SUGGESTIONS.md` - Smart suggestions
- `PHASE4_DO_BACKEND_REQUIREMENTS.md` - Live experiences

---

## ✅ Summary

**What you're adding:**
1. Two new GET endpoints (upcoming & completed)
2. Helper functions for media/review enrichment
3. Activity icon mapping
4. Permission checks

**What you're NOT changing:**
- Database schema (uses existing tables)
- Existing API endpoints
- RLS policies (should already exist)

**Estimated effort:** 2-4 hours of backend work

Once these endpoints are live, the frontend can build the new Moments UI! 🎨✨

