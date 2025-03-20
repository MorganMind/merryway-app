import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

enum LayoutType {
  mobile,
  tablet,
  desktop,
}

class LayoutState extends Equatable {
  final bool isRightPanelVisible;
  final bool isNavigationBarExpanded;
  final LayoutType layoutType;
  final bool shouldShowHeader;
  final bool shouldShowSidebar;
  final bool shouldShowMobileNavBar;
  
  const LayoutState({
    this.isRightPanelVisible = true,
    this.isNavigationBarExpanded = true,
    this.layoutType = LayoutType.desktop,
    this.shouldShowHeader = true,
    this.shouldShowSidebar = true,
    this.shouldShowMobileNavBar = true,
  });
  
  factory LayoutState.initial() {
    return LayoutState(
      isRightPanelVisible: true,
      isNavigationBarExpanded: true,
      layoutType: kIsWeb ? LayoutType.desktop : LayoutType.mobile,
      shouldShowHeader: true,
      shouldShowSidebar: true,
      shouldShowMobileNavBar: true,
    );
  }
  
  LayoutState copyWith({
    bool? isRightPanelVisible,
    bool? isNavigationBarExpanded,
    LayoutType? layoutType,
    bool? shouldShowHeader,
    bool? shouldShowSidebar,
    bool? shouldShowMobileNavBar,
  }) {
    return LayoutState(
      isRightPanelVisible: isRightPanelVisible ?? this.isRightPanelVisible,
      isNavigationBarExpanded: isNavigationBarExpanded ?? this.isNavigationBarExpanded,
      layoutType: layoutType ?? this.layoutType,
      shouldShowHeader: shouldShowHeader ?? this.shouldShowHeader,
      shouldShowSidebar: shouldShowSidebar ?? this.shouldShowSidebar,
      shouldShowMobileNavBar: shouldShowMobileNavBar ?? this.shouldShowMobileNavBar,
    );
  }
  
  @override
  List<Object?> get props => [
    isRightPanelVisible, 
    isNavigationBarExpanded, 
    layoutType,
    shouldShowHeader,
    shouldShowSidebar,
    shouldShowMobileNavBar,
  ];
} 