import 'dart:async';

import 'package:app/modules/core/di/service_locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/modules/user/models/user_analytics.dart';
import 'user_analytics_event.dart';
import 'user_analytics_state.dart';
import 'package:app/modules/user/repositories/user_analytics_repository.dart';

class UserAnalyticsBloc extends Bloc<UserAnalyticsEvent, UserAnalyticsState> {
  final UserAnalyticsRepository _analyticsRepository = sl<UserAnalyticsRepository>();
  StreamSubscription? _analyticsSubscription;

  UserAnalyticsBloc() : super(UserAnalyticsInitial()) {
    on<LoadUserAnalytics>(_onLoadUserAnalytics);
    on<RefreshUserAnalytics>(_onRefreshUserAnalytics);
  }

  Future<void> _onLoadUserAnalytics(
    LoadUserAnalytics event,
    Emitter<UserAnalyticsState> emit,
  ) async {
    emit(UserAnalyticsLoading());
    
    try {
      // Initialize analytics stream
      await _analyticsRepository.initializeAnalyticsStream(event.analyticsId);
      
      // Subscribe to analytics updates using emit.forEach
      await emit.forEach(
        _analyticsRepository.analytics,
        onData: (UserAnalytics analytics) => UserAnalyticsLoaded(analytics),
        onError: (error, stackTrace) {
          print('UserAnalyticsBloc: Error in analytics stream: $error');
          return UserAnalyticsError(error.toString());
        },
      );
    } catch (e) {
      emit(UserAnalyticsError(e.toString()));
    }
  }

  Future<void> _onRefreshUserAnalytics(
    RefreshUserAnalytics event,
    Emitter<UserAnalyticsState> emit,
  ) async {
    // No need for manual refresh as the repository handles real-time updates
    // But we could add refresh logic here if needed
  }

  @override
  Future<void> close() {
    _analyticsSubscription?.cancel();
    return super.close();
  }
} 