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

  // Supabase Configuration (hosted project)
  static String get supabaseUrl => const String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://xnvzkjqnirqfgemjakok.supabase.co',
  );

  static String get supabaseAnonKey => const String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhudnpranFuaXJxZmdlbWpha29rIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAyMTk0NTksImV4cCI6MjA3NTc5NTQ1OX0.3Xz99qEjRzCTInLHLDVqkBd7xF_RJ9NpF5_CxtULkwE',
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

  // OpenAI API Key (for journaling/parsing)
  static String get openAIApiKey => const String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: '', // User will provide via --dart-define
  );
  
} 