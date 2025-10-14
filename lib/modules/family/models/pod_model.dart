import 'package:equatable/equatable.dart';

class Pod extends Equatable {
  final String? id;
  final String householdId;
  final String name;
  final String? description;
  final List<String> memberIds;
  final String color;
  final String icon;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Pod({
    this.id,
    required this.householdId,
    required this.name,
    this.description,
    required this.memberIds,
    this.color = '#B4D7E8',
    this.icon = '👥',
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        householdId,
        name,
        description,
        memberIds,
        color,
        icon,
        createdAt,
        updatedAt,
      ];

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'household_id': householdId,
        'name': name,
        if (description != null) 'description': description,
        'member_ids': memberIds,
        'color': color,
        'icon': icon,
      };

  factory Pod.fromJson(Map<String, dynamic> json) {
    return Pod(
      id: json['id'],
      householdId: json['household_id'],
      name: json['name'],
      description: json['description'],
      memberIds: (json['member_ids'] as List<dynamic>?)
              ?.map((id) => id.toString())
              .toList() ??
          [],
      color: json['color'] ?? '#B4D7E8',
      icon: json['icon'] ?? '👥',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Pod copyWith({
    String? id,
    String? householdId,
    String? name,
    String? description,
    List<String>? memberIds,
    String? color,
    String? icon,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Pod(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      name: name ?? this.name,
      description: description ?? this.description,
      memberIds: memberIds ?? this.memberIds,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

