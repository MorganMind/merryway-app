import 'package:equatable/equatable.dart';
import 'package:app/modules/tags/models/tag.dart';

abstract class TagsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TagsInitial extends TagsState {}

class TagsLoading extends TagsState {}

class TagsError extends TagsState {
  final String message;

  TagsError(this.message);

  @override
  List<Object?> get props => [message];
}

// State for when user's tags are loaded
class UserTagsLoaded extends TagsState {
  final List<Tag> tags;

  UserTagsLoaded(this.tags);

  @override
  List<Object?> get props => [tags];
}

// State for when tags for a specific item are loaded
class ItemTagsLoaded extends TagsState {
  final List<Tag> tags;
  final String taggableId;

  ItemTagsLoaded(this.tags, this.taggableId);

  @override
  List<Object?> get props => [tags, taggableId];
}

// State for when items for specific tags are loaded
class TaggedItemsLoaded extends TagsState {
  final List<String> itemIds;
  final List<String> tagIds;

  TaggedItemsLoaded(this.itemIds, this.tagIds);

  @override
  List<Object?> get props => [itemIds, tagIds];
} 