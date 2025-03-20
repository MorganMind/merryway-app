import 'package:app/modules/tags/models/taggable_type.dart';

class Tagging {
  final String id;
  final String tagId;
  final TaggableType taggableType;
  final String taggableId;

  Tagging({
    required this.id,
    required this.tagId,
    required this.taggableType,
    required this.taggableId,
  });

  factory Tagging.fromJson(Map<String, dynamic> json) {
    return Tagging(
      id: json['id'],
      tagId: json['tag_id'],
      taggableType: TaggableType.fromString(json['taggable_type']),
      taggableId: json['taggable_id'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'tag_id': tagId,
    'taggable_type': taggableType.toString().split('.').last,
    'taggable_id': taggableId,
  };
} 