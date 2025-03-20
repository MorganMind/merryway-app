import 'package:equatable/equatable.dart';

abstract class LayoutEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ToggleRightPanel extends LayoutEvent {
  final bool? isVisible;
  
  ToggleRightPanel([this.isVisible]);
  
  @override
  List<Object?> get props => [isVisible];
}

class SetRightPanelForRoute extends LayoutEvent {
  final String route;
  
  SetRightPanelForRoute(this.route);
  
  @override
  List<Object?> get props => [route];
}

class ToggleNavigationBar extends LayoutEvent {
  final bool? isExpanded;
  
  ToggleNavigationBar([this.isExpanded]);
  
  @override
  List<Object?> get props => [isExpanded];
}

class UpdateLayoutType extends LayoutEvent {
  final double width;
  
  UpdateLayoutType(this.width);
  
  @override
  List<Object?> get props => [width];
}

class SetHeaderVisibility extends LayoutEvent {
  final bool isVisible;
  
  SetHeaderVisibility(this.isVisible);
  
  @override
  List<Object?> get props => [isVisible];
}

class SetSidebarVisibility extends LayoutEvent {
  final bool isVisible;
  
  SetSidebarVisibility(this.isVisible);
  
  @override
  List<Object?> get props => [isVisible];
}

class SetMobileNavBarVisibility extends LayoutEvent {
  final bool isVisible;

  SetMobileNavBarVisibility(this.isVisible);

  @override
  List<Object?> get props => [isVisible];
} 