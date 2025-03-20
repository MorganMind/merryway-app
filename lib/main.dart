import 'package:app/modules/auth/blocs/auth_bloc.dart';
import 'package:app/modules/auth/services/auth_state_listener.dart';
import 'package:app/modules/core/blocs/layout_bloc.dart';
import 'package:app/modules/core/blocs/layout_event.dart';
import 'package:app/modules/core/routing/app_router.dart';
import 'package:app/modules/onboarding/blocs/onboarding_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app/modules/core/di/service_locator.dart';
import 'package:app/modules/core/platform/url_strategy.dart';
import 'package:app/config/environment.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:app/modules/user/repositories/user_settings_repository.dart';
import 'package:app/modules/user/models/user_settings.dart' as u;
import 'package:app/modules/core/theme/theme_provider.dart';
import 'package:watch_it/watch_it.dart';

void mainCommon() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: Environment.supabaseUrl,
    anonKey: Environment.supabaseAnonKey,
  );
  
  await setupServiceLocator();

  sl<AuthStateListener>().initialize();
  
  initializeUrlStrategy();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget with WatchItMixin {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    final theme = watchStream(
      (UserSettingsRepository r) => r.theme,
      initialValue: sl<UserSettingsRepository>().currentTheme,
    ).data;

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => sl<AuthBloc>(),
        ),
        BlocProvider<LayoutBloc>.value(
          value: sl<LayoutBloc>(),
        ),
        BlocProvider<OnboardingBloc>(
          create: (context) => sl<OnboardingBloc>(),
        ),
      ],
      child: Builder(
        builder: (context) {
        
          return ThemeProvider(
            currentTheme: theme ?? u.ThemeMode.light,
            child: Builder(
              builder: (context) {
                final goRouter = AppRouter.setupRouter(context);
                final themeProvider = ThemeProvider.of(context);

                return LayoutBuilder(
                  builder: (context, constraints) {
                    sl<LayoutBloc>().add(
                          UpdateLayoutType(constraints.maxWidth),
                        );
                    
                    return ShadApp.materialRouter(
                      debugShowCheckedModeBanner: false,
                      routerConfig: goRouter,
                      theme: themeProvider.theme,
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
