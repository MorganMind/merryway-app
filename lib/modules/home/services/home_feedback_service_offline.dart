import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'offline_feedback_queue.dart';
import 'feedback_sync_service.dart';
import '../../../config/environment.dart';

/// Enhanced feedback service with offline support
class HomeFeedbackServiceOffline {
  final Dio dio = GetIt.I<Dio>();
  final FeedbackSyncService syncService = FeedbackSyncService();
  final String baseUrl = Environment.apiUrl;

  /// Initialize sync monitoring
  Future<void> initialize() async {
    await syncService.startSyncMonitor();
    
    // Try to sync any pending feedback from previous sessions
    final pendingCount = await OfflineFeedbackQueue.getQueueSize();
    if (pendingCount > 0) {
      print('📱 Found $pendingCount pending feedback items, syncing...');
      final result = await syncService.syncPendingFeedback();
      print('✅ Sync result: ${result.message}');
    }
  }

  /// Submit feedback with automatic offline fallback
  Future<FeedbackResult> submitFeedback({
    required String suggestionId,
    required String activityId,
    required String action,
    int? rating,
    String? notes,
  }) async {
    try {
      final isOnline = await syncService.isOnline();

      if (isOnline) {
        // Try immediate sync
        await dio.post(
          '$baseUrl/feedback/',
          data: {
            'suggestion_id': suggestionId,
            'activity_id': activityId,
            'action': action,
            if (rating != null) 'rating': rating,
            if (notes != null) 'notes': notes,
          },
        );

        return FeedbackResult(
          success: true,
          queued: false,
          message: 'Thanks for the feedback! 👍',
        );
      } else {
        // Queue for later sync
        await OfflineFeedbackQueue.addFeedback(
          suggestionId: suggestionId,
          activityId: activityId,
          action: action,
          rating: rating,
          notes: notes,
        );

        return FeedbackResult(
          success: true,
          queued: true,
          message: 'Saved offline - will sync when online 📱',
        );
      }
    } catch (e) {
      // Network error → fall back to queue
      await OfflineFeedbackQueue.addFeedback(
        suggestionId: suggestionId,
        activityId: activityId,
        action: action,
        rating: rating,
        notes: notes,
      );

      return FeedbackResult(
        success: true,
        queued: true,
        message: 'Queued for later: $e',
      );
    }
  }

  /// Mark activity complete with offline support
  Future<FeedbackResult> logCompletion({
    required String suggestionId,
    required String activityId,
    int? rating,
    String? notes,
  }) async {
    return submitFeedback(
      suggestionId: suggestionId,
      activityId: activityId,
      action: 'complete',
      rating: rating,
      notes: notes,
    );
  }

  /// Get pending feedback count
  Future<int> getPendingCount() async {
    return await OfflineFeedbackQueue.getQueueSize();
  }

  /// Manually trigger sync
  Future<SyncResult> syncNow() async {
    return await syncService.syncPendingFeedback();
  }
}

class FeedbackResult {
  final bool success;
  final bool queued;
  final String message;

  FeedbackResult({
    required this.success,
    required this.queued,
    required this.message,
  });
}

