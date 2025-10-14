# Backend Specification: Enhanced Activity Suggestions

## Overview
Add rich metadata to activity suggestions including location, distance, attire, food availability, detailed descriptions, and ratings.

---

## 📦 **1. Update Your ActivitySuggestion Model**

### Python (Pydantic Model)
```python
from pydantic import BaseModel
from typing import Optional, List, Dict

class ActivitySuggestion(BaseModel):
    activity: str
    rationale: str
    duration_minutes: int
    tags: List[str] = []
    
    # NEW FIELDS TO ADD:
    location: Optional[str] = None  # e.g., "Central Park, New York"
    distance_miles: Optional[float] = None  # e.g., 2.5
    attire: List[str] = []  # e.g., ["comfortable shoes", "casual clothing"]
    food_available: Optional[Dict[str, any]] = None  # e.g., {"available": true, "type": "cafe on-site"}
    description: Optional[str] = None  # Detailed "what to expect" text
    venue_type: Optional[str] = None  # e.g., "indoor", "outdoor", "park", "museum"
    average_rating: Optional[float] = None  # e.g., 4.5 (for Phase 2)
    review_count: Optional[int] = None  # e.g., 23 (for Phase 2)
```

---

## 🗄️ **2. Update Your Activity Database**

### Seed Data Example
```python
ACTIVITY_DATABASE = {
    "morning": {
        "sunny": [
            {
                "activity": "Visit the Children's Museum",
                "tags": ["indoor", "educational", "active"],
                "duration_minutes": 120,
                
                # NEW FIELDS:
                "location": "123 Museum Way, Your City",
                "distance_miles": 2.5,
                "attire": ["comfortable shoes", "casual clothing"],
                "food_available": {
                    "available": True,
                    "type": "cafe on-site with snacks and lunch"
                },
                "description": "Interactive science exhibits perfect for kids aged 3-12. Features hands-on displays, planetarium shows, and a special toddler area. Popular exhibits include the water play zone and construction corner.",
                "venue_type": "indoor",
                "average_rating": 4.5,
                "review_count": 127
            },
            {
                "activity": "Playground at Central Park",
                "tags": ["outdoor", "active", "free"],
                "duration_minutes": 90,
                
                # NEW FIELDS:
                "location": "Central Park North Playground, Your City",
                "distance_miles": 1.2,
                "attire": ["play clothes", "sun hat", "sneakers"],
                "food_available": {
                    "available": False,
                    "type": "bring your own snacks"
                },
                "description": "Large playground with modern equipment for all ages. Includes swings, climbing structures, slides, and shaded picnic areas. Bathrooms available. Gets crowded after 10am on weekends.",
                "venue_type": "outdoor",
                "average_rating": 4.7,
                "review_count": 89
            },
        ],
    },
}
```

---

## 🗺️ **3. Add Distance Calculation (Optional but Recommended)**

### Option A: Store Household Location
```python
# In your Household model
class Household:
    name: str
    address: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
```

### Option B: Calculate Distance at Request Time
```python
import math

def calculate_distance(lat1, lon1, lat2, lon2):
    """Calculate distance between two points in miles using Haversine formula"""
    R = 3959  # Earth's radius in miles
    
    lat1, lon1, lat2, lon2 = map(math.radians, [lat1, lon1, lat2, lon2])
    dlat = lat2 - lat1
    dlon = lon2 - lon1
    
    a = math.sin(dlat/2)**2 + math.cos(lat1) * math.cos(lat2) * math.sin(dlon/2)**2
    c = 2 * math.asin(math.sqrt(a))
    
    return R * c

# In your suggestion service
def generate_activity_suggestions(household, weather, time_of_day, day_of_week):
    # Get activities...
    
    # Calculate distances if household has location
    if household.latitude and household.longitude:
        for activity in activities:
            if activity.get('location_lat') and activity.get('location_lon'):
                activity['distance_miles'] = calculate_distance(
                    household.latitude,
                    household.longitude,
                    activity['location_lat'],
                    activity['location_lon']
                )
    
    return activities
```

### Option C: Use Geocoding API (Recommended for Production)
```python
# Using Google Maps Geocoding API
import googlemaps

gmaps = googlemaps.Client(key='YOUR_API_KEY')

def get_distance(origin_address, destination_address):
    """Get distance between two addresses"""
    result = gmaps.distance_matrix(
        origins=[origin_address],
        destinations=[destination_address],
        units='imperial'  # for miles
    )
    
    distance_miles = result['rows'][0]['elements'][0]['distance']['value'] / 1609.34
    return round(distance_miles, 1)
```

---

## 📤 **4. Updated API Response Format**

### Before (Current)
```json
{
  "suggestions": [
    {
      "activity": "Visit the park",
      "rationale": "Great for sunny weather...",
      "duration_minutes": 60,
      "tags": ["outdoor", "active"]
    }
  ],
  "context": {...}
}
```

### After (With New Fields)
```json
{
  "suggestions": [
    {
      "activity": "Visit the Children's Museum",
      "rationale": "Great for rainy days and curious minds!",
      "duration_minutes": 120,
      "tags": ["indoor", "educational", "active"],
      
      "location": "123 Museum Way, Your City",
      "distance_miles": 2.5,
      "attire": ["comfortable shoes", "casual clothing"],
      "food_available": {
        "available": true,
        "type": "cafe on-site with snacks and lunch"
      },
      "description": "Interactive science exhibits perfect for kids aged 3-12. Features hands-on displays, planetarium shows, and a special toddler area.",
      "venue_type": "indoor",
      "average_rating": 4.5,
      "review_count": 127
    }
  ],
  "context": {
    "weather": "rainy",
    "time_of_day": "morning",
    "day_of_week": "saturday",
    "household_name": "The Smiths"
  }
}
```

---

## ✅ **5. Field Specifications**

### Required Fields (Already Exist)
- ✅ `activity` (string) - Activity name
- ✅ `rationale` (string) - Why this activity is suggested
- ✅ `duration_minutes` (int) - How long it takes
- ✅ `tags` (list[str]) - Category tags

### New Optional Fields
- 📍 `location` (string) - Venue name and/or address
- 📏 `distance_miles` (float) - Distance from household (1 decimal)
- 👕 `attire` (list[str]) - What to wear/bring
  - Examples: `["comfortable shoes", "sun hat", "rain jacket", "play clothes"]`
- 🍽️ `food_available` (dict) - Food availability info
  ```json
  {
    "available": true/false,
    "type": "description of food options"
  }
  ```
- 📝 `description` (string) - Detailed "what to expect" (2-3 sentences)
- 🏢 `venue_type` (string) - Type of venue
  - Values: `"indoor"`, `"outdoor"`, `"park"`, `"museum"`, `"restaurant"`, `"theater"`, etc.
- ⭐ `average_rating` (float) - Average rating (0-5, optional for Phase 1)
- 📊 `review_count` (int) - Number of reviews (optional for Phase 1)

---

## 🚀 **6. Implementation Priority**

### Phase 1 (Implement Now)
1. ✅ Add all new fields to your `ActivitySuggestion` model
2. ✅ Update your seed data with rich information
3. ✅ Return new fields in API response
4. ⭐ (Optional) Add simple distance calculation

### Phase 2 (Future)
1. Add reviews/ratings system
2. User-generated ratings
3. More sophisticated distance filtering
4. Real-time data from Google Places API

---

## 📝 **7. Example Implementation**

### Quick Update to Existing Code
```python
# In your activity_service.py

def _build_suggestion(activity_data, household):
    """Build a suggestion from activity data"""
    return ActivitySuggestion(
        activity=activity_data["activity"],
        rationale=_build_rationale(activity_data, household),
        duration_minutes=activity_data.get("duration_minutes", 60),
        tags=activity_data.get("tags", []),
        
        # NEW FIELDS - just pass through from data:
        location=activity_data.get("location"),
        distance_miles=activity_data.get("distance_miles"),
        attire=activity_data.get("attire", []),
        food_available=activity_data.get("food_available"),
        description=activity_data.get("description"),
        venue_type=activity_data.get("venue_type"),
        average_rating=activity_data.get("average_rating"),
        review_count=activity_data.get("review_count"),
    )
```

---

## ✨ **That's It!**

The frontend is already ready to display all these fields. Just:
1. Add the fields to your model
2. Add the data to your seed database
3. Return them in your API response

The UI will automatically show:
- 📍 Distance chip at the top
- 🏢 Venue type chip
- ⏱️ Duration chip
- ⭐ Rating stars
- 📝 "What to Expect" section
- 👕 Attire requirements
- 🍽️ Food availability

