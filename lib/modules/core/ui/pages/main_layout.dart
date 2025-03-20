import 'package:app/modules/auth/blocs/auth_bloc.dart';
import 'package:app/modules/auth/blocs/auth_state.dart';
import 'package:app/modules/core/di/service_locator.dart';
import 'package:app/modules/core/ui/widgets/main_header.dart';
import 'package:app/modules/core/ui/widgets/navigation_sidebar.dart';
import 'package:app/modules/settings/blocs/settings_bloc.dart';
import 'package:app/modules/tags/blocs/tags_bloc.dart';
import 'package:app/modules/user/repositories/user_settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/modules/core/blocs/layout_bloc.dart';
import 'package:app/modules/core/blocs/layout_state.dart';
import 'package:app/modules/core/ui/widgets/mobile_navigation_bar.dart';
import 'package:app/modules/core/ui/widgets/animated_header.dart';
import 'package:app/modules/core/ui/widgets/animated_sidebar.dart';
import 'package:go_router/go_router.dart';
import 'package:app/modules/core/theme/theme_extension.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  
  const MainLayout({
    required this.child,
    Key? key,
  }) : super(key: key); 

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {

  @override 
  Widget build(BuildContext context) {
    final colors = context.appTheme;
    
    return MultiBlocProvider(
      providers: [
        BlocProvider<TagsBloc>.value(
          value: sl<TagsBloc>(),
        ),
      
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) => previous != current,
        listener: (context, authState) {
          if (authState is Authenticated) {
            // Handle other auth-related tasks if needed
          }
        },
        child: BlocBuilder<LayoutBloc, LayoutState>(
          bloc: sl<LayoutBloc>(),
          builder: (context, state) {

            // Mobile layout
            if (state.layoutType == LayoutType.mobile) {
             
              final authState = context.watch<AuthBloc>().state; 
              final currentPath = GoRouterState.of(context).uri.path; 
              final isSettingsRoute = currentPath.startsWith('/settings');

              return Scaffold(
                body: Row(
                  children: [
                    // Animated Navigation Sidebar
                    AnimatedSidebar(
                      isVisible: state.shouldShowSidebar,
                      isLoading: false,
                    ),
                      
                    // Main Content Column
                    Expanded(
                      child: Column(
                        children: [
                          AnimatedHeader(
                            isVisible: state.shouldShowHeader || isSettingsRoute,
                          ),
                          Expanded(child: widget.child),
                        ],
                      ),
                    ),
                  ],
                ),
                bottomNavigationBar: authState is Authenticated && state.shouldShowMobileNavBar
                  ? MobileNavigationBar(userData: authState.userData) 
                  : null,
                  );
            }

            // Web layout
            final authState = context.watch<AuthBloc>().state;  // Get auth state from context
            final currentPath = GoRouterState.of(context).uri.path;
            final isSettingsRoute = currentPath.startsWith('/settings');

            if (authState is! Authenticated) {
              return Scaffold(
                backgroundColor: colors.background,
                body: Row(
                  children: [
                    const SizedBox(width: 60), // Placeholder for sidebar
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: colors.muted,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        margin: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            MainHeader(),
                            Expanded(child: widget.child),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Scaffold(
              backgroundColor: colors.background,
              body: Row(
                children: [
                  if (!isSettingsRoute)  // Only show sidebar if not in settings
                    NavigationSidebar(),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: colors.muted,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          if (!isSettingsRoute)  // Only show header if not in settings
                            MainHeader(),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  flex: state.isRightPanelVisible ? 2 : 1,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: colors.background,
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: const Radius.circular(16),
                                        bottomRight: !state.isRightPanelVisible 
                                          ? const Radius.circular(16) 
                                          : Radius.zero,
                                      ),
                                    ),
                                    child: widget.child,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}