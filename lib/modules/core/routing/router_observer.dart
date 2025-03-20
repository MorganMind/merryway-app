import 'package:app/modules/core/blocs/layout_bloc.dart';
import 'package:app/modules/core/blocs/layout_event.dart';
import 'package:app/modules/core/di/service_locator.dart';
import 'package:flutter/material.dart';

class RouterObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final routeName = route.settings.name;
    if (routeName != null) {
      final layoutBloc = sl<LayoutBloc>();
      
      // Existing right panel logic
      layoutBloc.add(SetRightPanelForRoute(routeName));
      print('routeName: $routeName');
      // Add layout visibility logic
      if (routeName.startsWith('/agents')) {
        layoutBloc.add(SetSidebarVisibility(false)); 
        layoutBloc.add(SetHeaderVisibility(false));
        layoutBloc.add(SetMobileNavBarVisibility(false));
      } else if (routeName.startsWith('/chat/')) {
        layoutBloc.add(SetSidebarVisibility(false));
        layoutBloc.add(SetHeaderVisibility(false));
        layoutBloc.add(SetMobileNavBarVisibility(false));
      } else if (routeName.startsWith('/library')) {
        layoutBloc.add(SetSidebarVisibility(false)); 
        layoutBloc.add(SetHeaderVisibility(false));
        layoutBloc.add(SetMobileNavBarVisibility(false));
      } else {
        layoutBloc.add(SetSidebarVisibility(true));
        layoutBloc.add(SetHeaderVisibility(true));
        layoutBloc.add(SetMobileNavBarVisibility(true));
      }
    }
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute?.settings.name != null) {
      final layoutBloc = sl<LayoutBloc>();
      final routeName = previousRoute!.settings.name!;
      
      // Existing right panel logic
      layoutBloc.add(SetRightPanelForRoute(routeName));
      
      // Add layout visibility logic
      if (routeName.startsWith('/agents')) {
        layoutBloc.add(SetSidebarVisibility(false));
        layoutBloc.add(SetHeaderVisibility(true));
        layoutBloc.add(SetMobileNavBarVisibility(false));
      } else if (routeName.startsWith('/chat/')) {
        layoutBloc.add(SetSidebarVisibility(false));
        layoutBloc.add(SetHeaderVisibility(false));
        layoutBloc.add(SetMobileNavBarVisibility(false));
      } else {
        layoutBloc.add(SetSidebarVisibility(true));
        layoutBloc.add(SetHeaderVisibility(true));
        layoutBloc.add(SetMobileNavBarVisibility(true));
      }
    }
    super.didPop(route, previousRoute);
  }
}