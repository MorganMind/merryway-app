import 'package:equatable/equatable.dart';

enum MemberRole { parent, child, caregiver, teen }

class Household extends Equatable {
  final String? id;
  final String name;
  final List<FamilyMember> members;
  final bool familyModeEnabled;
  final DateTime? createdAt;

  const Household({
    this.id,
    required this.name,
    this.members = const [],
    this.familyModeEnabled = false,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, members, familyModeEnabled, createdAt];

  Map<String, dynamic> toJson() => {
        'name': name,
        'family_mode_enabled': familyModeEnabled,
      };

  factory Household.fromJson(Map<String, dynamic> json) {
    return Household(
      id: json['id'],
      name: json['name'],
      members: (json['members'] as List<dynamic>?)
              ?.map((m) => FamilyMember.fromJson(m))
              .toList() ??
          [],
      familyModeEnabled: json['family_mode_enabled'] ?? false,
      createdAt:
          json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }
}

class FamilyMember extends Equatable {
  final String? id;
  final String name;
  final int age;
  final MemberRole role;
  final List<String> favoriteActivities;
  final DateTime? birthday;
  final String? userId;  // Link to Supabase auth user (nullable)
  final String? avatarEmoji;
  final bool pinRequired;
  final String? devicePin;
  final String? photoUrl;  // Profile photo URL
  final DateTime? createdAt;

  const FamilyMember({
    this.id,
    required this.name,
    required this.age,
    required this.role,
    this.favoriteActivities = const [],
    this.birthday,
    this.userId,
    this.avatarEmoji,
    this.pinRequired = false,
    this.devicePin,
    this.photoUrl,
    this.createdAt,
  });

  bool isParent() => role == MemberRole.parent || role == MemberRole.caregiver;
  bool isChild() => role == MemberRole.child || role == MemberRole.teen;

  @override
  List<Object?> get props => [id, name, age, role, favoriteActivities, birthday, userId, avatarEmoji, pinRequired, photoUrl, createdAt];

  Map<String, dynamic> toJson() => {
        'name': name,
        'age': age,
        'role': role.name,
        'favorite_activities': favoriteActivities,
        if (birthday != null) 'birthday': birthday!.toIso8601String().split('T')[0],
        if (userId != null) 'user_id': userId,
        if (avatarEmoji != null) 'avatar_emoji': avatarEmoji,
        'pin_required': pinRequired,
        if (devicePin != null) 'device_pin': devicePin,
        if (photoUrl != null) 'photo_url': photoUrl,
      };

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      id: json['id'],
      name: json['name'],
      age: json['age'],
      role: MemberRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => MemberRole.child,
      ),
      favoriteActivities: List<String>.from(json['favorite_activities'] ?? []),
      birthday: json['birthday'] != null ? DateTime.parse(json['birthday']) : null,
      userId: json['user_id'],
      avatarEmoji: json['avatar_emoji'],
      pinRequired: json['pin_required'] ?? false,
      devicePin: json['device_pin'],
      photoUrl: json['photo_url'],
      createdAt:
          json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }
}

class ActivitySuggestion extends Equatable {
  final String? id; // Activity ID from backend
  final String activity;
  final String rationale;
  final int? durationMinutes;
  final List<String> tags;
  final String? location;
  final double? distanceMiles;
  final List<String> attire;
  final Map<String, dynamic>? foodAvailable;
  final String? description;
  final String? venueType;
  final double? averageRating;
  final int? reviewCount;

  const ActivitySuggestion({
    this.id,
    required this.activity,
    required this.rationale,
    this.durationMinutes,
    this.tags = const [],
    this.location,
    this.distanceMiles,
    this.attire = const [],
    this.foodAvailable,
    this.description,
    this.venueType,
    this.averageRating,
    this.reviewCount,
  });

  @override
  List<Object?> get props => [
        id,
        activity,
        rationale,
        durationMinutes,
        tags,
        location,
        distanceMiles,
        attire,
        foodAvailable,
        description,
        venueType,
        averageRating,
        reviewCount,
      ];

  factory ActivitySuggestion.fromJson(Map<String, dynamic> json) {
    return ActivitySuggestion(
      // Parse ID if available, otherwise use activity hash as fallback
      id: json['id']?.toString() ?? json['activity_id']?.toString(),
      // Handle both 'activity' and 'activity_name' (for AI suggestions)
      activity: json['activity'] ?? json['activity_name'] ?? '',
      rationale: json['rationale'] ?? '',
      // Handle both 'duration_minutes' and 'duration' (for AI suggestions)
      durationMinutes: json['duration_minutes'] ?? json['duration'],
      tags: json['tags'] != null 
          ? List<String>.from(json['tags'])
          : (json['category'] != null ? [json['category']] : []),
      location: json['location'],
      distanceMiles: json['distance_miles']?.toDouble(),
      attire: List<String>.from(json['attire'] ?? []),
      foodAvailable: json['food_available'] != null
          ? Map<String, dynamic>.from(json['food_available'])
          : null,
      description: json['description'],
      venueType: json['venue_type'] ?? json['indoor_outdoor'],
      averageRating: json['average_rating']?.toDouble(),
      reviewCount: json['review_count'],
    );
  }
}

class SuggestionsResponse extends Equatable {
  final List<ActivitySuggestion> suggestions;
  final Map<String, dynamic> context;

  const SuggestionsResponse({
    required this.suggestions,
    required this.context,
  });

  @override
  List<Object?> get props => [suggestions, context];

  factory SuggestionsResponse.fromJson(Map<String, dynamic> json) {
    return SuggestionsResponse(
      suggestions: (json['suggestions'] as List<dynamic>)
          .map((s) => ActivitySuggestion.fromJson(s))
          .toList(),
      context: json['context'] ?? {},
    );
  }
}

