import 'package:flutter_dotenv/flutter_dotenv.dart';

enum BuildFlavor {
  development,
  staging,
  production,
}

class Environment {
  static late BuildFlavor flavor;

  static void initialize(BuildFlavor flavor) {
    Environment.flavor = flavor;
  }

  static bool get isProduction => flavor == BuildFlavor.production;
  static bool get isDevelopment => flavor == BuildFlavor.development;
  static bool get isStaging => flavor == BuildFlavor.staging;

  static String get apiUrl {
    // Try to get from .env first, fallback to localhost
    return dotenv.get('API_URL', fallback: 'http://localhost:8000/api/v1');
  }

  // Supabase Configuration (from .env)
  static String get supabaseUrl => dotenv.get('SUPABASE_URL', fallback: '');

  static String get supabaseAnonKey => dotenv.get('SUPABASE_ANON_KEY', fallback: '');

  static String get appUrl {
    switch (flavor) {
      case BuildFlavor.development:
        // if (Platform.isAndroid && !kIsWeb) {
        //   return 'http://localhost:8000/api/v1'; 
        // }
        return 'http://localhost:8686';    // Web/Desktop/iOS simulator
      
      case BuildFlavor.staging:
        return 'http://localhost:8686';
      
      case BuildFlavor.production:
        return 'https://merryway.onrender.com';  // Production URL
    }
  }

  // OpenAI API Key (from .env)
  static String get openAIApiKey => dotenv.get('OPENAI_API_KEY', fallback: '');
  
} 