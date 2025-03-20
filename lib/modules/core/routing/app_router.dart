import 'package:app/modules/auth/blocs/auth_bloc.dart';
import 'package:app/modules/auth/blocs/auth_state.dart';
import 'package:app/modules/auth/pages/join_page.dart';
import 'package:app/modules/auth/pages/login_page.dart';
import 'package:app/modules/auth/pages/signup_page.dart';
import 'package:app/modules/core/di/service_locator.dart';
import 'package:app/modules/core/routing/router_observer.dart';
import 'package:app/modules/core/ui/pages/main_layout.dart';
import 'package:app/modules/core/routing/router_refresh_stream_group.dart';
import 'package:app/modules/home/pages/home_layout.dart';
import 'package:app/modules/home/pages/home_page.dart';
import 'package:app/modules/user/repositories/user_settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app/modules/onboarding/pages/onboarding_page.dart';
import 'package:app/modules/settings/pages/settings_layout.dart';
import 'package:app/modules/settings/pages/about_you_page.dart';
import 'package:app/modules/settings/pages/appearance_page.dart';

class AppRouter {
  static GoRouter setupRouter(BuildContext context) {
    final authBloc = sl<AuthBloc>();
    final settings = sl<UserSettingsRepository>();

    // Define standalone routes that bypass MainLayout
    final standaloneRoutes = {'/login', '/signup', '/start', '/join'};

    return GoRouter(
      debugLogDiagnostics: false,
      initialLocation: '/login',
      observers: [RouterObserver()],
      // Only refresh on auth changes, org changes, or initial settings load
      refreshListenable: GoRouterRefreshStreamGroup([
        authBloc.stream,
        settings.initialSettingsLoaded,
      ]),
      redirect: (context, state) {
        final authState = authBloc.state;
        final currentPath = state.uri.toString();
        final currentSettings = settings.currentSettings;
        
        print('Router Redirect - Current URI: $currentPath');

        // Don't redirect while loading or checking initial session
        if (authState is AuthLoading) {
          return null;
        }

        // Handle authenticated state
        if (authState is Authenticated) {

          // TODO: Always redirect to onboarding if not completed
          // if (!authState.userData.onboardingCompleted && !currentPath.startsWith('/join')) {
          //   if (currentPath != '/start') {
          //     print('Router Redirect - Redirecting to onboarding');
          //     return '/start';
          //   }
          //   return null;
          // }

          // If onboarding is complete and user is on auth or onboarding pages, 
          // redirect to default agent view
          if (currentPath.startsWith('/login') || 
              currentPath.startsWith('/signup') || 
              currentPath.startsWith('/start') ||
              currentPath.startsWith('/home')) {

            print('Router Redirect - Redirecting to main view');
            return '/home';
          }

          return null;
        }

        // Handle unauthenticated state
        if (authState is Unauthenticated || authState is AuthInitial) {
          // Allow access to login and signup pages
          if (currentPath.startsWith('/login') || 
              currentPath.startsWith('/signup') || 
              currentPath.startsWith('/join')) {
            return null;
          }
          
          // Redirect all other paths to login
          print('Router Redirect - Unauthenticated, redirecting to login');
          return '/login';
        }

        return null;
      },
      routes: [
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
                  // routes: [
                  //   GoRoute(
                  //     path: ':sourceId',
                  //     builder: (context, state) => SourceDetailsPage(
                  //       sourceId: state.pathParameters['sourceId']!,
                  //     ),
                  //   ),
                  // ],
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
                    // GoRoute(
                    //   path: '/preferences',
                    //   builder: (context, state) => const PreferencesPage(),
                    // ),
                    // GoRoute(
                    //   path: '/groups',
                    //   builder: (context, state) => const GroupsPage(),
                    // ),
                    // GoRoute(
                    //   path: '/notifications',
                    //   builder: (context, state) => const NotificationsPage(),
                    // ),
                    // GoRoute(
                    //   path: '/integrations',
                    //   builder: (context, state) => const IntegrationsPage(),
                    // ),
                    // GoRoute(
                    //   path: '/billing',
                    //   builder: (context, state) => const BillingPage(),
                    // ),
                    // GoRoute(
                    //   path: '/security',
                    //   builder: (context, state) => const SecurityPage(),
                    // ),
                    GoRoute(
                      path: '/appearance',
                      builder: (context, state) => const AppearancePage(),
                    ),

                  ]
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}