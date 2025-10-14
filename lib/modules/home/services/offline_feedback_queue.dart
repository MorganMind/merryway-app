import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FeedbackItem {
  final String id;
  final String suggestionId;
  final String activityId;
  final String action;
  final int? rating;
  final String? notes;
  final DateTime createdAt;
  bool synced;

  FeedbackItem({
    required this.id,
    required this.suggestionId,
    required this.activityId,
    required this.action,
    this.rating,
    this.notes,
    required this.createdAt,
    this.synced = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'suggestion_id': suggestionId,
        'activity_id': activityId,
        'action': action,
        'rating': rating,
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
        'synced': synced,
      };

  factory FeedbackItem.fromJson(Map<String, dynamic> json) {
    return FeedbackItem(
      id: json['id'],
      suggestionId: json['suggestion_id'],
      activityId: json['activity_id'],
      action: json['action'],
      rating: json['rating'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      synced: json['synced'] ?? false,
    );
  }
}

class OfflineFeedbackQueue {
  static const String _queueKey = 'feedback_queue';

  /// Add feedback to local queue
  static Future<void> addFeedback({
    required String suggestionId,
    required String activityId,
    required String action,
    int? rating,
    String? notes,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final queue = await _getQueue(prefs);

    final item = FeedbackItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      suggestionId: suggestionId,
      activityId: activityId,
      action: action,
      rating: rating,
      notes: notes,
      createdAt: DateTime.now(),
      synced: false,
    );

    queue.add(item);
    await _saveQueue(prefs, queue);
  }

  /// Get all pending feedback
  static Future<List<FeedbackItem>> getPendingFeedback() async {
    final prefs = await SharedPreferences.getInstance();
    final queue = await _getQueue(prefs);
    return queue.where((item) => !item.synced).toList();
  }

  /// Mark feedback as synced
  static Future<void> markSynced(String feedbackId) async {
    final prefs = await SharedPreferences.getInstance();
    final queue = await _getQueue(prefs);

    for (var item in queue) {
      if (item.id == feedbackId) {
        item.synced = true;
        break;
      }
    }

    await _saveQueue(prefs, queue);
  }

  /// Clear all synced feedback
  static Future<void> clearSynced() async {
    final prefs = await SharedPreferences.getInstance();
    final queue = await _getQueue(prefs);
    queue.removeWhere((item) => item.synced);
    await _saveQueue(prefs, queue);
  }

  /// Get queue size
  static Future<int> getQueueSize() async {
    final queue = await getPendingFeedback();
    return queue.length;
  }

  // Helper methods
  static Future<List<FeedbackItem>> _getQueue(SharedPreferences prefs) async {
    final jsonStr = prefs.getString(_queueKey) ?? '[]';
    final List<dynamic> jsonList = jsonDecode(jsonStr);
    return jsonList.map((item) => FeedbackItem.fromJson(item)).toList();
  }

  static Future<void> _saveQueue(
    SharedPreferences prefs,
    List<FeedbackItem> queue,
  ) async {
    final jsonList = queue.map((item) => item.toJson()).toList();
    await prefs.setString(_queueKey, jsonEncode(jsonList));
  }
}

