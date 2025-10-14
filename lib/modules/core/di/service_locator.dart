// Phase 1: Family module only
// Commented out legacy imports that have compilation errors
// import 'package:merryway/modules/auth/blocs/auth_bloc.dart';
// import 'package:merryway/modules/core/blocs/layout_bloc.dart';
// import 'package:merryway/modules/core/services/api/i_api_service.dart';
// import 'package:merryway/modules/core/services/sse/sse_service.dart';
// import 'package:merryway/modules/tags/blocs/tags_bloc.dart';
// import 'package:merryway/modules/user/repositories/user_settings_repository.dart';
// import '../services/api/api_service.dart';
// import 'package:merryway/modules/user/blocs/user_analytics_bloc.dart';
// import 'package:merryway/modules/user/repositories/user_repository.dart';
// import 'package:merryway/modules/auth/services/auth_state_listener.dart';
// import 'package:merryway/modules/core/services/upload/i_upload_service.dart';
// import 'package:merryway/modules/core/services/upload/upload_service.dart';
// import 'package:merryway/modules/settings/blocs/settings_bloc.dart';

import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:merryway/modules/family/repositories/family_repository.dart';
import 'package:merryway/modules/family/blocs/family_bloc.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Core - Phase 1 only
  sl.registerSingleton<SupabaseClient>(Supabase.instance.client);
  sl.registerSingleton<SharedPreferences>(
    await SharedPreferences.getInstance()
  );
  
  // HTTP client for API calls with auth interceptor
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio();
    
    // Add interceptor to include Supabase auth token in all requests
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final supabase = sl<SupabaseClient>();
        var session = supabase.auth.currentSession;
        
        if (session != null) {
          // Check if token is expired or about to expire (within 5 minutes)
          final expiresAt = DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000);
          final now = DateTime.now();
          final shouldRefresh = expiresAt.difference(now).inMinutes < 5;
          
          if (shouldRefresh) {
            try {
              print('🔄 Token expiring soon, refreshing...');
              final refreshResponse = await supabase.auth.refreshSession();
              session = refreshResponse.session;
              print('✅ Token refreshed successfully');
            } catch (e) {
              print('❌ Token refresh failed: $e');
              // If refresh fails, try to use existing token (will likely fail but backend will handle)
            }
          }
          
          if (session != null) {
            options.headers['Authorization'] = 'Bearer ${session.accessToken}';
          }
        }
        
        return handler.next(options);
      },
      onError: (error, handler) async {
        // Handle 401/403 errors by attempting token refresh
        if (error.response?.statusCode == 401 || error.response?.statusCode == 403) {
          final supabase = sl<SupabaseClient>();
          
          try {
            print('🔄 Got 401/403, attempting token refresh...');
            final refreshResponse = await supabase.auth.refreshSession();
            final newSession = refreshResponse.session;
            
            if (newSession != null) {
              // Retry the request with new token
              error.requestOptions.headers['Authorization'] = 'Bearer ${newSession.accessToken}';
              
              final response = await dio.fetch(error.requestOptions);
              return handler.resolve(response);
            }
          } catch (e) {
            print('❌ Token refresh on error failed: $e');
          }
        }
        
        return handler.next(error);
      },
    ));
    
    return dio;
  });
  
  // Phase 1: Family domain only
  sl.registerLazySingleton<FamilyRepository>(() => FamilyRepository());
  sl.registerLazySingleton<FamilyBloc>(() => FamilyBloc(sl<FamilyRepository>()));
  
  // Legacy services - commented out for Phase 1
  // sl.registerLazySingleton<IApiService>(() => ApiService());
  // sl.registerLazySingleton<SSEService>(() => SSEService());
  // sl.registerLazySingleton<IUploadService>(() => UploadService());
  // sl.registerLazySingleton<UserRepository>(() => UserRepository());
  // sl.registerLazySingleton<UserSettingsRepository>(() => UserSettingsRepository());
  // sl.registerLazySingleton(() => AuthStateListener());
  // sl.registerSingleton<AuthBloc>(AuthBloc());
  // sl.registerLazySingleton(() => SettingsBloc());
  // sl.registerSingleton<LayoutBloc>(LayoutBloc());
  // sl.registerLazySingleton<UserAnalyticsBloc>(() => UserAnalyticsBloc());
  // sl.registerLazySingleton<TagsBloc>(() => TagsBloc());





  // sl.registerLazySingleton<OrganizationBloc>(() => OrganizationBloc());

  // sl.registerLazySingleton<AgentsBloc>(() => AgentsBloc(agentRepository: sl<IAgentsRepository>(), chatRepository: sl<IChatRepository>()));
} 