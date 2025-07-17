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
  final bool isDataFresh;

  Authenticated(this.userId, this.userData, {this.isDataFresh = true});
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}