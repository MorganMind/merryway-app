import 'package:app/modules/core/blocs/layout_event.dart';
import 'package:app/modules/core/blocs/layout_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LayoutBloc extends Bloc<LayoutEvent, LayoutState> {
  LayoutBloc() : super(const LayoutState()) {
    on<ToggleRightPanel>(_onToggleRightPanel);
    on<SetRightPanelForRoute>(_onSetRightPanelForRoute);
    on<ToggleNavigationBar>(_onToggleNavigationBar);
    on<UpdateLayoutType>(_onUpdateLayoutType);
    on<SetHeaderVisibility>(_onSetHeaderVisibility);
    on<SetSidebarVisibility>(_onSetSidebarVisibility);
    on<SetMobileNavBarVisibility>(_onSetMobileNavBarVisibility);
  }

  void _onToggleRightPanel(ToggleRightPanel event, Emitter<LayoutState> emit) {
    final newValue = event.isVisible ?? !state.isRightPanelVisible;
    emit(state.copyWith(isRightPanelVisible: newValue));
  }

  void _onSetRightPanelForRoute(SetRightPanelForRoute event, Emitter<LayoutState> emit) {
    final shouldShowPanel = event.route != '/home';
    emit(state.copyWith(isRightPanelVisible: shouldShowPanel));
  }

  void _onToggleNavigationBar(ToggleNavigationBar event, Emitter<LayoutState> emit) {
    final newValue = event.isExpanded ?? !state.isNavigationBarExpanded;
    emit(state.copyWith(isNavigationBarExpanded: newValue));
  }

  void _onUpdateLayoutType(UpdateLayoutType event, Emitter<LayoutState> emit) {
    final newLayoutType = event.width < 600 
        ? LayoutType.mobile 
        : event.width < 1200 
            ? LayoutType.tablet 
            : LayoutType.desktop;

    if (state.layoutType == LayoutType.mobile && newLayoutType != LayoutType.mobile) {
      emit(state.copyWith(
        layoutType: newLayoutType,
        shouldShowHeader: true,
        shouldShowSidebar: true,
        isNavigationBarExpanded: true,
      ));
    } else {
      emit(state.copyWith(
        layoutType: newLayoutType,
        isNavigationBarExpanded: newLayoutType != LayoutType.mobile,
        isRightPanelVisible: newLayoutType != LayoutType.mobile,
      ));
    }
  }

  void _onSetHeaderVisibility(SetHeaderVisibility event, Emitter<LayoutState> emit) {
    emit(state.copyWith(shouldShowHeader: event.isVisible));
  }

  void _onSetSidebarVisibility(SetSidebarVisibility event, Emitter<LayoutState> emit) {
    emit(state.copyWith(shouldShowSidebar: event.isVisible));
  }

  void _onSetMobileNavBarVisibility(SetMobileNavBarVisibility event, Emitter<LayoutState> emit) {
    emit(state.copyWith(shouldShowMobileNavBar: event.isVisible));
  }
} 