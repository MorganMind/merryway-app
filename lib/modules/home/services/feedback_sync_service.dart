import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'offline_feedback_queue.dart';
import '../../../config/environment.dart';

class SyncResult {
  final bool success;
  final int synced;
  final int failed;
  final String message;

  SyncResult({
    required this.success,
    required this.synced,
    required this.failed,
    required this.message,
  });
}

class FeedbackSyncService {
  final Dio dio = GetIt.I<Dio>();
  final Connectivity connectivity = Connectivity();
  final String baseUrl = Environment.apiUrl;

  /// Monitor connectivity and sync when online
  Future<void> startSyncMonitor() async {
    connectivity.onConnectivityChanged.listen((ConnectivityResult result) async {
      if (result != ConnectivityResult.none) {
        await syncPendingFeedback();
      }
    });
  }

  /// Try to sync all pending feedback
  Future<SyncResult> syncPendingFeedback() async {
    final pending = await OfflineFeedbackQueue.getPendingFeedback();

    if (pending.isEmpty) {
      return SyncResult(
        success: true,
        synced: 0,
        failed: 0,
        message: 'No pending feedback',
      );
    }

    int synced = 0;
    int failed = 0;

    for (final item in pending) {
      try {
        await dio.post(
          '$baseUrl/feedback/',
          data: {
            'suggestion_id': item.suggestionId,
            'activity_id': item.activityId,
            'action': item.action,
            if (item.rating != null) 'rating': item.rating,
            if (item.notes != null) 'notes': item.notes,
          },
        );

        await OfflineFeedbackQueue.markSynced(item.id);
        synced++;
      } catch (e) {
        // Log but continue with next item
        print('Failed to sync feedback ${item.id}: $e');
        failed++;
      }
    }

    // Clean up synced items
    await OfflineFeedbackQueue.clearSynced();

    return SyncResult(
      success: failed == 0,
      synced: synced,
      failed: failed,
      message: 'Synced $synced, failed $failed',
    );
  }

  /// Check if currently online
  Future<bool> isOnline() async {
    final result = await connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
}

