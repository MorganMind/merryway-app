# Backend Specification: Locations & Birthday Features

## Overview
Add support for:
1. **Birthday field** - Auto-calculate age from birthday (optional field)
2. **Locations** - Store and use locations for distance-based activity suggestions

---

## 📦 **1. Update Your Django Models**

### `family/models/household.py`

```python
from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import date, datetime
from uuid import UUID

class FamilyMember(BaseModel):
    id: Optional[str] = None
    household_id: str
    name: str
    age: int
    role: str  # 'parent', 'child', 'caregiver'
    favorite_activities: List[str] = []
    birthday: Optional[date] = None  # NEW - Optional
    created_at: Optional[datetime] = None

    @property
    def calculated_age(self) -> int:
        """Calculate age from birthday if available, otherwise use stored age"""
        if self.birthday:
            today = date.today()
            age = today.year - self.birthday.year
            # Adjust if birthday hasn't occurred this year yet
            if (today.month, today.day) < (self.birthday.month, self.birthday.day):
                age -= 1
            return age
        return self.age

    @property
    def age_group(self) -> str:
        """Return age group for activity suggestions"""
        age = self.calculated_age
        if age < 3:
            return 'infant'
        elif age < 6:
            return 'toddler'
        elif age < 13:
            return 'child'
        elif age < 18:
            return 'teen'
        elif age < 65:
            return 'adult'
        else:
            return 'senior'

class Location(BaseModel):
    id: Optional[str] = None
    household_id: str
    name: str  # e.g., "Home", "School", "Work"
    address: str
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    notes: Optional[str] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

    class Config:
        json_encoders = {
            datetime: lambda v: v.isoformat() if v else None,
        }
```

---

## 🗺️ **2. Create Location Service**

### `family/services/location_service.py`

```python
from typing import List, Optional
import math
from ..models.household import Location
from supabase import Client
import logging

logger = logging.getLogger(__name__)

class LocationService:
    def __init__(self, supabase_client: Client):
        self.supabase = supabase_client

    async def get_household_locations(self, household_id: str) -> List[Location]:
        """Fetch all locations for a household"""
        try:
            response = self.supabase.table('locations') \
                .select('*') \
                .eq('household_id', household_id) \
                .order('name') \
                .execute()
            
            return [Location(**loc) for loc in response.data]
        except Exception as e:
            logger.error(f"Error fetching locations: {e}")
            return []

    async def get_location_by_name(self, household_id: str, name: str) -> Optional[Location]:
        """Get a specific location by name (case-insensitive)"""
        try:
            response = self.supabase.table('locations') \
                .select('*') \
                .eq('household_id', household_id) \
                .ilike('name', name) \
                .single() \
                .execute()
            
            return Location(**response.data) if response.data else None
        except Exception as e:
            logger.error(f"Error fetching location '{name}': {e}")
            return None

    @staticmethod
    def calculate_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
        """
        Calculate distance between two points using Haversine formula.
        Returns distance in miles.
        """
        if not all([lat1, lon1, lat2, lon2]):
            return None
        
        # Convert to radians
        lat1_rad = math.radians(lat1)
        lon1_rad = math.radians(lon1)
        lat2_rad = math.radians(lat2)
        lon2_rad = math.radians(lon2)
        
        # Haversine formula
        dlat = lat2_rad - lat1_rad
        dlon = lon2_rad - lon1_rad
        
        a = math.sin(dlat/2)**2 + math.cos(lat1_rad) * math.cos(lat2_rad) * math.sin(dlon/2)**2
        c = 2 * math.asin(math.sqrt(a))
        
        # Earth's radius in miles
        R = 3959
        
        distance = R * c
        return round(distance, 1)

    @staticmethod
    def calculate_distance_from_location(origin: Location, dest_lat: float, dest_lon: float) -> Optional[float]:
        """Calculate distance from a location to a destination"""
        if not origin.latitude or not origin.longitude:
            return None
        return LocationService.calculate_distance(
            origin.latitude, origin.longitude, 
            dest_lat, dest_lon
        )

    async def parse_location_from_prompt(self, household_id: str, prompt: str) -> Optional[Location]:
        """
        Parse location references from prompt.
        Examples:
        - "near home" -> returns Home location
        - "close to school" -> returns School location
        - "around work" -> returns Work location
        """
        if not prompt:
            return None
        
        prompt_lower = prompt.lower()
        
        # Common location keywords
        location_keywords = {
            'home': ['home', 'house'],
            'school': ['school', 'classroom', 'campus'],
            'work': ['work', 'office', 'workplace'],
        }
        
        # Check for location indicators
        if any(word in prompt_lower for word in ['near', 'close to', 'around', 'by', 'at']):
            # Try to find matching location
            locations = await self.get_household_locations(household_id)
            
            for location in locations:
                location_name_lower = location.name.lower()
                
                # Direct name match
                if location_name_lower in prompt_lower:
                    return location
                
                # Keyword match
                for category, keywords in location_keywords.items():
                    if any(kw in prompt_lower for kw in keywords) and category in location_name_lower:
                        return location
        
        return None
```

---

## 🎯 **3. Update Activity Service**

### `family/services/activity_service.py`

```python
from typing import List, Optional, Dict
from ..models.household import ActivitySuggestion, SuggestionResponse, Household, Location
from .location_service import LocationService
import random
import logging

logger = logging.getLogger(__name__)

class ActivityService:
    # ... existing ACTIVITY_DATABASE ...

    @staticmethod
    def generate_activity_suggestions(
        household: Household,
        weather: str,
        time_of_day: str,
        day_of_week: str,
        custom_prompt: Optional[str] = None,
        reference_location: Optional[Location] = None,  # NEW
    ) -> SuggestionResponse:
        """
        Generate 1-3 activity suggestions based on context.
        
        Args:
            household: The household requesting suggestions
            weather: 'sunny', 'rainy', 'cloudy'
            time_of_day: 'morning', 'afternoon', 'evening'
            day_of_week: 'monday', 'tuesday', etc.
            custom_prompt: Optional custom user prompt
            reference_location: Optional location to calculate distances from
        """
        # Validate inputs
        if weather.lower() not in ["sunny", "rainy", "cloudy"]:
            weather = "cloudy"
        if time_of_day.lower() not in ["morning", "afternoon", "evening"]:
            time_of_day = "afternoon"
        
        weather = weather.lower()
        time_of_day = time_of_day.lower()
        day_of_week = day_of_week.lower()
        
        # Get base activities for this context
        base_activities = ActivityService.ACTIVITY_DATABASE.get(time_of_day, {}).get(weather, [])
        if not base_activities:
            base_activities = ActivityService.ACTIVITY_DATABASE["afternoon"]["cloudy"]
        
        # Filter by custom prompt if provided
        if custom_prompt and custom_prompt.strip():
            suggested_activities = ActivityService._filter_by_prompt(
                base_activities, custom_prompt, household.members or []
            )
            if not suggested_activities:
                suggested_activities = base_activities
        else:
            # Filter by household member preferences
            suggested_activities = ActivityService._filter_by_preferences(
                base_activities, household.members or []
            )
            if not suggested_activities:
                suggested_activities = base_activities
        
        # Filter by age groups
        suggested_activities = ActivityService._filter_by_age_groups(
            suggested_activities, household.members or []
        )
        
        # Adjust for day of week (weekend = more elaborate activities)
        is_weekend = day_of_week in ["saturday", "sunday"]
        if not is_weekend:
            quick_activities = [a for a in suggested_activities if "quick" in a.get("tags", [])]
            if quick_activities:
                suggested_activities = quick_activities
        
        # Calculate distances if reference location provided
        if reference_location:
            for activity in suggested_activities:
                if activity.get("location_lat") and activity.get("location_lon"):
                    distance = LocationService.calculate_distance_from_location(
                        reference_location,
                        activity["location_lat"],
                        activity["location_lon"]
                    )
                    if distance:
                        activity["distance_miles"] = distance
        
        # Build suggestion objects with rationale
        suggestions = []
        for i, activity_data in enumerate(suggested_activities[:3]):
            rationale = ActivityService._build_rationale(
                activity_data["activity"],
                weather,
                time_of_day,
                day_of_week,
                household.members or [],
                custom_prompt
            )
            
            suggestions.append(ActivitySuggestion(
                activity=activity_data["activity"],
                rationale=rationale,
                tags=activity_data.get("tags", []),
                duration_minutes=ActivityService._estimate_duration(activity_data["activity"]),
                location=activity_data.get("location"),
                distance_miles=activity_data.get("distance_miles"),
                attire=activity_data.get("attire", []),
                food_available=activity_data.get("food_available"),
                description=activity_data.get("description"),
                venue_type=activity_data.get("venue_type"),
                average_rating=activity_data.get("average_rating"),
                review_count=activity_data.get("review_count"),
            ))
        
        return SuggestionResponse(
            suggestions=suggestions,
            context={
                "weather": weather,
                "time_of_day": time_of_day,
                "day_of_week": day_of_week,
                "household_name": household.name,
                "custom_prompt": custom_prompt,
                "reference_location": reference_location.name if reference_location else None,
            }
        )

    @staticmethod
    def _filter_by_age_groups(activities: List[Dict], members: List) -> List[Dict]:
        """Filter activities based on age groups of family members"""
        if not members:
            return activities
        
        # Get age groups in household
        age_groups = set()
        for member in members:
            age = member.calculated_age if hasattr(member, 'calculated_age') else member.age
            if age < 3:
                age_groups.add('infant')
            elif age < 6:
                age_groups.add('toddler')
            elif age < 13:
                age_groups.add('child')
            elif age < 18:
                age_groups.add('teen')
            else:
                age_groups.add('adult')
        
        # Filter activities that match age groups
        filtered = []
        for activity in activities:
            activity_age_groups = activity.get("age_groups", ["all"])
            
            if "all" in activity_age_groups:
                filtered.append(activity)
            elif any(ag in age_groups for ag in activity_age_groups):
                filtered.append(activity)
        
        return filtered if filtered else activities

    # ... rest of existing methods (unchanged) ...
```

---

## 🔌 **4. Update View to Use Locations**

### `family/views/household_view.py`

```python
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods
import json
import logging

from ..services.household_service import HouseholdService
from ..services.activity_service import ActivityService
from ..services.location_service import LocationService
from ...core.auth import auth_required

logger = logging.getLogger(__name__)

@csrf_exempt
@require_http_methods(["POST"])
@auth_required(allow_anonymous=False)
async def suggest_activity_view(request):
    """
    Get activity suggestions based on context.
    
    Request body:
    {
        "household_id": "uuid",
        "weather": "sunny|rainy|cloudy",
        "time_of_day": "morning|afternoon|evening",
        "day_of_week": "monday|tuesday|...|sunday",
        "custom_prompt": "optional - e.g., 'something active near home'",
        "participants": ["member_id1", "member_id2"]  # optional
    }
    """
    try:
        data = json.loads(request.body)
        household_id = data.get("household_id")
        
        if not household_id:
            return JsonResponse({"error": "Household ID required"}, status=400)
        
        # Get household
        household = await HouseholdService.get_household(household_id)
        if not household:
            return JsonResponse({"error": "Household not found"}, status=404)
        
        weather = data.get("weather", "cloudy")
        time_of_day = data.get("time_of_day", "afternoon")
        day_of_week = data.get("day_of_day", "monday")
        custom_prompt = data.get("custom_prompt")
        participants = data.get("participants")  # Optional list of member IDs
        
        # NEW: Initialize location service
        from supabase import create_client
        from django.conf import settings
        supabase = create_client(settings.SUPABASE_URL, settings.SUPABASE_KEY)
        location_service = LocationService(supabase)
        
        # NEW: Try to parse location from prompt
        reference_location = None
        if custom_prompt:
            reference_location = await location_service.parse_location_from_prompt(
                household_id, custom_prompt
            )
            
            # If no location found in prompt, default to "Home"
            if not reference_location:
                reference_location = await location_service.get_location_by_name(
                    household_id, "home"
                )
        
        # NEW: Filter members by participants if provided
        if participants:
            household.members = [
                m for m in household.members 
                if m.id in participants
            ]
        
        # Generate suggestions with location context
        suggestions = ActivityService.generate_activity_suggestions(
            household=household,
            weather=weather,
            time_of_day=time_of_day,
            day_of_day=day_of_week,
            custom_prompt=custom_prompt,
            reference_location=reference_location,  # NEW
        )
        
        logger.info(f"Generated suggestions for household {household_id}")
        
        return JsonResponse(suggestions.model_dump(exclude_none=True))
        
    except Exception as e:
        logger.error(f"Error generating suggestions: {str(e)}", exc_info=True)
        return JsonResponse({"error": str(e)}, status=400)
```

---

## 📊 **5. Update Activity Database with Locations**

### `family/services/activity_service.py` (ACTIVITY_DATABASE)

```python
ACTIVITY_DATABASE = {
    "morning": {
        "sunny": [
            {
                "activity": "Visit the Children's Museum",
                "tags": ["indoor", "educational", "active"],
                "duration_minutes": 120,
                "location": "Children's Museum Downtown",
                "location_lat": 40.7128,  # Example coordinates
                "location_lon": -74.0060,
                "attire": ["comfortable shoes", "casual clothing"],
                "food_available": {
                    "available": True,
                    "type": "cafe on-site with snacks and lunch"
                },
                "description": "Interactive science exhibits perfect for kids aged 3-12. Features hands-on displays, planetarium shows, and a special toddler area.",
                "venue_type": "indoor",
                "average_rating": 4.5,
                "review_count": 127,
                "age_groups": ["toddler", "child", "adult"],  # NEW
            },
            {
                "activity": "Playground at Central Park",
                "tags": ["outdoor", "active", "free"],
                "duration_minutes": 90,
                "location": "Central Park North Playground",
                "location_lat": 40.7829,
                "location_lon": -73.9654,
                "attire": ["play clothes", "sun hat", "sneakers"],
                "food_available": {
                    "available": False,
                    "type": "bring your own snacks"
                },
                "description": "Large playground with modern equipment for all ages. Includes swings, climbing structures, slides, and shaded picnic areas.",
                "venue_type": "outdoor",
                "average_rating": 4.7,
                "review_count": 89,
                "age_groups": ["toddler", "child", "adult"],  # NEW
            },
        ],
        "rainy": [
            {
                "activity": "Indoor Trampoline Park",
                "tags": ["indoor", "active", "energetic"],
                "duration_minutes": 120,
                "location": "Sky Zone Trampoline Park",
                "location_lat": 40.7580,
                "location_lon": -73.9855,
                "attire": ["athletic clothes", "grip socks required"],
                "food_available": {
                    "available": True,
                    "type": "snack bar with pizza and drinks"
                },
                "description": "Wall-to-wall trampolines, foam pits, and dodgeball courts. Great for burning energy on rainy days. Toddler area available.",
                "venue_type": "indoor",
                "average_rating": 4.3,
                "review_count": 203,
                "age_groups": ["child", "teen", "adult"],  # NEW
            },
        ],
        # ... add more activities
    },
    # ... rest of your activity database
}
```

---

## 🔧 **6. Helper Functions**

### `family/utils/age_calculator.py`

```python
from datetime import date
from typing import Optional

def calculate_age_from_birthday(birthday: date) -> int:
    """Calculate current age from birthday"""
    today = date.today()
    age = today.year - birthday.year
    
    # Adjust if birthday hasn't occurred this year yet
    if (today.month, today.day) < (birthday.month, birthday.day):
        age -= 1
    
    return age

def get_age_group(age: int) -> str:
    """Get age group category"""
    if age < 3:
        return 'infant'
    elif age < 6:
        return 'toddler'
    elif age < 13:
        return 'child'
    elif age < 18:
        return 'teen'
    elif age < 65:
        return 'adult'
    else:
        return 'senior'

def should_update_age(birthday: Optional[date], stored_age: int) -> bool:
    """Check if stored age needs updating based on birthday"""
    if not birthday:
        return False
    
    calculated_age = calculate_age_from_birthday(birthday)
    return calculated_age != stored_age
```

---

## 🎯 **7. Geocoding Helper (Optional but Recommended)**

If you want to auto-populate lat/lon from addresses:

### `family/services/geocoding_service.py`

```python
import requests
from typing import Optional, Tuple
import logging

logger = logging.getLogger(__name__)

class GeocodingService:
    """Service for geocoding addresses to lat/lon coordinates"""
    
    # You can use:
    # - Google Maps Geocoding API (requires API key)
    # - OpenStreetMap Nominatim (free, rate limited)
    # - Mapbox Geocoding API (requires API key)
    
    @staticmethod
    def geocode_address(address: str) -> Optional[Tuple[float, float]]:
        """
        Convert address to (latitude, longitude).
        Using OpenStreetMap Nominatim (free).
        """
        try:
            url = "https://nominatim.openstreetmap.org/search"
            params = {
                "q": address,
                "format": "json",
                "limit": 1
            }
            headers = {
                "User-Agent": "MerrywayApp/1.0"  # Required by Nominatim
            }
            
            response = requests.get(url, params=params, headers=headers)
            response.raise_for_status()
            
            data = response.json()
            if data:
                lat = float(data[0]["lat"])
                lon = float(data[0]["lon"])
                return (lat, lon)
            
            return None
            
        except Exception as e:
            logger.error(f"Geocoding error for '{address}': {e}")
            return None

    @staticmethod
    def geocode_address_google(address: str, api_key: str) -> Optional[Tuple[float, float]]:
        """
        Convert address to (latitude, longitude) using Google Maps.
        More accurate but requires API key.
        """
        try:
            url = "https://maps.googleapis.com/maps/api/geocode/json"
            params = {
                "address": address,
                "key": api_key
            }
            
            response = requests.get(url, params=params)
            response.raise_for_status()
            
            data = response.json()
            if data["status"] == "OK" and data["results"]:
                location = data["results"][0]["geometry"]["location"]
                return (location["lat"], location["lng"])
            
            return None
            
        except Exception as e:
            logger.error(f"Google geocoding error for '{address}': {e}")
            return None
```

---

## 📝 **Summary of Changes**

### **Models:**
✅ Add `birthday` field to `FamilyMember`  
✅ Add `calculated_age` property to auto-calculate from birthday  
✅ Add `age_group` property for categorization  
✅ Create `Location` model

### **Services:**
✅ Create `LocationService` with:
   - Fetch locations from Supabase
   - Distance calculation (Haversine)
   - Parse locations from prompts

✅ Update `ActivityService` to:
   - Accept `reference_location` parameter
   - Calculate distances to activities
   - Filter by age groups
   - Use birthday-based ages

### **Views:**
✅ Update `suggest_activity_view` to:
   - Parse locations from prompts
   - Default to "Home" location
   - Pass location to activity service

### **Database:**
✅ Add lat/lon to activity seed data  
✅ Add `age_groups` to activities

---

## 🚀 **Testing Examples**

### **Test Birthday Age Calculation:**
```python
member = FamilyMember(
    name="Alice",
    age=8,  # Stored age
    birthday=date(2016, 3, 15),  # Birthday
    # ...
)

print(member.calculated_age)  # Uses birthday -> 8 or 9 depending on date
print(member.age_group)  # "child"
```

### **Test Distance Calculation:**
```python
home = Location(
    name="Home",
    address="123 Main St",
    latitude=40.7128,
    longitude=-74.0060
)

museum_lat = 40.7580
museum_lon = -73.9855

distance = LocationService.calculate_distance(
    home.latitude, home.longitude,
    museum_lat, museum_lon
)
print(f"Distance to museum: {distance} miles")
```

### **Test Location Prompt Parsing:**
```python
location = await location_service.parse_location_from_prompt(
    household_id,
    "Find activities near home"
)
print(location.name)  # "Home"
```

---

That's everything! Let me know if you need any clarification. 🚀

