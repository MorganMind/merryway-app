import 'package:app/modules/auth/blocs/auth_bloc.dart';
import 'package:app/modules/core/blocs/layout_bloc.dart';
import 'package:app/modules/core/services/api/i_api_service.dart';
import 'package:app/modules/core/services/sse/sse_service.dart';
import 'package:app/modules/tags/blocs/tags_bloc.dart';
import 'package:app/modules/user/repositories/user_settings_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/api/api_service.dart';
import 'package:app/modules/user/blocs/user_analytics_bloc.dart';
import 'package:app/modules/user/repositories/user_repository.dart';
import 'package:app/modules/auth/services/auth_state_listener.dart';
import 'package:app/modules/core/services/upload/i_upload_service.dart';
import 'package:app/modules/core/services/upload/upload_service.dart';
import 'package:app/modules/settings/blocs/settings_bloc.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Core
  sl.registerSingleton<SupabaseClient>(Supabase.instance.client);
  
  // Services
  sl.registerLazySingleton<IApiService>(() => ApiService());

  sl.registerLazySingleton<SSEService>(() => SSEService());
  
  sl.registerLazySingleton<IUploadService>(() => UploadService());
  
  // Repositories
  sl.registerLazySingleton<UserRepository>(() => UserRepository());
  sl.registerLazySingleton<UserSettingsRepository>(() => UserSettingsRepository());
  
  // sl.registerLazySingleton<InvitesRepository>(() => InvitesRepository());
  // sl.registerLazySingleton<IChatRepository>(() => ChatRepository());

  // Auth State Listener
  sl.registerLazySingleton(() => AuthStateListener());

  // Blocs
  sl.registerSingleton<AuthBloc>(AuthBloc());

  sl.registerLazySingleton(() => SettingsBloc());

  sl.registerSingleton<LayoutBloc>(LayoutBloc());

  sl.registerLazySingleton<UserAnalyticsBloc>(() => UserAnalyticsBloc());

  sl.registerLazySingleton<TagsBloc>(() => TagsBloc());
  
  // sl.registerFactory<OnboardingBloc>(() => OnboardingBloc());







  // sl.registerLazySingleton<OrganizationBloc>(() => OrganizationBloc());

  // sl.registerLazySingleton<AgentsBloc>(() => AgentsBloc(agentRepository: sl<IAgentsRepository>(), chatRepository: sl<IChatRepository>()));
} 