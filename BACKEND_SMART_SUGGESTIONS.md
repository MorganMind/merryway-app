# Backend Implementation: Smart Location & Proximity Suggestions

## Overview
This document contains **complete backend code** for implementing privacy-first, location-aware smart suggestions in your Django backend.

---

## 1. Database Schema (Supabase SQL)

Run this SQL in your Supabase SQL editor:

```sql
-- Smart Suggestion Logs (coarse data only)
CREATE TABLE smart_suggestion_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  household_id UUID NOT NULL REFERENCES households(id) ON DELETE CASCADE,
  pod_id UUID,
  location_label TEXT,  -- "near School", NOT coordinates
  member_ids UUID[] DEFAULT ARRAY[]::uuid[],
  suggested_activity_title TEXT,
  reason TEXT,  -- "3 kids at school after 3pm"
  user_dismissed BOOLEAN DEFAULT FALSE,
  user_activated BOOLEAN DEFAULT FALSE,
  timestamp TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_smart_suggestion_logs_household ON smart_suggestion_logs(household_id);
CREATE INDEX idx_smart_suggestion_logs_timestamp ON smart_suggestion_logs(timestamp DESC);

-- Household Locations (labels only, coordinates on device)
CREATE TABLE household_locations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  household_id UUID NOT NULL REFERENCES households(id) ON DELETE CASCADE,
  name TEXT NOT NULL,  -- "Home", "School"
  label TEXT NOT NULL,  -- "near Home", "near School"
  location_type TEXT,  -- "home", "school", "work", "park", "custom"
  radius_meters FLOAT DEFAULT 200,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_household_locations_household ON household_locations(household_id);

-- Location Privacy Settings (per member)
CREATE TABLE location_privacy_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  member_id UUID NOT NULL REFERENCES family_members(id) ON DELETE CASCADE,
  location_sharing_enabled BOOLEAN DEFAULT FALSE,
  bluetooth_detection_enabled BOOLEAN DEFAULT FALSE,
  wifi_detection_enabled BOOLEAN DEFAULT FALSE,
  auto_suggestions_enabled BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Row Level Security
ALTER TABLE smart_suggestion_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE household_locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE location_privacy_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their household's smart logs"
  ON smart_suggestion_logs FOR SELECT
  USING (
    household_id IN (
      SELECT id FROM households WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert into smart logs"
  ON smart_suggestion_logs FOR INSERT
  WITH CHECK (
    household_id IN (
      SELECT id FROM households WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update their smart logs"
  ON smart_suggestion_logs FOR UPDATE
  USING (
    household_id IN (
      SELECT id FROM households WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can view their household's locations"
  ON household_locations FOR ALL
  USING (
    household_id IN (
      SELECT id FROM households WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Members can manage their own privacy settings"
  ON location_privacy_settings FOR ALL
  USING (
    member_id IN (
      SELECT id FROM family_members
      WHERE household_id IN (
        SELECT id FROM households WHERE user_id = auth.uid()
      )
    )
  );
```

---

## 2. Python Models

Create `family/models/locations.py`:

```python
from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime
from enum import Enum

class LocationType(str, Enum):
    HOME = "home"
    SCHOOL = "school"
    WORK = "work"
    PARK = "park"
    DAYCARE = "daycare"
    ACTIVITY = "activity"
    CUSTOM = "custom"

class HouseholdLocation(BaseModel):
    """Defined location (coordinates stored on device only)"""
    id: Optional[str] = None
    household_id: str
    name: str  # "Home", "Maya's School"
    label: str  # "near Home", "near School"
    location_type: LocationType
    radius_meters: float = 200
    created_at: Optional[datetime] = None

    def to_dict(self):
        return {
            "id": self.id,
            "household_id": self.household_id,
            "name": self.name,
            "label": self.label,
            "location_type": self.location_type.value,
            "radius_meters": self.radius_meters,
            "created_at": self.created_at.isoformat() if self.created_at else None,
        }

class ProximitySignal(str, Enum):
    GEOFENCE = "geofence"
    WIFI = "wifi"
    BLUETOOTH = "bluetooth"

class SmartSuggestionContext(BaseModel):
    """Context for smart suggestion (coarse data only)"""
    household_id: str
    location_label: str  # "near School", "near Home"
    nearby_member_ids: List[str]
    time_bucket: str  # "morning", "afternoon", "evening"
    day_type: str  # "weekday", "weekend"
    confidence: float  # 0-1
    signals_used: List[ProximitySignal]
    reason: str  # "3 kids detected at school 3:15pm"

class LocationPrivacySettings(BaseModel):
    """Member-level privacy controls"""
    id: Optional[str] = None
    member_id: str
    location_sharing_enabled: bool = False
    bluetooth_detection_enabled: bool = False
    wifi_detection_enabled: bool = False
    auto_suggestions_enabled: bool = False
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

    def to_dict(self):
        return {
            "id": self.id,
            "member_id": self.member_id,
            "location_sharing_enabled": self.location_sharing_enabled,
            "bluetooth_detection_enabled": self.bluetooth_detection_enabled,
            "wifi_detection_enabled": self.wifi_detection_enabled,
            "auto_suggestions_enabled": self.auto_suggestions_enabled,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
        }
```

---

## 3. Smart Suggestion Service

Create `family/services/smart_suggestion_service.py`:

```python
from typing import Optional, Tuple, List
from ..models.locations import SmartSuggestionContext, ProximitySignal
from ..models.household import ActivitySuggestion, Household
from .pod_suggestion_service import PodSuggestionService
from .policy_service import PolicyEvaluationService
from ..models.consent import PolicyCheckRequest
from common.supabase.supabase_client import get_supabase_client
from datetime import datetime, timedelta
import logging

logger = logging.getLogger(__name__)

class SmartSuggestionService:
    TABLE_SMART_LOGS = "smart_suggestion_logs"
    TABLE_PRIVACY = "location_privacy_settings"
    
    # Configuration
    CONFIDENCE_THRESHOLD = 0.65
    COOLDOWN_MINUTES = 15
    
    @staticmethod
    async def generate_smart_suggestion(
        household: Household,
        context: SmartSuggestionContext,
        weather: str,
        day_of_week: str,
    ) -> Optional[dict]:
        """
        Generate smart suggestion based on proximity and location.
        
        Returns: {
            "pod_id": str,
            "location_label": str,
            "member_ids": List[str],
            "reason": str,
            "activity": ActivitySuggestion,
            "log_id": str,
        } or None
        """
        
        # 1. Validate confidence
        if context.confidence < SmartSuggestionService.CONFIDENCE_THRESHOLD:
            logger.info(f"Confidence too low: {context.confidence}")
            return None
        
        # 2. Check cooldown (don't spam suggestions)
        if await SmartSuggestionService._in_cooldown(household.id):
            logger.info(f"Still in cooldown for household {household.id}")
            return None
        
        # 3. Check privacy settings (all members must opt in)
        if not await SmartSuggestionService._check_privacy_opt_in(
            context.nearby_member_ids
        ):
            logger.info("Not all members have opted into auto-suggestions")
            return None
        
        # 4. Find or create pod for this context
        pod_id = await SmartSuggestionService._find_or_create_smart_pod(
            household_id=household.id,
            member_ids=context.nearby_member_ids,
            location_label=context.location_label,
        )
        
        if not pod_id:
            logger.error("Failed to create/find smart pod")
            return None
        
        # 5. Generate pod-aware suggestions
        try:
            suggestions = await PodSuggestionService.generate_suggestions_for_pod(
                household=household,
                pod_member_ids=context.nearby_member_ids,
                weather=weather,
                time_bucket=context.time_bucket,
                day_of_week=day_of_week,
                custom_prompt=f"Smart: {context.location_label}, {context.time_bucket}",
                pod_id=pod_id,
            )
        except Exception as e:
            logger.error(f"Error generating suggestions: {e}")
            return None
        
        if not suggestions or len(suggestions) == 0:
            logger.info("No suggestions generated")
            return None
        
        # 6. Check policy for each suggestion, pick first valid one
        for suggestion in suggestions:
            policy_request = PolicyCheckRequest(
                participant_ids=context.nearby_member_ids,
                action="suggest_activity",
                action_context={
                    "activity_id": suggestion.get("activity"),
                    "location": context.location_label,
                    "time_bucket": context.time_bucket,
                }
            )
            
            try:
                policy_response = await PolicyEvaluationService.check_policy(
                    household_id=household.id,
                    request=policy_request,
                )
                
                if policy_response.allowed:
                    # Log the suggestion
                    log_id = await SmartSuggestionService._log_suggestion(
                        household_id=household.id,
                        pod_id=pod_id,
                        location_label=context.location_label,
                        member_ids=context.nearby_member_ids,
                        activity_title=suggestion.get("activity"),
                        reason=context.reason,
                    )
                    
                    return {
                        "pod_id": pod_id,
                        "location_label": context.location_label,
                        "member_ids": context.nearby_member_ids,
                        "reason": context.reason,
                        "activity": suggestion,
                        "log_id": log_id,
                    }
            except Exception as e:
                logger.error(f"Policy check error: {e}")
                continue
        
        # No policy-compliant suggestion found
        logger.info("No policy-compliant suggestions")
        return None
    
    @staticmethod
    async def _in_cooldown(household_id: str) -> bool:
        """Check if still in cooldown period"""
        supabase = get_supabase_client()
        
        try:
            cutoff_time = datetime.utcnow() - timedelta(
                minutes=SmartSuggestionService.COOLDOWN_MINUTES
            )
            
            result = supabase.table(SmartSuggestionService.TABLE_SMART_LOGS)\
                .select("id")\
                .eq("household_id", household_id)\
                .gte("timestamp", cutoff_time.isoformat())\
                .limit(1)\
                .execute()
            
            return len(result.data or []) > 0
        except Exception as e:
            logger.error(f"Error checking cooldown: {e}")
            return False  # Allow on error
    
    @staticmethod
    async def _check_privacy_opt_in(member_ids: List[str]) -> bool:
        """Check if all members have opted into auto-suggestions"""
        supabase = get_supabase_client()
        
        for member_id in member_ids:
            try:
                result = supabase.table(SmartSuggestionService.TABLE_PRIVACY)\
                    .select("auto_suggestions_enabled")\
                    .eq("member_id", member_id)\
                    .single()\
                    .execute()
                
                if not result.data:
                    # No settings = default to False (opt-in required)
                    return False
                
                if not result.data.get("auto_suggestions_enabled", False):
                    return False
            except Exception as e:
                # If member has no settings, default to False
                logger.warning(f"No privacy settings for member {member_id}")
                return False
        
        return True
    
    @staticmethod
    async def _find_or_create_smart_pod(
        household_id: str,
        member_ids: List[str],
        location_label: str,
    ) -> Optional[str]:
        """Find existing pod or create temporary smart pod"""
        supabase = get_supabase_client()
        
        try:
            # Check for existing pod with exact member match
            pods_result = supabase.table("pods")\
                .select("id, member_ids")\
                .eq("household_id", household_id)\
                .execute()
            
            member_set = set(member_ids)
            
            for pod in pods_result.data or []:
                pod_member_set = set(pod.get("member_ids", []))
                if pod_member_set == member_set:
                    return pod["id"]
            
            # Create temporary smart pod
            pod_data = {
                "household_id": household_id,
                "name": f"Smart: {location_label}",
                "member_ids": member_ids,
                "icon": "🎯",
                "color": "#FF6B6B",
                "description": f"Auto-generated for {location_label}",
            }
            
            result = supabase.table("pods")\
                .insert(pod_data)\
                .execute()
            
            return result.data[0]["id"] if result.data else None
        except Exception as e:
            logger.error(f"Error creating smart pod: {e}")
            return None
    
    @staticmethod
    async def _log_suggestion(
        household_id: str,
        pod_id: str,
        location_label: str,
        member_ids: List[str],
        activity_title: str,
        reason: str,
    ) -> Optional[str]:
        """Log smart suggestion (coarse data only)"""
        supabase = get_supabase_client()
        
        log_data = {
            "household_id": household_id,
            "pod_id": pod_id,
            "location_label": location_label,
            "member_ids": member_ids,
            "suggested_activity_title": activity_title,
            "reason": reason,
            "timestamp": datetime.utcnow().isoformat(),
        }
        
        try:
            result = supabase.table(SmartSuggestionService.TABLE_SMART_LOGS)\
                .insert(log_data)\
                .execute()
            
            return result.data[0]["id"] if result.data else None
        except Exception as e:
            logger.error(f"Error logging suggestion: {e}")
            return None
    
    @staticmethod
    async def log_user_action(log_id: str, action: str):
        """Log user interaction (dismissed or activated)"""
        supabase = get_supabase_client()
        
        update_data = {}
        if action == "dismissed":
            update_data["user_dismissed"] = True
        elif action == "activated":
            update_data["user_activated"] = True
        
        try:
            supabase.table(SmartSuggestionService.TABLE_SMART_LOGS)\
                .update(update_data)\
                .eq("id", log_id)\
                .execute()
        except Exception as e:
            logger.error(f"Error logging action: {e}")
```

---

## 4. Django Views (API Endpoints)

Add to `family/views/household_view.py`:

```python
import json
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods
from ..services.smart_suggestion_service import SmartSuggestionService
from ..services.household_service import HouseholdService
from ..models.locations import SmartSuggestionContext, ProximitySignal
from common.supabase.supabase_client import get_supabase_client
from datetime import datetime
import logging

logger = logging.getLogger(__name__)

@csrf_exempt
@require_http_methods(["POST"])
async def smart_suggestion_view(request):
    """
    Generate smart suggestion based on device proximity.
    
    POST /api/v1/smart-suggestion/
    
    Request Body:
    {
        "household_id": "uuid",
        "location_label": "near School",
        "nearby_member_ids": ["member-1", "member-2"],
        "time_bucket": "afternoon",
        "day_type": "weekday",
        "day_of_week": "monday",
        "confidence": 0.85,
        "signals_used": ["geofence", "wifi"],
        "reason": "3 kids detected at school 3:15pm",
        "weather": "sunny"
    }
    
    Response:
    {
        "success": true,
        "pod_id": "uuid",
        "location_label": "near School",
        "member_ids": ["uuid", "uuid"],
        "reason": "3 kids at school after 3pm",
        "activity": { ... },
        "log_id": "uuid"
    }
    """
    try:
        data = json.loads(request.body)
        household_id = data.get("household_id")
        
        if not household_id:
            return JsonResponse({"error": "household_id required"}, status=400)
        
        # Get household
        household = await HouseholdService.get_household(household_id)
        if not household:
            return JsonResponse({"error": "Household not found"}, status=404)
        
        # Build context
        context = SmartSuggestionContext(
            household_id=household_id,
            location_label=data.get("location_label", "unknown"),
            nearby_member_ids=data.get("nearby_member_ids", []),
            time_bucket=data.get("time_bucket", "afternoon"),
            day_type=data.get("day_type", "weekday"),
            confidence=float(data.get("confidence", 0.5)),
            signals_used=[
                ProximitySignal(s) for s in data.get("signals_used", [])
            ],
            reason=data.get("reason", "Smart context detected"),
        )
        
        # Generate suggestion
        result = await SmartSuggestionService.generate_smart_suggestion(
            household=household,
            context=context,
            weather=data.get("weather", "cloudy"),
            day_of_week=data.get("day_of_week", "monday"),
        )
        
        if not result:
            return JsonResponse({
                "success": False,
                "reason": "No valid suggestion for this context",
            })
        
        return JsonResponse({
            "success": True,
            **result,
        })
    
    except Exception as e:
        logger.error(f"Error in smart_suggestion_view: {str(e)}", exc_info=True)
        return JsonResponse({"error": str(e)}, status=400)


@csrf_exempt
@require_http_methods(["POST"])
async def log_smart_action_view(request):
    """
    Log user action on smart suggestion.
    
    POST /api/v1/smart-suggestion/action/
    
    Request Body:
    {
        "log_id": "uuid",
        "action": "dismissed"  // or "activated"
    }
    """
    try:
        data = json.loads(request.body)
        log_id = data.get("log_id")
        action = data.get("action")
        
        if not log_id or not action:
            return JsonResponse({"error": "log_id and action required"}, status=400)
        
        if action not in ["dismissed", "activated"]:
            return JsonResponse({"error": "action must be 'dismissed' or 'activated'"}, status=400)
        
        await SmartSuggestionService.log_user_action(log_id, action)
        
        return JsonResponse({"success": True})
    
    except Exception as e:
        logger.error(f"Error logging action: {str(e)}", exc_info=True)
        return JsonResponse({"error": str(e)}, status=400)


@csrf_exempt
@require_http_methods(["GET", "POST"])
async def location_privacy_view(request):
    """
    Get or update member's location privacy settings.
    
    GET /api/v1/location/privacy/?member_id=uuid
    POST /api/v1/location/privacy/
    {
        "member_id": "uuid",
        "location_sharing_enabled": true,
        "bluetooth_detection_enabled": true,
        "wifi_detection_enabled": false,
        "auto_suggestions_enabled": true
    }
    """
    supabase = get_supabase_client()
    
    if request.method == "GET":
        member_id = request.GET.get("member_id")
        if not member_id:
            return JsonResponse({"error": "member_id required"}, status=400)
        
        try:
            result = supabase.table("location_privacy_settings")\
                .select("*")\
                .eq("member_id", member_id)\
                .single()\
                .execute()
            
            if result.data:
                return JsonResponse(result.data)
            else:
                # Return defaults
                return JsonResponse({
                    "member_id": member_id,
                    "location_sharing_enabled": False,
                    "bluetooth_detection_enabled": False,
                    "wifi_detection_enabled": False,
                    "auto_suggestions_enabled": False,
                })
        except Exception as e:
            logger.error(f"Error fetching privacy settings: {e}")
            return JsonResponse({"error": str(e)}, status=400)
    
    elif request.method == "POST":
        try:
            data = json.loads(request.body)
            member_id = data.get("member_id")
            
            if not member_id:
                return JsonResponse({"error": "member_id required"}, status=400)
            
            privacy_data = {
                "member_id": member_id,
                "location_sharing_enabled": data.get("location_sharing_enabled", False),
                "bluetooth_detection_enabled": data.get("bluetooth_detection_enabled", False),
                "wifi_detection_enabled": data.get("wifi_detection_enabled", False),
                "auto_suggestions_enabled": data.get("auto_suggestions_enabled", False),
                "updated_at": datetime.utcnow().isoformat(),
            }
            
            # Check if exists
            existing = supabase.table("location_privacy_settings")\
                .select("id")\
                .eq("member_id", member_id)\
                .execute()
            
            if existing.data:
                # Update
                result = supabase.table("location_privacy_settings")\
                    .update(privacy_data)\
                    .eq("member_id", member_id)\
                    .execute()
            else:
                # Insert
                privacy_data["created_at"] = datetime.utcnow().isoformat()
                result = supabase.table("location_privacy_settings")\
                    .insert(privacy_data)\
                    .execute()
            
            return JsonResponse({"success": True, "data": result.data[0] if result.data else None})
        
        except Exception as e:
            logger.error(f"Error updating privacy settings: {e}")
            return JsonResponse({"error": str(e)}, status=400)


@csrf_exempt
@require_http_methods(["GET", "POST", "DELETE"])
async def household_locations_view(request):
    """
    Manage household locations (labels only, coordinates on device).
    
    GET /api/v1/locations/?household_id=uuid
    POST /api/v1/locations/
    {
        "household_id": "uuid",
        "name": "School",
        "label": "near School",
        "location_type": "school",
        "radius_meters": 200
    }
    DELETE /api/v1/locations/?id=uuid
    """
    supabase = get_supabase_client()
    
    if request.method == "GET":
        household_id = request.GET.get("household_id")
        if not household_id:
            return JsonResponse({"error": "household_id required"}, status=400)
        
        try:
            result = supabase.table("household_locations")\
                .select("*")\
                .eq("household_id", household_id)\
                .order("created_at", desc=False)\
                .execute()
            
            return JsonResponse({"locations": result.data or []})
        except Exception as e:
            logger.error(f"Error fetching locations: {e}")
            return JsonResponse({"error": str(e)}, status=400)
    
    elif request.method == "POST":
        try:
            data = json.loads(request.body)
            
            location_data = {
                "household_id": data.get("household_id"),
                "name": data.get("name"),
                "label": data.get("label"),
                "location_type": data.get("location_type", "custom"),
                "radius_meters": data.get("radius_meters", 200),
                "created_at": datetime.utcnow().isoformat(),
            }
            
            result = supabase.table("household_locations")\
                .insert(location_data)\
                .execute()
            
            return JsonResponse({"success": True, "location": result.data[0] if result.data else None})
        except Exception as e:
            logger.error(f"Error creating location: {e}")
            return JsonResponse({"error": str(e)}, status=400)
    
    elif request.method == "DELETE":
        location_id = request.GET.get("id")
        if not location_id:
            return JsonResponse({"error": "id required"}, status=400)
        
        try:
            supabase.table("household_locations")\
                .delete()\
                .eq("id", location_id)\
                .execute()
            
            return JsonResponse({"success": True})
        except Exception as e:
            logger.error(f"Error deleting location: {e}")
            return JsonResponse({"error": str(e)}, status=400)
```

---

## 5. URL Configuration

Add to `family/urls.py`:

```python
from django.urls import path
from .views.household_view import (
    # ... existing imports ...
    smart_suggestion_view,
    log_smart_action_view,
    location_privacy_view,
    household_locations_view,
)

urlpatterns = [
    # ... existing routes ...
    
    # Smart Suggestions
    path("smart-suggestion/", smart_suggestion_view, name="smart_suggestion"),
    path("smart-suggestion/action/", log_smart_action_view, name="log_smart_action"),
    
    # Location Privacy
    path("location/privacy/", location_privacy_view, name="location_privacy"),
    
    # Household Locations
    path("locations/", household_locations_view, name="household_locations"),
]
```

---

## 6. Dependencies

Add to your `requirements.txt`:

```
# Existing dependencies...

# For smart suggestions (if not already present)
pydantic>=2.0.0
```

---

## Testing

### Test Smart Suggestion Endpoint

```bash
curl -X POST http://localhost:8000/api/v1/smart-suggestion/ \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_SUPABASE_JWT" \
  -d '{
    "household_id": "your-household-uuid",
    "location_label": "near School",
    "nearby_member_ids": ["member-1-uuid", "member-2-uuid"],
    "time_bucket": "afternoon",
    "day_type": "weekday",
    "day_of_week": "friday",
    "confidence": 0.85,
    "signals_used": ["geofence", "wifi"],
    "reason": "3 kids at school 3:15pm",
    "weather": "sunny"
  }'
```

### Test Privacy Settings

```bash
# Get settings
curl -X GET "http://localhost:8000/api/v1/location/privacy/?member_id=member-uuid" \
  -H "Authorization: Bearer YOUR_SUPABASE_JWT"

# Update settings
curl -X POST http://localhost:8000/api/v1/location/privacy/ \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_SUPABASE_JWT" \
  -d '{
    "member_id": "member-uuid",
    "location_sharing_enabled": true,
    "auto_suggestions_enabled": true
  }'
```

---

## Summary

### Backend Provides:

✅ **3 API Endpoints**:
- `POST /api/v1/smart-suggestion/` - Generate smart suggestion
- `POST /api/v1/smart-suggestion/action/` - Log user action
- `GET/POST /api/v1/location/privacy/` - Manage privacy settings
- `GET/POST/DELETE /api/v1/locations/` - Manage household locations

✅ **Privacy-First**:
- Only coarse labels stored (`"near School"`, not coordinates)
- Opt-in required for all members
- Cooldown period prevents spam
- Confidence threshold ensures quality

✅ **Policy-Aware**:
- Checks policies before suggesting
- Respects member/pod rules
- Falls back gracefully

### Frontend Will Handle:

- On-device geofencing (coordinates never leave device)
- Bluetooth/WiFi detection
- Dwell time and state management
- UI for suggestions and privacy settings

---

Copy this entire backend code into your Django project and you're ready for the frontend implementation!

