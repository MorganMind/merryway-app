import 'package:equatable/equatable.dart';

class UserData extends Equatable {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? fullName;
  final DateTime? createdAt;
  final bool onboardingCompleted;
  final String? analyticsId;
  final String? avatarUrl;

  const UserData({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.fullName,
    this.createdAt,
    required this.onboardingCompleted,
    this.analyticsId,
    this.avatarUrl,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      fullName: json['full_name'],
      createdAt: DateTime.parse(json['created_at']),
      onboardingCompleted: json['onboarding_completed'] ?? false,
      analyticsId: json['analytics_id'],
      avatarUrl: json['avatar_url'],
    );
  }

  static const empty = UserData(id: '', email: '', onboardingCompleted: false);

  @override
  List<Object?> get props => [
    id, 
    email, 
    firstName, 
    lastName, 
    fullName, 
    createdAt, 
    onboardingCompleted, 
    analyticsId, 
    avatarUrl, 
  ];
}