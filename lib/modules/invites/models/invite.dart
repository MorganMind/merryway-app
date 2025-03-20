import 'package:equatable/equatable.dart';

class Invite extends Equatable {
  final String id;
  final String? name;
  final String email;
  final bool pending;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final bool accepted;
  final bool declined;
  final String userId;
  final String? acceptedUserId; 

  static final empty = Invite(
    id: '',
    name: '',
    email: '',
    userId: '',
    createdAt: DateTime.now(),
  );

  const Invite({
    required this.id,
    this.name,
    required this.email,
    this.pending = true,
    required this.createdAt,
    this.acceptedAt,
    this.accepted = false,
    this.declined = false,
    required this.userId,
    this.acceptedUserId,
  });

  factory Invite.fromJson(Map<String, dynamic> json) {
    return Invite(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      pending: json['pending'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      acceptedAt: json['accepted_at'] != null 
          ? DateTime.parse(json['accepted_at'])
          : null,
      accepted: json['accepted'] ?? false,
      declined: json['declined'] ?? false,
      userId: json['user_id'],
      acceptedUserId: json['accepted_user_id'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'pending': pending,
    'created_at': createdAt.toIso8601String(),
    'accepted_at': acceptedAt?.toIso8601String(),
    'accepted': accepted,
    'declined': declined,
    'user_id': userId,
    'accepted_user_id': acceptedUserId,
  };

  @override
  List<Object?> get props => [
    id, 
    name, 
    email, 
    pending, 
    createdAt, 
    acceptedAt, 
    accepted, 
    declined, 
    userId, 
    acceptedUserId, 
  ];
} 