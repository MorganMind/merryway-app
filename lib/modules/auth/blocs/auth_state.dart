import 'package:equatable/equatable.dart';
import 'package:app/modules/user/models/user_data.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final String userId;
  final UserData userData;

  Authenticated(this.userId, this.userData);

  @override
  List<Object?> get props => [userId, userData];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}