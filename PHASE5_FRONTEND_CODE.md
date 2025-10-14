# Phase 5: Frontend Code Files

## File: `lib/modules/family/models/learning_models.dart`

```dart
import 'package:equatable/equatable.dart';

class ContextSnapshot extends Equatable {
  final String timeBucket;
  final String? placeLabel;
  final String weather;
  final int? durationMinutes;
  final String dayType;
  final String ageMix;
  final List<String> participantIds;
  final String? customPrompt;

  const ContextSnapshot({
    required this.timeBucket,
    this.placeLabel,
    required this.weather,
    this.durationMinutes,
    required this.dayType,
    required this.ageMix,
    required this.participantIds,
    this.customPrompt,
  });

  @override
  List<Object?> get props => [
        timeBucket,
        placeLabel,
        weather,
        durationMinutes,
        dayType,
        ageMix,
        participantIds,
        customPrompt,
      ];

  Map<String, dynamic> toJson() => {
        'time_bucket': timeBucket,
        'place_label': placeLabel,
        'weather': weather,
        'duration_minutes': durationMinutes,
        'day_type': dayType,
        'age_mix': ageMix,
        'participant_ids': participantIds,
        'custom_prompt': customPrompt,
      };

  factory ContextSnapshot.fromJson(Map<String, dynamic> json) =>
      ContextSnapshot(
        timeBucket: json['time_bucket'] as String,
        placeLabel: json['place_label'] as String?,
        weather: json['weather'] as String,
        durationMinutes: json['duration_minutes'] as int?,
        dayType: json['day_type'] as String,
        ageMix: json['age_mix'] as String,
        participantIds: List<String>.from(json['participant_ids'] as List),
        customPrompt: json['custom_prompt'] as String?,
      );
}

class CandidateActivity extends Equatable {
  final String activityId;
  final String title;
  final String? description;
  final double baseScore;
  final Map<String, double> featureScores;
  final double finalScore;
  final int rank;
  final List<String> tags;
  final int? durationMinutesMin;
  final int? durationMinutesMax;
  final double? explorationBonus;
  final double? diversityPenalty;

  const CandidateActivity({
    required this.activityId,
    required this.title,
    this.description,
    required this.baseScore,
    required this.featureScores,
    required this.finalScore,
    required this.rank,
    this.tags = const [],
    this.durationMinutesMin,
    this.durationMinutesMax,
    this.explorationBonus,
    this.diversityPenalty,
  });

  @override
  List<Object?> get props => [
        activityId,
        title,
        description,
        baseScore,
        featureScores,
        finalScore,
        rank,
        tags,
        durationMinutesMin,
        durationMinutesMax,
        explorationBonus,
        diversityPenalty,
      ];

  factory CandidateActivity.fromJson(Map<String, dynamic> json) =>
      CandidateActivity(
        activityId: json['activity_id'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        baseScore: (json['base_score'] as num).toDouble(),
        featureScores: Map<String, double>.from(
          (json['feature_scores'] as Map).map(
            (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
          ),
        ),
        finalScore: (json['final_score'] as num).toDouble(),
        rank: json['rank'] as int,
        tags: json['tags'] != null
            ? List<String>.from(json['tags'] as List)
            : [],
        durationMinutesMin: json['duration_minutes_min'] as int?,
        durationMinutesMax: json['duration_minutes_max'] as int?,
        explorationBonus: json['exploration_bonus'] != null
            ? (json['exploration_bonus'] as num).toDouble()
            : null,
        diversityPenalty: json['diversity_penalty'] != null
            ? (json['diversity_penalty'] as num).toDouble()
            : null,
      );
}

class SuggestionResponseV2 extends Equatable {
  final List<CandidateActivity> suggestions;
  final String? suggestionLogId;
  final String rationale;

  const SuggestionResponseV2({
    required this.suggestions,
    this.suggestionLogId,
    required this.rationale,
  });

  @override
  List<Object?> get props => [suggestions, suggestionLogId, rationale];

  factory SuggestionResponseV2.fromJson(Map<String, dynamic> json) =>
      SuggestionResponseV2(
        suggestions: (json['suggestions'] as List)
            .map((s) => CandidateActivity.fromJson(s as Map<String, dynamic>))
            .toList(),
        suggestionLogId: json['suggestion_log_id'] as String?,
        rationale: json['rationale'] as String,
      );
}

enum EffortLevel { low, medium, high }

enum MessLevel { low, medium, high }

class ExperienceReviewEnhanced extends Equatable {
  final String experienceId;
  final int rating;
  final String? notes;
  final int? actualDurationMinutes;
  final EffortLevel? actualEffortLevel;
  final MessLevel? actualMessLevel;
  final int? contextMatchRating;
  final String? photoUrl;
  final String? photoLocalPath;
  final bool offlineQueued;

  const ExperienceReviewEnhanced({
    required this.experienceId,
    required this.rating,
    this.notes,
    this.actualDurationMinutes,
    this.actualEffortLevel,
    this.actualMessLevel,
    this.contextMatchRating,
    this.photoUrl,
    this.photoLocalPath,
    this.offlineQueued = false,
  });

  @override
  List<Object?> get props => [
        experienceId,
        rating,
        notes,
        actualDurationMinutes,
        actualEffortLevel,
        actualMessLevel,
        contextMatchRating,
        photoUrl,
        photoLocalPath,
        offlineQueued,
      ];

  Map<String, dynamic> toJson() => {
        'experience_id': experienceId,
        'rating': rating,
        'notes': notes,
        'actual_duration_minutes': actualDurationMinutes,
        'actual_effort_level': actualEffortLevel?.name,
        'actual_mess_level': actualMessLevel?.name,
        'context_match_rating': contextMatchRating,
        'photo_url': photoUrl,
        'photo_local_path': photoLocalPath,
        'offline_queued': offlineQueued,
      };

  factory ExperienceReviewEnhanced.fromJson(Map<String, dynamic> json) =>
      ExperienceReviewEnhanced(
        experienceId: json['experience_id'] as String,
        rating: json['rating'] as int,
        notes: json['notes'] as String?,
        actualDurationMinutes: json['actual_duration_minutes'] as int?,
        actualEffortLevel: json['actual_effort_level'] != null
            ? EffortLevel.values.firstWhere(
                (e) => e.name == json['actual_effort_level'],
              )
            : null,
        actualMessLevel: json['actual_mess_level'] != null
            ? MessLevel.values.firstWhere(
                (e) => e.name == json['actual_mess_level'],
              )
            : null,
        contextMatchRating: json['context_match_rating'] as int?,
        photoUrl: json['photo_url'] as String?,
        photoLocalPath: json['photo_local_path'] as String?,
        offlineQueued: json['offline_queued'] as bool? ?? false,
      );
}

class LearningMetrics extends Equatable {
  final double acceptanceRate;
  final double acceptanceRateDelta;
  final double completionRate;
  final double avgRating;
  final int? timeToFirstGoodSuggestionSeconds;
  final double wishbookSourcedPercent;
  final int totalSuggestionsShown;
  final int totalAccepted;
  final int totalCompleted;
  final List<ActivityStats> topActivities;

  const LearningMetrics({
    required this.acceptanceRate,
    required this.acceptanceRateDelta,
    required this.completionRate,
    required this.avgRating,
    this.timeToFirstGoodSuggestionSeconds,
    required this.wishbookSourcedPercent,
    required this.totalSuggestionsShown,
    required this.totalAccepted,
    required this.totalCompleted,
    required this.topActivities,
  });

  @override
  List<Object?> get props => [
        acceptanceRate,
        acceptanceRateDelta,
        completionRate,
        avgRating,
        timeToFirstGoodSuggestionSeconds,
        wishbookSourcedPercent,
        totalSuggestionsShown,
        totalAccepted,
        totalCompleted,
        topActivities,
      ];

  factory LearningMetrics.fromJson(Map<String, dynamic> json) =>
      LearningMetrics(
        acceptanceRate: (json['acceptance_rate'] as num).toDouble(),
        acceptanceRateDelta: (json['acceptance_rate_delta'] as num).toDouble(),
        completionRate: (json['completion_rate'] as num).toDouble(),
        avgRating: (json['avg_rating'] as num).toDouble(),
        timeToFirstGoodSuggestionSeconds:
            json['time_to_first_good_suggestion_seconds'] as int?,
        wishbookSourcedPercent:
            (json['wishbook_sourced_percent'] as num).toDouble(),
        totalSuggestionsShown: json['total_suggestions_shown'] as int,
        totalAccepted: json['total_accepted'] as int,
        totalCompleted: json['total_completed'] as int,
        topActivities: (json['top_activities'] as List)
            .map((a) => ActivityStats.fromJson(a as Map<String, dynamic>))
            .toList(),
      );
}

class ActivityStats extends Equatable {
  final String activityId;
  final int timesShown;
  final int timesChosen;
  final int timesCompleted;
  final double? avgRating;
  final double? successRate;

  const ActivityStats({
    required this.activityId,
    required this.timesShown,
    required this.timesChosen,
    required this.timesCompleted,
    this.avgRating,
    this.successRate,
  });

  @override
  List<Object?> get props => [
        activityId,
        timesShown,
        timesChosen,
        timesCompleted,
        avgRating,
        successRate,
      ];

  factory ActivityStats.fromJson(Map<String, dynamic> json) => ActivityStats(
        activityId: json['activity_id'] as String,
        timesShown: json['times_shown'] as int,
        timesChosen: json['times_chosen'] as int,
        timesCompleted: json['times_completed'] as int,
        avgRating: json['avg_rating'] != null
            ? (json['avg_rating'] as num).toDouble()
            : null,
        successRate: json['success_rate'] != null
            ? (json['success_rate'] as num).toDouble()
            : null,
      );
}

class OfflineReviewQueueItem extends Equatable {
  final String id;
  final String experienceId;
  final Map<String, dynamic> reviewData;
  final String? photoLocalPath;
  final String idempotencyKey;
  final bool synced;
  final DateTime? syncAttemptedAt;
  final String? syncError;

  const OfflineReviewQueueItem({
    required this.id,
    required this.experienceId,
    required this.reviewData,
    this.photoLocalPath,
    required this.idempotencyKey,
    required this.synced,
    this.syncAttemptedAt,
    this.syncError,
  });

  @override
  List<Object?> get props => [
        id,
        experienceId,
        reviewData,
        photoLocalPath,
        idempotencyKey,
        synced,
        syncAttemptedAt,
        syncError,
      ];

  Map<String, dynamic> toJson() => {
        'id': id,
        'experience_id': experienceId,
        'review_data': reviewData,
        'photo_local_path': photoLocalPath,
        'idempotency_key': idempotencyKey,
        'synced': synced,
        'sync_attempted_at': syncAttemptedAt?.toIso8601String(),
        'sync_error': syncError,
      };

  factory OfflineReviewQueueItem.fromJson(Map<String, dynamic> json) =>
      OfflineReviewQueueItem(
        id: json['id'] as String,
        experienceId: json['experience_id'] as String,
        reviewData: Map<String, dynamic>.from(json['review_data'] as Map),
        photoLocalPath: json['photo_local_path'] as String?,
        idempotencyKey: json['idempotency_key'] as String,
        synced: json['synced'] as bool,
        syncAttemptedAt: json['sync_attempted_at'] != null
            ? DateTime.parse(json['sync_attempted_at'] as String)
            : null,
        syncError: json['sync_error'] as String?,
      );
}
```

## File: `lib/modules/family/services/learning_api_service.dart`

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/learning_models.dart';

class LearningApiService {
  final String baseUrl;
  final String Function() getToken;

  LearningApiService({
    required this.baseUrl,
    required this.getToken,
  });

  Future<SuggestionResponseV2?> generateSuggestionsV2({
    required String householdId,
    required String podId,
    required ContextSnapshot context,
    int limit = 5,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/suggestions/v2/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${getToken()}',
        },
        body: jsonEncode({
          'household_id': householdId,
          'pod_id': podId,
          'context': context.toJson(),
          'limit': limit,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SuggestionResponseV2.fromJson(data);
      } else {
        print('Failed to generate suggestions: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error generating suggestions: $e');
      return null;
    }
  }

  Future<bool> submitReviewV2({
    required String experienceId,
    String? suggestionLogId,
    required ExperienceReviewEnhanced review,
    required String householdId,
    String? podId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reviews/v2/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${getToken()}',
        },
        body: jsonEncode({
          'experience_id': experienceId,
          'suggestion_log_id': suggestionLogId,
          'rating': review.rating,
          'notes': review.notes,
          'actual_duration_minutes': review.actualDurationMinutes,
          'actual_effort_level': review.actualEffortLevel?.name,
          'actual_mess_level': review.actualMessLevel?.name,
          'context_match_rating': review.contextMatchRating,
          'photo_url': review.photoUrl,
          'household_id': householdId,
          'pod_id': podId,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error submitting review: $e');
      return false;
    }
  }

  Future<String?> queueOfflineReview({
    required String householdId,
    required String experienceId,
    required Map<String, dynamic> reviewData,
    String? photoLocalPath,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reviews/offline/queue/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${getToken()}',
        },
        body: jsonEncode({
          'household_id': householdId,
          'experience_id': experienceId,
          'review_data': reviewData,
          'photo_local_path': photoLocalPath,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['idempotency_key'] as String?;
      }
      return null;
    } catch (e) {
      print('Error queuing offline review: $e');
      return null;
    }
  }

  Future<Map<String, int>> syncOfflineReviews({
    required String householdId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reviews/offline/sync/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${getToken()}',
        },
        body: jsonEncode({
          'household_id': householdId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'synced': data['synced'] as int,
          'failed': data['failed'] as int,
        };
      }
      return {'synced': 0, 'failed': 0};
    } catch (e) {
      print('Error syncing offline reviews: $e');
      return {'synced': 0, 'failed': 0};
    }
  }

  Future<LearningMetrics?> getLearningMetrics({
    required String householdId,
    String? podId,
    int days = 30,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/metrics/learning/').replace(
        queryParameters: {
          'household_id': householdId,
          if (podId != null) 'pod_id': podId,
          'days': days.toString(),
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${getToken()}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return LearningMetrics.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error fetching learning metrics: $e');
      return null;
    }
  }
}
```

## File: `lib/modules/family/services/offline_queue_manager.dart`

```dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/learning_models.dart';
import 'learning_api_service.dart';

class OfflineQueueManager {
  static const String _queueKey = 'offline_review_queue';
  final LearningApiService apiService;

  OfflineQueueManager(this.apiService);

  Future<void> addToQueue(OfflineReviewQueueItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final queueJson = prefs.getString(_queueKey);

    List<Map<String, dynamic>> queue = [];
    if (queueJson != null) {
      queue = List<Map<String, dynamic>>.from(jsonDecode(queueJson));
    }

    queue.add(item.toJson());
    await prefs.setString(_queueKey, jsonEncode(queue));
  }

  Future<List<OfflineReviewQueueItem>> getQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final queueJson = prefs.getString(_queueKey);

    if (queueJson == null) return [];

    final List<dynamic> queueList = jsonDecode(queueJson);
    return queueList
        .map((json) => OfflineReviewQueueItem.fromJson(json))
        .toList();
  }

  Future<void> removeFromQueue(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final queueJson = prefs.getString(_queueKey);

    if (queueJson == null) return;

    List<Map<String, dynamic>> queue =
        List<Map<String, dynamic>>.from(jsonDecode(queueJson));

    queue.removeWhere((item) => item['id'] == id);
    await prefs.setString(_queueKey, jsonEncode(queue));
  }

  Future<void> syncQueue(String householdId) async {
    final result = await apiService.syncOfflineReviews(
      householdId: householdId,
    );

    print('Synced ${result['synced']} reviews, ${result['failed']} failed');

    final queue = await getQueue();
    for (final item in queue) {
      if (item.synced) {
        await removeFromQueue(item.id);
      }
    }
  }

  Future<int> getPendingCount() async {
    final queue = await getQueue();
    return queue.where((item) => !item.synced).length;
  }
}
```

## File: `lib/modules/home/widgets/suggestion_card_v2.dart`

```dart
import 'package:flutter/material.dart';
import '../../family/models/learning_models.dart';
import '../../core/theme/merryway_theme.dart';

class SuggestionCardV2 extends StatelessWidget {
  final CandidateActivity suggestion;
  final String rationale;
  final VoidCallback onTap;

  const SuggestionCardV2({
    Key? key,
    required this.suggestion,
    required this.rationale,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getRankColor(),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '#${suggestion.rank}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      suggestion.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                rationale,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _buildFeatureChips(),
              ),
              if (suggestion.description != null) ...[
                const SizedBox(height: 12),
                Text(
                  suggestion.description!,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getRankColor() {
    switch (suggestion.rank) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  List<Widget> _buildFeatureChips() {
    final sortedFeatures = suggestion.featureScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedFeatures.take(3).map((entry) {
      return Chip(
        label: Text(
          '${_formatFeatureName(entry.key)}: ${(entry.value * 100).toInt()}%',
          style: const TextStyle(fontSize: 12),
        ),
        backgroundColor: Colors.blue[50],
      );
    }).toList();
  }

  String _formatFeatureName(String name) {
    return name
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
```

## File: `lib/modules/experiences/widgets/experience_review_form_v2.dart`

```dart
import 'package:flutter/material.dart';
import '../../family/models/learning_models.dart';
import '../../core/theme/merryway_theme.dart';

class ExperienceReviewFormV2 extends StatefulWidget {
  final Function(ExperienceReviewEnhanced) onSubmit;
  final String experienceId;
  final String? suggestionLogId;

  const ExperienceReviewFormV2({
    Key? key,
    required this.onSubmit,
    required this.experienceId,
    this.suggestionLogId,
  }) : super(key: key);

  @override
  State<ExperienceReviewFormV2> createState() =>
      _ExperienceReviewFormV2State();
}

class _ExperienceReviewFormV2State extends State<ExperienceReviewFormV2> {
  int _rating = 3;
  String? _notes;
  int? _actualDuration;
  EffortLevel? _effortLevel;
  MessLevel? _messLevel;
  int _contextMatchRating = 3;
  String? _photoUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'How was it?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Overall Rating'),
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () => setState(() => _rating = index + 1),
                );
              }),
            ),
            const SizedBox(height: 16),
            const Text('How well did it match the situation?'),
            Slider(
              value: _contextMatchRating.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: _contextMatchRating.toString(),
              onChanged: (value) =>
                  setState(() => _contextMatchRating = value.toInt()),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Actual Duration (minutes)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) => _actualDuration = int.tryParse(value),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<EffortLevel>(
              decoration: const InputDecoration(
                labelText: 'Effort Level',
                border: OutlineInputBorder(),
              ),
              value: _effortLevel,
              items: EffortLevel.values.map((level) {
                return DropdownMenuItem(
                  value: level,
                  child: Text(level.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) => setState(() => _effortLevel = value),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<MessLevel>(
              decoration: const InputDecoration(
                labelText: 'Mess Level',
                border: OutlineInputBorder(),
              ),
              value: _messLevel,
              items: MessLevel.values.map((level) {
                return DropdownMenuItem(
                  value: level,
                  child: Text(level.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) => setState(() => _messLevel = value),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) => _notes = value,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: MerryWayTheme.primarySoftBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Submit Review',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _submit() {
    final review = ExperienceReviewEnhanced(
      experienceId: widget.experienceId,
      rating: _rating,
      notes: _notes,
      actualDurationMinutes: _actualDuration,
      actualEffortLevel: _effortLevel,
      actualMessLevel: _messLevel,
      contextMatchRating: _contextMatchRating,
      photoUrl: _photoUrl,
    );

    widget.onSubmit(review);
  }
}
```

## File: `lib/modules/settings/widgets/learning_metrics_dashboard.dart`

```dart
import 'package:flutter/material.dart';
import '../../family/models/learning_models.dart';
import '../../core/theme/merryway_theme.dart';

class LearningMetricsDashboard extends StatelessWidget {
  final LearningMetrics metrics;

  const LearningMetricsDashboard({
    Key? key,
    required this.metrics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Learning Performance',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildMetricCard(
                'Acceptance Rate',
                '${(metrics.acceptanceRate * 100).toInt()}%',
                metrics.acceptanceRateDelta > 0
                    ? '+${(metrics.acceptanceRateDelta * 100).toInt()}%'
                    : '${(metrics.acceptanceRateDelta * 100).toInt()}%',
                metrics.acceptanceRateDelta >= 0 ? Colors.green : Colors.red,
              ),
              _buildMetricCard(
                'Completion Rate',
                '${(metrics.completionRate * 100).toInt()}%',
                null,
                Colors.blue,
              ),
              _buildMetricCard(
                'Avg Rating',
                metrics.avgRating.toStringAsFixed(1),
                '⭐',
                Colors.amber,
              ),
              _buildMetricCard(
                'Wishbook %',
                '${(metrics.wishbookSourcedPercent * 100).toInt()}%',
                null,
                Colors.purple,
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (metrics.timeToFirstGoodSuggestionSeconds != null)
            _buildTimeToValueCard(metrics.timeToFirstGoodSuggestionSeconds!),
          const SizedBox(height: 24),
          const Text(
            'Top Performing Activities',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...metrics.topActivities.map(_buildActivityRow),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    String? subtitle,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: color),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimeToValueCard(int seconds) {
    final minutes = (seconds / 60).round();
    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.timer, color: Colors.green, size: 32),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Time to First Good Suggestion',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  '$minutes minutes',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityRow(ActivityStats stats) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text('Activity ${stats.activityId}'),
        subtitle: Text(
          'Success: ${(stats.successRate! * 100).toInt()}% • '
          'Rating: ${stats.avgRating?.toStringAsFixed(1) ?? 'N/A'}',
        ),
        trailing: Text(
          '${stats.timesChosen}/${stats.timesShown}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
```

## File: `lib/modules/home/pages/pod_suggestions_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../family/services/learning_api_service.dart';
import '../../family/services/offline_queue_manager.dart';
import '../../family/models/learning_models.dart';
import '../widgets/suggestion_card_v2.dart';
import '../../experiences/widgets/experience_review_form_v2.dart';
import '../../core/theme/merryway_theme.dart';
import '../../../config/environment.dart';

class PodSuggestionsScreen extends StatefulWidget {
  final String householdId;
  final String podId;

  const PodSuggestionsScreen({
    Key? key,
    required this.householdId,
    required this.podId,
  }) : super(key: key);

  @override
  State<PodSuggestionsScreen> createState() => _PodSuggestionsScreenState();
}

class _PodSuggestionsScreenState extends State<PodSuggestionsScreen> {
  late LearningApiService _apiService;
  late OfflineQueueManager _queueManager;

  SuggestionResponseV2? _suggestions;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _apiService = LearningApiService(
      baseUrl: Environment.apiUrl,
      getToken: () {
        final token = Supabase.instance.client.auth.currentSession?.accessToken;
        return token ?? '';
      },
    );
    _queueManager = OfflineQueueManager(_apiService);
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    setState(() => _loading = true);

    final context = ContextSnapshot(
      timeBucket: _getTimeBucket(),
      weather: 'sunny',
      dayType: _getDayType(),
      ageMix: 'child_adult',
      participantIds: ['member1', 'member2'],
    );

    final result = await _apiService.generateSuggestionsV2(
      householdId: widget.householdId,
      podId: widget.podId,
      context: context,
    );

    setState(() {
      _suggestions = result;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suggestions'),
        backgroundColor: MerryWayTheme.primarySoftBlue,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_suggestions == null || _suggestions!.suggestions.isEmpty) {
      return const Center(child: Text('No suggestions available'));
    }

    return ListView.builder(
      itemCount: _suggestions!.suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = _suggestions!.suggestions[index];
        return SuggestionCardV2(
          suggestion: suggestion,
          rationale: _suggestions!.rationale,
          onTap: () => _selectSuggestion(suggestion),
        );
      },
    );
  }

  void _selectSuggestion(CandidateActivity suggestion) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ExperienceReviewFormV2(
          experienceId: 'temp_experience_id',
          suggestionLogId: _suggestions!.suggestionLogId,
          onSubmit: (review) => _submitReview(review, suggestion),
        ),
      ),
    );
  }

  Future<void> _submitReview(
    ExperienceReviewEnhanced review,
    CandidateActivity suggestion,
  ) async {
    final hasConnectivity = true;

    if (hasConnectivity) {
      await _apiService.submitReviewV2(
        experienceId: review.experienceId,
        suggestionLogId: _suggestions!.suggestionLogId,
        review: review,
        householdId: widget.householdId,
        podId: widget.podId,
      );
    } else {
      await _queueManager.addToQueue(
        OfflineReviewQueueItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          experienceId: review.experienceId,
          reviewData: review.toJson(),
          idempotencyKey: DateTime.now().toIso8601String(),
          synced: false,
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review queued for sync')),
        );
      }
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  String _getTimeBucket() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }

  String _getDayType() {
    final weekday = DateTime.now().weekday;
    return weekday >= 6 ? 'weekend' : 'weekday';
  }
}
```

