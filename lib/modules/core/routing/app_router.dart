import 'package:app/modules/auth/blocs/auth_bloc.dart';
import 'package:app/modules/auth/blocs/auth_state.dart';
import 'package:app/modules/auth/pages/join_page.dart';
import 'package:app/modules/auth/pages/login_page.dart';
import 'package:app/modules/auth/pages/signup_page.dart';
import 'package:app/modules/core/di/service_locator.dart';
import 'package:app/modules/core/routing/router_observer.dart';
import 'package:app/modules/core/ui/pages/main_layout.dart';
import 'package:app/modules/core/routing/router_refresh_stream_group.dart';
import 'package:app/modules/core/ui/widgets/fullscreen_loader.dart';
import 'package:app/modules/home/pages/home_layout.dart';
import 'package:app/modules/home/pages/home_page.dart';
import 'package:app/modules/user/repositories/user_settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app/modules/settings/pages/settings_layout.dart';
import 'package:app/modules/settings/pages/about_you_page.dart';
import 'package:app/modules/settings/pages/appearance_page.dart';
import 'package:app/modules/memberships/screens/membership_home_screen.dart';
import 'package:app/modules/memberships/screens/subscribe_screen.dart';
import 'package:app/modules/memberships/screens/checkout_return_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppRouter {

  static final SharedPreferences _prefs = sl<SharedPreferences>();

  static GoRouter setupRouter(BuildContext context) {
    final authBloc = sl<AuthBloc>();
    final settings = sl<UserSettingsRepository>();

    // Define standalone routes that bypass MainLayout
    final standaloneRoutes = {'/login', '/signup', '/start', '/join'};

    return GoRouter(
      debugLogDiagnostics: false,
      initialLocation: '/',
      observers: [RouterObserver()],
      // Only refresh on auth changes, org changes, or initial settings load
      refreshListenable: GoRouterRefreshStreamGroup([
        authBloc.stream,
        settings.initialSettingsLoaded,
      ]),
      redirect: (context, state) {
        final authState = authBloc.state;
        final currentPath = state.uri.path;
        
        // Always allow splash screen to show while loading
        if (currentPath == '/') {
          if (authState is AuthLoading || authState is AuthInitial) {
            return null; // Stay on splash screen
          } else if (authState is Authenticated) {
            final deepLink = _getStoredDeepLink();
            if (deepLink != null && deepLink.isNotEmpty) {
              _clearStoredDeepLink();
              return deepLink;
            }
            return '/home';
          } else {
            return '/login';
          }
        }
        
        // Store deep link attempts during loading
        if ((authState is AuthLoading || authState is AuthInitial) && 
            currentPath != '/' && 
            !currentPath.startsWith('/login') && 
            !currentPath.startsWith('/signup')) {
          _storeDeepLink(currentPath);
          return '/'; // Redirect to splash screen
        }

        // Handle authenticated users
        if (authState is Authenticated) {
          if (currentPath.startsWith('/login') || currentPath.startsWith('/signup')) {
            final deepLink = _getStoredDeepLink();
            if (deepLink != null && deepLink.isNotEmpty) {
              _clearStoredDeepLink();
              return deepLink;
            }
            return '/home';
          }
          return null; // Allow authenticated users to access their routes
        }

        // Handle unauthenticated users
        if (authState is Unauthenticated) {
          if (currentPath.startsWith('/login') || currentPath.startsWith('/signup')) {
            return null; // Allow access to auth pages
          }
          
          // Store attempted path and redirect to login
          if (!currentPath.startsWith('/join') && currentPath != '/') {
            _storeDeepLink(currentPath);
          }
          return '/login';
        }

        return null;
      },
      routes: [
        // Root/Splash route
        GoRoute(
          path: '/',
          builder: (context, state) => FullscreenLoader(),
        ),
        // Auth routes (no shell)
        GoRoute(
          path: '/login/:code',
          builder: (context, state) => LoginPage(
            code: state.pathParameters['code'],
          ),
        ),
        GoRoute(
          name: 'login',
          path: '/login',
          builder: (context, state) => LoginPage(),
        ),
        GoRoute(
          path: '/signup/:code',
          builder: (context, state) => SignUpPage(
            code: state.pathParameters['code'],
          ),
        ),
        GoRoute(
          name: 'signup',
          path: '/signup',
          builder: (context, state) => const SignUpPage(),
        ),

        // Join routes (no shell)
        GoRoute(
          path: '/join/:joinCode/:code',
          builder: (context, state) => JoinPage(
            joinCode: state.pathParameters['joinCode'],
            code: state.pathParameters['code'],
          ),
        ),
        GoRoute(
          path: '/join/:joinCode',
          builder: (context, state) => JoinPage(
            joinCode: state.pathParameters['joinCode'],
          ),
        ),
        GoRoute(
          path: '/join',
          builder: (context, state) => const JoinPage(),
        ),
        
        // Main shell route
        ShellRoute(
          builder: (context, state, child) {
            final currentPath = state.uri.toString();
            
            // Bypass MainLayout for standalone pages
            if (standaloneRoutes.contains(currentPath)) {
              return child;
            }
            
            return MainLayout(child: child);
          },
          routes: [
            GoRoute(
              path: '/',
              redirect: (_, state) {
                return '/home';
              },
            ),
          
            // Content routes (nested shell)
            ShellRoute(
              builder: (context, state, child) {
                return HomeLayout(child: child);
              },
              routes: [
                GoRoute(
                  path: '/home',
                  builder: (context, state) => HomePage(),
                ),
              ],
            ),

            // Settings routes (nested shell)
            ShellRoute(
              builder: (context, state, child) {
                return SettingsLayout(child: child);
              },
              routes: [
                GoRoute(
                  path: '/settings',
                  builder: (context, state) => AboutYouPage(),
                  routes: [
                    GoRoute(
                      path: '/about-you',
                      builder: (context, state) => const AboutYouPage(),
                    ),
                    GoRoute(
                      path: '/appearance',
                      builder: (context, state) => const AppearancePage(),
                    ),

                  ]
                ),
              ],
            ),

            // Membership routes (nested shell)
            ShellRoute(
              builder: (context, state, child) {
                return SettingsLayout(child: child);
              },
              routes: [
                GoRoute(
                  path: '/membership',
                  builder: (context, state) {
                    final shouldRefresh = state.queryParameters['refresh'] == 'true';
                    return MembershipHomeScreen(key: shouldRefresh ? UniqueKey() : null);
                  },
                  routes: [
                    GoRoute(
                      path: '/subscribe',
                      builder: (context, state) => const SubscribeScreen(),
                    ),
                    GoRoute(
                      path: '/success',
                      builder: (context, state) {
                        final sessionId = state.queryParameters['session_id'];
                        return CheckoutReturnScreen(status: 'success', sessionId: sessionId);
                      },
                    ),
                    GoRoute(
                      path: '/cancel',
                      builder: (context, state) => const CheckoutReturnScreen(status: 'cancel'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // Deep link storage methods
  static void _storeDeepLink(String path) {
    _prefs.setString('deep_link', path);
  }
  
  static String? _getStoredDeepLink() {
    return _prefs.getString('deep_link');
  }
  
  static void _clearStoredDeepLink() {
    _prefs.remove('deep_link');
  }
}