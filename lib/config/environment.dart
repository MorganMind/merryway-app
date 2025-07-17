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
    switch (flavor) {
      case BuildFlavor.development:
        // if (Platform.isAndroid && !kIsWeb) {
        //   return 'http://localhost:8000/api/v1'; 
        // }
        return 'http://localhost:8000/api/v1';    // Web/Desktop/iOS simulator
      
      case BuildFlavor.staging:
        return 'http://localhost:8000/api/v1';
      
      case BuildFlavor.production:
        return 'http://localhost:8000/api/v1';
    }
  }

  // Add other environment-specific configurations
  static String get supabaseUrl => const String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://live-wired-fox.ngrok-free.app',
  );

  static String get supabaseAnonKey => const String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsImlzcyI6InN1cGFiYXNlIiwiaWF0IjoxNzQ1NDY3MjAwLCJleHAiOjE5MDMyMzM2MDB9.nJIBddnuSoAuyDW_4dZl0MaX41Gnvn__3EHySRVziZI',
  );

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
        return 'http://localhost:8686';
    }
  }
  
} 