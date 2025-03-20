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
    defaultValue: 'https://sjajyqbqwoffvazwvwva.supabase.co',
  );

  static String get supabaseAnonKey => const String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNqYWp5cWJxd29mZnZhend2d3ZhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDIzNDY5NjUsImV4cCI6MjA1NzkyMjk2NX0.RHlNlN-lxx1CM0YvWnde9lcJ8FvDDVdJ1mWyVHSN5t0',
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