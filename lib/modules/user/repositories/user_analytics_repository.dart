import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app/modules/user/models/user_analytics.dart';
import 'package:app/modules/core/di/service_locator.dart';

class UserAnalyticsRepository {
  final SupabaseClient _supabase = sl<SupabaseClient>();
  StreamController<UserAnalytics> _controller = StreamController<UserAnalytics>.broadcast();
  UserAnalytics _cachedAnalytics = UserAnalytics.empty;
  StreamSubscription? _analyticsSubscription;

  // Expose stream of analytics updates
  Stream<UserAnalytics> get analytics => _controller.stream;

  // Synchronous getter for cached analytics
  UserAnalytics? get currentAnalytics => _cachedAnalytics;

  // Initialize the stream for a specific user
  Future<void> initializeAnalyticsStream(String analyticsId) async {

    // Reopen the controller if it is closed
    if (_controller.isClosed) {
      _controller = StreamController<UserAnalytics>.broadcast();
    }

    // Cancel any existing subscription
    await _analyticsSubscription?.cancel();

    try {
      // Get initial analytics data
      final data = await _supabase
          .from('user_analytics')
          .select()
          .eq('id', analyticsId)
          .single();
      
      final analytics = UserAnalytics.fromJson(data);
      _cachedAnalytics = analytics;
      _controller.add(analytics);

      // Subscribe to realtime updates
      _analyticsSubscription = _supabase
          .from('user_analytics')
          .stream(primaryKey: ['id'])
          .eq('id', analyticsId)
          .map((event) => UserAnalytics.fromJson(event.first))
          .listen(
            (analytics) {
              _cachedAnalytics = analytics;
              _controller.add(analytics);
            },
            onError: (error) {
              print('UserAnalyticsRepository: Error in analytics stream: $error');
            },
          );
    } catch (e) {
      print('UserAnalyticsRepository: Error initializing analytics stream: $e');
      _controller.addError(e);
    }
  }

  // Clean up resources
  Future<void> dispose() async {
    _cachedAnalytics = UserAnalytics.empty;
    await _analyticsSubscription?.cancel();
    await _controller.close();
  }
} 