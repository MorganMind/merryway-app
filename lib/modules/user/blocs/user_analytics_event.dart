abstract class UserAnalyticsEvent {}

class LoadUserAnalytics extends UserAnalyticsEvent {
  final String analyticsId;
  LoadUserAnalytics(this.analyticsId);
}

class RefreshUserAnalytics extends UserAnalyticsEvent {} 