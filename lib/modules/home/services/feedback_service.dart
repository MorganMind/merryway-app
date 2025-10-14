import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../config/environment.dart';

class HomeFeedbackService {
  final Dio dio = GetIt.I<Dio>();
  final String baseUrl = Environment.apiUrl;

  Future<void> submitFeedback({
    required String suggestionId,
    required String activityId,
    required String action, // "accept", "skip", "complete"
    int? rating,
    String? notes,
  }) async {
    try {
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
    } catch (e) {
      throw 'Failed to submit feedback: $e';
    }
  }

  Future<void> logCompletion({
    required String suggestionId,
    required String activityId,
    required int rating,
    String? notes,
  }) async {
    await submitFeedback(
      suggestionId: suggestionId,
      activityId: activityId,
      action: 'complete',
      rating: rating,
      notes: notes,
    );
  }
}

