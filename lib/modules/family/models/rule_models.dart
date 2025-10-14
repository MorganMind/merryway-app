import 'package:equatable/equatable.dart';

class MemberRule extends Equatable {
  final String? id;
  final String memberId;
  final String ruleText;
  final String? category; // 'time', 'health', 'safety', 'preference'
  final bool isActive;
  final DateTime? createdAt;

  const MemberRule({
    this.id,
    required this.memberId,
    required this.ruleText,
    this.category,
    this.isActive = true,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, memberId, ruleText, category, isActive];

  factory MemberRule.fromJson(Map<String, dynamic> json) {
    return MemberRule(
      id: json['id'],
      memberId: json['member_id'],
      ruleText: json['rule_text'],
      category: json['category'],
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'member_id': memberId,
        'rule_text': ruleText,
        if (category != null) 'category': category,
        'is_active': isActive,
      };
}

class PodRule extends Equatable {
  final String? id;
  final String podId;
  final String ruleText;
  final String? category; // 'time', 'health', 'safety', 'preference'
  final bool isActive;
  final DateTime? createdAt;

  const PodRule({
    this.id,
    required this.podId,
    required this.ruleText,
    this.category,
    this.isActive = true,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, podId, ruleText, category, isActive];

  factory PodRule.fromJson(Map<String, dynamic> json) {
    return PodRule(
      id: json['id'],
      podId: json['pod_id'],
      ruleText: json['rule_text'],
      category: json['category'],
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'pod_id': podId,
        'rule_text': ruleText,
        if (category != null) 'category': category,
        'is_active': isActive,
      };
}

