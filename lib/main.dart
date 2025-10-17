// Phase 1: Simplified main.dart for family module only
import 'package:merryway/modules/core/routing/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:merryway/modules/core/di/service_locator.dart';
import 'package:merryway/modules/core/platform/url_strategy.dart';
import 'package:merryway/config/environment.dart';
import 'package:merryway/modules/family/blocs/family_bloc.dart';
import 'package:merryway/modules/core/theme/merryway_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Custom page transitions builder that provides instant transitions (no animation)
class NoTransitionPageTransitionsBuilder extends PageTransitionsBuilder {
  const NoTransitionPageTransitionsBuilder();

  @override
  Widget buildTransitions<T extends Object?>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Return the child immediately without any animation
    return child;
  }
}

// Legacy imports commented out for Phase 1
// import 'package:merryway/modules/auth/blocs/auth_bloc.dart';
// import 'package:merryway/modules/auth/services/auth_state_listener.dart';
// import 'package:merryway/modules/core/blocs/layout_bloc.dart';
// import 'package:merryway/modules/user/repositories/user_settings_repository.dart';
// import 'package:merryway/modules/core/theme/theme_provider.dart';

void main() async {
  mainCommon();
}

void mainCommon() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: Environment.supabaseUrl,
    anonKey: Environment.supabaseAnonKey,
  );
  
  await setupServiceLocator();

  // Legacy auth listener - commented out for Phase 1
  // sl<AuthStateListener>().initialize();
  
  initializeUrlStrategy();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Phase 1: Only FamilyBloc
        BlocProvider<FamilyBloc>(
          create: (context) => sl<FamilyBloc>(),
        ),
        // Legacy blocs commented out for Phase 1
        // BlocProvider<AuthBloc>(create: (context) => sl<AuthBloc>()),
        // BlocProvider<LayoutBloc>.value(value: sl<LayoutBloc>()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.setupRouter(context),
        theme: MerryWayTheme.lightTheme.copyWith(
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: NoTransitionPageTransitionsBuilder(),
              TargetPlatform.iOS: NoTransitionPageTransitionsBuilder(),
              TargetPlatform.linux: NoTransitionPageTransitionsBuilder(),
              TargetPlatform.macOS: NoTransitionPageTransitionsBuilder(),
              TargetPlatform.windows: NoTransitionPageTransitionsBuilder(),
            },
          ),
        ),
        title: 'Merryway - Phase 1',
      ),
    );
  }
}
