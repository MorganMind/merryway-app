import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  // Open-Meteo API - completely free, no API key needed!
  static const String _weatherBaseUrl = 'https://api.open-meteo.com/v1/forecast';
  static const String _geoBaseUrl = 'https://ipapi.co/json/';

  /// Get current weather based on IP geolocation
  /// Returns: 'sunny', 'rainy', or 'cloudy'
  static Future<String> getCurrentWeather() async {
    try {
      // Step 1: Get location from IP (works on web without permissions)
      final locationResponse = await http.get(Uri.parse(_geoBaseUrl)).timeout(
        const Duration(seconds: 5),
      );

      if (locationResponse.statusCode != 200) {
        return _getFallbackWeather();
      }

      final locationData = jsonDecode(locationResponse.body);
      final lat = locationData['latitude'];
      final lon = locationData['longitude'];

      if (lat == null || lon == null) {
        return _getFallbackWeather();
      }

      // Step 2: Get weather from Open-Meteo (no API key needed!)
      final weatherUri = Uri.parse(
        '$_weatherBaseUrl?latitude=$lat&longitude=$lon&current_weather=true',
      );

      final weatherResponse = await http.get(weatherUri).timeout(
        const Duration(seconds: 5),
      );

      if (weatherResponse.statusCode != 200) {
        return _getFallbackWeather();
      }

      final weatherData = jsonDecode(weatherResponse.body);
      final currentWeather = weatherData['current_weather'];
      final weatherCode = currentWeather['weathercode'] as int;

      // Map Open-Meteo weather code to our 3 states
      return _mapWeatherCode(weatherCode);
    } catch (e) {
      print('Weather fetch error: $e');
      return _getFallbackWeather();
    }
  }

  /// Get weather for specific coordinates
  static Future<String> getWeatherByCoordinates(double lat, double lon) async {
    try {
      final weatherUri = Uri.parse(
        '$_weatherBaseUrl?latitude=$lat&longitude=$lon&current_weather=true',
      );

      final weatherResponse = await http.get(weatherUri).timeout(
        const Duration(seconds: 5),
      );

      if (weatherResponse.statusCode != 200) {
        return _getFallbackWeather();
      }

      final weatherData = jsonDecode(weatherResponse.body);
      final currentWeather = weatherData['current_weather'];
      final weatherCode = currentWeather['weathercode'] as int;

      return _mapWeatherCode(weatherCode);
    } catch (e) {
      print('Weather fetch error: $e');
      return _getFallbackWeather();
    }
  }

  /// Map Open-Meteo weather codes to our simple 3-state system
  /// WMO Weather interpretation codes (WW): https://open-meteo.com/en/docs
  static String _mapWeatherCode(int code) {
    // 0 = Clear sky
    // 1, 2, 3 = Mainly clear, partly cloudy, and overcast
    // 45, 48 = Fog
    // 51, 53, 55 = Drizzle
    // 56, 57 = Freezing Drizzle
    // 61, 63, 65 = Rain
    // 66, 67 = Freezing Rain
    // 71, 73, 75 = Snow fall
    // 77 = Snow grains
    // 80, 81, 82 = Rain showers
    // 85, 86 = Snow showers
    // 95 = Thunderstorm
    // 96, 99 = Thunderstorm with hail

    if (code == 0) {
      // Clear sky
      return 'sunny';
    } else if (code >= 1 && code <= 3) {
      // Partly cloudy to overcast
      if (code == 1) {
        return 'sunny'; // Mainly clear
      }
      return 'cloudy';
    } else if (code >= 45 && code <= 48) {
      // Fog
      return 'cloudy';
    } else if (code >= 51 && code <= 67) {
      // Drizzle, freezing drizzle, rain, freezing rain
      return 'rainy';
    } else if (code >= 71 && code <= 77) {
      // Snow
      return 'rainy'; // Treat snow as indoor weather
    } else if (code >= 80 && code <= 86) {
      // Rain showers, snow showers
      return 'rainy';
    } else if (code >= 95 && code <= 99) {
      // Thunderstorm
      return 'rainy';
    }

    // Default
    return 'cloudy';
  }

  /// Fallback weather based on time of day
  static String _getFallbackWeather() {
    final hour = DateTime.now().hour;
    if (hour >= 8 && hour <= 16) return 'sunny';
    return 'cloudy';
  }

  /// Get weather emoji
  static String getWeatherEmoji(String weather) {
    switch (weather.toLowerCase()) {
      case 'sunny':
        return '☀️';
      case 'rainy':
        return '🌧️';
      case 'cloudy':
        return '☁️';
      default:
        return '☁️';
    }
  }

  /// Get weather description
  static String getWeatherDescription(String weather) {
    switch (weather.toLowerCase()) {
      case 'sunny':
        return 'Clear & Sunny';
      case 'rainy':
        return 'Rainy';
      case 'cloudy':
        return 'Cloudy';
      default:
        return 'Unknown';
    }
  }
}

