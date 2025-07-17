import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitialize extends AuthEvent {}

class AuthSignIn extends AuthEvent {
  final String email;
  final String password;

  AuthSignIn(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class AuthSignOut extends AuthEvent {}

class AuthSignUp extends AuthEvent {
  final String email;
  final String password;

  AuthSignUp(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class AuthSignUpWithGoogle extends AuthEvent {
  final String? redirectUrl;

  AuthSignUpWithGoogle({this.redirectUrl = ''});

  @override
  List<Object?> get props => [redirectUrl];
}

class AuthStateChanged extends AuthEvent {
  final AuthState authState;

  AuthStateChanged(this.authState);

  @override
  List<Object?> get props => [authState];
}

class CheckInitialSession extends AuthEvent {
  final String userId;
  CheckInitialSession(this.userId);
}