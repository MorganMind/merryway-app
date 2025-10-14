# Open-Meteo Weather Integration

## 🌤️ Zero Setup Required!

**Open-Meteo is 100% FREE** and requires **NO API KEY**! 🎉

---

## ✨ Why Open-Meteo?

✅ **Completely Free** - No signup, no API key, no usage limits  
✅ **Global Coverage** - Works worldwide with high accuracy  
✅ **No Rate Limits** - Generous usage for all apps  
✅ **Simple API** - Just latitude + longitude  
✅ **WMO Standard** - Uses official weather codes  
✅ **Fast & Reliable** - Production-ready  

**Perfect for Phase 1-2!**

---

## 🔧 How It Works

### Automatic Location Detection:
1. **Get user's approximate location** via IP (ipapi.co)
2. **Fetch current weather** from Open-Meteo API
3. **Map to 3 simple states**: Sunny ☀️ / Rainy 🌧️ / Cloudy ☁️
4. **Fallback**: Time-based weather if API unavailable

### No Setup Required:
- **No API key** to configure
- **No signup** required
- **No rate limits** to worry about
- **Just works!** ✨

---

## 📊 Weather Code Mapping

Open-Meteo uses **WMO Weather Interpretation Codes**:

| WMO Code | Description | Merryway State |
|----------|-------------|----------------|
| 0 | Clear sky | ☀️ Sunny |
| 1 | Mainly clear | ☀️ Sunny |
| 2 | Partly cloudy | ☁️ Cloudy |
| 3 | Overcast | ☁️ Cloudy |
| 45, 48 | Fog | ☁️ Cloudy |
| 51-67 | Drizzle/Rain | 🌧️ Rainy |
| 71-77 | Snow | 🌧️ Rainy |
| 80-86 | Showers | 🌧️ Rainy |
| 95-99 | Thunderstorm | 🌧️ Rainy |

---

## 🧪 Test It

### 1. Start the App:
```bash
flutter run -d web-server --web-port 8686
```

### 2. Check Console:
```
✅ Good: Weather fetched successfully
   Current weather code: 0 (Clear sky)
   Mapped to: sunny

❌ Bad: Weather fetch error: ...
   Fallback: time-based weather
```

### 3. Verify on Home Page:
- Should show **real weather** chip (☀️/☁️/🌧️)
- Based on your **actual location**!
- Updates automatically on app restart

---

## 📍 API Endpoints Used

### 1. **IP Geolocation** (ipapi.co)
```
GET https://ipapi.co/json/

Response:
{
  "latitude": 37.7749,
  "longitude": -122.4194,
  "city": "San Francisco",
  ...
}
```

### 2. **Weather Data** (Open-Meteo)
```
GET https://api.open-meteo.com/v1/forecast
  ?latitude=37.7749
  &longitude=-122.4194
  &current_weather=true

Response:
{
  "current_weather": {
    "temperature": 15.0,
    "windspeed": 10.5,
    "weathercode": 0,
    "time": "2024-01-15T12:00"
  }
}
```

---

## 🌍 Manual Location Override

Want to set a specific location instead of auto-detect?

### Option 1: Hardcode Coordinates
```dart
// In weather_service.dart, replace getCurrentWeather():
static Future<String> getCurrentWeather() async {
  // Skip IP lookup, use fixed location
  return await getWeatherByCoordinates(
    37.7749,  // San Francisco latitude
    -122.4194, // San Francisco longitude
  );
}
```

### Option 2: Add Location Picker
```dart
// Let users choose their location in settings
// Store in SharedPreferences
final prefs = await SharedPreferences.getInstance();
await prefs.setDouble('user_latitude', 37.7749);
await prefs.setDouble('user_longitude', -122.4194);

// Then fetch weather:
final lat = prefs.getDouble('user_latitude');
final lon = prefs.getDouble('user_longitude');
if (lat != null && lon != null) {
  final weather = await WeatherService.getWeatherByCoordinates(lat, lon);
}
```

---

## 🚨 Troubleshooting

### Issue: Always shows fallback weather
**Causes:**
- IP geolocation failed (ipapi.co down)
- Open-Meteo API unreachable
- Network blocked (corporate firewall)

**Fix:**
1. Check browser console for errors
2. Test API manually: https://api.open-meteo.com/v1/forecast?latitude=40&longitude=-74&current_weather=true
3. If API works, issue is with IP geolocation

### Issue: Wrong location detected
**Cause:** IP geolocation is approximate (city-level accuracy)

**Fix:**
- Add manual location picker (see above)
- Or use browser's Geolocation API (requires permissions)

### Issue: CORS errors (web only)
**Cause:** Browser blocking cross-origin requests

**Fix:** Open-Meteo has CORS enabled, but if you see errors:
```bash
flutter run -d web-server --web-port 8686 --web-renderer html
```

---

## 📊 API Usage & Limits

**Open-Meteo Free Tier:**
- ✅ **Unlimited API calls**
- ✅ **No authentication required**
- ✅ **No rate limits**
- ✅ **Global coverage**
- ✅ **Commercial use allowed**

**Fair Use Policy:**
- Don't abuse (millions of requests/minute)
- Cache results for a few minutes
- Be a good citizen! 🌍

**Current Merryway Usage:**
- 1 call per app load
- ~10-50 calls/day in development
- Well within fair use! ✅

---

## 🎯 Advanced Features (Optional)

Open-Meteo supports much more than current weather!

### Hourly Forecast:
```dart
// Get 24-hour forecast
final uri = Uri.parse(
  'https://api.open-meteo.com/v1/forecast'
  '?latitude=$lat&longitude=$lon'
  '&hourly=temperature_2m,precipitation_probability,weathercode'
  '&forecast_days=1'
);
```

### Daily Forecast:
```dart
// Get 7-day forecast
final uri = Uri.parse(
  'https://api.open-meteo.com/v1/forecast'
  '?latitude=$lat&longitude=$lon'
  '&daily=weathercode,temperature_2m_max,temperature_2m_min'
  '&forecast_days=7'
);
```

### Additional Data:
- Temperature, humidity, wind speed
- Precipitation probability
- UV index, visibility
- Sunrise/sunset times

See: https://open-meteo.com/en/docs

---

## 🔄 Migration from OpenWeatherMap

**Already using OpenWeatherMap?** Just replace the service!

**Old (OpenWeatherMap):**
- ❌ Requires API key
- ❌ Limited free tier (1000 calls/day)
- ❌ 10-120 min activation wait
- ❌ Sign up required

**New (Open-Meteo):**
- ✅ No API key
- ✅ Unlimited calls
- ✅ Works immediately
- ✅ No sign up

**Code stays the same!**
```dart
final weather = await WeatherService.getCurrentWeather();
// Still returns: 'sunny', 'rainy', or 'cloudy'
```

---

## 📚 Resources

- **Open-Meteo Docs:** https://open-meteo.com/en/docs
- **API Playground:** https://open-meteo.com/en/docs#api-playground
- **WMO Weather Codes:** https://www.nodc.noaa.gov/archive/arc0021/0002199/1.1/data/0-data/HTML/WMO-CODE/WMO4677.HTM

---

## ✅ Summary

**Open-Meteo Integration:**
- ✅ Zero setup required
- ✅ No API key needed
- ✅ Completely free forever
- ✅ Works globally
- ✅ Production-ready
- ✅ Already integrated!

**Just run your app and enjoy real weather! 🌤️**

---

**Perfect choice for Phase 1-2!** 🚀

