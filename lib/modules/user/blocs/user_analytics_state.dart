import 'package:app/modules/user/models/user_analytics.dart';

abstract class UserAnalyticsState {}

class UserAnalyticsInitial extends UserAnalyticsState {}

class UserAnalyticsLoading extends UserAnalyticsState {}

class UserAnalyticsLoaded extends UserAnalyticsState {
  final UserAnalytics analytics;
  UserAnalyticsLoaded(this.analytics);
}

class UserAnalyticsError extends UserAnalyticsState {
  final String message;
  UserAnalyticsError(this.message);
} 