import 'package:equatable/equatable.dart';

/// Status of an experience
enum ExperienceStatus {
  planned,
  live,
  done,
  cancelled;

  String toDbString() {
    return name;
  }

  static ExperienceStatus fromDbString(String value) {
    return ExperienceStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ExperienceStatus.planned,
    );
  }
}

/// An experience is a planned/live/done activity
class Experience extends Equatable {
  final String? id;
  final String householdId;
  final String? activityName;
  final String? suggestionId;
  final List<String> participantIds;
  final DateTime? startAt;
  final DateTime? endAt;
  final String? place;
  final String? placeAddress;
  final double? placeLat;
  final double? placeLng;
  final ExperienceStatus status;
  final String? prepNotes;
  final bool needsAdult;
  final double? costEstimate;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Experience({
    this.id,
    required this.householdId,
    this.activityName,
    this.suggestionId,
    required this.participantIds,
    this.startAt,
    this.endAt,
    this.place,
    this.placeAddress,
    this.placeLat,
    this.placeLng,
    this.status = ExperienceStatus.planned,
    this.prepNotes,
    this.needsAdult = false,
    this.costEstimate,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        householdId,
        activityName,
        suggestionId,
        participantIds,
        startAt,
        endAt,
        place,
        status,
        prepNotes,
        needsAdult,
        costEstimate,
      ];

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'household_id': householdId,
        'activity_name': activityName,
        'suggestion_id': suggestionId,
        'participant_ids': participantIds,
        'start_at': startAt?.toIso8601String(),
        'end_at': endAt?.toIso8601String(),
        'place': place,
        'place_address': placeAddress,
        'place_lat': placeLat,
        'place_lng': placeLng,
        'status': status.toDbString(),
        'prep_notes': prepNotes,
        'needs_adult': needsAdult,
        'cost_estimate': costEstimate,
        'created_by': createdBy,
      };

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      id: json['id'],
      householdId: json['household_id'],
      activityName: json['activity_name'],
      suggestionId: json['suggestion_id'],
      participantIds: List<String>.from(json['participant_ids'] ?? []),
      startAt: json['start_at'] != null ? DateTime.parse(json['start_at']) : null,
      endAt: json['end_at'] != null ? DateTime.parse(json['end_at']) : null,
      place: json['place'],
      placeAddress: json['place_address'],
      placeLat: json['place_lat']?.toDouble(),
      placeLng: json['place_lng']?.toDouble(),
      status: ExperienceStatus.fromDbString(json['status'] ?? 'planned'),
      prepNotes: json['prep_notes'],
      needsAdult: json['needs_adult'] ?? false,
      costEstimate: json['cost_estimate']?.toDouble(),
      createdBy: json['created_by'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Experience copyWith({
    String? id,
    String? householdId,
    String? activityName,
    String? suggestionId,
    List<String>? participantIds,
    DateTime? startAt,
    DateTime? endAt,
    String? place,
    String? placeAddress,
    double? placeLat,
    double? placeLng,
    ExperienceStatus? status,
    String? prepNotes,
    bool? needsAdult,
    double? costEstimate,
    String? createdBy,
  }) {
    return Experience(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      activityName: activityName ?? this.activityName,
      suggestionId: suggestionId ?? this.suggestionId,
      participantIds: participantIds ?? this.participantIds,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      place: place ?? this.place,
      placeAddress: placeAddress ?? this.placeAddress,
      placeLat: placeLat ?? this.placeLat,
      placeLng: placeLng ?? this.placeLng,
      status: status ?? this.status,
      prepNotes: prepNotes ?? this.prepNotes,
      needsAdult: needsAdult ?? this.needsAdult,
      costEstimate: costEstimate ?? this.costEstimate,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}

/// Review/debrief after an experience
class ExperienceReview extends Equatable {
  final String? id;
  final String experienceId;
  final String householdId;
  final int rating; // 1-5
  final String? effortFelt; // 'easy', 'moderate', 'hard'
  final String? cleanupFelt; // 'easy', 'moderate', 'hard'
  final String? note;
  final String? reviewedBy;
  final DateTime? createdAt;

  const ExperienceReview({
    this.id,
    required this.experienceId,
    required this.householdId,
    required this.rating,
    this.effortFelt,
    this.cleanupFelt,
    this.note,
    this.reviewedBy,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        experienceId,
        rating,
        effortFelt,
        cleanupFelt,
        note,
      ];

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'experience_id': experienceId,
        'household_id': householdId,
        'rating': rating,
        'effort_felt': effortFelt,
        'cleanup_felt': cleanupFelt,
        'note': note,
        'reviewed_by': reviewedBy,
      };

  factory ExperienceReview.fromJson(Map<String, dynamic> json) {
    return ExperienceReview(
      id: json['id'],
      experienceId: json['experience_id'],
      householdId: json['household_id'],
      rating: json['rating'],
      effortFelt: json['effort_felt'],
      cleanupFelt: json['cleanup_felt'],
      note: json['note'],
      reviewedBy: json['reviewed_by'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }
}

/// A Merry Moment is a memory/journal entry (manual or from completed experience)
class MerryMoment extends Equatable {
  final String? id;
  final String householdId;
  final String? experienceId;
  final String title;
  final String? description;
  final List<String> participantIds;
  final DateTime occurredAt;
  final String? place;
  final List<String> mediaIds;
  final String? createdBy;
  final bool isManual; // true if manually created (journaling)
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MerryMoment({
    this.id,
    required this.householdId,
    this.experienceId,
    required this.title,
    this.description,
    required this.participantIds,
    required this.occurredAt,
    this.place,
    this.mediaIds = const [],
    this.createdBy,
    this.isManual = false,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        householdId,
        experienceId,
        title,
        description,
        participantIds,
        occurredAt,
        place,
        mediaIds,
        isManual,
      ];

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'household_id': householdId,
        'experience_id': experienceId,
        'title': title,
        'description': description,
        'participant_ids': participantIds,
        'occurred_at': occurredAt.toIso8601String(),
        'place': place,
        'media_ids': mediaIds,
        'created_by': createdBy,
        'is_manual': isManual,
      };

  factory MerryMoment.fromJson(Map<String, dynamic> json) {
    return MerryMoment(
      id: json['id'],
      householdId: json['household_id'],
      experienceId: json['experience_id'],
      title: json['title'],
      description: json['description'],
      participantIds: List<String>.from(json['participant_ids'] ?? []),
      occurredAt: DateTime.parse(json['occurred_at']),
      place: json['place'],
      mediaIds: List<String>.from(json['media_ids'] ?? []),
      createdBy: json['created_by'],
      isManual: json['is_manual'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }
}

/// Media item (photo/video) attached to a Merry Moment
class MediaItem extends Equatable {
  final String? id;
  final String householdId;
  final String? merryMomentId;
  final String? experienceId;
  final String fileUrl;
  final String? thumbnailUrl;
  final String mimeType;
  final int? fileSizeBytes;
  final int? widthPx;
  final int? heightPx;
  final int? durationSeconds;
  final String? caption;
  final String? uploadedBy;
  final DateTime? createdAt;

  const MediaItem({
    this.id,
    required this.householdId,
    this.merryMomentId,
    this.experienceId,
    required this.fileUrl,
    this.thumbnailUrl,
    required this.mimeType,
    this.fileSizeBytes,
    this.widthPx,
    this.heightPx,
    this.durationSeconds,
    this.caption,
    this.uploadedBy,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        householdId,
        merryMomentId,
        experienceId,
        fileUrl,
        thumbnailUrl,
        mimeType,
      ];

  bool get isVideo => mimeType.startsWith('video/');
  bool get isImage => mimeType.startsWith('image/');

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'household_id': householdId,
        'merry_moment_id': merryMomentId,
        'experience_id': experienceId,
        'file_url': fileUrl,
        'thumbnail_url': thumbnailUrl,
        'mime_type': mimeType,
        'file_size_bytes': fileSizeBytes,
        'width_px': widthPx,
        'height_px': heightPx,
        'duration_seconds': durationSeconds,
        'caption': caption,
        'uploaded_by': uploadedBy,
      };

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      id: json['id'],
      householdId: json['household_id'],
      merryMomentId: json['merry_moment_id'],
      experienceId: json['experience_id'],
      fileUrl: json['file_url'],
      thumbnailUrl: json['thumbnail_url'],
      mimeType: json['mime_type'],
      fileSizeBytes: json['file_size_bytes'],
      widthPx: json['width_px'],
      heightPx: json['height_px'],
      durationSeconds: json['duration_seconds'],
      caption: json['caption'],
      uploadedBy: json['uploaded_by'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }
}

